----------------------------------------------------------------
-- SHRIKE
----------------------------------------------------------------
-- This module will handle the logic for the seeker head and 
-- deploying the AGM-45 Shrike
----------------------------------------------------------------
dofile(LockOn_Options.script_path .. "ConfigurePackage.lua")
Scooter = require('Scooter')
require(common_scripts .. "devices_defs")
require("devices")
require("Systems.electric_system_api")
require("command_defs")
require("utils")
require("Systems.adi_needles_api")
require("Systems.rhaw_radars") -- Import the Radars

avionics = require_avionics()

require("ImGui")

local SHRIKE = GetSelf()
local update_time_step = 0.02  --20 time per second
make_default_activity(update_time_step)
device_timer_dt     = 0.02  	--0.2  	

local sensor_data            = get_base_data()

SHRIKE_HORZ_FOV = 12
SHRIKE_VERT_FOV = 12

local aircraft_heading_deg = 0
local aircraft_pitch_deg = 0
local shrike_lock = false
local target_expire_time = 3.0
local shrike_lock_volume = 0
-- local shrike_sidewinder_volume = 0.5

-- Current Selected Shrike
local shrike_seeker_band_min = get_param_handle("SHRIKE_BAND_MIN")
local shrike_seeker_band_max = get_param_handle("SHRIKE_BAND_MAX")

local shrike_band = nil

shrike_armed_param = get_param_handle("SHRIKE_ARMED")
shrike_sidewinder_volume = get_param_handle("SHRIKE_SIDEWINDER_VOLUME")

-- populate table with contacts from the RWR
maxContacts = 9
contacts = {}
for i = 1, maxContacts do
    contacts[i] =
    {
        elevation_h 	= get_param_handle("RWR_CONTACT_0" .. i .. "_ELEVATION"),       -- elevation of the target relative to the aircraft
        azimuth_h 		= get_param_handle("RWR_CONTACT_0" .. i .. "_AZIMUTH"),         -- direction of the target relative to the aircraft
        power_h 		= get_param_handle("RWR_CONTACT_0" .. i .. "_POWER"),           -- strength of signal. use to detect contact and relative distance
        unit_type_h		= get_param_handle("RWR_CONTACT_0" .. i .. "_UNIT_TYPE"),       -- name of unit
        
        general_type_h	= get_param_handle("RWR_CONTACT_0" .. i .. "_GENERAL_TYPE"),    -- (0) EWR, (1) Aircraft, (2) Search Radar
        priority_h		= get_param_handle("RWR_CONTACT_0" .. i .. "_PRIORITY"),        -- some value which shows how dangerous the threat is to you
        signal_h		= get_param_handle("RWR_CONTACT_0" .. i .. "_SIGNAL"),          -- (1) Search, (2) Locked, (3) Missile launched
        time_h			= get_param_handle("RWR_CONTACT_0" .. i .. "_TIME"),            -- time since target data was updated
        source_h		= get_param_handle("RWR_CONTACT_0" .. i .. "_SOURCE"),          -- unique id of the object
    }
end

-- create table with shrike targets, tracked by source id
local shrike_targets = {}

function BandsText(bands)

    if bands == nil then
        return "{}"
    end

    local s = {}

    for i,v in ipairs(bands) do
        table.insert(s, string.format("{%f,%f}", v[1] / 1.0e9, v[2] / 1.0e9))
    end

    return table.concat(s, ", ")
end

function VectorText(v)
    return string.format("(%f,%f,%f)", v.x, v.y, v.z)
end

ImGui.AddItem("Systems", "Shrike", function()

    if shrike_band == nil then
        ImGui:Text("Shrike Band: nil")
    else
        ImGui:Text(string.format("Shrike Band (GHz): { %f -> %f }", shrike_band[1] / 1.0e9, shrike_band[2] / 1.0e9))
    end

    
    ImGui:Tree("Contacts", function()

        ImGui:Text(string.format("local v: %s", VectorText(Scooter.ToLocal({x = 1, y=0, z=0}))))
        --ImGui:Text(string.format("local v: %s", VectorText(Scooter.ToLocal({x = 0.995, y=-0.0995, z=0.0}))))
        ImGui:Text(string.format("fwd: %s", VectorText(Scooter.GetForward())))
        ImGui:Text(string.format("up: %s", VectorText(Scooter.GetUp())))
        ImGui:Text(string.format("right: %s", VectorText(Scooter.GetRight())))

        local contacts_tab = {
            { "Time", "Power", "Bands (GHz)"}
        }

        for i, v in ipairs(contacts) do
            local t = v.time_h:get()
            local p = v.power_h:get()
            local bands = TargetBands(v.unit_type_h:get())
            table.insert(contacts_tab, {t,p,BandsText(bands)})
        end
        
        ImGui:Table(contacts_tab)

    end)

    ImGui:Tree("Shrike Target", function() 

        for i,target in pairs(shrike_targets) do

            local x,y,z = sensor_data.getSelfCoordinates()
            local v = subtract_vector( target.world_position, {x=x,y=y,z=z} )
            v = normalize_vector(v)
            v = Scooter.ToLocal(v)
            local el,az = pitch_yaw(v)

            ImGui:Text(string.format("local v: %s", VectorText(v)))
            ImGui:Text(string.format("EL: %f, AZ: %f", math.deg(el), math.deg(az)))
        end

        ImGui:Text(ImGui.Serialize(shrike_targets))
    end)
end)

function post_initialize()
    local RWR = GetDevice(devices.RWR)
    shrike_armed_param:set(0)
    -- RWR:set_power(true)

    -- initialise sounds
    sndhost             = create_sound_host("SHRIKE","HEADPHONES",0,0,0) -- TODO: look into defining this sound host for HEADPHONES/HELMET
    snd_shrike_tone     = sndhost:create_sound("Aircrafts/A-4E-C/agm-45a-shrike-tone")
    snd_shrike_search   = sndhost:create_sound("Aircrafts/A-4E-C/agm-45a-shrike-search")
    snd_shrike_lock     = sndhost:create_sound("Aircrafts/A-4E-C/agm-45a-shrike-lock")
end

function remove_incorrect_incompatible_contacts()
    for i,v in ipairs(shrike_targets) do
        if not CheckTargetBand(v.bands) then
            shrike_targets[i] = nil
        end
    end
end

function update()

    ImGui.Refresh()

    if shrike_seeker_band_min:get() > 0 and shrike_seeker_band_max:get() > 0 then
        shrike_band = { shrike_seeker_band_min:get() * 1.e9, shrike_seeker_band_max:get() * 1.e9 }
    else
        shrike_band = nil
    end
    
    -- If the seeker has changed (selected another missile), then remove the incompatible contacts
    remove_incorrect_incompatible_contacts()
    
    -- TODO: Check for AFT MON AC BUS and MONITORED DC BUS
    if get_elec_aft_mon_ac_ok() and get_elec_mon_dc_ok() and shrike_band ~= nil then
        -- get aircraft current heading
        aircraft_heading_deg    = math.deg(sensor_data.getMagneticHeading())
        aircraft_pitch_deg      = math.deg(sensor_data.getPitch())
        local current_time      = get_absolute_model_time()
        
        -- TODO: Delete invalid targets after 3 seconds
        for i, contact in ipairs(contacts) do
            --and (contact.general_type_h:get() == 2 or contact.general_type_h:get() == 0)
            if contact.power_h:get() > 0 and contact.time_h:get() < 0.05 and contact.time_h:get() > 0 then
                local id = contact.source_h:get()
                local target_type = contact.unit_type_h:get()
                
                local freqs = TargetBands(target_type)

                if CheckTargetBand(freqs) then
                    -- check if data already exists
                    if shrike_targets[id] then
                        -- only update target data if data is new
                        if shrike_targets[id].raw_azimuth ~= contact.azimuth_h:get() then
                            updateTargetData(id, contact, current_time, freqs)
                        end
                    else -- create new target
                        updateTargetData(id, contact, current_time, freqs)
                    end
                end
            end
        end

        shrike_lock = false
        local best_world_position = nil
        local best_strength = 0.0
        -- sort through target list and get deviations
        for i, target in pairs(shrike_targets) do
            -- check contact is still valid based on time last updated.
            if (current_time - target.time_stored) < target_expire_time then
                if checkShrikeLock(target) then
                    shrike_lock = true
                    if target.strength > best_strength then
                        best_world_position = target.world_position
                        best_strength = target.strength
                    end
                end
            end
        end

        if best_world_position then
            local el,az = Needles(best_world_position)
            adi_needles_api:setTarget(devices.SHRIKE, el / 3.0, az / 3.0)
        end


    end -- check power is available

    if not shrike_lock then
        adi_needles_api:releaseNeedles(devices.SHRIKE)
    end
    -- update search volume with deviation
    update_lock_volume()

end

function SetCommand(command, value)
end


-- Checks the intersection of two bands
-- in the format {a_min, a_max}, {b_min, b_max}
function CheckBandIntersection(a, b)
    return math.max(a[1], b[1]) <= math.min(a[2], b[2])
end

function TargetBands(target_type)
    local unit = units[target_type]

    if unit == nil then
        return nil
    end

    if unit.frequencies == nil or #unit.frequencies <= 0 then
        return nil
    end

    return unit.frequencies

end

function CheckTargetBand( bands )

    if bands == nil then
        return false
    end

    for i,v in ipairs(bands) do
        if CheckBandIntersection(v,shrike_band) then
            return true
        end
    end

    return false
end

-- this function parses the raw data format into the target table
function updateTargetData(id, contact, current_time, bands)
    shrike_targets[id] = {
        ['raw_azimuth']     = contact.azimuth_h:get(),
        ['raw_elevation']   = contact.elevation_h:get(),
        ['heading']         = getTargetHeading(math.deg(contact.azimuth_h:get()), aircraft_heading_deg),
        ['elevation']       = getTargetElevation(math.deg(contact.elevation_h:get()), aircraft_pitch_deg),
        ['time_stored']   = current_time,
        ['bands'] = bands,
        ['world_position'] = avionics.MissionObjects.getObjectIDPosition(id),
        ['strength'] = contact.power_h:get()
    }
end

function Needles(world_position)
    local x,y,z = sensor_data.getSelfCoordinates()
    local v = subtract_vector( world_position, {x=x,y=y,z=z} )
    v = normalize_vector(v)
    v = Scooter.ToLocal(v)
    local el,az = pitch_yaw(v)
    return math.deg(el) + 4.0, math.deg(az)
end

function checkShrikeLock(target)
    -- calculate horizontal deviation
    local horz_deviation = math.abs(aircraft_heading_deg - target.heading)

    -- calculate vertical deviation
    local vert_deviation = math.abs((target.elevation + 4) - aircraft_pitch_deg)

    -- check if deviation is within params for a shrike lock
    if horz_deviation < (SHRIKE_HORZ_FOV/2) and vert_deviation < (SHRIKE_VERT_FOV/2) then
        shrike_lock_volume = (((3 - (get_absolute_model_time() - target.time_stored)) / 3) * 0.6) + 0.4
        return true
    else
        return false
    end
end

function getTargetHeading(target_azimuth_deg, aircraft_heading)
    if target_azimuth_deg > 180 then -- target is on the right
        contact_horz_deviation_deg = 360 - target_azimuth_deg
        return (aircraft_heading + contact_horz_deviation_deg) % 360
    else -- target is on the left
        contact_horz_deviation_deg = target_azimuth_deg
        return (aircraft_heading - contact_horz_deviation_deg) % 360
    end
end

function getTargetElevation(target_elevation_deg, aircraft_pitch)
    return aircraft_pitch + target_elevation_deg
end

function update_lock_volume()

    if shrike_armed_param:get() == 1 and (get_elec_aft_mon_ac_ok() and get_elec_mon_dc_ok()) then

        --print_message_to_user('Shrike Volume: '..(shrike_sidewinder_volume:get()+1)*0.5)
        local new_shrike_volume_normalized = (shrike_sidewinder_volume:get()+1)*0.12 + 0.01
        snd_shrike_tone:update(nil, new_shrike_volume_normalized*0.25, nil)
        --print_message_to_user('Shrike Volume (Normalized): '..new_shrike_volume_normalized)
        
        if not snd_shrike_tone:is_playing() then
            snd_shrike_tone:play_continue()
        end

        if not shrike_lock then
            snd_shrike_lock:update(nil, 0, nil)
            snd_shrike_search:update(nil, new_shrike_volume_normalized*0.9, nil)
        else
            snd_shrike_lock:update(nil, new_shrike_volume_normalized, nil)
            snd_shrike_search:update(nil, 0, nil)
        end

        if not snd_shrike_lock:is_playing() then
            snd_shrike_lock:play_continue()
        end
        if not snd_shrike_search:is_playing() then
            snd_shrike_search:play_continue()
        end
    else
        snd_shrike_tone:update(nil, 0, nil)
        snd_shrike_search:update(nil, 0, nil)
        snd_shrike_lock:update(nil, 0, nil)
    end

end


need_to_be_closed = false -- close lua state after initialization