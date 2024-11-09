
dofile(LockOn_Options.script_path.."ConfigurePackage.lua")
require('Nav.coord_utils')
require("EFM_Data_Bus")
require("command_defs")
require("Systems.electric_system_api")
require("utils")
require('ImGui')

avionics = require_avionics()

local dev = GetSelf()

local tacan_beacons = require('Mission.tacan')
local Terrain = require('terrain')

local update_time_step = 0.05
make_default_activity(update_time_step)--update will be called 20 times per second

local sensor_data = get_efm_sensor_data_overrides()

-------------------------------------------
--           COMMAND LISTENER
-------------------------------------------
dev:listen_command(Keys.TacanModeInc)
dev:listen_command(Keys.TacanModeDec)
dev:listen_command(Keys.TacanChMajorInc)
dev:listen_command(Keys.TacanChMajorDec)
dev:listen_command(Keys.TacanChMinorInc)
dev:listen_command(Keys.TacanChMinorDec)
dev:listen_command(Keys.TacanVolumeInc)
dev:listen_command(Keys.TacanVolumeDec)
dev:listen_command(Keys.TacanVolumeStartUp)
dev:listen_command(Keys.TacanVolumeStartDown)
dev:listen_command(Keys.TacanVolumeStop)

dev:listen_command(device_commands.tacan_ch_major)
dev:listen_command(device_commands.tacan_ch_minor)
dev:listen_command(device_commands.tacan_volume)
dev:listen_command(device_commands.tacan_volume_axis_abs)
dev:listen_command(device_commands.tacan_volume_axis_slew)
dev:listen_command(device_commands.tacan_mode)

-------------------------------------------
--           FILE CONSTANTS
-------------------------------------------

-- System State
TACAN_STATE_OFF = 0
TACAN_STATE_REC = 1
TACAN_STATE_TR = 2
TACAN_STATE_AA = 3

-- Mode Select
TACAN_MODE_OFF = 0
TACAN_MODE_REC = 1
TACAN_MODE_TR = 2
TACAN_MODE_AA = 3


-------------------------------------------
--           FILE VARIABLES
-------------------------------------------
tacan_state = TACAN_STATE_OFF
tacan_mode = TACAN_MODE_OFF
arn52_range = nil
arn52_bearing = 0
arn52_target_bearing = nil

local tacan_bearing_handle = get_param_handle("TACAN_BEARING")
local tacan_range_handle = get_param_handle("TACAN_RANGE")

local tacan_volume = 0
local tacan_volume_moving = 0
local tacan_volume_playback = 0
local tacan_ch_major = 0
local tacan_ch_minor = 1
local tacan_channel = 1

-- Morze Stuff
local morse_unit_time = 0.1  -- MorzeDot.wav is 0.1s long, MorzeDash.wav is 0.3s
local time_to_next_morse = 0
local current_morse_string=""
local morse_silent = false
local current_morse_char = 0
local tacan_audio_active = false

-------------------------------------------
--                 PARAMS
-------------------------------------------

-------------------------------------------

function update_tacan_channel()
    tacan_channel = round(10 * tacan_ch_major + tacan_ch_minor)
    stop_morse_playback()
end

-- Commands
local command_callbacks = {
    [device_commands.tacan_mode] = function(value)
        tacan_mode = round(value*10)
    end,
    [device_commands.tacan_ch_major] = function(value)
        tacan_ch_major = value * 20
        update_tacan_channel()
    end,
    [device_commands.tacan_ch_minor] = function(value)
        tacan_ch_minor = value * 10
        update_tacan_channel()
    end,
    [device_commands.tacan_volume] = function(value)
        tacan_volume = value
        if tacan_volume < -0.5 then
            dev:performClickableAction(device_commands.tacan_volume, 0.8, false)  -- bound check to fix wrap
        elseif tacan_volume < 0 and tacan_volume > -0.5 then
            dev:performClickableAction(device_commands.tacan_volume, 0, false)  -- bounds check to fix wrap
        else
            morse_dot_snd:update(nil,tacan_volume_playback,nil)
            morse_dash_snd:update(nil,tacan_volume_playback,nil)
        end
    end,
    [device_commands.tacan_volume_axis_abs] = function(value)
        -- normalize and constrain tacan axis input to bounds set above (0.2-0.8)
        local set_tacan_volume_from_axis = (((value+1)*0.5)*0.6) + 0.2
        dev:performClickableAction(device_commands.tacan_volume, set_tacan_volume_from_axis, false)
    end,
    [device_commands.tacan_volume_axis_slew] = function(value)
        tacan_volume_moving = value/75
    end,
    [Keys.TacanModeInc] = function()
        if tacan_mode == TACAN_MODE_OFF then
            dev:performClickableAction(device_commands.tacan_mode, 0.1, false) -- set REC
        elseif tacan_mode == TACAN_MODE_REC then
            dev:performClickableAction(device_commands.tacan_mode, 0.2, false) -- set T/R
        elseif tacan_mode == TACAN_MODE_TR then
            dev:performClickableAction(device_commands.tacan_mode, 0.3, false) -- set A/A
        end
    end,
    [Keys.TacanModeDec] = function()
         if tacan_mode == TACAN_MODE_AA then
            dev:performClickableAction(device_commands.tacan_mode, 0.2, false) -- set T/R
        elseif tacan_mode == TACAN_MODE_TR then
            dev:performClickableAction(device_commands.tacan_mode, 0.1, false) -- set REC
        elseif tacan_mode == TACAN_MODE_REC then
            dev:performClickableAction(device_commands.tacan_mode, 0.0, false) -- set OFF
        end
    end,
    [Keys.TacanChMajorInc] = function()
        dev:performClickableAction(device_commands.tacan_ch_major, clamp(tacan_ch_major / 20 + 0.05, 0, 0.6), false) -- increment as as per amounts and limits set above
    end,
    [Keys.TacanChMajorDec] = function()
        dev:performClickableAction(device_commands.tacan_ch_major, clamp(tacan_ch_major / 20 - 0.05, 0, 0.6), false) -- decrement as as per amounts and limits set above
    end,
    [Keys.TacanChMinorInc] = function()
        dev:performClickableAction(device_commands.tacan_ch_minor, clamp(tacan_ch_minor / 10 + 0.10, 0, 0.9), false) -- increment as as per amounts and limits set above
    end,
    [Keys.TacanChMinorDec] = function()
        dev:performClickableAction(device_commands.tacan_ch_minor, clamp(tacan_ch_minor / 10 - 0.10, 0, 0.9), false) -- decrement as as per amounts and limits set above
    end,
    [Keys.TacanVolumeInc] = function()
        dev:performClickableAction(device_commands.tacan_volume, clamp(tacan_volume + 0.03, 0.2, 0.8), false)
    end,
    [Keys.TacanVolumeDec] = function()
        dev:performClickableAction(device_commands.tacan_volume, clamp(tacan_volume - 0.03, 0.2, 0.8), false)
    end,
    [Keys.TacanVolumeStartUp] = function()
        tacan_volume_moving = 1/100
    end,
    [Keys.TacanVolumeStartDown] = function()
        tacan_volume_moving = -1/100
    end,
    [Keys.TacanVolumeStop] = function()
        tacan_volume_moving = 0
    end,
}

function SetCommand(command, value)
    if command_callbacks[command] == nil then
        return
    end
    command_callbacks[command](value)
end

ImGui.AddItem("Systems", "TACAN", function()
    ImGui:Text("Tacan State: "..tostring(tacan_state))
    ImGui:Text("Tacan Mode: "..tostring(tacan_mode))
    ImGui:Text(string.format("Bearing: %s", tostring(arn52_target_bearing)))
    ImGui:Text(string.format("Bearing: %s", tostring(arn52_bearing)))
    ImGui:Text(string.format("Range: %s", tostring(arn52_range)))
    ImGui:Tree("TACAN Stations", function() 
        for i,v in pairs(tacan_beacons) do
            ImGui:Header(i, function()
                ImGui:Text(ImGui.Serialize(v))
            end)
        end
    end)
end)

function post_initialize()
    sndhost = create_sound_host("COCKPIT_TACAN", "HEADPHONES", 0, 0, 0)
    morse_dot_snd = sndhost:create_sound("Aircrafts/A-4E-C/MorzeDot") -- refers to sdef file, and sdef file content refers to sound file, see DCSWorld/Sounds/sdef/_example.sdef
    morse_dash_snd = sndhost:create_sound("Aircrafts/A-4E-C/MorzeDash")
    marker_middle_snd = sndhost:create_sound("Aircrafts/A-4E-C/MarkerMiddle")
    marker_outer_snd = sndhost:create_sound("Aircrafts/A-4E-C/MarkerOuter")


    dev:performClickableAction(device_commands.tacan_ch_major, 0.0, true)
    dev:performClickableAction(device_commands.tacan_ch_minor, 0.1, true)

    local birth = LockOn_Options.init_conditions.birth_place

    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
    elseif birth == "GROUND_COLD" then
    end
end

function update()
    -- Do elec in state
    --get_elec_mon_primary_ac_ok()
    update_tacan()  -- AN/ARN-52(V) TACAN BEARING-DISTANCE EQUIPMENT

    if tacan_state ~= TACAN_STATE_OFF then
        update_bearing(arn52_target_bearing)
    end

    tacan_bearing_handle:set(math.deg(arn52_bearing))
    if arn52_range == nil then
        tacan_range_handle:set(-1)
    else
        tacan_range_handle:set(arn52_range)
    end

    if tacan_volume_moving ~= 0 then
        dev:performClickableAction(device_commands.tacan_volume, clamp(tacan_volume + tacan_volume_moving, 0.2, 0.8),
        false)
    end
    
    if tacan_audio_active then
        --update_morse_playback()
        update_morse_playback_2()
    end

    tacan_volume_playback = clamp(tacan_volume - 0.21, 0, 0.6)
    

    ImGui.Refresh()
end

function cancel_tacan()
    morse_silent = true
    arn52_range = nil
    arn52_target_bearing = nil
    stop_morse_playback()
end

function get_tacan_state()
    if not get_elec_mon_primary_ac_ok() then
        return TACAN_STATE_OFF
    end

    if tacan_mode == TACAN_MODE_OFF then
        return TACAN_STATE_OFF
    elseif tacan_mode == TACAN_MODE_REC then
        return TACAN_STATE_REC
    elseif tacan_mode == TACAN_MODE_TR then
        return TACAN_STATE_TR
    elseif tacan_mode == TACAN_MODE_AA then
        return TACAN_STATE_AA
    end
       
    return TACAN_STATE_OFF
end

-- Literally copy the ADF logic
function update_bearing(bearing)
    local speed = math.rad(72.0)
    local step = speed * update_time_step

    if bearing then
        local d_pos = bearing - arn52_bearing
        local d_pos_abs = math.abs(d_pos)
        local d_pos_abs_inverse = 2.0 * math.pi - d_pos_abs

        if d_pos_abs < d_pos_abs_inverse then
            arn52_bearing = arn52_bearing + clamp(d_pos, -step, step)
        else
            arn52_bearing = arn52_bearing + clamp(-d_pos, -step, step)
        end
    else
        arn52_bearing = arn52_bearing - step
    end


    if arn52_bearing < -math.pi then
        arn52_bearing = math.pi + math.fmod(arn52_bearing, math.pi)
    elseif arn52_bearing > math.pi then
        arn52_bearing = -math.pi + math.fmod(arn52_bearing, math.pi)
    end
end

function update_beacons(matched_beacons)
    local curx,cury,curz = sensor_data.getSelfCoordinates()
    for i,beacon in ipairs(matched_beacons) do
        if beacon.unit_id then
            matched_beacons[i].position = avionics.MissionObjects.getObjectPosition(beacon.unit_id, beacon.name, beacon.unit_type)
        end

        local position = matched_beacons[i].position
        if position then
            local nm2meter = 1852
            matched_beacons[i].range = math.sqrt( (position.x - curx)^2 + (position.y - cury)^2 + (position.z - curz)^2 )/nm2meter
            matched_beacons[i].visible = Terrain.isVisible( curx, cury, curz, position.x, position.y + 15, position.z )
        else
            matched_beacons[i].visible = false
            matched_beacons[i].range = 500
        end
    end
end

function update_tacan()

    local new_tacan_state = get_tacan_state()
    if new_tacan_state ~= tacan_state and -- on transition
        new_tacan_state == TACAN_STATE_AA then
        stop_morse_playback()
    end

    tacan_state = new_tacan_state

    local max_tacan_range = 225

    if tacan_state == TACAN_STATE_OFF then 
        arn52_bearing = 0
        arn52_bearing = 0
        arn52_range = nil
        cancel_tacan()
        return
    end

    local matching_beacons = tacan_beacons[tacan_channel]
    if matching_beacons == nil or #matching_beacons == 0 then
        cancel_tacan()
        return
    end

    update_beacons(matching_beacons)

    table.sort(matching_beacons, function(a, b)
        if a.visible ~= b.visible then
            return a.visible < b.visible
        end
        return a.range < b.range
    end)

    local closest_beacon = matching_beacons[1]

    if not closest_beacon.visible then
        cancel_tacan()
        return
    end

    local curx, cury, curz = sensor_data.getSelfCoordinates()

    if closest_beacon.range > max_tacan_range then
        cancel_tacan()
        return
    end

    if tacan_state == TACAN_STATE_REC then
        arn52_range = nil
    else
        arn52_range = closest_beacon.range
    end

    if closest_beacon.bearing then
        --local bearing = true_bearing_deg_from_xz(curx, curz, atcn.position.x, atcn.position.z)
        local bearing = true_bearing_viall_from_xz(curx, curz, closest_beacon.position.x, closest_beacon.position.z)
        --local declination = get_declination() -- relative bearing so no declination
        -- grid X/Y isn't aligned with true north, so find average adjustment between current position and beacon source
        local adj = get_true_deviation_from_grid((closest_beacon.position.x + curx) / 2,
            (closest_beacon.position.z + curz) / 2)

        arn52_target_bearing = math.rad((bearing - adj))
    end

    configure_morse_playback(closest_beacon.callsign)
end

--[[
short mark, dot or "dit" (·) : "dot duration" is one time unit long
longer mark, dash or "dah" (–) : three time units long
inter-element gap between the dots and dashes within a character : one dot duration or one unit long
short gap (between letters) : three time units long
medium gap (between words) : seven time units long
--]]
local morse_alphabet={ a=".-~",b="-...~",c="-.-.~",d="-..~",e=".~",f="..-.~",g="--.~",h="....~",
i="..~",j=".---~",k="-.-~",l=".-..~",m="--~",n="-.~",o="---~",p=".--.~",q="--.-~",r=".-.~",
s="...~",t="-~",u="..-~",v="...-~",w=".--~",x="-..-~",y="-.--~",z="--..~",[" "]="|",
["0"]="-----~",["1"]=".----~",["2"]="..---~",["3"]="...--~",["4"]="....-~",["5"]=".....~",
["6"]="-....~",["7"]="--...~",["8"]="---..~",["9"]="----.~"}

function get_morse(str)
     local morse = string.gsub(string.lower(str), "%Z", morse_alphabet)
     local morse = string.gsub(morse, "~|", "      ") -- 6 units, 7th given by preceding dot or dash
     local morse = string.gsub(morse, "|", "       ")
     local morse = string.gsub(morse, "~", "  ") -- 2 units, 3rd given by preceding dot or dash
     return morse
end

function configure_morse_playback(code)
    if not tacan_audio_active then
        local timenow = get_model_time()
        if (math.floor(timenow) % 8) == 0 then
            current_morse_string = get_morse(code)
            tacan_audio_active = true
        end
    end
end

function stop_morse_playback()
    current_morse_char = 0
    tacan_audio_active = false
    current_morse_string = ""
end

function update_morse_playback_2()
    time_to_next_morse = time_to_next_morse - update_time_step

    if time_to_next_morse <= 0 then

        if morse_silent and false then
            morse_dot_snd:update(nil,0,nil)
            morse_dash_snd:update(nil,0,nil)
        else
            morse_dot_snd:update(nil,tacan_volume_playback,nil)
            morse_dash_snd:update(nil,tacan_volume_playback,nil)
        end

        local c = current_morse_string:sub(current_morse_char+1, current_morse_char+1)

        if c == '.' then
            time_to_next_morse = 2 * morse_unit_time
            morse_dot_snd:play_once()
        elseif c == '-' then
            time_to_next_morse = 4 * morse_unit_time
            morse_dash_snd:play_once()
        elseif c == ' ' then
            time_to_next_morse = morse_unit_time
        end

        current_morse_char = (current_morse_char + 1) % #current_morse_string

        if current_morse_char == 0 then
            time_to_next_morse = 0
            tacan_audio_active = false
        end

    end
end


need_to_be_closed = false -- close lua state after initialization