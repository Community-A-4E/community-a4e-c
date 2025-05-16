----------------------------------------------------------------
-- RWR/ECM
----------------------------------------------------------------
-- This module will handle the logic for the ALQ-51A, AN/APR-25
-- and AN/APR-27
----------------------------------------------------------------

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."APR-25_RWR/rwr_apr-25_api.lua")
dofile(LockOn_Options.script_path.."sound_params.lua")

device_timer_dt     = 0.02  	--0.2  	
--local update_rate 	= 0.2
MaxThreats          = 9
EmitterLiveTime     = 7.0	

RWR_detection_coeff = 0.85

local dev     = GetSelf()

	eyes ={}	-- RWR sensors

	eyes[1] =
	{
		position      = {x = 5.447,y = -0.376,z =  0.356},--2
		orientation   = {azimuth  = math.rad(45),elevation = math.rad(0.0)},
		field_of_view = math.rad(120) 
	}
	eyes[2] =
	{
		position      = {x = 5.447,y = -0.376,z = -0.357},
		orientation   = {azimuth  = math.rad(-45),elevation = math.rad(0.0)},
		field_of_view = math.rad(120) 
	}
	eyes[3] =
	{
		position      = {x = -10.668,y = 0.836,z =  0.097},
		orientation   = {azimuth  = math.rad(135),elevation = math.rad(0.0)},
		field_of_view = math.rad(120) 
	}
	eyes[4] =
	{
		position      = {x = -10.679,y = 0.875,z =  -0.07},
		orientation   = {azimuth  = math.rad(-135),elevation = math.rad(0.0)},
		field_of_view = math.rad(120) 
	}



maxcontacts = MaxThreats
rwr = 	{}
for i = 1,maxcontacts do	
	rwr[i] = 	{
					signal_h		= get_param_handle("RWR_CONTACT_0" .. i .. "_SIGNAL"),
					power_h			= get_param_handle("RWR_CONTACT_0" .. i .. "_POWER"),
					general_type_h	= get_param_handle("RWR_CONTACT_0" .. i .. "_GENERAL_TYPE"),
				}
				
end


Light = {	
				ECM_TEST	= get_param_handle("ECM_TEST"),
				ECM_GO		= get_param_handle("ECM_GO"),
				ECM_NO_GO	= get_param_handle("ECM_NO_GO"),
				
				ECM_SAM		= get_param_handle("ECM_SAM"),
				ECM_RPT		= get_param_handle("ECM_RPT"),
				ECM_STBY	= get_param_handle("ECM_STBY"),
				ECM_REC		= get_param_handle("ECM_REC"),
}

local ticker=0
local light_ticker = 0
local Launch_played=false
local Lock_played=false

local master_test_param 			= get_param_handle("D_MASTER_TEST")
local rwr_status_light_param	= get_param_handle("RWR_STATUS_LIGHT")
local rwr_status_signal_param	= get_param_handle("RWR_STATUS_SIGNAL")
rwr_status_light_param:set(0)
rwr_status_signal_param:set(0)

local rwr_apr25_power = 0 	--1 = on
local volume_prf = 0		--0-2		--inner
local volume_msl = 0		--0-2		--outer
local prf_audio_state  = 1		---1 = on

local volume_msl_pos = 0
local volume_prf_pos = 0
local rwr_inner_knob_moving = 0 
local rwr_outer_knob_moving = 0 
	
local rwr_apr25_alq_audio = 0
local rwr_apr27_status = 0
local ecm_alq_selector = 0
local ecm_upper_button	= 0
local ecm_lower_button	= 0

local ALQ_WARMUP_TIME = 2 * 60 -- two minutes
local ALQ_MODE = 0	-- 0 => OFF, 1 => STBY, 2 => REC, 3 => RPT

local BIT_TEST_STATE = false
local BIT_TEST_DURATION = 30 -- 28 to 34 seconds
local TIMER_alq_warmup = 0
local TIMER_BIT_TEST = 0

-- intermediate light state for BIT test
local BIT_TEST_REC_LIGHT_STATE = false
local BIT_TEST_RPT_LIGHT_STATE = false
local BIT_TEST_TEST_LIGHT_STATE = false
local BIT_TEST_GO_LIGHT_STATE = false
local BIT_TEST_NOGO_LIGHT_STATE = false

local HIDE_ECM = false


dev:listen_command(device_commands.ecm_apr25_off)
dev:listen_command(device_commands.ecm_apr25_audio)
dev:listen_command(device_commands.ecm_apr27_off)

dev:listen_command(device_commands.ecm_systest_upper)
dev:listen_command(device_commands.ecm_systest_lower)

dev:listen_command(device_commands.ecm_selector_knob)

dev:listen_command(device_commands.ecm_msl_alert_axis_inner)
dev:listen_command(device_commands.ecm_msl_alert_axis_inner_abs)
dev:listen_command(device_commands.ecm_msl_alert_axis_inner_slew)
dev:listen_command(device_commands.ecm_msl_alert_axis_outer)
dev:listen_command(device_commands.ecm_msl_alert_axis_outer_abs)
dev:listen_command(device_commands.ecm_msl_alert_axis_outer_slew)

dev:listen_command(Keys.ecm_apr25_off)
dev:listen_command(Keys.ecm_apr27_off)
dev:listen_command(Keys.ecm_select_cw)
dev:listen_command(Keys.ecm_select_ccw)

dev:listen_command(Keys.ecm_InnerKnobInc)
dev:listen_command(Keys.ecm_InnerKnobDec)
dev:listen_command(Keys.ecm_InnerKnobStartUp)
dev:listen_command(Keys.ecm_InnerKnobStartDown)
dev:listen_command(Keys.ecm_InnerKnobStop)

dev:listen_command(Keys.ecm_OuterKnobInc)
dev:listen_command(Keys.ecm_OuterKnobDec)
dev:listen_command(Keys.ecm_OuterKnobStartUp)
dev:listen_command(Keys.ecm_OuterKnobStartDown)
dev:listen_command(Keys.ecm_OuterKnobStop)

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
        [SIGNAL_SEARCH] = get_param_handle("RWR_AI_SEARCH"), -- 1-second shimmer azimuth sweep
        [SIGNAL_LOCK] = get_param_handle("RWR_AI_GENERAL"), -- Solid tone (I-band)
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
--SAM SA-2/3/5 P19 "Flat Face" SR           --p-19 s-125 sr                 --E/F, ~12s rotation
add_emitter("p-19 s-125 sr", E_BAND_RADAR, 1.0, nil, {"RWR_SA2_SEARCH"})
--SAM SA-5 S-200 ST-68U "Tin Shield" SR     --RLS_19J6                      --E/F, ~12s rotation
add_emitter("RLS_19J6", E_BAND_RADAR, 1.0, nil, {"RWR_SA5_SEARCH"})
--SAM SA-10 S-300 "Grumble" Big Bird SR     --S-300PS 64H6E sr              --E/F, ~12s rotation
add_emitter("S-300PS 64H6E sr", E_BAND_RADAR, 1.0, nil, {"RWR_SA10_SR_BB"})
--SAM SA-10 S-300 "Grumble" Clam Shell SR   --S-300PS 40B6MD sr             --E/F, ~3s rotation
add_emitter("S-300PS 40B6MD sr", E_BAND_RADAR, 1.0, nil, {"RWR_SA10_SR_CS"})
--SAM SA-10 S-300 "Grumble" Tin Shield SR   --S-300PS 40B6MD sr_19J6        --E/F, ~10s rotation
add_emitter("S-300PS 40B6MD sr_19J6", E_BAND_RADAR, 1.0, nil, {"RWR_SA10_SR_TS"})
--SAM SA-11 Buk "Gadfly" Snow Drift SR      --SA-11 Buk SR 9S18M1           --E, ~12s rotation
add_emitter("SA-11 Buk SR 9S18M1", E_BAND_RADAR, 1.0, nil, {"RWR_SA11_SR"})
--SAM NASAMS SR MPQ64F1                     --NASAMS_Radar_MPQ64F1          --H/I

--==========================================================================================
--TRACKING RADARS                           --EMITTER ID                    --BAND (NATO)
--==========================================================================================
--AAA SON Fire Can							--SON_9							--E
add_emitter("SON_9", E_BAND_RADAR, 0.7, {LIGHT_REC}, {"RWR_AAA_FIRECAN_SON9"})
--SAM Avenger (Stinger)                     --M1097 Avenger                 --H/I
--SAM Chaparral M48                         --M48 Chaparral                 --D
--SAM Hawk TR (AN/MPQ-46)                   --Hawk tr                       --J (HPIR), out of band range, no sound
--SAM Linebacker - Bradley M6               --M6 Linebacker                 --H/I
--SAM Rapier Blindfire TR                   --rapier_fsa_blindfire_radar    --F
--SAM SA-2 S-75 "Fan Song" TR               --SNR_75V                       --E/G variants assigned below
add_emitter("SNR_75VE", E_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC,LIGHT_SAM}, {"RWR_SA2_E_LO", "RWR_SA2_E_HI"})
add_emitter("SNR_75VG", G_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC,LIGHT_SAM}, {"RWR_SA2_G_LO", "RWR_SA2_G_LO", "RWR_SA2_G_LAUNCH"})
--SAM SA-3 S-125 "Low Blow" TR              --snr s-125 tr                  --E
add_emitter("snr s-125 tr", E_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC}, {"RWR_SA3_LO"})
--SAM SA-5 S-200 "Square Pair" TR           --RPC_5N62V                     --I
add_emitter("RPC_5N62V", I_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC}, {"RWR_SA5_LO", "RWR_SA5_HI"})
--SAM SA-6 Kub "Straight Flush" STR         --Kub 1S91 str                  --I
add_emitter("Kub 1S91 str", I_BAND_RADAR, 1.0, {LIGHT_REC,LIGHT_REC}, {"RWR_SA6_LO", "RWR_SA6_HI"})
--SAM SA-8 Osa "Gecko" TEL                  --Osa 9A33 ln                   --I
add_emitter("Osa 9A33 ln", I_BAND_RADAR, 0.7, {LIGHT_REC}, {"RWR_SA8_TR"})
--SAM SA-9 Strela 1 "Gaskin" TEL            --Strela-1 9P31                 --passively informed, no sound
--SAM SA-10 S-300 "Grumble" Flap Lid-A TR   --S-300PS 40B6M tr              --H/I/J
add_emitter("S-300PS 40B6M tr", I_BAND_RADAR, 1.0, {LIGHT_REC}, {"RWR_SA10_TR_A"})
--SAM SA-10 S-300 "Grumble" Flap Lid-B TR   --S-300PS 5H63C 30H6_tr         --H/I/J
add_emitter("S-300PS 5H63C 30H6_tr", I_BAND_RADAR, 1.0, {LIGHT_REC}, {"RWR_SA10_TR_B"})
--SAM SA-11 Buk "Gadfly" Fire Dome TEL      --SA-11 Buk LN 9A310M1          --H/I
add_emitter("SA-11 Buk LN 9A310M1", I_BAND_RADAR, 1.0, {LIGHT_REC}, {"RWR_SA11_TR"})
--SAM SA-13 Strela 10M3 "Gopher" TEL        --Strela-10M3                   --F/G
add_emitter("Strela-10M3", I_BAND_RADAR, 0.7, {LIGHT_REC}, {"RWR_SA13_TR"})
--SAM SA-15 Tor "Gauntlet"                  --Tor 9A331                     --K, out of band range, so no sound
--SAM SA-19 Tunguska "Grison"               --2S6 Tunguska                  --J
add_emitter("2S6 Tunguska", I_BAND_RADAR, 0.7, {LIGHT_REC}, {"RWR_SA19_TR"})

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
add_emitter("A-50", E_BAND_RADAR, 1.0, nil, {"RWR_EWR"})
--AJS37                                     --AJS37
--AV-8B N/A                                 --AV8BNA
--C-101CC                                   --C-101CC
--C-101EB                                   --C-101EB
--E-2D                                      --E-2C                          --Yes, not a typo!
add_emitter("E-2C", E_BAND_RADAR, 1.0, nil, {"RWR_EWR"})
--E-3A                                      --E-3A
add_emitter("E-3A", E_BAND_RADAR, 1.0, nil, {"RWR_EWR"})
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

-- Takes table with signal types and their audio params
function get_closest_priority_sound(audio_table, signal)

    while signal >= SIGNAL_SEARCH and audio_table[signal] == nil do
        signal = signal - 1
    end

    return audio_table[signal]
end

function reset_audio()
    for i1,v1 in pairs(emitter_default_sounds) do
        
        if v1 ~= nil then
            for i2,v2 in ipairs(v1) do

                if v2 ~= nil then
                    v2:set(0.0)
                end
            end
        end
    end

    for i1,v1 in pairs(emitter_info) do
        for i2,v2 in ipairs(v1.audio) do
			if v2 ~= nil then
            	v2:set(0.0)
			end
        end
    end

end

function trigger_light(lights, signal)
    if lights == nil then
        return
    end

    for i,light in pairs(lights) do
        if light ~= nil and signal >= i then
			local light_on = true
			if light == LIGHT_SAM then
				light_on = light_on and (rwr_apr27_status == 1)
			end
            apr25_lights[light] = (apr25_lights[light]) or light_on
        end
    end
end

function update_for_contact(general_type, type, signal, power)

    power = calculate_volume(power * volume_prf)

    local info = emitter_info[type]

	--print_message_to_user(type)

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

			if general_type ~= GENERAL_TYPE_EWR then
				trigger_light({nil,LIGHT_REC}, signal)
			end
        end
    end
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

function update_new()
    --debug_print_delay()

    reset_audio()
    reset_lights()

	sound_params.snd_alws_rwr_hum:set(0)
	sound_params.snd_cont_rwr_msl_volume:set(volume_msl)
	
    if not get_elec_aft_mon_ac_ok() or rwr_apr25_power ~= 1 or ALQ_MODE <= 1 or not ALQ_READY then
        return
    end

	if ALQ_MODE >= 2 then
		sound_params.snd_alws_rwr_hum:set(volume_prf*0.6)
	end

	if BIT_TEST_STATE then
		if BIT_TEST_REC_LIGHT_STATE then
			update_for_contact(GENERAL_TYPE_SURFACE, "ZSU-23-4 Shilka", SIGNAL_LOCK, 1.0)
	end
	else

		--temporary test launch signal
		--update_for_contact(GENERAL_TYPE_SURFACE, "SNR_75VG", SIGNAL_LAUNCH, volume_msl)

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
			end
		end

	end
    set_lights()
end


local ECM_vis_param = get_param_handle("ECM_VIS")

local function hideECMPanel(hideECM)
    if hideECM == 1 then
        local ECM_CLICKABLES = {"PNT_503", "PNT_504", "PNT_501", "PNT_507", "PNT_510", "PNT_506", "PNT_505", "PNT_502"}
        ECM_vis_param:set(1)
        for i = 1, #ECM_CLICKABLES, 1 do
            local clickable_ref = get_clickable_element_reference(ECM_CLICKABLES[i])
            clickable_ref:hide(0)
        end
    end
end

function calculate_volume(value)
	return LinearTodB(((round(value,2))+1)*0.5)
end

function post_initialize()

	HIDE_ECM = get_aircraft_property("HideECMPanel")

	-------------------------------------
	-- BIRTH INITIALIZATION CODE
	-------------------------------------
	local birth = LockOn_Options.init_conditions.birth_place
	-- TODO Init code for HOT STARTS
	if birth=="GROUND_HOT" or birth=="AIR_HOT" then
		-- skip ALQ Warmup, place ALQ in standby mode
		ALQ_READY = true
		dev:performClickableAction(device_commands.ecm_selector_knob, 0.33) -- ALQ-51A in STBY MODE
		-- Initialise position of knobs
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_inner, 0) -- Volume knobs at 50%
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_outer, 0) -- Volume knobs at 50%
		
    elseif birth=="GROUND_COLD" then
		-- Initialise position of knobs
		dev:performClickableAction(device_commands.ecm_selector_knob, 0.0) -- ALQ-51A in OFF MODE
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_inner, -1) -- volume off
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_outer, -1) -- volume off
    end
	

end
---------------------------------
function SetCommand(command,value)
		--print_message_to_user(command .. " / " ..value)
	
	-----------------
	-- keys
	-----------------
	if command == Keys.ecm_apr25_off then
		dev:performClickableAction((device_commands.ecm_apr25_off), ((rwr_apr25_power * -1) +1), false) -- currently off, so enable pylon
	elseif command == Keys.ecm_apr27_off then
		dev:performClickableAction((device_commands.ecm_apr27_off), ((rwr_apr27_status * -1) +1), false)
	-- plusnine mode selector - could be more efficient, but it works.
	elseif command == Keys.ecm_select_cw then
		if ALQ_MODE == 0 then
			dev:performClickableAction(device_commands.ecm_selector_knob, 0.33)
		elseif ALQ_MODE == 1 then
			dev:performClickableAction(device_commands.ecm_selector_knob, 0.66)
		elseif ALQ_MODE == 2 then
			dev:performClickableAction(device_commands.ecm_selector_knob, 0.99)
		end
	elseif command == Keys.ecm_select_ccw then
		if ALQ_MODE == 3 then
			dev:performClickableAction(device_commands.ecm_selector_knob, 0.66)
		elseif ALQ_MODE == 2 then
			dev:performClickableAction(device_commands.ecm_selector_knob, 0.33)
		elseif ALQ_MODE == 1 then
			dev:performClickableAction(device_commands.ecm_selector_knob, 0.00)
		end
	--PRF VOLUME
	elseif command == Keys.ecm_InnerKnobInc then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_inner, clamp(volume_prf_pos + 0.05, -0.9, 0.9))
	elseif command == Keys.ecm_InnerKnobDec then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_inner, clamp(volume_prf_pos - 0.05, -0.9, 0.9))
	elseif command == Keys.ecm_InnerKnobStartUp then
		rwr_inner_knob_moving = 1/100
	elseif command == Keys.ecm_InnerKnobStartDown then
		rwr_inner_knob_moving = -1/100
	elseif command == Keys.ecm_InnerKnobStop then
		rwr_inner_knob_moving = 0
	--MSL ALERT VOLUME
	elseif command == Keys.ecm_OuterKnobInc then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_outer, clamp(volume_msl_pos + 0.10, -0.9, 0.9))
	elseif command == Keys.ecm_OuterKnobDec then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_outer, clamp(volume_msl_pos - 0.10, -0.9, 0.9))
	elseif command == Keys.ecm_OuterKnobStartUp then
		rwr_outer_knob_moving = 1/100
	elseif command == Keys.ecm_OuterKnobStartDown then
		rwr_outer_knob_moving = -1/100
	elseif command == Keys.ecm_OuterKnobStop then
		rwr_outer_knob_moving = 0
	end

	-----------------
	-- clickable	
	-----------------
	if command == device_commands.ecm_apr25_off then
		rwr_apr25_power = value
		
	-- APR-25/ALQ audio toggle switch
	elseif command == device_commands.ecm_apr25_audio then
		rwr_apr25_alq_audio = value
		-- no audible change between ALQ and APR-25 for now as no information about audio tones for ALQ.
		-- assume that audio tones are the same
		-- if rwr_apr25_alq_audio == 1 then -- ALQ
		-- 	prf_audio_state = 1
		-- elseif rwr_apr25_alq_audio == 0 then -- APR-25
		-- 	prf_audio_state = 1
		-- end
			
	-- APR-27 Power Toggle Switch
	elseif command == device_commands.ecm_apr27_off then
		rwr_apr27_status = value

	-- PRF Volume Knob
	elseif command == device_commands.ecm_msl_alert_axis_inner then
		volume_prf = clamp((value+0.9)*0.5/0.9,0,1)
		volume_prf_pos = value
	elseif command == device_commands.ecm_msl_alert_axis_inner_abs then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_inner, value*0.9)
	elseif command == device_commands.ecm_msl_alert_axis_inner_slew then
		if value < 0.001 and value > -0.001 then
            rwr_inner_knob_moving = 0
        else
            rwr_inner_knob_moving = value/50
        end

	-- MSL Volume Knob			
	elseif command == device_commands.ecm_msl_alert_axis_outer then
		volume_msl = clamp((value+0.9)*0.5/0.9,0,1)
		volume_msl_pos = value
	elseif command == device_commands.ecm_msl_alert_axis_outer_abs then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_outer, value*0.9)
	elseif command == device_commands.ecm_msl_alert_axis_outer_slew then
		if value < 0.001 and value > -0.001 then
            rwr_outer_knob_moving = 0
        else
            rwr_outer_knob_moving = value/50
        end
	
	-- ALQ Rotary Control Switch
	elseif command == device_commands.ecm_selector_knob then
		local ecm_alq_selector = round(value, 2)

		-- cancel BIT Test if ALQ mode is changed
		if BIT_TEST_STATE then
			stop_bit_test()
		end

		-- update ALQ mode based on selector position
		if ecm_alq_selector == 0.0 then
			ALQ_MODE = 0 -- OFF
		elseif ecm_alq_selector == 0.33 then
			ALQ_MODE = 1 -- STBY
		elseif ecm_alq_selector == 0.66 then
			ALQ_MODE = 2 -- REC
		elseif ecm_alq_selector == 0.99 then
			ALQ_MODE = 3 -- RPT
		end

	-- Upper button on the ECM Panel
	elseif command == device_commands.ecm_systest_upper then
		ecm_upper_button = value
		-- print_message_to_user("Test Button: "..value)

		if value == 1  and ALQ_MODE == 2 and ALQ_READY then -- ALQ is in REC mode
			-- start bit test if test is not running
			if not BIT_TEST_STATE then
				-- print_message_to_user("BIT TEST STARTED")
				TIMER_BIT_TEST = 0
				BIT_TEST_STATE = true
				BIT_TEST_TEST_LIGHT_STATE = true
				BIT_TEST_REC_LIGHT_STATE = true
			else
				stop_bit_test()
			end
		end

	-- Lower button on ECM Panel
	elseif command == device_commands.ecm_systest_lower then
		ecm_lower_button = value

	end

end

function update()
	
	hideECMPanel(HIDE_ECM)
	
	if HIDE_ECM == 1 then -- if ECM is removed from cockpit. Skip ECM code.
		return
	end
	
--	if (get_elec_mon_dc_ok()) and rwr_apr25_power == 1 then
	
	if get_elec_aft_mon_ac_ok() == true then
		GetDevice(devices.RWR):set_power(true)		
	else
		GetDevice(devices.RWR):set_power(false)
	end
	
	update_new()
	
    if rwr_inner_knob_moving ~= 0 then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_inner, clamp(volume_prf_pos + rwr_inner_knob_moving,-0.9,0.9))
    end

	if rwr_outer_knob_moving ~= 0 then
		dev:performClickableAction(device_commands.ecm_msl_alert_axis_outer, clamp(volume_msl_pos + rwr_outer_knob_moving,-0.9,0.9))
    end

	update_ALQ()
	alq_bit_test()
end

function update_ALQ()

	rwr_api:set_ecm(false)

	if get_elec_aft_mon_ac_ok() == true then

		alq_warm_up()

		-- print_message_to_user("ALQ READY: "..tostring(ALQ_READY))

		if master_test_param:get() == 1 then
			Light.ECM_RPT:set(1)
			Light.ECM_SAM:set(1)
			Light.ECM_REC:set(1)
			Light.ECM_STBY:set(1)
			Light.ECM_TEST:set(1)
			Light.ECM_GO:set(1)
			Light.ECM_NO_GO:set(1)

		elseif ALQ_MODE == 0 then -- ALQ OFF
			-- reset warmup timer and ready mode
			TIMER_alq_warmup = 0
			ALQ_READY = false

			-- all lights should be off when ALQ is OFF
			Light.ECM_RPT:set(0)
			Light.ECM_SAM:set(0)
			Light.ECM_REC:set(0)
			Light.ECM_STBY:set(0)
			Light.ECM_TEST:set(0)
			Light.ECM_GO:set(0)
			Light.ECM_NO_GO:set(0)

		elseif ALQ_MODE == 1 then -- ALQ STBY
			-- check if warmup time has passed
			if ALQ_READY then
				Light.ECM_STBY:set(0)
				Light.ECM_SAM:set(0)
				Light.ECM_REC:set(0)
				Light.ECM_RPT:set(0)
				Light.ECM_TEST:set(0)
				Light.ECM_GO:set(0)
				Light.ECM_NO_GO:set(0)
			else
				Light.ECM_STBY:set(1)
				Light.ECM_SAM:set(0)
				Light.ECM_REC:set(0)
				Light.ECM_RPT:set(0)
				Light.ECM_TEST:set(0)
				Light.ECM_GO:set(0)
				Light.ECM_NO_GO:set(0)
			end

		elseif ALQ_MODE == 2 then -- ALQ REC
			if not ALQ_READY then
				Light.ECM_STBY:set(1)
				Light.ECM_SAM:set(0)
				Light.ECM_REC:set(0)
				Light.ECM_RPT:set(0)
				Light.ECM_TEST:set(0)
				Light.ECM_GO:set(0)
				Light.ECM_NO_GO:set(0)

			elseif not BIT_TEST_STATE then
				Light.ECM_STBY:set(0)
				Light.ECM_RPT:set(0)
				Light.ECM_TEST:set(0)
				Light.ECM_GO:set(0)
				Light.ECM_NO_GO:set(0)

			elseif BIT_TEST_STATE then

				if BIT_TEST_RPT_LIGHT_STATE then
					Light.ECM_RPT:set(1)
				else
					Light.ECM_RPT:set(0)
				end
				
				if BIT_TEST_REC_LIGHT_STATE then
					Light.ECM_REC:set(1)
				else
					Light.ECM_REC:set(0)
				end
				
				if BIT_TEST_TEST_LIGHT_STATE then
					Light.ECM_TEST:set(1)
				else
					Light.ECM_TEST:set(0)
				end

				if BIT_TEST_GO_LIGHT_STATE then
					Light.ECM_GO:set(1)
				else
					Light.ECM_GO:set(0)
				end

				if BIT_TEST_NOGO_LIGHT_STATE then
					Light.ECM_NO_GO:set(1)
				else
					Light.ECM_NO_GO:set(0)
				end

				Light.ECM_STBY:set(0)
				Light.ECM_SAM:set(0)
			end



		elseif ALQ_MODE == 3 then -- ALQ RPT
			-- check if warmup time has passed
			if not ALQ_READY then
				Light.ECM_STBY:set(1)
				
			elseif not BIT_TEST_STATE then
			-- turn on REC and RPT light if radar lock detected
				if apr25_lights[LIGHT_REC] then
					Light.ECM_RPT:set(1)
					rwr_api:set_ecm(true)
				else
					Light.ECM_RPT:set(0)
					rwr_api:set_ecm(false)
				end

				Light.ECM_STBY:set(0)
				Light.ECM_TEST:set(0)
				Light.ECM_GO:set(0)
				Light.ECM_NO_GO:set(0)

			elseif BIT_TEST_STATE then
				stop_bit_test()
			end

		else
			-- log error message
		end
	else
		Light.ECM_RPT:set(0)
		Light.ECM_SAM:set(0)
		Light.ECM_REC:set(0)
		Light.ECM_STBY:set(0)
		Light.ECM_TEST:set(0)
		Light.ECM_GO:set(0)
		Light.ECM_NO_GO:set(0)
	end

	
end

function alq_warm_up()
	-- check if warmup time has passed
	if not ALQ_READY and (TIMER_alq_warmup < ALQ_WARMUP_TIME) then
		TIMER_alq_warmup = TIMER_alq_warmup + device_timer_dt
		ALQ_READY = false
	elseif not ALQ_READY then
		ALQ_READY = true
	end
end


function alq_bit_test()
	if ALQ_MODE == 2 and ALQ_READY then
		-- update test state if test is running
		if BIT_TEST_STATE then
			-- One second after REC light comes on, RPT light flashes three times 
			-- (1-second time interval between flashes)
			if (TIMER_BIT_TEST > 1.0 and TIMER_BIT_TEST < 1.5) or
			(TIMER_BIT_TEST > 2.0 and TIMER_BIT_TEST < 2.5) or
			(TIMER_BIT_TEST > 3.0 and TIMER_BIT_TEST < 3.5) then
				BIT_TEST_RPT_LIGHT_STATE = true
			else
				BIT_TEST_RPT_LIGHT_STATE = false
			end

			-- GO light comes on 28-34 seconds after start of test
			if TIMER_BIT_TEST > BIT_TEST_DURATION then
				BIT_TEST_GO_LIGHT_STATE = true
			end

			-- Audio tone ceases, REC light goes off in ~5 seconds after end of BIT TEST
			if TIMER_BIT_TEST > (BIT_TEST_DURATION + 5) then
				BIT_TEST_REC_LIGHT_STATE = false
			end

			TIMER_BIT_TEST = TIMER_BIT_TEST + device_timer_dt
			-- print_message_to_user(TIMER_BIT_TEST)
		end
	end
end

function stop_bit_test()
	-- print_message_to_user("BIT TEST STOPPED")
	BIT_TEST_STATE = false
	BIT_TEST_REC_LIGHT_STATE = false
	BIT_TEST_RPT_LIGHT_STATE = false
	BIT_TEST_TEST_LIGHT_STATE = false
	BIT_TEST_GO_LIGHT_STATE = false
	BIT_TEST_NOGO_LIGHT_STATE = false
end

need_to_be_closed = false -- close lua state after initialization

--[[
devices.lua
device_init.lua
Systems/rwr.lua
]]--

--[[
BIT TEST
1. Turn control switch to STBY. STBY light will come on and goes off after warmup time delay of 2 minutes
2. Turn control switch to REC after warmup
3. Depress and then release TEST switch
4. Verify TEST and REC lights come on. Audio tone is present. (What is this audio tone?)
5. One second after REC light comes on, RPT light flashes three times (1-second time interval between flashes)
6. GO or NO GO light comes on 28~34 seconds after TEST light comes on
7. Audio tone ceases, REC light goes off in ~5 seconds
8. Depress TEST switch (TEST light off) to return system to normal
]]
