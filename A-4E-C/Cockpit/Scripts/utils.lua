dofile(LockOn_Options.script_path.."../../Sounds/Sounders/Curve.lua")

-- Utility functions/classes

function randomf(lower,upper)
  return lower + math.random() * (upper - lower)
end

function startup_print(...)
    print(...)
end

function directionVector(pitch,yaw)
  local cosPitch = math.cos(pitch)
  local sinPitch = math.sin(pitch)
  local cosYaw = math.cos(yaw)
  local sinYaw = math.sin(yaw)

  local x = cosYaw * cosPitch
  local z = sinYaw * cosPitch
  local y = sinPitch

  return x,y,z
end

-- rounds the number 'num' to the number of decimal places in 'idp'
--
-- print(round(107.75, -1))     : 110.0
-- print(round(107.75, 0))      : 108.0
-- print(round(107.75, 1))      : 107.8
function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function roundBase(num,idp,base)
  num = num / base
  return round(num, idp) * base
end

function clamp(value, minimum, maximum)
	return math.max(math.min(value,maximum),minimum)
end

-- calculates the x,y,z in russian coordinates of the point that is 'radius' distance away
-- from px,py,pz using the x,z angle of 'hdg' and the vertical slant angle
-- of 'slantangle'
function pointFromVector( px, py, pz, hdg, slantangle, radius )
    local x = px + (radius * math.cos(hdg) * math.cos(slantangle))
    local z = pz + (radius * math.sin(-hdg) * math.cos(slantangle))  -- pi/2 radians is west
    local y = py + (radius * math.sin(slantangle))

    return x,y,z
end
 
-- return GCD of m,n
function gcd(m, n)
    while m ~= 0 do
        m, n = math.fmod(n, m), m;
    end
    return n;
end


function LinearTodB(value)
    return math.pow(value, 3)
end


-- jumpwheel()
-- 
-- utility function to generate an animation argument for numberwhels that animate from 0.x11 to 0.x19
-- useful for "whole number" output dials, or any case where the decimal component determines when to
-- do the rollover.  All digits will roll at the same time as the ones digit, if they should roll.
--
-- input 'number' is the original raw number (e.g. 397.3275) and which digit position you want to draw
-- input 'position' is which digit position you want to generate an animation argument
--
-- technique: for aBcc.dd, where B is the position we're asking about, we break the number up into
--            component parts:
--            
--            a is throwaway.
--            B will become the first digit of the output.
--            cc tells us whether we're rolling or not.  All digits in cc must be "9".
--            dd is used for 0.Bdd as the return if we're going to be rolling B.
--
function jumpwheel(number, position)
    local rolling = false
    local a,dd = math.modf( number )                -- gives us aBcc in a, and .dd in dd

    a = math.fmod( a, 10^position )                 -- strips a to give us Bcc in a
    local B = math.floor( a / (10^(position-1)) )   -- gives us B by itself
    local cc = math.fmod( a, 10^(position-1) )      -- gives us cc by itself

    if cc == (10^(position-1)-1) then
        rolling = true                              -- if all the digits to the right are 9, then we are rolling based on the decimal component
    end

    if rolling then
        return( (B+dd)/10 )
    else
        return B/10
    end
end

---------------------------------------------
--[[
Function to recursively dump a table to a string, can be used to gain introspection into _G too
Usage:
str=dump("_G",_G)
print(str)  -- or log to DCS log file (log.alert), or print_message_to_user etc.
--]]
function basic_dump (o)
  if type(o) == "number" then
    return tostring(o)
  elseif type(o) == "string" then
    return string.format("%q", o)
  else -- nil, boolean, function, userdata, thread; assume it can be converted to a string
    return tostring(o)
  end
end


function dump (name, value, saved, result)
  seen = seen or {}       -- initial value
  result = result or ""
  result=result..name.." = "
  if type(value) ~= "table" then
    result=result..basic_dump(value).."\n"
  elseif type(value) == "table" then
    if seen[value] then    -- value already saved?
      result=result.."->"..seen[value].."\n"  -- use its previous name
    else
      seen[value] = name   -- save name for next time
      result=result.."{}\n"     -- create a new table
      for k,v in pairs(value) do      -- save its fields
        local fieldname = string.format("%s[%s]", name,
                                        basic_dump(k))
        if fieldname~="_G[\"seen\"]" then
          result=dump(fieldname, v, seen, result)
        end
      end
    end
  end
  return result
end

function strsplit(delimiter, text)
  local list = {}
  local pos = 1
  if string.find("", delimiter, 1) then
    return {}
  end
  while 1 do
    local first, last = string.find(text, delimiter, pos)
    if first then -- found?
      table.insert(list, string.sub(text, pos, first-1))
      pos = last+1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end
  return list
end

---------------------------------------------
---------------------------------------------
--[[
PID Controller class (Proportional-Integral-Derivative Controller)
(backward Euler discrete form)
--]]

PID = {} -- the table representing the class, which will double as the metatable for the instances
PID.__index = PID -- failed table lookups on the instances should fallback to the class table, to get methods
setmetatable(PID, {
  __call = function( cls, ... )
    return cls.new(...) -- automatically call constructor when class is called like a function, e.g. a=PID() is equivalent to a=PID.new()
  end,
})

function PID.new( Kp, Ki, Kd, umin, umax, uscale )
    local self = setmetatable({}, PID)

    self.Kp = Kp or 1   -- default to a weight=1 "P" controller
    self.Ki = Ki or 0
    self.Kd = Kd or 0

    self.k1 = self.Kp + self.Ki + self.Kd
    self.k2 = -self.Kp - 2*self.Kd
    self.k3 = self.Kd

    self.e2 = 0     -- error term history for I/D functions
    self.e1 = 0
    self.e = 0

    self.du = 0     -- delta U()
    self.u = 0      -- U() term for output

    self.umax = umax or 999999  -- allow bounding of e for PID output limits
    self.umin = umin or -999999
    self.uscale = uscale or 1   -- allow embedded output scaling and range limiting

    return self
end

-- used to tune Kp on the fly
function PID:set_Kp( val )
    self.Kp = val
    self.k1 = self.Kp + self.Ki + self.Kd
    self.k2 = -self.Kp - 2*self.Kd
end

-- used to tune Kp on the fly
function PID:get_Kp()
    return self.Kp
end

-- used to tune Ki on the fly
function PID:set_Ki( val )
    self.Ki = val
    self.k1 = self.Kp + self.Ki + self.Kd
end

-- used to tune Ki on the fly
function PID:get_Ki()
    return self.Ki
end

-- used to tune Kd on the fly
function PID:set_Kd( val )
    self.Kd = val
    self.k1 = self.Kp + self.Ki + self.Kd
    self.k2 = -self.Kp - 2*self.Kd
    self.k3 = self.Kd
end

-- used to tune Kd on the fly
function PID:get_Kd()
    return self.Kd
end

function PID:run( setpoint, mv )
    self.e2 = self.e1
    self.e1 = self.e
    self.e = setpoint - mv

    -- backward Euler discrete PID function
    self.du = self.k1*self.e + self.k2*self.e1 + self.k3*self.e2
    self.u = self.u + self.du

    if self.u < self.umin then
        self.u = self.umin
    elseif self.u > self.umax then
        self.u = self.umax
    end

    return self.u*self.uscale
end

-- reset dynamic state
function PID:reset(u)
    self.e2 = 0
    self.e1 = 0
    self.e = 0

    self.du = 0
    if u then
        self.u = u/self.uscale
    else
        self.u = 0
    end
end


PID_alt = {}
PID_alt.__index = PID_alt
setmetatable(PID_alt, {
  __call = function( cls, ... )
    return cls.new(...) -- automatically call constructor when class is called like a function, e.g. a=PID() is equivalent to a=PID.new()
  end,
})

function PID_alt.new(kp, ki, kd, centre, errIMin, errIMax)
  local self = setmetatable({}, PID_alt)
  self.kp = kp
  self.ki = ki
  self.kd = kd

  self.errIMin = errIMin or -100000000.0
  self.errIMax = errIMax or  100000000.0

  self.errorD = 0.0
  self.errorI = 0.0
  self.centre = centre or 0.0

  return self
end

function PID_alt:run(setpoint, process_variable)
  local error = setpoint - process_variable

  self.errorI = clamp(self.errorI + error, self.errIMin, self.errIMax)

  local p = self.kp * error
  local i = self.ki * self.errorI
  local d = self.kd * (error - self.errorD)

  self.errorD = error

  return self.centre + p + i + d
end

function PID_alt:reset(centre)
  self.errorD = 0.0
  self.errorI = 0.0
  self.centre = centre
end

---------------------------------------------
---------------------------------------------
--[[
Weighted moving average class, useful for supplying values to gauges in an exponential decay/growth form (avoid instantaneous step values)
It keeps only a single previous value, the pseudocode is:
  prev_value = (weight*new_value + (1-weight)*prev_value)
Example usage:
myvar=WMA(0.15,0)   -- create the object (once off), first param is weight for newest values, second param is initial value, both params optional
-- use the object repeatedly, the value passed is stored internally in the object and the return value is the weighted moving average
gauge_param:set(myvar:get_WMA(new_val))

0.15 is a good value to use for gauges, it takes about 20 steps to achieve 95% of a new set point value
--]]

WMA = {} -- the table representing the class, which will double as the metatable for the instances
WMA.__index = WMA -- failed table lookups on the instances should fallback to the class table, to get methods
setmetatable(WMA, {
  __call = function (cls, ...)
    return cls.new(...) -- automatically call constructor when class is called like a function, e.g. a=WMA() is equivalent to a=WMA.new()
  end,
})

-- Create a new instance of the object.
-- latest_weight must be between 0.01 and 1,  defaults to 0.5 if not supplied.
-- init_val sets the initial value, if not supplied it will be initialized the first time get_WMA() is called
function WMA.new (latest_weight, init_val)
  local self = setmetatable({}, WMA)

  self.cur_weight=latest_weight or 0.5 -- default to 0.5 if not passed as param
  if self.cur_weight>1.0 then
  	self.cur_weight=1.0
  end
  if self.cur_weight<0.01 then
  	self.cur_weight=0.01
  end
  self.cur_val = init_val  -- can be nil if not passed, will be initialized first time get_WMA() is called
  self.target_val = self.cur_val
  return self
end

-- this updates current value based on weighted moving average with new value v, and returns the weighted moving average
-- the target value v is kept internally and can be retrieved with the get_target_val() function
function WMA:get_WMA (v)
  self.target_val = v
  if not self.cur_val then
  	self.cur_val=v
  	return self.cur_val
  end
  self.cur_val = self.cur_val+(v-self.cur_val)*self.cur_weight
  return self.cur_val
end

-- if necessary to update the current value instantaneously (bypass weighted moving average)
function WMA:set_current_val (v)
    self.cur_val = v
    self.target_val = v
end

-- if necessary to read the current weighted average value (without updating the weighted moving average with a new value)
function WMA:get_current_val ()
    return self.cur_val
end

-- read the target value (latest value passed to the get_WMA() function)
function WMA:get_target_val ()
    return self.target_val
end

--[[
-- test code
target_cur={}
table.insert(target_cur, {600,0})
table.insert(target_cur, {0,600})

for k,v in ipairs(target_cur) do
	target=v[1]
	cur=v[2]

	print("--- "..cur,target)
	myvar=WMA(0.15,cur)
	for j=1,20 do
		print(myvar:get_WMA(target))
	end
end
--]]

---------------------------------------------


---------------------------------------------
--[[
Weighted moving average class that treats [range_min,range_max] as wraparound, useful for supplying values to circular gauges in an exponential decay/growth form (avoid instantaneous step values)
It keeps only a single previous value, the pseudocode is:
  prev_value = ((prev_value+weight*(wrapped(new_value-old_value)))
Example usage:
myvar=WMA_wrap(0.15,0)   -- create the object (once off), first param is weight for newest values, second param is initial value, both params optional
-- use the object repeatedly, the value passed is stored internally in the object and the return value is the weighted moving average wrapped between range_min and range_max
gauge_param:set(myvar:get_WMA_wrap(new_val))

0.15 is a good value to use for gauges, it takes about 20 steps to achieve 95% of a new set point value
--]]

WMA_wrap = {} -- the table representing the class, which will double as the metatable for the instances
WMA_wrap.__index = WMA_wrap -- failed table lookups on the instances should fallback to the class table, to get methods
setmetatable(WMA_wrap, {
  __call = function (cls, ...)
    return cls.new(...) -- automatically call constructor when class is called like a function, e.g. a=WMA_wrap() is equivalent to a=WMA_wrap.new()
  end,
})

-- Create a new instance of the object.
-- latest_weight must be between 0.01 and 1,  defaults to 0.5 if not supplied.
-- init_val sets the initial value, if not supplied it will be initialized the first time get_WMA_wrap() is called
-- range_min defaults to 0, range_max defaults to 1
function WMA_wrap.new (latest_weight, init_val, range_min, range_max)
  local self = setmetatable({}, WMA_wrap)

  self.cur_weight=latest_weight or 0.5 -- default to 0.5 if not passed as param
  if self.cur_weight>1.0 then
  	self.cur_weight=1.0
  end
  if self.cur_weight<0.01 then
  	self.cur_weight=0.01
  end
  self.cur_val = init_val  -- can be nil if not passed, will be initialized first time get_WMA_wrap() is called
  self.target_val = self.cur_val
  self.range_min=math.min(range_min or 0.0, range_max or 1.0)
  self.range_max=math.max(range_min or 0.0, range_max or 1.0)
  self.range_delta=range_max-range_min;
  self.range_thresh=self.range_delta/8192
  return self
end

-- this can almost certainly be simplified, but I was lazy and did it the straightforward way
local function get_shortest_delta(target,cur,min,max)
	local d1,d2,delta
	if target>=cur then
		d1=target-cur
		d2=cur-min+(max-target)
		if d2<d1 then
			delta=-d2
		else
			delta=d1
		end
	else
		d1=cur-target
		d2=target-min+(max-cur)
		if d1<d2 then
			delta=-d1
		else
			delta=d2
		end
	end
	return delta
end

-- this updates current value based on weighted moving average with new value v, and returns the weighted moving average
-- the target value v is kept internally and can be retrieved with the get_target_val() function
-- it wraps within [range_min,range_max] and also moves in the shortest direction (clockwise or anticlockwise) between two points
function WMA_wrap:get_WMA_wrap (v)
  self.target_val = v
  if not self.cur_val then
  	self.cur_val=v
  	return self.cur_val
  end
  delta=get_shortest_delta(v, self.cur_val, self.range_min, self.range_max)
  self.cur_val=self.cur_val+(delta*self.cur_weight)
  if math.abs(delta)<self.range_thresh then
    self.cur_val=self.target_val
  end
  if self.cur_val>self.range_max then
  	self.cur_val=self.cur_val-self.range_delta
  elseif self.cur_val<self.range_min then
  	self.cur_val=self.cur_val+self.range_delta
  end
  return self.cur_val
end

-- if necessary to update the current value instantaneously (bypass weighted moving average)
function WMA_wrap:set_current_val (v)
    self.cur_val = v
    self.target_val = v
end

-- if necessary to read the current weighted average value (without updating the weighted moving average with a new value)
function WMA_wrap:get_current_val ()
    return self.cur_val
end

-- read the target value (latest value passed to the get_WMA_wrap() function)
function WMA_wrap:get_target_val ()
    return self.target_val
end

Random_Walker = {}
Random_Walker.__index = Random_Walker
setmetatable(Random_Walker,
  {
    __call = function(cls, ...) return cls.new(...) end
  }
)

function Random_Walker.new(speed, min, max, start)
  local self = setmetatable({}, Random_Walker)
  self.speed = speed
  self.min = min
  self.max = max
  self.pos = start
  self.vel = 0.0
  return self
end

function Random_Walker:update(timestep)
  local step = randomf(-self.speed, self.speed)
  self.vel = clamp(self.vel + step * timestep, self.min,self.max)
  self.pos = clamp(self.pos + self.vel * timestep, self.min,self.max)
end

--------------------------------------------------------------------

Constant_Speed_Controller = {}
Constant_Speed_Controller.__index = Constant_Speed_Controller
setmetatable(Constant_Speed_Controller,
  {
    __call = function(cls, ...)
        return cls.new(...) --call constructor if someone calls this table
    end
  }
)

function Constant_Speed_Controller.new(speed, min, max, pos)
  local self = setmetatable({}, Constant_Speed_Controller)
  self.speed = speed
  self.min = min
  self.max = max
  self.pos = pos

  return self
end

function Constant_Speed_Controller:update(target)

  local p = self.pos
  local direction = target - self.pos

  if math.abs(direction) <= self.speed then
    self.pos = target
  elseif direction < 0.0 then
    self.pos = self.pos - self.speed
  elseif direction > 0.0 then
    self.pos = self.pos + self.speed
  end

end

function Constant_Speed_Controller:get_position()
  return self.pos
end

function Constant_Speed_Controller:set_position(x)
  self.pos = x
end










--------------------------------------------------------------------

--[[
Description
Recursively descends both meta and regular tables and prints their key : value pairs until
limits are reached or the table is exhausted. Returns the resulting string.

@param[in] table_to_print 		root of the tables to recursively explore
@param[in] max_depth				how many levels are recursion (not function recursion) are allowed.
@param[in] max_number_tables		how many different tables are allowed to be processed in total

@return STRING
]]--
function recursively_traverse(table_to_print, max_depth, max_number_tables)
	
  max_depth = max_depth or 100
  max_number_tables = max_number_tables or 100

	stack = {}
	
	table.insert(stack, {key = "start", value = table_to_print, level = 0})
	
	total = 0
	
	hash_table = {}

	hash_table[tostring(hash_table)] = 2
	hash_table[tostring(stack)] = 2
	
  str = ""

	item = true
	while (item) do
		item = table.remove(stack)
		
		if (item == nil) then
			break
		end
		key = item.key
		value = item.value
		level = item.level
		
		str = str..(string.rep("        ", level)..tostring(key).." = "..tostring(value).."\n")
		
		hash = hash_table[tostring(value)]
		valid_table = (hash == nil or hash < 2)
		
		if (type(value) == "table" and valid_table) then
			for k,v in pairs(value) do
				if (v ~= nil and level <= max_depth and total < max_number_tables) then
					table.insert(stack, {key = k, value = v, level = level+1})
					if (type(v) == "table") then
						if (hash_table[tostring(v)] == nil) then
							hash_table[tostring(v)] = 1
						elseif (hash_table[tostring(v)] < 2) then
							hash_table[tostring(v)] = 2
						end
						total = total + 1
					end
				end
			end
		end
		
		if (getmetatable(value) and valid_table) then
			for k,v in pairs(getmetatable(value)) do
				if (v ~= nil and level <= max_depth and total < max_number_tables) then
					table.insert(stack, {key = k, value = v, level = level+1})
					if (type(v) == "table") then
						if (hash_table[tostring(v)] == nil) then
							hash_table[tostring(v)] = 1
						elseif (hash_table[tostring(v)] < 2) then
							hash_table[tostring(v)] = 2
						end
						total = total + 1
					end
				end
			end
		end
	end

  return str
end

--[[
Description
Recursively descends both meta and regular tables and prints their key : value pairs until
limits are reached or the table is exhausted.

@param[in] table_to_print 		root of the tables to recursively explore
@param[in] max_depth				how many levels are recursion (not function recursion) are allowed.
@param[in] max_number_tables		how many different tables are allowed to be processed in total
@param[in] filepath				path to put this data

@return VOID
]]--
function recursively_print(table_to_print, filepath, max_depth, max_number_tables)
  file = io.open(filepath, "w")
	file:write("Key,Value\n")
  str = recursively_traverse(table_to_print,max_depth,max_number_tables)
  file:write(str)
  file:close()
end

--[[
-- test code
target_cur={}
table.insert(target_cur, {350,10})
table.insert(target_cur, {10,350})
table.insert(target_cur, {280,90})
table.insert(target_cur, {90,280})

for k,v in ipairs(target_cur) do
	target=v[1]
	cur=v[2]

	print("--- "..cur,target)
	myvar=WMA_wrap(0.15,cur,0,360)
	for j=1,20 do
		print(myvar:get_WMA_wrap(target))
	end
end
--]]
---------------------------------------------

--[[
Description
Fetch the pointer to the vfptr table for the lua device of a device. This
is used in the 'hacks' to make the radio (and potentially the ILS) work.

@param[in] avDevice   Device for which to fetch the ptr.
@return STRING        String containing the address to the lua device vfptr table.
]]--
function find_lua_device_ptr(device)
  str_ptr = string.sub(tostring(device.link),10)
  return str_ptr
end

function bearing_to_vec2d(brg)
	brg = math.rad(brg)
	vec = {
		x = math.cos(brg),
		z = math.sin(brg)
	}
	
	return vec
end

function vec2d_to_bearing(vec)
	angle = math.deg(math.atan2(vec.z,vec.x))
	
	if angle < 0 then
		angle = 360 + angle
	end
	
	return angle
end

function normalize_vec2d(vec)
	mag = math.sqrt(vec.x^2 + vec.z^2)
	new_vec = {
		x = vec.x / mag,
		z = vec.z / mag
	}
	return new_vec
end

local function stub(self, ...) 
  return nil
end

local function new(cls, ...)
  tbl = getmetatable(cls)
  tbl.__index = tbl

  return setmetatable({}, tbl)
end

function require_avionics()
  package.cpath = package.cpath..";"..LockOn_Options.script_path.."..\\..\\bin\\?.dll"
  success,result = pcall(require,'ScooterAvionics')

  if success and result ~= false then
    return result
  else
    -- These stub out the functions that are required by ScooterAvionics.dll
    -- This is so that if someone rebuilds the open-source part of the code
    -- they can still use the aircraft without errors.
    local stubs = {
      ExtendedRadio = setmetatable({}, {
        __call = new,
        init = stub,
        setPower = stub,
        pushToTalk = stub,
      }),

      AdvancedWeaponSystem = setmetatable({}, {
        __call = new,
        launch = stub,
        updateSteering = stub,
      }),

      MissionObjects = {
        getObjectBearing = stub,
        getObjectPosition = stub,
        getMissionID = stub,
      },
    }
    return stubs
  end
end

function CreateAlternateChannels()
  channels = {
    254,
    265,
    256,
    254,
    250,
    270,
    257,
    258,
    262,
    259,
    268,
    269,
    260,
    263,
    261,
    267,
    253,
    266,
    251,
    251
  }
  return channels
end


function GetRadioChannels()
  if get_aircraft_mission_data == nil then
    return CreateAlternateChannels()
  end

  local radio = get_aircraft_mission_data("Radio")

  if radio == nil then
    return CreateAlternateChannels()
  end

  local radio_one = radio[1]
  if radio_one == nil then
    return CreateAlternateChannels()
  end

  local channels = radio_one.channels
  if channels then
    return channels
  end

  return CreateAlternateChannels()
end