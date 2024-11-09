dofile(LockOn_Options.script_path.."Nav/ils_utils.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."Systems/mission.lua")
dofile(LockOn_Options.script_path.."Systems/mission_utils.lua")
dofile(LockOn_Options.script_path.."Systems/adi_needles_api.lua")
dofile(LockOn_Options.script_path.."EFM_Data_Bus.lua")

avionics = require_avionics()

local dev = GetSelf()

local Terrain = require('terrain')

local update_time_step = 0.05
make_default_activity(update_time_step)--update will be called 20 times per second

sensor_data = get_efm_sensor_data_overrides()

-------------------------------------------
--           COMMAND LISTENER
-------------------------------------------
dev:listen_command(device_commands.mcl_channel_selector)
dev:listen_command(device_commands.mcl_power_switch)
dev:listen_command(Keys.MCL_Power_Toggle)
dev:listen_command(Keys.MCL_Chan_Inc)
dev:listen_command(Keys.MCL_Chan_Dec)

-------------------------------------------
--           FILE CONSTANTS
-------------------------------------------
MCL_STATE_OFF = 0
MCL_STATE_ON = 1
MCL_STATE_BIT = 2

MCL_PWR_OFF = 0
MCL_PWR_ON = 1
MCL_PWR_BIT = 2

local ils_data, marker_data = get_ils_data_in_format()
local tacan_to_object_id = {}
local icls_to_object_id = {}

-- Beacon offset in format [x offset (forward-backward), z offset(left-right), deck angle]
--
-- deck angle of Melbourne and Hermes found in lua scripts for resp. ship mod

local beacon_offsets = {
    ["Stennis"] = {18.0, 13.0, 9.0},
    ["hmas_melbourne_wip"] = {60.0, 0.0, 6.0},
    ["hmas_melbourne"] = {60.0, 0.0, 6.0},
    ["HERMES69"] = {45.0, 0.0, 9.0},
}

-------------------------------------------
--           FILE VARIABLES
-------------------------------------------
local mcl_channel = 1
local mcl_state = MCL_STATE_OFF
local mcl_power_switch = MCL_PWR_OFF

adi_loc_needle = -1
adi_gs_needle = -1

-- 4 seconds per cycle, 2 units per length and 0.66 lengths per cycle so (1/3) * 4 / (2 * 2)
loc_bit = Constant_Speed_Controller(update_time_step / 3, -0.33, 0.33, -0.33)
loc_bit_target = 0.33

-------------------------------------------
--                 PARAMS
-------------------------------------------

-------------------------------------------

--device commands
function channelFromArg(arg)
    return round(arg * 20 + 1.0)
end

function argFromChannel(chn)
    return (chn - 1.0) / 20.0
end

function mcl_channel_selector_callback(value)
    mcl_channel = channelFromArg(value)
end

function mcl_power_switch_callback(value)
    mcl_power_switch = round(value + 1.0)
end

--keys
function MCL_Power_Toggle_callback(value)
    if mcl_power_switch == MCL_PWR_OFF then
        dev:performClickableAction(device_commands.mcl_power_switch, 0, false)
    else 
        dev:performClickableAction(device_commands.mcl_power_switch, -1, false)
    end
end

function MCL_Chan_Inc_callback(value)
    local mcl_channel_target = mcl_channel + 1
    if mcl_channel_target <= 20 then
        dev:performClickableAction(device_commands.mcl_channel_selector, argFromChannel(mcl_channel_target), false)
    end
end

function MCL_Chan_Dec_callback(value)
    local mcl_channel_target = mcl_channel - 1
    if mcl_channel_target >= 1 then
        dev:performClickableAction(device_commands.mcl_channel_selector, argFromChannel(mcl_channel_target), false)
    end
end


command_callbacks = {
    [device_commands.mcl_channel_selector] = mcl_channel_selector_callback,
    [device_commands.mcl_power_switch] = mcl_power_switch_callback,
    [Keys.MCL_Power_Toggle] = MCL_Power_Toggle_callback,
    [Keys.MCL_Chan_Inc] = MCL_Chan_Inc_callback,
    [Keys.MCL_Chan_Dec] = MCL_Chan_Dec_callback,
}

function SetCommand(command, value)

    --print_message_to_user("Command: "..tostring(command).." Value: "..tostring(value))

    if command_callbacks[command] == nil then
        return
    end

    command_callbacks[command](value)
end

function post_initialize()

    sndhost = create_sound_host("COCKPIT_MCL","HEADPHONES",0,0,0)
    marker_middle_snd = sndhost:create_sound("Aircrafts/A-4E-C/MarkerMiddle")
    marker_outer_snd = sndhost:create_sound("Aircrafts/A-4E-C/MarkerOuter")

    local birth = LockOn_Options.init_conditions.birth_place

    load_tempmission_file() 
    tacan_to_object_id, icls_to_object_id = find_mobile_tacan_and_icls()

    local birth = LockOn_Options.init_conditions.birth_place

    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
        dev:performClickableAction(device_commands.mcl_power_switch, 0.0, true)
        mcl_power_switch = MCL_PWR_ON
    elseif birth == "GROUND_COLD" then
        dev:performClickableAction(device_commands.mcl_power_switch, -1.0, true)
        mcl_power_switch = MCL_PWD_OFF
    end
    
end

function mcl_get_state()
    if not get_elec_mon_primary_ac_ok() then
        return MCL_STATE_OFF
    end

    if mcl_power_switch == MCL_PWR_ON then
        return MCL_STATE_ON
    elseif mcl_power_switch == MCL_PWR_BIT then
        return MCL_STATE_BIT
    else
        return MCL_STATE_OFF
    end
end

function mcl_calculate_bit_angle()
    loc_bit:update(loc_bit_target)

    if loc_bit:get_position() >= 0.33 then
        loc_bit_target = -0.33
    elseif loc_bit:get_position() <= -0.33 then
        loc_bit_target = 0.33
    end

    return 0.0, loc_bit:get_position()
end

function update()
    mcl_state = mcl_get_state()

    if mcl_state == MCL_STATE_OFF then
        adi_needles_api:releaseNeedles(devices.MCL)
    elseif mcl_state == MCL_STATE_BIT then
        print_message_to_user()
        local gs, loc = mcl_calculate_bit_angle()
        adi_needles_api:setTarget(devices.MCL, gs, loc)
    elseif mcl_state == MCL_STATE_ON then
        local gs, loc = mcl_calculate_angles()
        if gs and loc then
            adi_needles_api:setTarget(devices.MCL, gs, loc)
        else
            adi_needles_api:releaseNeedles(devices.MCL)
        end
    end
end

function find_ils_loc(pos, brg, invert_brg)

    --print_message_to_user(tostring(pos.x).." "..tostring(pos.y).." "..tostring(pos.z))

    if invert_brg then
        if brg > 180 then
            brg = brg - 180
        else
            brg = brg + 180
        end
    end

	local curx, cury, curz = sensor_data.getSelfCoordinates()
	
    local posy = pos.y + 19

	if not Terrain.isVisible(curx,cury,curz,pos.x,posy,pos.z) then
		return 3.0, false
    end
    
    local range = math.sqrt((pos.x - curx)^2 + (posy - cury)^2 + (pos.z - curz)^2)

    

    if range > 33000 then
        return 3.0, false
    end
	
	
	runway_vec = bearing_to_vec2d(brg)
	aircraft_vec = {
		x = (pos.x - curx),
		z = (pos.z - curz)
	}

    --print_message_to_user("x: "..aircraft_vec.x.." z: "..aircraft_vec.z)
	
	aircraft_vec = normalize_vec2d(aircraft_vec)
	--runway_vec = normalize_vec2d(runway_vec)
	
	--tan(angle) = y/x
	--y = a x b
	--x = a . b
	-- where a and b are vectors.
	localiser_angle =  math.deg(math.atan2( - aircraft_vec.z*runway_vec.x + aircraft_vec.x*runway_vec.z, aircraft_vec.z*runway_vec.z + aircraft_vec.x * runway_vec.x))

    if math.abs(localiser_angle) > 35 then
        return 3.0, false
    end

	return localiser_angle, true
end

function find_ils_gs(pos, carrier)
	local curx, cury, curz = sensor_data.getSelfCoordinates()

    local posy = pos.y + 19
	if not Terrain.isVisible(curx,cury,curz,pos.x,pos.y+19,pos.z) then
		return -3.0, false
	end
	
    local horizontal_range = math.sqrt((pos.x - curx)^2 + (pos.z - curz)^2)
    
    if horizontal_range > 22000 then
        return -3.0, false
    end

	local height = cury - posy
	
	glide_slope_angle = math.deg(math.atan(height/horizontal_range))
    --print_message_to_user("Height: "..height.." Range: "..horizontal_range.." Angle: "..glide_slope_angle)
	
	return glide_slope_angle, true
end

function fetch_current_ils()

    local current_ils = nil
    local carrier = false

    local objects = icls_to_object_id[mcl_channel]
    --print_message_to_user(recursively_traverse(icls_to_object_id))
    

    if objects then

        local object_data = objects[1]

        local position = avionics.MissionObjects.getObjectPosition(object_data.id, object_data.name, 3) -- 3 -> type ship

        if position then

            local x = position.x
            local y = position.y
            local z = position.z

            local heading = avionics.MissionObjects.getObjectBearing(object_data.id, object_data.name, 3) -- 3 -> type ship

            local z_dir = bearing_to_vec2d(heading - 90)
            local x_dir = bearing_to_vec2d(heading)

            --Stennis Offset:
            -- x = 18.0 metres
            -- z = 13.0
            --This is really lazy, I just couldn't
            --be bothered to create another 2d rotation
            --function.
            local x_offset = 18.0
            local z_offset = 13.0

            -- Nimitz class deck angle = 9.0 deg
            -- Majestic class deck angle = 5.5 deg
            local deck_angle = 9.0
			
            local ship_os = beacon_offsets[object_data.type]
            -- override the default values if ship type found
            if ship_os then
                --print_message_to_user("x= "..tostring(ship_os[1]).." z= "..tostring(ship_os[2]).." angle= "..tostring(ship_os[3]))
                x_offset = ship_os[1]
                z_offset = ship_os[2]
                deck_angle = ship_os[3]
            end
			
            x_dir.x = -x_dir.x * x_offset
            x_dir.z = -x_dir.z * x_offset

            z_dir.x = z_dir.x * z_offset
            z_dir.z = z_dir.z * z_offset

            x = x + x_dir.x + z_dir.x
            z = z + x_dir.z + z_dir.z

            local curx, cury, curz = sensor_data.getSelfCoordinates()

            --print_message_to_user(tostring(x - curx).." "..(z - curz))


            --print_message_to_user("x_dir: "..tostring(x_dir.x).." "..tostring(x_dir.z).." z_dir: "..tostring(z_dir.x).." "..tostring(z_dir.z))

            current_ils = {
                callsign = "",
                name = "",
                [BEACON_TYPE_ILS_GLIDESLOPE] = {
                    position = {
                        x = x,
                        y = y,
                        z = z, 
                    },
                    direction = heading - deck_angle,
                    frequency = 0,
                },

                [BEACON_TYPE_ILS_LOCALIZER] = {
                    position = {
                        x = x,
                        y = y,
                        z = z,
                        
                    },
                    direction = heading - deck_angle,
                    frequency = 0,
                },
            }
            carrier = true
        end
    end


    if current_ils == nil then
        current_ils = ils_data[mcl_channel]
        carrier = false
    end

    return current_ils, carrier

end

function mcl_calculate_angles()
    
    local current_ils, carrier = fetch_current_ils()

    if current_ils ~= nil then
        local localiser_angle = 3.0
        local glide_slope_angle = -3.0
        local desired_gs = -1.0
        local desired_loc = -1.0
        local loc_avail = false
        local gs_avail = false

        if current_ils[BEACON_TYPE_ILS_GLIDESLOPE] ~= nil then
            glide_slope_angle, gs_avail = find_ils_gs(current_ils[BEACON_TYPE_ILS_GLIDESLOPE].position, carrier)
        end

        if current_ils[BEACON_TYPE_ILS_LOCALIZER] ~= nil then

            localiser_angle, loc_avail  = find_ils_loc(current_ils[BEACON_TYPE_ILS_LOCALIZER].position, current_ils[BEACON_TYPE_ILS_LOCALIZER].direction, not carrier)

            --No volume dial on the MCL.
            --if loc_avail then
                --configure_morse_playback(current_ils.callsign)
            --else
                --stop_morse_playback()
            --end

            if math.abs(localiser_angle) > 7 then
                gs_avail = false
            end

        end
        
        --See 1-56B in the NATOPS for these numbers
        local DEGREES_TO_DEFLECTION_LOC = 1.0/6.0
        local DEGREES_TO_DEFLECTION_GS = 1.0/1.4 


        if loc_avail and gs_avail then

            local gs_appr_angle = 3
            if carrier then
                gs_appr_angle = 3.5
            end

            desired_gs = (gs_appr_angle - glide_slope_angle) * DEGREES_TO_DEFLECTION_GS
            update_marker()
        end

        if loc_avail then
            desired_loc = -localiser_angle * DEGREES_TO_DEFLECTION_LOC
        end


        if loc_avail or gs_avail then
            return desired_gs, desired_loc
        else
            return nil, nil
        end
    end

    return nil, nil
end

function update_marker()
    
    marker_outer_snd:update(nil, 1.0, nil)
    marker_middle_snd:update(nil, 1.0, nil)

    local curx, cury, curz = sensor_data.getSelfCoordinates()

    if current_marker then
        if (cury - current_marker.position.y) >= 330 then
            current_marker = nil
            return
        end

        --250 m -> squared
        if (math.abs(curx - current_marker.position.x)^2 + math.abs(curz - current_marker.position.z)^2) >= 562500 then
            current_marker = nil
            return
        end

        return
    end

    for i,v in ipairs(marker_data) do
        if (cury - v.position.y) < 330 then
            --250 m -> squared
            if (math.abs(curx - v.position.x)^2 + math.abs(curz - v.position.z)^2) < 562500 then
                    current_marker = v
                    if v.far then
                        marker_outer_snd:play_once()
                    else
                        marker_middle_snd:play_once()
                    end
                    return
            end
        end
    end
end

need_to_be_closed = false -- close lua state after initialization