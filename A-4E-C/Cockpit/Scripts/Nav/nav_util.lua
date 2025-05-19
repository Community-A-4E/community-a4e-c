-- if below macro does not work, 
-- use DCS default ones in 'Scripts/World/Radio/BeaconTypes.lua'

NAV_TYPE_NDB       = 8 --BEACON_TYPE_HOMER
NAV_TYPE_NDB_AF    = 4104 --BEACON_TYPE_AIRPORT_HOMER
NAV_TYPE_NDB_AF_MK = 4136 --BEACON_TYPE_AIRPORT_HOMER_WITH_MARKER
NAV_TYPE_NDB_INNER = 16424 --BEACON_TYPE_ILS_NEAR_HOMER = 16424
NAV_TYPE_NDB_OUTER = 16408 --BEACON_TYPE_ILS_FAR_HOMER = 16408

NAV_TYPE_VOR     = 1 --BEACON_TYPE_VOR
NAV_TYPE_VOR_DME = 3 --BEACON_TYPE_VOR_DME
NAV_TYPE_VOR_TAC = 5 --BEACON_TYPE_VORTAC
NAV_TYPE_TCN     = 4 --BEACON_TYPE_TACAN

NAV_TYPE_ILS_LOC = 16640 --BEACON_TYPE_ILS_LOCALIZER = 16640
NAV_TYPE_ILS_GS  = 16896 --BEACON_TYPE_ILS_GLIDESLOPE = 16896

-- Airdrome_name = {
  -- [1] = "Khersones"
  -- [2] = "Saki"
  -- [3] = "Simpheropol"
  -- [4] = "Razdolnoe"
  -- [5] = "Dzhankoy"
  -- [6] = "Kirovskoe"
  -- [7] = "Kerch"
  -- [8] = "Belbek"
  -- [9] = "Krasnogvardeyskoye"
  -- [10] = "Octyabrskoe"
  -- [11] = "Gvardeyskoe"
  -- [12] = "Anapa"
  -- [13] = "Krasnodar"
  -- [14] = "Novorossiysk"
  -- [15] = "Krymsk"
  -- [16] = "Maykop"
  -- [17] = "Gelendzhik"
  -- [18] = "Sochi"
  -- [19] = "Krasnodar P"
  -- [20] = "Sukhumi"
  -- [21] = "Gudauta"
  -- [22] = "Batumi"
  -- [23] = "Senaki"
  -- [24] = "Kobuleti"
  -- [25] = "Kutaisi"
  -- [26] = "MinVody"
  -- [27] = "Nalchick"
  -- [28] = "Mozdok"
  -- [29] = "Lochini"
  -- [30] = "Tbilisi Military"
  -- [31] = "Vaziani"
  -- [32] = "Beslan"
-- }

--[[ 
  Reference:
    Ka-50/Cockpit/Scripts: /ARK/ARK.lua, /Devices_specs/ARK.lua
--]]

---- ********************** ----
-- !!! if test, comment below; for module, uncomment !!! --
--[[
local fileName = get_terrain_related_data("beacons") or get_terrain_related_data("beaconsFile")
if fileName then 
	local f = loadfile(fileName)
	if f then
    f()
	end
end

terrainAirdromes = get_terrain_related_data("Airdromes") or {};
theatre          = get_terrain_related_data("name")
]]
---- ********************** ----

-- nav_adf = {} -- ndb, vor, vortac, tcn
-- nav_ils = {} -- loc & gs

function LL2LO(pos, geopos)
  local lopos = nil
  
  if pos.x and pos.z then
    return pos
  end
  
  -- if pos[1] and pos[2] and pos[3] then
    -- local postmp = {
                      -- x = pos[1],
                      -- y = pos[2],
                      -- z = pos[3],
                    -- }
    -- return postmp
  -- end
  
  if geopos ~= nil then
    if geopos.latitude ~= nil and geopos.longitude ~= nil then
      lopos = geo_to_lo_coords(geopos.latitude, geopos.longitude)
    end
  elseif pos ~= nil then
    if pos.latitude ~= nil and pos.longitude ~= nil then
      lopos = geo_to_lo_coords(pos.latitude, pos.longitude)
    end
  end
  
  return lopos
end

-- for Caucasus runway ILS
function ils_homer(homer)
	--airdrome runway ils
	local homer_data = nil
  homer_data = {
		name        = homer.name or '',
    beaconId    = homer.beaconId or '',
    ntype       = homer.type,
		callsign    = homer.callsign or nil,
		frequency   = homer.frequency or nil,
    channel     = homer.channel or nil,
    position    = homer.position or nil, -- in-game xyz or xy
    direction   = homer.direction or nil,
    positionGeo = homer.positionGeo or nil, -- lat/long 
  }

  homer_data.position = LL2LO(homer.position, homer.positionGeo)
	
	return homer_data
end

-- for Caucasus runway inner and outer
function rwy_homer(homer)
	--airdrome runway homer
	local homer_data = nil
  homer_data = {
		name        = homer.name or '',
    beaconId    = homer.beaconId or '',
    ntype       = homer.type,
		callsign    = homer.callsign or nil,
		frequency   = homer.frequency or nil,
    channel     = homer.channel or nil,
    position    = homer.position or nil, -- in-game xyz or xy
    direction   = homer.direction or nil,
    positionGeo = homer.positionGeo or nil, -- lat/long 
  }

  homer_data.position = LL2LO(homer.position, homer.positionGeo)
  
	return homer_data
end

-- for Caucasus AF vor & tacan
function af_homer(afname, homer)
    --airdrome runway homer
    local homer_data = nil
    homer_data = {
        name        = homer.name or afname,
        beaconId    = homer.beaconId or '',
        ntype       = homer.type,
        callsign    = homer.callsign or nil,
        frequency   = homer.frequency or getTACANFrequency(homer.channel,'X') or nil,
        channel     = homer.channel or tonumber(string.sub(homer.channelTACAN,1,#homer.channelTACAN-1)) or nil,
        position    = homer.position or nil, -- in-game xyz or xz
        direction   = homer.direction or nil,
        positionGeo = homer.positionGeo or nil, -- lat/long
        display_name = homer.display_name
    }

    homer_data.position = LL2LO(homer.position, homer.positionGeo)
  
    return homer_data
end

-- how it works, i'm not quite sure
-- ADF saved state (match Caucasus but not sure for NTTR)
function airdrome_homer(airdrome, number, name_)
	number = number or 1
	--airdrome (non-runway) homer
	local homer = airdrome.airdrome[number]
	return {
    airdrome_id = homer.id,
		name = airdrome.name or name_,
    frequency = homer.frequency,
    callsign = homer.callsign
  }
end

function Load_ADF_State()
  -- load this lua
	local f1 = copy_to_mission_and_get_buffer(LockOn_Options.script_path.."NAV_EB.lua")
	if f1 ~= nil then
		setfenv(f1,getfenv(airdrome_homer))
	  f1()
	end
end


-- for NTTR ALL (beaconTableFormat 2)
-- * ILS GS and LOC are separated table entries
function NAV_STATION2(homer)
    if not homer then 
       return nil 
    end
  
    local tmppos = {
        x = homer.position[1],
        y = homer.position[2],
        z = homer.position[3],
    }

    if homer.direction < 0 then homer.direction = homer.direction + 360 end
  
    homer_data = {
        name        = homer.name,
        beaconId    = homer.beaconId,
        ntype       = homer.type,
        callsign    = homer.callsign or nil,
        frequency   = homer.frequency or getTACANFrequency(homer.channel,'X') or nil,
        channel     = homer.channel or nil,
        position    = tmppos or nil, -- in-game xyz
        direction   = homer.direction or nil,
        positionGeo = homer.positionGeo or nil, -- lat/long
        display_name = homer.display_name
    }
  
  --homer_data.position = LL2LO(homer.position, homer.positionGeo)
  
    return homer_data
end

-- for Caucasus NDB ONLY (beaconTableFormat 1)
function NAV_STATION1(homer)
	if not homer then 
	   return nil 
	end
	homer_data = {
		name        = homer.name or "",
    beaconId    = homer.beaconId or "",
    ntype       = homer.type,
		callsign    = homer.callsign or nil,
		frequency   = homer.frequency or getTACANFrequency(homer.channel,'X') or nil,
    channel     = homer.channel or nil,
    position    = nil, -- in-game xyz (caucasus N/A for ndb)
    direction   = homer.direction or nil,
    positionGeo = homer.position or nil, -- lat/long
	}
  
  homer_data.position = LL2LO(homer.position, nil)
  
  return homer_data  
end

function NAV_STATION3(homer, name)
	if not homer then 
	   return nil 
	end
	homer_data = {
		name        = name or "",
    beaconId    = homer.beaconId or "",
    ntype       = homer.type,
		callsign    = homer.callsign or nil,
		frequency   = homer.frequency or getTACANFrequency(homer.channel,'X') or nil,
    channel     = homer.channel or nil,
    position    = nil, -- in-game xyz (caucasus N/A for ndb)
    direction   = homer.direction or nil,
    positionGeo = homer.position or nil, -- lat/long
	}
  
  homer_data.position = LL2LO(homer.position, nil)
  
  return homer_data  
end
-- from DCS ME
function matchSideName(sideName, edge1name, edge2name)
	if sideName == edge1name then
		return 1
	elseif sideName == edge2name then
		return 2
	else
		local sideNumber	= tonumber(string.match(sideName,	'%d+'))		
		local edge1Number	= tonumber(string.match(edge1name,	'%d+'))
		local edge2Number	= tonumber(string.match(edge2name,	'%d+'))
		
		if	edge1Number == sideNumber	or 
			edge1Number == sideNumber + 1 or 
			edge1Number == sideNumber - 1 then
			
			return 1
		end	
		
		if	edge2Number == sideNumber	or 
			edge2Number == sideNumber + 1 or 
			edge2Number == sideNumber - 1 then
			
			return 2
		end
	end
	
	return 0
end

function getBeaconPlacement(sideName, runway, roadnet)
	local x
	local y
	local angle
	local matchResult = matchSideName(sideName, runway.edge1name, runway.edge2name)
	
	if 1 == matchResult then
		x			= runway.edge1x
		y			= runway.edge1y
		angle		= math.pi + runway.course	
	elseif 2 == matchResult then
		x			= runway.edge2x
		y			= runway.edge2y
		angle		= runway.course	
	else
		x			= runway.edge1x
		y			= runway.edge1y
		angle		= math.pi + runway.course
		
		print('Error! Beacon side not found!', sideName, runway.edge1name, runway.edge2name, roadnet)
	end
	
	return x, y, angle
end

function getBeaconPosition(x, y, angle, position)	
	if position.S0 then					   
	   return	x - position.S0 * math.cos(angle),
				y - position.S0 * math.sin(angle) 
	end
	
	if position.Z0 then					   
	   return	x + position.Z0 * math.cos(-math.pi / 2 + angle),
				y + position.Z0 * math.sin(-math.pi / 2 + angle)					
	end
					
	return x, y
end

-- extracts the digits from an XXX.YY lua number, returning them in reverse order using degree:minutes
-- first entry is "true" if number is positive
function get_digits_LL123(x)
  local y = {false, 0, 0, 0, 0, 0}
  local n = 2

  if x >= 0 then
      y[1] = true
  else
      y[1] = false
      x = math.abs(x)
  end

  local a,b = math.modf(x)
  x = (a * 100) + (b * 60)

  while x > 0 and n <= 6 do
      y[n] = x % 10
      x = math.floor(x/10)
      n = n + 1
  end

  return y
end

-- extracts the digits from an XX.YY lua number, returning them in reverse order using degree:minutes
-- first entry is "true" if number is positive
function get_digits_LL122(x)
  local y = {false, 0, 0, 0, 0}
  local n = 2

  if x >= 0 then
      y[1] = true
  else
      y[1] = false
      x = math.abs(x)
  end

  local a,b = math.modf(x)
  x = (a * 100) + (b * 60)

  while x > 0 and n <= 5 do
      y[n] = x % 10
      x = math.floor(x/10)
      n = n + 1
  end

  return y
end