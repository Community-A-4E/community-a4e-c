dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."sound_class.lua")

local SOUND_SYSTEM = GetSelf()
local update_time_step = 0.02  --20 time per second
make_default_activity(update_time_step)
device_timer_dt     = 0.02  	--0.2

local sensor_data = get_base_data()

function debug_print(message)
    -- print_message_to_user(message)
end

-- params
local param_catapult_takeoff = get_param_handle("SOUND_CAT_TAKEOFF")

local sounds

function post_initialize()    
    -- initialise soundhosts
    sndhost_cockpit             = create_sound_host("COCKPIT","2D",0,0,0) -- submix to DCS "In Cockpit" volume
    sndhost_headphones          = create_sound_host("HEADPHONES","HEADPHONES",0,0,0) -- submix to DCS "Helmet" volume

	--[[
  		= = = = = = = = = = = = = = = = = = = = = = = = =
        SOUND DEFINITION FILES AND ASSETS
  		= = = = = = = = = = = = = = = = = = = = = = = = =

        Localiztion, volume, and other imporant variables are set in the sdefs, see:
        /Sounds/sdef/Aircrafts/A-4E-C

        To avoid distracting binaural processing issues,
        for example, the sound occasionally only being heard in only one ear,
        be sure to set any engine sounds as originating well behind the pilot's head.

        In-cockpit sound assets are placed in: 
        /Sounds/Effects/Aircrafts/A-4E-C

   		= = = = = = = = = = = = = = = = = = = = = = = = =
		WARNING! WARNING! WARNING! WARNING! WARNING! 
		= = = = = = = = = = = = = = = = = = = = = = = = =
		DO NOT COPY OR USE THESE SOUNDS IN YOUR PROJECTS
		= = = = = = = = = = = = = = = = = = = = = = = = =
		
        The A-4E-C team purchased and licensed some assets 
        to use in the creation of our engine sounds.
		While many parts of this project are open source, 
		these sounds are not. 

		While they are significantly transformed 
		from their original sources, taking these sounds 
		for use in your own project is theft: 
		not from the Community A-4E-C project, 
		but from the original licensors of the source material.

		Distributing these sounds puts YOU in legal jeopardy 
		should the licensors of the original assets find out,
		and rest assured, there are entire teams of people 
		whose entire livelihood is chasing theives down
		and making them pay (in spades). 

		The Community A-4E-C project is not reponsible 
		for your copyright infringement.

  		= = = = = = = = = = = = = = = = = = = = = = = = =
        ENGINE SOUNDS
  		= = = = = = = = = = = = = = = = = = = = = = = = =

        Loud, large-frequency spectrum sounds can easily damage your hearing.
        Be mindful of how loud you set sounds like this.
        Be mindful of how loud you set your volume in DCS World.
        Take regular breaks to give your ears and your brain a break.

        The engine has two signature tones, with a baseline curve across RPM.
        
        a LOW tone: 
        curve = {0.30, 0.61, 0.85, 1.00, 1.04, 1.09, 1.13},
        
        and a HIGH tone:
        curve = {0.30, 0.61, 0.85, 0.99, 1.10, 1.21, 1.33},

        These sounds are listed in the order they become audible 
        as the engine starts up and moves toward taxi and takeoff.
        Gain volumes are set quite high, as this assists in drowning out
        the default SU-25T engine sound scheme. DCS' sound engine 
        prevents any digital clipping by automatically lowering the mix 
        of lower-gain sounds, so in addition to volume, this variable 
        should also be thought of as a kind of priority.

        Interior mixing is less smooth and creates more pilot-significance.
        Special attention should be paid so important engine-start-up events or
        other performance changes in the air can be detected by sound.

        In order to maintain consistency when the pilot opens the canopy, 
		asset signature frequencies and pitch curves should be replicated 
		on the exterior sound set, see: 
        /Sounds/Sounders/Aircraft/Engines/Engine.lua

        = = = = = = = = = = = = = = = = = = = = = = = = =
        SOUNDS LINKED FROM ELSEWHERE
  		= = = = = = = = = = = = = = = = = = = = = = = = =

        A few systems play their own sounds outside this sound system, 
        for example, the sidewinder and shrike seeker head audio sets. 
        this is so their tone information can be driven by code elsewhere.

        = = = = = = = = = = = = = = = = = = = = = = = = =
        INTERPRETING ASSETS AND SDEFS
  		= = = = = = = = = = = = = = = = = = = = = = = = =

        Ensure engine sounds originate at least 1.5 meteers  
        from behind the pilot head position. This prevents sounds
        jumping from one ear to the other.

  		= = = = = = = = = = = = = = = = = = = = = = = = =

    ]]

    -- ENGINE WIND 
    -- The turbine is winding.
    -- This is one of the first sounds to be heard after the valve opens. 
    -- It's fairly neutral in tone.
    engine_wind_pitch = {
        curve = {0.30, 0.61, 0.85, 0.99, 1.07, 1.14, 1.21},
        min = 1.0,
        max = 100.0,
    }
    engine_wind_volume = {
        --curve = {0.00, 0.61, 0.71, 0.85, 0.97, 0.99, 1.00},
        curve = {0.00, 3.60, 4.25, 4.75, 5.00, 5.50, 6.00},
        min = 1.0,
        max = 100.0,
    }
    -- ENGINE TONE (LOW) 
    -- This is one of the first sounds to be heard after the valve opens. 
    -- It's the primary signature tone of the aircraft heard in the cockpit.
    -- The baseline is used to align the pitch engine samples before hand-tuning each one.
    engine_low_pitch = {
        curve = {0.30, 0.61, 0.85, 1.00, 1.04, 1.09, 1.13},
        min = 1.0,
        max = 100.0,
    }
    engine_low_volume = {
        curve = {0.00, 3.60, 4.25, 5.10, 6.00, 7.00, 8.00},
        min = 1.0,
        max = 100.0,
    }
    -- ENGINE ROAR 
    -- Combustion is occurring and thrust is being generated.
    -- It can be heard once the fuel ignites, around 11-15% RPM.
    -- It's a dull low roar.
    engine_roar_pitch = {
        curve = {0.46, 0.61, 0.83, 1.08},
        min = 1.0,
        max = 100.0,
    }
    engine_roar_volume = {
        curve = {0.00, 0.01, 0.04, 0.30},
        min = 11.0,
        max = 100.0,
    }
    -- ENGINE TONE (HIGH) 
    -- Fuel is ignited, the engine approaches power stability.
    -- This tone is a high-pitched whine, and is a signature in high-power operation.
    -- It's tuning has been exaggerated slightly from the baseline.
    -- This is to provide aggression and more meaningful feedback for throttle operation.
    engine_high_pitch = {
        curve = {0.30, 0.61, 0.85, 0.99, 1.10, 1.21, 1.33},
        min = 1.0,
        max = 100.0,
    }
    engine_high_volume = {
        curve = {0.00, 0.30, 0.60, 1.50},
        min = 22.0,
        max = 100.0,
    }
    -- ENGINE GROWL
    -- The engine is power-stable and can be throttled.
    -- This tone is an quiet, yet emergent, fuzzy groan.
    -- It provides sonic complexity to the engine.
    -- It is heard primarily during takeoff to help signify a throttle down or other loss of RPM.
    -- In the air, it tends to get buried by the wind.
    engine_growl_pitch = {
        curve = {0.20, 0.20, 0.20, 0.60, 0.72, 0.85},
        min = 1.0,
        max = 100.0,
    }
    engine_growl_volume = {
        curve = {0.00, 0.03, 0.06, 0.20, 0.40},
        min = 22.0,
        max = 100.0,
    }
    -- WIND RUSHING
    -- The aircraft is moving at speed and air is deforming around against the cockpit glass.
    -- This is a mostly high-frequency white-noise with an occasional 'whipping' shift.
    -- It provides audio feedback in response to the aircraft's speed, as opposed to RPM.
    -- This sound is heard during takeoff/landing, and other significant changes in airspeed.
    -- Airspeed min/max declarations below are made in m/s.
    wind_rushing_pitch = {
        curve = {0.50, 0.75, 1.25, 1.50},
        min = 16.0,
        max = 225.0,
    }
    wind_rushing_volume = {
        curve = {0.00, 1.00, 3.50, 5.50, 7.00},
        min = 18.0,
        max = 200.0,
    }

    sounds = {
        --DEBUG TEST SOUNDS
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a4e-debugtest05", "SND_CONT_TEST_05", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a4e-debugtest10", "SND_CONT_TEST_10", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a4e-debugtest15", "SND_CONT_TEST_15", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a4e-debugtest20", "SND_CONT_TEST_20", SOUND_CONTINUOUS),

        --AIRFLOW ADDITIVES
        --adjustable surfaces
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_AirflowSpoiler", "FM_SPOILERS", SOUND_ALWAYS, 18.0, 51.5),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_AirflowFlaps", "FM_FLAPS", SOUND_ALWAYS, 18.0, 51.5),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_AirflowSpeedbrake", "FM_BRAKES", SOUND_ALWAYS, 26.0, 77.0),
        --gear
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_AirflowGear_C", "FM_GEAR_NOSE", SOUND_ALWAYS, 20.5, 62.0),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_AirflowGear_L", "FM_GEAR_LEFT", SOUND_ALWAYS, 20.5, 62.0),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_AirflowGear_R", "FM_GEAR_RIGHT", SOUND_ALWAYS, 20.5, 62.0),
        --skid
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitTireSkidL", "SKID_L_DETECTOR", SOUND_CONTINUOUS_STOPABLE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitTireSkidR", "SKID_R_DETECTOR", SOUND_CONTINUOUS_STOPABLE),
        --ENVIRONMENTAL
        --damage
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_DamageGearOverspeed", "SND_INST_DAMAGE_GEAR_OVERSPEED", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitStructuralDamage", "SND_ALWS_DAMAGE_AIRFRAME_STRESS", SOUND_ALWAYS, nil, nil, 4.0, 1.0),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitStructuralDamageStrain", "SND_ALWS_DAMAGE_AIRFRAME_STRESS", SOUND_ALWAYS, nil, nil, 3.0, 1.0),
        --engine
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitAvionics", "SND_INST_AVIONICS_WHINE", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineIgniterWhirr", "SND_INST_ENGINE_IGNITER_WHIRR", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineIgniterSpark", "SND_ALWS_ENGINE_IGNITER_SPARK", SOUND_ALWAYS, nil, nil, 1.0, 0.1),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineWindUp", "SND_INST_ENGINE_WIND_UP", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineWindDown", "SND_INST_ENGINE_WIND_DOWN", SOUND_ONCE),

        Sound_Player.new_always_controlled(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineWindConstant", "RPM", engine_wind_volume, engine_wind_pitch),
        Sound_Player.new_always_controlled(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineOperationLo", "RPM", engine_low_volume, engine_low_pitch),
        Sound_Player.new_always_controlled(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineOperationHi", "RPM", engine_high_volume, engine_high_pitch),
        Sound_Player.new_always_controlled(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineGrowl", "RPM", engine_growl_volume, engine_growl_pitch),
        Sound_Player.new_always_controlled(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineRoar", "RPM", engine_roar_volume, engine_roar_pitch),
        Sound_Player.new_always_controlled(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitWindRushing", "SOUND_TRUE_AIRSPEED", wind_rushing_volume, wind_rushing_pitch),

        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_EngineCompressorStall", "SND_INST_ENGINE_STALL", SOUND_CONTINUOUS),
        --gear pod doors
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearPodClose_L", "SND_INST_L_GEAR_POD_CLOSE", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearPodOpen_L", "SND_INST_L_GEAR_POD_OPEN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearPodClose_R", "SND_INST_R_GEAR_POD_CLOSE", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearPodOpen_R", "SND_INST_R_GEAR_POD_OPEN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearPodClose_C", "SND_INST_C_GEAR_POD_CLOSE", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearPodOpen_C", "SND_INST_C_GEAR_POD_OPEN", SOUND_ONCE),
        --gear pod travel end
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearEndIn_L", "SND_INST_L_GEAR_END_IN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearEndOut_L", "SND_INST_L_GEAR_END_OUT", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearEndIn_R", "SND_INST_R_GEAR_END_IN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearEndOut_R", "SND_INST_R_GEAR_END_OUT", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearEndIn_C", "SND_INST_C_GEAR_END_IN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearEndOut_C", "SND_INST_C_GEAR_END_OUT", SOUND_ONCE),
        --rattle and rumble
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitRumble", "SND_ALWS_COCKPIT_RUMBLE", SOUND_ALWAYS, nil, nil, 1.0, 2.0 / device_timer_dt ),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitRattle", "SND_ALWS_COCKPIT_RATTLE", SOUND_ALWAYS, nil, nil, 1.0, 2.0 / device_timer_dt ),
        --refuelingb
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitRefuel", "SND_CONT_FUEL_INTAKE", SOUND_CONTINUOUS),
        --slats
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitSlatsLeftIn", "SND_INST_L_SLAT_IN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitSlatsLeftOut", "SND_INST_L_SLAT_OUT", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitSlatsRightIn", "SND_INST_R_SLAT_IN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitSlatsRightOut", "SND_INST_R_SLAT_OUT", SOUND_ONCE),
        --wheels
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitTouchdownN", "SND_INST_WHEELS_TOUCHDOWN_N", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitTouchdownL", "SND_INST_WHEELS_TOUCHDOWN_L", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitTouchdownR", "SND_INST_WHEELS_TOUCHDOWN_R", SOUND_ONCE),

        --HYDRAULICS
        --canopy
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsCanopyOpenMove", "SND_CONT_CANOPY_MOV_OPEN", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsCanopyCloseMove", "SND_CONT_CANOPY_MOV_CLOSE", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsCanopyCloseStop", "SND_INST_CANOPY_CLOSE_STOP", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsCanopyOpenStop", "SND_INST_CANOPY_OPEN_STOP", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsCanopyOpenSeal", "SND_INST_CANOPY_MOV_SEAL_OPEN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsCanopyCloseSeal", "SND_INST_CANOPY_MOV_SEAL_CLOSE", SOUND_ONCE),
        --seat
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsSeatMove", "SND_CONT_SEAT_MOVE", SOUND_CONTINUOUS),
        --flaps
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsFlapsMove", "SND_CONT_FLAPS_MOVE", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsFlapsStop", "SND_INST_FLAPS_STOP", SOUND_ONCE),
        --gear
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearMove", "SND_CONT_GEAR_MOV", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsGearStop", "SND_INST_GEAR_STOP", SOUND_ONCE),
        --guns
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_GunsChargeL", "SND_INST_GUNS_CHARGE_L", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_GunsChargeR", "SND_INST_GUNS_CHARGE_R", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_GunsSafeL", "SND_INST_GUNS_SAFE_L", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_GunsSafeR", "SND_INST_GUNS_SAFE_R", SOUND_ONCE),
        --supplemental
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitEmerSpeedbrakeIn", "SND_INST_EMER_SPEEDBRAKE_IN", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_CockpitEmerSpeedbrakeOut", "SND_INST_EMER_SPEEDBRAKE_OUT", SOUND_ONCE),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsSpeedbrakeMove", "SND_CONT_HYD_MOV", SOUND_CONTINUOUS),
        Sound_Player(sndhost_cockpit, "Aircrafts/A-4E-C/a-4e_HydraulicsSpeedbrakeStop", "SND_INST_HYD_STOP", SOUND_ONCE),

        --APG-53A RADAR
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/obsttone", "D_GLARE_OBST", SOUND_CONTINUOUS, nil, nil, nil, nil, "APG53_OBST_VOLUME"),
        
        --Radio Sounds
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_arn25_adf_garble", "SND_CONT_ADF_GARBLE", SOUND_CONTINUOUS, nil, nil, nil, nil, "SND_CONT_ADF_GARBLE_VOLUME"),

        --APR-25 RWR SOUNDS
        -- system sounds
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a4e-rwr-hum-loop", "SND_ALWS_RWR_HUM", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_missile_launch", "ECM_SAM", SOUND_CONTINUOUS, nil, nil, nil, nil, "SND_CONT_RWR_MSL_VOLUME"),
        -- generic sounds
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_ewr", "RWR_EWR", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_ship_default_lo", "RWR_SHIP_DEFAULT_LO", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_ship_default_hi", "RWR_SHIP_DEFAULT_HI", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_ai_default", "RWR_AI_GENERAL", SOUND_ALWAYS),
        -- specific radar sounds
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_aaa_fire_can_son9", "RWR_AAA_FIRECAN_SON9", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa2_flatface", "RWR_SA2_SEARCH", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa2_fansong_e_lo", "RWR_SA2_E_LO", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa2_fansong_e_hi", "RWR_SA2_E_HI", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa2_fansong_g_lo", "RWR_SA2_G_LO", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa2_fansong_g_hi", "RWR_SA2_G_HI", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a4e-rwr-aaa-hi-loop", "RWR_SA2_G_LAUNCH", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a4e-rwr-i-sam-lo-loop", "RWR_SA3_LO", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa5_tinshield", "RWR_SA5_SEARCH", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa5_squarepair_lo", "RWR_SA5_LO", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa5_squarepair_hi", "RWR_SA5_HI", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa6_straightflush_lo", "RWR_SA6_LO", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa6_straightflush_hi", "RWR_SA6_HI", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa8_tr", "RWR_SA8_TR", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa10_sr_bb", "RWR_SA10_SR_BB", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa10_sr_cs", "RWR_SA10_SR_CS", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa10_sr_ts", "RWR_SA10_SR_TS", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa10_tr_a", "RWR_SA10_TR_A", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa10_tr_b", "RWR_SA10_TR_B", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa11_sr", "RWR_SA11_SR", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa11_tr", "RWR_SA11_TR", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa13_tr", "RWR_SA13_TR", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_sam_sa19_tr", "RWR_SA19_TR", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_vehicle_gepard", "RWR_VEHICLE_GEPARD", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_vehicle_shilka", "RWR_VEHICLE_SHILKA", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_vehicle_vulcan", "RWR_VEHICLE_VULCAN", SOUND_ALWAYS),
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_apr25_aircraft_search", "RWR_AI_SEARCH", SOUND_ALWAYS),

        --APN-141 RADAR ALTIMETER
        Sound_Player(sndhost_headphones, "Aircrafts/A-4E-C/a-4e_CockpitRadarAltimeterWarn", "SND_INST_RADAR_ALTIMITER_WARNING", SOUND_ONCE),

    }

    -- initialise sounds
    -- it appears DCS standardizes these sounds across modules and calls are no longer required
    -- snd_catapultTakeoff = sndhost_cockpit:create_sound("Aircrafts/A-4E-C/A4E-CarrierCatapultTakeoff_In")
    -- snd_catapultLaunchbarDisconnect = sndhost_cockpit:create_sound("Aircrafts/A-4E-C/A4E-CarrierLaunchBarDisconnect")

    param_catapult_takeoff:set(-1)
end

function update()

    for index, sound in pairs(sounds) do
        sound:update()
    end

    playSoundOnceByParam(snd_catapultTakeoff, snd_catapultLaunchbarDisconnect, param_catapult_takeoff)
end

-- Reset = -1, Play == 1
function playSoundOnceByParam(start_sound, stop_sound, param)
    if param:get() > -1 then
        if start_sound then
            if param:get() == 0 and start_sound:is_playing() then
                start_sound:stop()
                if stop_sound then
                    stop_sound:play_once()
                end
            else
                start_sound:play_once()
            end
        end
        param:set(-1)
    end
end

need_to_be_closed = false -- close lua state after initialization
