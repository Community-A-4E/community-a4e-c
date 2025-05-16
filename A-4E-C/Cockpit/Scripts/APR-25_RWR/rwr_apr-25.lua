dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."APR-25_RWR/rwr_apr-25_api.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

local dev = GetSelf()
local update_time_step = 0.05
make_default_activity(update_time_step)
--device_timer_dt     = 0.02  	--0.2 

dev:listen_command(device_commands.new_apr25_sound_on)
dev:listen_command(device_commands.new_apr25_volume)
dev:listen_command(device_commands.new_apr25_power)

NO_BAND = 0
I_BAND_RADAR = 1
G_BAND_RADAR = 2
E_BAND_RADAR = 3

local apr25_power = false

local apr25_band_enabled = {
    [NO_BAND] = false,
    [I_BAND_RADAR] = true,
    [G_BAND_RADAR] = true,
    [E_BAND_RADAR] = true,
}

local apr25_aaa_defeat = false
local apr25_audio = false
local apr25_volume = 0.1

local apr25_sam_light = false
local apr25_launch_light = false

--Signal
SIGNAL_SEARCH = 1
SIGNAL_LOCK = 2
SIGNAL_LAUNCH = 3

--General Type
GENERAL_TYPE_EWR = 0
GENERAL_TYPE_AIRCRAFT = 1
GENERAL_TYPE_SURFACE = 2
GENERAL_TYPE_SHIP = 3

--Lights
LIGHT_SAM = 1
LIGHT_REC = 2

apr25_lights_params = {
    [LIGHT_SAM] = get_param_handle("ECM_SAM"),
    [LIGHT_REC] = get_param_handle("ECM_REC"),
}

apr25_lights = {
    [LIGHT_SAM] = false,
    [LIGHT_REC] = false,
}

--source returns the unique unit id.
--power is between 0 and 1
--priority some abstract priority number on the order of hundreds
--time is time since the last recieved signal.

emitter_info = {}

emitter_default_sounds = {
    [GENERAL_TYPE_EWR] = {
        [SIGNAL_SEARCH] = get_param_handle("RWR_EWR"), -- 7.5-second low growl pulse
    },
    [GENERAL_TYPE_AIRCRAFT] = {
        [SIGNAL_SEARCH] = get_param_handle("RWR_AI_GENERAL"), -- Solid tone (I-band)
    },
    [GENERAL_TYPE_SURFACE] = {
        --No default, creates too many false positives
    },
    [GENERAL_TYPE_SHIP] = {
        --Might be good to produce a few ship variants,
        --since any sound can only be playing once?
        [SIGNAL_SEARCH] = get_param_handle("RWR_SHIP_DEFAULT_LO"), --6.5-second EWR pulse
        [SIGNAL_LOCK] = get_param_handle("RWR_SHIP_DEFAULT_HI"), --Solid tone (E-band)
    },
}

function add_emitter(name, band, gain, lights, sounds)
    emitter_info[name] = {
        band = band,
        gain = gain,
        audio = {
            [SIGNAL_SEARCH] = get_param_handle(sounds[1]),
            [SIGNAL_LOCK] = get_param_handle(sounds[2]),
            [SIGNAL_LAUNCH] = get_param_handle(sounds[3]),
        },
        lights = lights,
            [SIGNAL_SEARCH] = get_param_handle(search),
            [SIGNAL_LOCK] = get_param_handle(lock),
            [SIGNAL_LAUNCH] = get_param_handle(launch),
        }
    }
end

--==========================================================================================
--GROUND UNIT LIST: https://github.com/pydcs/dcs/blob/master/dcs/vehicles.py
--AIRCRAFT LIST: https://github.com/pydcs/dcs/blob/master/dcs/planes.py
--RADAR BANDS: https://en.wikipedia.org/wiki/Radio_spectrum#EU,_NATO,_US_ECM_frequency_designations

--[[
    Now, only one unit using the default can be heard, even if several are in range.
    Perhaps for EWRs and Search radars, it might be more efficient to assign a rotation speed:
    Once the rotation speed is reached, if the radar still has contact, play a sample (bank) once.
    This would allow for more cluttered and complex radar environments and sample banks
    of chirps could be easily re-pitched to to suit a new individual unit's entry.
    I'm also noticing a longer initialization period, which I think is related to having 
    too many continuous sounds playing. It might be wise to set these to continuous instead, 
    and only play them when called for by a signal.
--]]

--==========================================================================================
--EARLY WARNING RADARS                      --EMITTER ID                    --BAND (NATO)
--==========================================================================================
--EWR 55G6                                  --55G6 EWR
--EWR IL13                                  --IL13 EWR

--These items are surface radars, but operate more like EWRs:
--SAM Roland EWR                            --Roland Radar
--SAM Hawk CWAR AN/MPQ-55                   --Hawk cwar

--==========================================================================================
--SEARCH RADARS                             --EMITTER ID                    --BAND (NATO)
--==========================================================================================
--MCC-SR Sborka "Dog Ear" SR                --Dog Ear radar                 --F/G
--SAM Hawk SR (AN/MPQ-50)                   --Hawk sr                       --H/I/J
--SAM SA-2/3/5 P19 "Flat Face" SR           --p-19 s-125 sr                 --E/F, 12s rotation
add_emitter("p-19 s-125 sr", E_BAND_RADAR, 1.0, nil, {"RWR_SA2_SEARCH"})
--SAM SA-5 S-200 ST-68U "Tin Shield" SR     --RLS_19J6                      --E/F, 6/12s rotation
add_emitter("RLS_19J6", E_BAND_RADAR, 1.0, nil, {"RWR_SA5_SEARCH"})
--SAM SA-10 S-300 "Grumble" Clam Shell SR   --S-300PS 40B6MD sr             --E/F
--SAM SA-10 S-300 "Grumble" Big Bird SR     --S-300PS 64H6E s               --E/F
--SAM SA-11 Buk "Gadfly" Snow Drift SR      --SA-11 Buk SR 9S18M1           --E
--SAM NASAMS SR MPQ64F1                     --NASAMS_Radar_MPQ64F1          --H/I

--==========================================================================================
--TRACKING RADARS                           --EMITTER ID                    --BAND (NATO)
--==========================================================================================
--AAA Fire Can SON-9                        --need emitter ID               --E
--add_emitter("???", E_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC}, {"RWR_AAA_FIRECAN_SON9"})
--SAM Avenger (Stinger)                     --M1097 Avenger                 --H/I
--SAM Chaparral M48                         --M48 Chaparral                 --D
--SAM Hawk TR (AN/MPQ-46)                   --Hawk tr                       --J (HPIR)
--SAM Linebacker - Bradley M6               --M6 Linebacker                 --H/I
--SAM Rapier Blindfire TR                   --rapier_fsa_blindfire_radar    --F
--SAM SA-2 S-75 "Fan Song" TR               --SNR_75V                       --E/G variants assigned below
add_emitter("SNR_75VE", E_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC,LIGHT_SAM}, {"RWR_SA2_E_LO", "RWR_SA2_E_HI"})
add_emitter("SNR_75VG", G_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC,LIGHT_SAM}, {"RWR_SA2_G_LO", "RWR_SA2_G_LO", "RWR_SA2_G_LAUNCH"})
--SAM SA-3 S-125 "Low Blow" TR              --snr s-125 tr                  --E
add_emitter("snr s-125 tr", E_BAND_RADAR, {LIGHT_REC,LIGHT_REC}, 1.0, {"RWR_SA3_LO"})
--SAM SA-5 S-200 "Square Pair" TR           --RPC_5N62V                     --I
add_emitter("RPC_5N62V", I_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC}, {"RWR_SA5_LO", "RWR_SA5_HI"})
--SAM SA-6 Kub "Straight Flush" STR         --Kub 1S91 str                  --I
add_emitter("Kub 1S91 str", I_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC}, {"RWR_SA6_LO", "RWR_SA6_HI"})
--SAM SA-8 Osa "Gecko" TEL                  --Osa 9A33 ln                   --I
--SAM SA-9 Strela 1 "Gaskin" TEL            --Strela-1 9P31                 --E/F
--SAM SA-10 S-300 "Grumble" Flap Lid TR     --S-300PS 40B6M tr              --H/I/J
--SAM SA-11 Buk "Gadfly" Fire Dome TEL      --SA-11 Buk LN 9A310M1          --H/I
--SAM SA-13 Strela 10M3 "Gopher" TEL        --Strela-10M3                   --F/G
--SAM SA-15 Tor "Gauntlet"                  --Tor 9A331                     --K
--SAM SA-19 Tunguska "Grison"               --2S6 Tunguska                  --H/I

--==========================================================================================
--VEHICLES                                  --EMITTER ID                    --BAND (NATO)
--==========================================================================================
--SPAAA Gepard                              --Gepard                        --E
add_emitter("Gepard", E_BAND_RADAR, 0.7, {LIGHT_REC,LIGHT_REC}, {"RWR_VEHICLE_GEPARD"})
--SPAAA Vulcan M163                         --Vulcan                        --E
add_emitter("Vulcan", E_BAND_RADAR, 0.7, {LIGHT_REC,LIGHT_REC}, {"RWR_VEHICLE_VULCAN"})
--SPAAA ZSU-23-4 Shilka "Gun Dish"          --ZSU-23-4 Shilka               --E
add_emitter("ZSU-23-4 Shilka", E_BAND_RADAR, 0.7, {LIGHT_REC,LIGHT_REC}, {"RWR_VEHICLE_SHILKA"})

--==========================================================================================
--SHIPS                                     --EMITTER ID                    --BAND (NATO)
--==========================================================================================
--Battlecruiser 1144.2 Pyotr Velikiy        --PIOTR
--CG Ticonderoga                            --TICONDEROG
--Corvette 1124.4 Grisha                    --ALBATROS
--Corvette 1241.1 Molniya                   --MOLNIYA
--Cruiser 1164 Moskva                       --MOSCOW
--CV 1143.5 Admiral Kuznetsov               --KUZNECOW
--CV 1143.5 Admiral Kuznetsov(2017)         --CV_1143_5
--CVN-70 Carl Vinson                        --VINSON
--CVN-71 Theodore Roosevelt                 --CVN_71
--CVN-72 Abraham Lincoln                    --CVN_72
--CVN-74 John C. Stennis                    --Stennis
--CVN-73 George Washington                  --CVN_73
--CVN-75 Harry S. Truman                    --CVN_75
--DDG Arleigh Burke IIa                     --USS_Arleigh_Burke_IIa
--FAC La Combattante IIa                    --La_Combattante_II
--FFG Oliver Hazard Perry                   --PERRY
--Frigate 1135M Rezky                       --REZKY
--Frigate 11540 Neustrashimy                --NEUSTRASH
--LHA-1 Tarawa                              --LHA_Tarawa
--Type 052B Destroyer                       --Type_052B
--Type 054A Frigate                         --Type_054A
--Type 052C Destroyer                       --Type_052C

--==========================================================================================
--AIRCRAFT                                  --EMITTER ID                    --BAND (NATO)
--==========================================================================================
--A-50                                      --A-50
--AJS37                                     --AJS37
--AV-8B N/A                                 --AV8BNA
--C-101CC                                   --C-101CC
--C-101EB                                   --C-101EB
--E-2D                                      --E-2C                          --Yes, not a typo!
--E-3A                                      --E-3A
--F-4E                                      --F-4E
--F-5E                                      --F-5E
--F-5E-3                                    --F-5E-3
--F-14A-135GR                               --F-14A
--F-14B                                     --F-14B
--F-15C                                     --F-15C
--F-15E                                     --F-15E
--F-16A                                     --F-16A
--F-16A MLU                                 --F-16A MLU
--F-16C bl.50                               --F-16C bl.50
--F-16C bl.52d                              --F-16C bl.52d
--F-16CM bl.50                              --F-16C_50
--F/A-18A                                   --F/A-18A
--F/A-18C                                   --F/A-18C
--F/A-18C Lot 20                            --FA-18C_hornet
--F-117A                                    --F-117A
--J-11A                                     --J-11A
--JF-17                                     --JF-17
--KJ-2000                                   --KJ-2000
--L-39C                                     --L-39C
--L-39ZA                                    --L-39ZA
--M-2000C                                   --M-2000C
--MiG-15bis                                 --MiG-15bis
--MiG-19P                                   --MiG-19P
--MiG-21Bis                                 --MiG-21Bis
--MiG-23MLD                                 --MiG-23MLD
--MiG-24RBT                                 --MiG-25RBT
--MiG-25PD                                  --MiG-25PD
--MiG-27K                                   --MiG-27K
--MiG-29A                                   --MiG-29A
--MiG-29S                                   --MiG-29S
--MiG-31                                    --MiG-31
--Mirage 2000-5                             --Mirage 2000-5
--Su-17M4                                   --Su-17M4
--Su-24M                                    --Su-24M
--Su-24MR                                   --Su-24MR
--Su-25                                     --Su-25
--Su-25T                                    --Su-25T
--Su-25TM                                   --Su-25TM
--Su-27                                     --Su-27
--Su-30                                     --Su-30
--Su-33                                     --Su-33
--Su-34                                     --Su34
--Tornado GR4                               --Tornado GR4
--Tornado IDS                               --Tornado IDS

--==========================================================================================

band_map = {
    [I_BAND_RADAR] = DASHED,
    [G_BAND_RADAR] = DOTTED,
    [E_BAND_RADAR] = SOLID,
}

fan_song_variant = {}

emitter_pos = {}

launch_timers = {}

function new_apr25_power(value)
    apr25_power = (value == 1.0)
end

function new_apr25_sound_on(value)
    apr25_audio = (value == 1.0)
end

function new_apr25_volume(value)
    apr25_volume = (1.0 + value) / 2.0
end

commands = {
    [device_commands.new_apr25_sound_on] = new_apr25_sound_on,
    [device_commands.new_apr25_volume] = new_apr25_volume,
    [device_commands.new_apr25_power] = new_apr25_power,
}

function SetCommand(command, value)
    --print_message_to_user(command.. " / "..value)
    if commands[command] then
        commands[command](value)
    end
end

function post_initialize()
    print_message_to_user("APR-25 RWR INIT")
end

function get_fan_song_variant(unit_id)
    if fan_song_variant[unit_id] == nil then
        local number = math.mod(math.floor(unit_id / 256.0), 10)
        
        fan_song_variant[unit_id] = number > 3 and "E" or "G"
    end
    return fan_song_variant[unit_id]
end

function get_unit_type(unit_type, unit_id)
    if unit_type == "SNR_75V" then
        unit_type = unit_type .. get_fan_song_variant(unit_id)
    end
    return unit_type
end

function reset_emitter_position(i)
    emitter_pos[i] = { unit_id = nil, r = 0, a= 0 }
end

function update_emitter_position(i, r, a, unit_id)

    if emitter_pos[i] == nil or emitter_pos[i].unit_id ~= unit_id then
        emitter_pos[i] = {
            unit_id = unit_id,
            r = r,
            a = a,
        }
        print_message_to_user(rwr_api:get(i, "unit_type").." ("..rwr_api:get(i, "general_type").."), "..tostring(r)..", "..tostring(a))
    else
        local x1 = emitter_pos[i].r * math.cos(emitter_pos[i].a)
        local y1 = emitter_pos[i].r * math.sin(emitter_pos[i].a)

        local x2 = r * math.cos(a)
        local y2 = r * math.sin(a)

        local x3 = x1 + (x2 - x1) * update_time_step * 1.2
        local y3 = y1 + (y2 - y1) * update_time_step * 1.2

        emitter_pos[i].r = math.sqrt(x3*x3 + y3*y3)
        emitter_pos[i].a = math.atan2(y3, x3)

        --emitter_pos[i].r = emitter_pos[i].r + (r - emitter_pos[i].r) * update_time_step

        --local delta = math.pi - math.abs(math.fmod(a - emitter_pos[i].a, 2.0 * math.pi))
        --emitter_pos[i].a = emitter_pos[i].a + delta * update_time_step
    end
end

function update_lights(i)

end

-- Takes table with signal types and their audio params
function get_closest_priority_sound(audio_table, signal)

    while signal >= SIGNAL_SEARCH and audio_table[signal] == nil do
        signal = signal - 1
    end

    return audio_table[signal]
end

function get_default(general_type, signal, power)

end

function reset_audio()
    for i1,v1 in pairs(emitter_default_sounds) do
        
        if v ~= nil then
            for i2,v2 in ipairs(v) do

                if v2 ~= nil then
                    v2:set(0.0)
                end
            end
        end
    end

    for i1,v1 in pairs(emitter_info) do
        for i2,v2 in ipairs(v1.audio) do
            v2:set(0.0)
        end
    end

end

function trigger_light(lights, signal)
    if lights == nil then
        return
    end

    for i,light in pairs(lights) do
        if light ~= nil and signal >= i then
            apr25_lights[light] = apr25_lights[light] or true
        end
    end
end

function update_for_contact(general_type, type, signal, power)

    power = power * apr25_volume

    local info = emitter_info[type]

    if info then
        audio_param = get_closest_priority_sound(info.audio, signal)
        if audio_param ~= nil then
            audio_param:set(power)
        end

        trigger_light(info.lights, signal)
    else
        if emitter_default_sounds[general_type] ~= nil then
            local audio_param = get_closest_priority_sound(emitter_default_sounds[general_type], signal)
            if audio_param ~= nil then
                audio_param:set(power)
            end
        end
    end
end

function get_radar_band(general_type, type)

    if general_type == GENERAL_TYPE_AIRCRAFT then
        return I_BAND_RADAR, 1.0
    end

    local info = emitter_info[type]
    --print_message_to_user(tostring(unit)..tostring(info.band))

    if info ~= nil then
        return info.band, info.gain
    end

    return NO_BAND, 1.0
end

function should_draw(signal, raw_unit_type, band)

    if apr25_band_enabled[band] == false then
        return false
    end

    if signal ~= SIGNAL_LAUNCH then
        return true
    end

    if raw_unit_type ~= "SNR_75V" then
        return true
    end

    if launch_timers[i] == nil or launch_timers[i] <= 0.0 then
        launch_timers[i] = 0.3
    end

    launch_timers[i] = launch_timers[i] - update_time_step

    if launch_timers[i] < 0.15 then
        return true
    end

    return false
end

function get_power_variation()
    return math.random() * 0.1
end

function get_azimuth_variation()
    return math.random() * 0.05
end

delay = 0

function debug_print()

    for i=1, num_contacts do
        unit = rwr_api:get(i, "unit_type")

        if unit ~= 0 then
            print_message_to_user(unit.." "..rwr_api:get(i, "source"))
        end
    end

    --print_message_to_user("Power: "..tostring(rwr_api:get(1, "power"))) 
    --print_message_to_user("General Type: "..tostring(rwr_api:get(1, "general_type"))) 
    --print_message_to_user("Signal: "..tostring(rwr_api:get(1, "signal"))) 
    --print_message_to_user("Source: "..tostring(rwr_api:get(1, "source"))) 
    --print_message_to_user("Priority: "..tostring(rwr_api:get(1, "priority")))
    --print_message_to_user("Unit type: "..tostring(rwr_api:get(1, "unit_type"))) 
    --print_message_to_user("Time: "..tostring(rwr_api:get(1, "time"))) 
end

function debug_print_delay()
    delay = delay + update_time_step

    if delay < 1.0 then
        return
    end

    delay = 0
    debug_print()
end

function reset_lights()
    for i,v in pairs(apr25_lights) do
        apr25_lights[i] = false
    end
end

function set_lights()
    for i,v in pairs(apr25_lights) do
        apr25_lights_params[i]:set(v and 1 or 0)
    end
end

draw_enabled = false

function update_new()
    --debug_print_delay()

    if draw_enabled then
        rwr_api:reset()
    end

    reset_audio()
    reset_lights()
    
    if not get_elec_aft_mon_ac_ok() or not apr25_power then
        return
    end
    
    --bit_i_band()

    for i=1, num_contacts do

        local power = rwr_api:get(i, "power")
        if power > 0.0 and rwr_api:get(i, "time") < 3.0 then

            local general_type = rwr_api:get(i, "general_type")
            local raw_unit_type = rwr_api:get(i, "unit_type")
            local unit_id = rwr_api:get(i,"source")
            local type = get_unit_type(raw_unit_type, unit_id)
            local signal = rwr_api:get(i, "signal")
            local azimuth = rwr_api:get(i, "azimuth")
            
            update_for_contact(general_type, type, signal, power)

            if draw_enabled then
                update_emitter_position(i, power, azimuth, unit_id) 

                local band, radar_gain = get_radar_band(general_type, type)
                local line_type = band_map[band]

                if line_type ~= nil then

                    power = (emitter_pos[i].r + get_power_variation()) * radar_gain
                    if should_draw(signal, raw_unit_type, band) then
                        rwr_api:set(emitter_pos[i].a + get_azimuth_variation(), power, line_type)
                    end
                end
            end
        elseif draw_enabled then
            reset_emitter_position(i)
        end
    end

    set_lights()
end

function bit(band)
    rwr_api:set(math.rad(45)  + get_azimuth_variation(), 0.8  + get_power_variation(), band)
    rwr_api:set(math.rad(135) + get_azimuth_variation(), 0.8  + get_power_variation(), band)
    rwr_api:set(math.rad(225) + get_azimuth_variation(), 0.8  + get_power_variation(), band)
    rwr_api:set(math.rad(315) + get_azimuth_variation(), 0.8  + get_power_variation(), band)
end

function bit_i_band()
    bit(DASHED)
end

function bit_g_band()
    bit(DOTTED)
end

function bit_e_band()
    bit(SOLID)
end

need_to_be_closed = false -- close lua state after initialization
