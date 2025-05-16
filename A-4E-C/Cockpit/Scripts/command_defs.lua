
start_custom_command   = 10000
local __count_custom = start_custom_command-1
local function __custom_counter()
	__count_custom = __count_custom + 1
	return __count_custom
end

--[[
	===================================================
				   WARNING WARNING WARNING
	===================================================
	
	DO NOT PUT COMMANDS BEFORE COMMANDS MARKED FOR EFM. 
	SERIOUSLY DON'T PUT CONTROLS BEFORE THIS. IF YOU DO 
	YOU WILL BREAK ALL THE EFM SPECIFIC BINDS. AS THESE
	MUST BE HARD CODED INTO THE BINARY.
]]--

Keys =
{
	PlanePickleOn	                = 350,
	PlanePickleOff	                = 351,
    PlaneChgWeapon                  = 101,
    PlaneChgTargetNext              = 102,    -- iCommandPlaneChangeTarget
    PlaneModeNAV                    = 105,
    PlaneModeBVR                    = 106,
    PlaneModeVS                     = 107,
    PlaneModeBore                   = 108,
    PlaneModeGround                 = 111,

	Canopy                          = 71,
	
	PlaneAirBrake                   = 73,
	PlaneAirBrakeOn                 = 147,
	PlaneAirBrakeOff                = 148,	
	
	PlaneFlaps                      = 72,
	PlaneFlapsOn                    = 145, -- Fully down
	PlaneFlapsOff                   = 146, -- Fully up
    	
	PlaneGear                       = 68,						-- Шасси
	PlaneGearUp	                    = 430,
	PlaneGearDown                   = 431,
		
	-- LeftEngineStart = 311,			-- ?????? ?????? ?????????
	-- RightEngineStart = 312,			-- ?????? ??????? ?????????

	-- LeftEngineStop = 313,				-- ?????????? ?????? ?????????
	-- RightEngineStop = 314,			-- ?????????? ??????? ?????????

	PowerOnOff                      = 315,
    ShowControls                    = 851,

    --[[   -- Do not use the built-in altimeter adjustments, they have internal SSM affects on the altimeter that we cannot limit
    AltimeterPressureIncrease = 316,  
    AltimeterPressureDecrease = 317,
    AltimeterPressureStop = 318,        ]]--

    PlaneLightsOnOff                = 175,
    PlaneHeadlightOnOff             = 328,

    PowerGeneratorLeft              = 711,
    PowerGeneratorRight             = 712,

    BatteryPower                    = 1073,   -- iCommandBatteryPower

    PlaneChgTargetPrev              = 1315,   -- iCommandPlaneUFC_STEER_DOWN

    -- add custom commands here --
    --EFM SPECIFIC BINDS
	nws_engage						 = __custom_counter(),
	nws_disengage					 = __custom_counter(),
    radio_ptt						 = __custom_counter(),
    BrakesOnLeft                   = __custom_counter(),
    BrakesOffLeft                  = __custom_counter(),
    BrakesOnRight                  = __custom_counter(),
    BrakesOffRight                 = __custom_counter(),
    BrakesOn                        = __custom_counter(),
    BrakesOff                       = __custom_counter(),
    ToggleSlatsLock                = __custom_counter(),
	--END EFM SPECIFIC BINDS


    PlaneFlapsStop                  = __custom_counter(),
    PlaneFlapsUpHotas               = __custom_counter(),
    PlaneFlapsDownHotas             = __custom_counter(),

    SpoilersArmToggle               = __custom_counter(),
    SpoilersArmOn                   = __custom_counter(),
    SpoilersArmOff                  = __custom_counter(),
	PlaneFireOn		                = __custom_counter(), -- replaces iCommandPlaneFire
	PlaneFireOff	                = __custom_counter(), -- replaces iCommandPlaneFireOff
    PickleOn                        = __custom_counter(), -- replaces iCommandPlanePickleOn
    PickleOff                       = __custom_counter(), -- replaces iCommandPlanePickleOff

    MasterArmToggle                 = __custom_counter(),
    GunsReadyToggle                 = __custom_counter(),

    Station1                        = __custom_counter(), -- these 5 must be in-order, per weapon_system.lua
    Station2                        = __custom_counter(),
    Station3                        = __custom_counter(),
    Station4                        = __custom_counter(),
    Station5                        = __custom_counter(),

    ArmsFuncSelectorCCW             = __custom_counter(),
    ArmsFuncSelectorCW              = __custom_counter(),
	
    GunpodLeft                      = __custom_counter(),
    GunpodCenter                    = __custom_counter(),
    GunpodRight                     = __custom_counter(),
    GunpodCharge                    = __custom_counter(),

	EngineStarterDown               = __custom_counter(),
    Engine_Start                    = __custom_counter(),
    Engine_Stop                     = __custom_counter(),
    
    --SpoilerCoverToggle = 10025,  -- available for reuse

    FuelGaugeExt                    = __custom_counter(),
    FuelGaugeInt                    = __custom_counter(),

    AltPressureInc                  = __custom_counter(),
    AltPressureDec                  = __custom_counter(),

    RadarAltWarningDown             = __custom_counter(),
    RadarAltWarningUp               = __custom_counter(),
    
    --iCommandPlaneHook = 69        -- DO NOT USE.  Tied to SFM!
    PlaneHook                       = __custom_counter(),
    PlaneHookUp                     = __custom_counter(),
    PlaneHookDown                   = __custom_counter(),
    JettisonWeapons                 = __custom_counter(),  -- normal iCommandPlaneJettisonWeapons = 82 invokes SFM functionality
    JettisonWeaponsUp               = __custom_counter(),
    JettisonFC3                     = __custom_counter(),    
            
    NavReset                        = __custom_counter(),
    --NavTCNNext = 10101,
    --NavTCNPrev = 10102,
    NavNDBNext                      = __custom_counter(),
    NavNDBPrev                      = __custom_counter(),
    NavILSNext                      = __custom_counter(),
    NavILSPrev                      = __custom_counter(),

    NavPPosLatInc                   = __custom_counter(),  -- no longer used. ready for removal
    NavPPosLatDec                   = __custom_counter(),  -- no longer used. ready for removal
    NavPPosLonInc                   = __custom_counter(),  -- no longer used. ready for removal
    NavPPosLonDec                   = __custom_counter(),  -- no longer used. ready for removal
    NavDestLatInc                   = __custom_counter(),  -- no longer used. ready for removal
    NavDestLatDec                   = __custom_counter(),  -- no longer used. ready for removal
    NavDestLonInc                   = __custom_counter(),  -- no longer used. ready for removal
    NavDestLonDec                   = __custom_counter(),  -- no longer used. ready for removal

    NavDopplerCW                    = __custom_counter(),
    NavDopplerCCW                   = __custom_counter(),

    NavSelectCW                     = __custom_counter(),
    NavSelectCCW                    = __custom_counter(),

    BdhiModeNavComputer             = __custom_counter(),
    BdhiModeTacan                   = __custom_counter(),
    BdhiModeNavPac                  = __custom_counter(),

    -- APG-53A Radar
    RadarModeOFF                    = __custom_counter(),
    RadarModeSTBY                   = __custom_counter(),
    RadarModeSearch                 = __custom_counter(),
    RadarModeTC                     = __custom_counter(),
    RadarModeA2G                    = __custom_counter(),
    RadarMode                       = __custom_counter(),  -- cycles between "on" radar modes
    RadarModeCW                     = __custom_counter(),  -- cycles mode button clockwise
    RadarModeCCW                    = __custom_counter(),  -- cycles mode button counter clockwise
    RadarTCPlanProfile              = __custom_counter(),  -- 1 Plan, 0 Profile, -1 Toggle
    RadarRangeLongShort             = __custom_counter(),  -- 1 Long, 0 Short, -1 Toggle
    RadarVolume                     = __custom_counter(),  -- 1 Inc, 0 Dec
    RadarAntennaAngle               = __custom_counter(),  -- 1 Inc, 0 Dec
    RadarAoAComp                    = __custom_counter(),  -- 1 Enable, 0 Disable

    -- ARN-52V TACAN
    TacanModeOFF                    = __custom_counter(),
    TacanModeREC                    = __custom_counter(),
    TacanModeTR                     = __custom_counter(),
    TacanModeAA                     = __custom_counter(),
    TacanModeInc                    = __custom_counter(),
    TacanModeDec                    = __custom_counter(),
    TacanChMajorInc                 = __custom_counter(),
    TacanChMajorDec                 = __custom_counter(),
    TacanChMinorInc                 = __custom_counter(),
    TacanChMinorDec                 = __custom_counter(),
    TacanVolumeInc                  = __custom_counter(),
    TacanVolumeDec                  = __custom_counter(),

    ExtLightMaster                  = __custom_counter(),
    ExtLightProbe                   = __custom_counter(),
    ExtLightTaxi                    = __custom_counter(),
    ExtLightAnticollision           = __custom_counter(),
    ExtLightNav                     = __custom_counter(),
    ExtLightTail                    = __custom_counter(),
    ExtLightFuselage                = __custom_counter(),
    ExtLightFlashSteady             = __custom_counter(),

    ExtLightMasterToggle            = __custom_counter(),
    ExtLightProbeCycle              = __custom_counter(),
    ExtLightTaxiToggle              = __custom_counter(),
    ExtLightAnticollisionToggle     = __custom_counter(),
    ExtLightNavCycle                = __custom_counter(),
    ExtLightTailCycle               = __custom_counter(),
    ExtLightFuselageCycle           = __custom_counter(),
    ExtLightFlashSteadyToggle       = __custom_counter(),

    IntLightWhiteFlood              = __custom_counter(),
    IntLightInstruments             = __custom_counter(),
    IntLightConsole                 = __custom_counter(),
    IntLightBrightness              = __custom_counter(),

    TrimUp                          = __custom_counter(),
    TrimDown                        = __custom_counter(),
    TrimLeft                        = __custom_counter(),
    TrimRight                       = __custom_counter(),
    TrimLeftRudder                  = __custom_counter(),
    TrimRightRudder                 = __custom_counter(),
    TrimStop                        = __custom_counter(),
    TrimCancel                      = __custom_counter(),

    APCEngageStbyOff                = __custom_counter(),
    APCHotStdCold                   = __custom_counter(),

    AFCSOverride                    = __custom_counter(),
    AFCSStandbyToggle               = __custom_counter(),
    AFCSEngageToggle                = __custom_counter(),
    AFCSAltitudeToggle              = __custom_counter(),
    AFCSHeadingToggle               = __custom_counter(),
    AFCSHeadingInc                  = __custom_counter(),
    AFCSHeadingDec                  = __custom_counter(),
    AFCSHotasMode                   = __custom_counter(),
    AFCSHotasPath                   = __custom_counter(),  -- for warthog hotas
    AFCSHotasAltHdg                 = __custom_counter(),  -- for warthog hotas
    AFCSHotasAlt                    = __custom_counter(),  -- for warthog hotas
    AFCSHotasEngage                 = __custom_counter(),  -- for warthog hotas

    Tune1                           = __custom_counter(),
    Tune2                           = __custom_counter(),
    Tune3                           = __custom_counter(),

    ToggleStick                     = __custom_counter(),

    JATOFiringButton                = __custom_counter(),
    CmBankSelectRotate              = __custom_counter(),
    CmBankSelect                    = __custom_counter(),
    CmAutoButton                    = __custom_counter(),
    CmBank1AdjUp                    = __custom_counter(),
    CmBank1AdjDown                  = __custom_counter(),
    CmBank2AdjUp                    = __custom_counter(),
    CmBank2AdjDown                  = __custom_counter(),
    CmPowerToggle                   = __custom_counter(),

    AccelReset                      = __custom_counter(),

    RadarHoldToggle                 = __custom_counter(),
    RadarHoldInc                    = __custom_counter(),
    RadarHoldDec                    = __custom_counter(),
    SpeedHoldToggle                 = __custom_counter(),
    SpeedHoldInc                    = __custom_counter(),
    SpeedHoldDec                    = __custom_counter(),
	
	catapult_ready                  = __custom_counter(),
	catapult_shoot                  = __custom_counter(),
    catapult_abort                  = __custom_counter(),
    
    ChangeCBU2AQuantity             = __custom_counter(),
    ChangeCBU2BAQuantity            = __custom_counter(),
	
	ecm_apr25_off	                = __custom_counter(),
	ecm_apr25_audio	                = __custom_counter(),
	ecm_apr27_off	                = __custom_counter(),
	
	ecm_systest_upper	            = __custom_counter(),
	ecm_systest_lower	            = __custom_counter(),
		
    ecm_selector_knob               = __custom_counter(),
    
    ChangeCmsBursts                 = __custom_counter(),
    ChangeCmsBurstInterval          = __custom_counter(),
    ChangeCmsSalvos                 = __custom_counter(),
    ChangeSalvoInterval             = __custom_counter(),

    AWRSMultiplierToggle            = __custom_counter(),
    AWRSQtySelIncrease              = __custom_counter(),
    AWRSQtySelDecrease              = __custom_counter(),
    AWRSModeSelCCW                  = __custom_counter(),
    AWRSModeSelCW                   = __custom_counter(),
	
    AFCSStabAugToggle              = __custom_counter(),
    OxygenToggle                   = __custom_counter(),
    RadarAltToggle                 = __custom_counter(),
    RadarAltWarningStartUp         = __custom_counter(),
    RadarAltWarningStartDown       = __custom_counter(),
    RadarAltWarningStop            = __custom_counter(),
    UHFModeInc                     = __custom_counter(),
    UHFModeDec                     = __custom_counter(),
    UHF10MHzInc                    = __custom_counter(),
    UHF10MHzDec                    = __custom_counter(),
    UHF1MHzInc                     = __custom_counter(),
    UHF1MHzDec                     = __custom_counter(),
    UHF50kHzInc                    = __custom_counter(),
    UHF50kHzDec                    = __custom_counter(),
    UHFVolumeInc                   = __custom_counter(),
    UHFVolumeDec                   = __custom_counter(),
    UHFVolumeStartUp               = __custom_counter(),
    UHFVolumeStartDown             = __custom_counter(),
    UHFVolumeStop                  = __custom_counter(),
    TacanVolumeStartUp             = __custom_counter(),
    TacanVolumeStartDown           = __custom_counter(),
    TacanVolumeStop                = __custom_counter(),
    ecm_select_cw                  = __custom_counter();
    ecm_select_ccw                 = __custom_counter();
    ecm_InnerKnobInc               = __custom_counter();
    ecm_InnerKnobDec               = __custom_counter();
    ecm_InnerKnobStartUp           = __custom_counter();
    ecm_InnerKnobStartDown         = __custom_counter();
    ecm_InnerKnobStop              = __custom_counter();
    ecm_OuterKnobInc               = __custom_counter();
    ecm_OuterKnobDec               = __custom_counter();
    ecm_OuterKnobStartUp           = __custom_counter();
    ecm_OuterKnobStartDown         = __custom_counter();
    ecm_OuterKnobStop              = __custom_counter();
    GunsightElevationInc           = __custom_counter();
    GunsightElevationDec           = __custom_counter();
    GunsightElevationStartUp       = __custom_counter();
    GunsightElevationStartDown     = __custom_counter();
    GunsightElevationStop          = __custom_counter();
    GunsightBrightnessInc          = __custom_counter();
    GunsightBrightnessDec          = __custom_counter();
    GunsightBrightnessStartUp      = __custom_counter();
    GunsightBrightnessStartDown    = __custom_counter();
    GunsightBrightnessStop         = __custom_counter();
    GunsightDayNightToggle         = __custom_counter();
    MissileVolumeInc               = __custom_counter();
    MissileVolumeDec               = __custom_counter();
    MissileVolumeStartUp           = __custom_counter();
    MissileVolumeStartDown         = __custom_counter();
    MissileVolumeStop              = __custom_counter();
    AltPressureStartUp             = __custom_counter();
    AltPressureStartDown           = __custom_counter();
    AltPressureStop                = __custom_counter();
    UHFFreqModeInc                 = __custom_counter(), -- adding commands to end per jnels suggestion
    UHFFreqModeDec                 = __custom_counter(),
    UHFPresetChannelInc            = __custom_counter(),
    UHFPresetChannelDec            = __custom_counter(),
    RadarTiltInc                   = __custom_counter(),
    RadarTiltDec                   = __custom_counter(),
    RadarTiltStartUp               = __custom_counter(),
    RadarTiltStartDown             = __custom_counter(),
    RadarTiltStop                  = __custom_counter(),
    RadarVolumeStartUp             = __custom_counter(),
    RadarVolumeStartDown           = __custom_counter(),
    RadarVolumeStop                = __custom_counter(),
    MCL_Power_Toggle               = __custom_counter(),
    MCL_Chan_Inc                   = __custom_counter(),
    MCL_Chan_Dec                   = __custom_counter(),
    Fuel_Transfer_Bypass_Toggle    = __custom_counter(),
    AWRS_Drop_Interval_Inc         = __custom_counter(),
    AWRS_Drop_Interval_Dec         = __custom_counter(),
    ArmsEmerSelCW                  = __custom_counter(),
    ArmsEmerSelCCW                 = __custom_counter(),
    FuelControl                    = __custom_counter(),
    cat_power_toggle               = __custom_counter(),

    bullpup_up                     = __custom_counter(),
    bullpup_down                   = __custom_counter(),
    bullpup_left                   = __custom_counter(),
    bullpup_right                  = __custom_counter(),
    bullpup_yaw_stop               = __custom_counter(),
    bullpup_pitch_stop             = __custom_counter(),

    Radar_Bril_Step_Inc            = __custom_counter(),
    Radar_Bril_Step_Dec            = __custom_counter(),
    Radar_Bril_Cont_Up             = __custom_counter(),
    Radar_Bril_Cont_Down           = __custom_counter(),
    Radar_Bril_Cont_Stop           = __custom_counter(),
    Radar_Stor_Step_Inc            = __custom_counter(),
    Radar_Stor_Step_Dec            = __custom_counter(),
    Radar_Stor_Cont_Up             = __custom_counter(),
    Radar_Stor_Cont_Down           = __custom_counter(),
    Radar_Stor_Cont_Stop           = __custom_counter(),
    Radar_Gain_Step_Inc            = __custom_counter(),
    Radar_Gain_Step_Dec            = __custom_counter(),
    Radar_Gain_Cont_Up             = __custom_counter(),
    Radar_Gain_Cont_Down           = __custom_counter(),
    Radar_Gain_Cont_Stop           = __custom_counter(),
    Radar_Det_Step_Inc             = __custom_counter(),
    Radar_Det_Step_Dec             = __custom_counter(),
    Radar_Det_Cont_Up              = __custom_counter(),
    Radar_Det_Cont_Down            = __custom_counter(),
    Radar_Det_Cont_Stop            = __custom_counter(),
    Radar_Ret_Step_Inc             = __custom_counter(),
    Radar_Ret_Step_Dec             = __custom_counter(),
    Radar_Ret_Cont_Up              = __custom_counter(),
    Radar_Ret_Cont_Down            = __custom_counter(),
    Radar_Ret_Cont_Stop            = __custom_counter(),
    radio_ptt_voip                 = __custom_counter(),

    drop_tank_press_cycle          = __custom_counter(),
    fuel_dump_cycle                = __custom_counter(),

    modifier_left_down             = __custom_counter(),
    modifier_left_up               = __custom_counter(),
    
    modifier_right_down            = __custom_counter(),
    modifier_right_up              = __custom_counter(),

    afcs_hdg_set_start_up          = __custom_counter(),
    afcs_hdg_set_start_down        = __custom_counter(),
    afcs_hdg_set_stop              = __custom_counter(),

    nvg_toggle                     = __custom_counter(),
	
	canopy_open                    = __custom_counter(),
	canopy_close                   = __custom_counter(),

    throttle_position_off          = __custom_counter(),
    throttle_position_ign          = __custom_counter(),
    throttle_position_run          = __custom_counter(),

    throttle_inc                   = __custom_counter(),
    throttle_dec                   = __custom_counter(),

    AWRS_Drop_Interval_StartUp    = __custom_counter(),
    AWRS_Drop_Interval_StartDown  = __custom_counter(),
    AWRS_Drop_Interval_Stop       = __custom_counter(),

    intlight_whiteflood_startup   = __custom_counter(),
    intlight_whiteflood_startdown = __custom_counter(),
    intlight_whiteflood_stop      = __custom_counter(),
    intlight_instruments_startup   = __custom_counter(),
    intlight_instruments_startdown = __custom_counter(),
    intlight_instruments_stop      = __custom_counter(),
    intlight_console_startup      = __custom_counter(),
    intlight_console_startdown    = __custom_counter(),
    intlight_console_stop         = __custom_counter(),

    BombArmSwitch                 = __custom_counter(),
    throttle_acc                  = __custom_counter(),
    CmBankSelectToggle            = __custom_counter(),
    
    shrike_seeker_change_1      = __custom_counter(),
    shrike_seeker_change_2      = __custom_counter(),
    -- Station 3 cannot carry shrike
    shrike_seeker_change_4      = __custom_counter(),
    shrike_seeker_change_5      = __custom_counter(),

}

start_command   = 3000
local __count = start_command-1
local function __counter()
	__count = __count + 1
	return __count
end

device_commands =
{
    Button_Test                     = __counter(),
    arm_gun                         = __counter(),
    arm_master                      = __counter(),
    arm_station1                    = __counter(),
    arm_station2                    = __counter(),
    arm_station3                    = __counter(),
    arm_station4                    = __counter(),
    arm_station5                    = __counter(),
    arm_func_selector               = __counter(),
    gunpod_l                        = __counter(),
    gunpod_c                        = __counter(),
    gunpod_r                        = __counter(),
    gunpod_chargeclear              = __counter(),
	push_starter_switch             = __counter(),
	throttle                        = __counter(),
    flaps                           = __counter(),
	spoiler_cover                   = __counter(),
	spoiler_arm                     = __counter(),
    FuelGaugeExtButton              = __counter(),
    AltPressureKnob                 = __counter(),
    Gear                            = __counter(),
    Hook                            = __counter(),
    emer_gen_bypass                 = __counter(),
    emer_gen_deploy                 = __counter(),
    speedbrake                      = __counter(),
    arm_emer_sel                    = __counter(),
    arm_bomb                        = __counter(),
    emer_bomb_release               = __counter(),
    GunsightKnob                    = __counter(),
    GunsightDayNight                = __counter(),
    GunsightBrightness              = __counter(),
    AWRS_quantity                   = __counter(),
    AWRS_drop_interval              = __counter(),
    AWRS_multiplier                 = __counter(),
    AWRS_stepripple                 = __counter(),
    speedbrake_emer                 = __counter(),
    emer_gear_release               = __counter(),
    radar_alt_indexer               = __counter(),
    radar_alt_switch                = __counter(),
    master_test                     = __counter(),
    ias_index_button                = __counter(),
    ias_index_knob                  = __counter(),
    stby_att_index_button           = __counter(),
    stby_att_index_knob             = __counter(),

    bdhi_mode                       = __counter(),

    doppler_select                  = __counter(),
    doppler_memory_test             = __counter(),

    nav_select                      = __counter(),
    asn41_magvar                    = __counter(),
    asn41_windspeed                 = __counter(),
    asn41_winddir                   = __counter(),
    ppos_lat                        = __counter(),
    ppos_lon                        = __counter(),
    dest_lat                        = __counter(),
    dest_lon                        = __counter(),

    radar_planprofile               = __counter(),
    radar_range                     = __counter(),
    radar_storage                   = __counter(),
    radar_brilliance                = __counter(),
    radar_detail                    = __counter(),
    radar_gain                      = __counter(),
    radar_filter                    = __counter(),
    radar_reticle                   = __counter(),
    radar_mode                      = __counter(),
    radar_aoacomp                   = __counter(),
    radar_angle                     = __counter(),
    radar_angle_axis                = __counter(),
    radar_angle_axis_abs            = __counter(),
    radar_volume                    = __counter(),
    tacan_mode                      = __counter(),
    tacan_ch_major                  = __counter(),
    tacan_ch_minor                  = __counter(),
    tacan_volume                    = __counter(),
    extlight_master                 = __counter(),
    extlight_probe                  = __counter(),
    extlight_taxi                   = __counter(),
    extlight_anticoll               = __counter(),
    extlight_fuselage               = __counter(),
    extlight_flashsteady            = __counter(),
    extlight_nav                    = __counter(),
    extlight_tail                   = __counter(),
    intlight_whiteflood             = __counter(),
    intlight_instruments            = __counter(),
    intlight_console                = __counter(),
    intlight_brightness             = __counter(),
    rudder_trim                     = __counter(),
    throttle_axis                   = __counter(),
    throttle_click                  = __counter(),

    afcs_standby                    = __counter(),
    afcs_engage                     = __counter(),
    afcs_hdg_sel                    = __counter(),
    afcs_alt                        = __counter(),
    afcs_hdg_set                    = __counter(),
    afcs_stab_aug                   = __counter(),
    afcs_ail_trim                   = __counter(),

    apc_engagestbyoff               = __counter(),
    apc_hotstdcold                  = __counter(),

    arc51_mode                      = __counter(),
    arc51_xmitmode                  = __counter(),
    arc51_volume                    = __counter(),
    arc51_squelch                   = __counter(),
    arc51_freq_preset               = __counter(),
    arc51_freq_XXooo                = __counter(),
    arc51_freq_ooXoo                = __counter(),
    arc51_freq_oooXX                = __counter(),

    clock_stopwatch                 = __counter(),

    cm_bank                         = __counter(),
    cm_auto                         = __counter(),
    cm_adj1                         = __counter(),
    cm_adj2                         = __counter(),
    cm_pwr                          = __counter(),

    accel_reset                     = __counter(),
	
	throttle_axis_mod               = __counter(),
	
	ecm_apr25_off	                = __counter(),
	ecm_apr25_audio	                = __counter(),
	ecm_apr27_off	                = __counter(),
	
	ecm_systest_upper	            = __counter(),
	ecm_systest_lower	            = __counter(),
	
	ecm_msl_alert_axis_inner	    = __counter(),
	ecm_msl_alert_axis_outer	    = __counter(),
	
	ecm_selector_knob               = __counter(),
	
	pitch_axis_mod 	                = __counter(),
	roll_axis_mod 	                = __counter(),
	rudder_axis_mod                 = __counter(),
	wheelbrake_AXIS 	            = __counter(),

    shrike_sidewinder_volume        = __counter(),

    AWRS_drop_interval_AXIS         = __counter(),
    intlight_whiteflood_AXIS        = __counter(),
    intlight_instruments_AXIS       = __counter(),
    intlight_console_AXIS           = __counter(),
    intlight_whiteflood_CHANGE      = __counter(),
    intlight_instruments_CHANGE     = __counter(),
    intlight_console_CHANGE         = __counter(),
    
    cabin_pressure                  = __counter(),
    windshield_defrost              = __counter(),
    cabin_temp                      = __counter(),

    man_flt_control_override        = __counter(),
    
    shrike_selector                 = __counter(),
    oxygen_switch                   = __counter(),
    
    COMPASS_set_heading             = __counter(),
    COMPASS_push_to_sync            = __counter(),
    COMPASS_free_slaved_switch      = __counter(),
    COMPASS_latitude                = __counter(),
    
    ENGINE_wing_fuel_sw             = __counter(),
    ENGINE_drop_tanks_sw            = __counter(),
    ENGINE_fuel_control_sw          = __counter(),
    ENGINE_manual_fuel_shutoff      = __counter(),
    ENGINE_manual_fuel_shutoff_catch  = __counter(),

    CPT_shoulder_harness            = __counter(),
    CPT_secondary_ejection_handle   = __counter(),
    ppos_lat_push                   = __counter(),
    ppos_lon_push                   = __counter(),
    dest_lat_push                   = __counter(),
    dest_lon_push                   = __counter(),
    asn41_magvar_push               = __counter(),
    asn41_windspeed_push            = __counter(),
    asn41_winddir_push              = __counter(),

    throttle_click_ITER             = __counter(),

    JATO_arm                        = __counter(),
    JATO_jettison                   = __counter(),

    gunsight_elevation_axis         = __counter(),
    gunsight_elevation_axis_abs     = __counter(),
    pilot_salute                    = __counter(),

    left_wheelbrake_AXIS            = __counter(),
    right_wheelbrake_AXIS           = __counter(),

    AOA_dimming_wheel_AXIS          = __counter(),

    dest_lat_slew                   = __counter(),
    dest_lon_slew                   = __counter(),

    mcl_channel_selector            = __counter(),
    mcl_power_switch                = __counter(),

    afcs_test_guard                 = __counter(),
    afcs_test                       = __counter(),

    --Most of these are dummy/placeholder.
    tacan_antenna                   = __counter(),
    rain_removal                    = __counter(),
    nav_dead_recon                  = __counter(),
    seat_adjustment                 = __counter(),

    fuel_transfer_bypass            = __counter(),
    fuel_transfer_bypass            = __counter(),
    mouse_x                         = __counter(),
    mouse_y                         = __counter(),

    --avionics
    intlight_instruments_axis_slew  = __counter(),
    intlight_console_axis_slew      = __counter(),
    intlight_whiteflood_axis_slew   = __counter(),

    --gunsight
    gunsight_brightness_axis_abs    = __counter(),
    gunsight_brightness_axis_slew   = __counter(),

    --weapon system
    awrs_drop_interval_axis_slew    = __counter(),
    shrike_sidewinder_volume_abs    = __counter(),
    shrike_sidewinder_volume_slew   = __counter(),

    --nav
    tacan_volume_axis_abs           = __counter(),
    tacan_volume_axis_slew          = __counter(),

    --rwr
    ecm_msl_alert_axis_inner_abs    = __counter(),
    ecm_msl_alert_axis_inner_slew   = __counter(),
    ecm_msl_alert_axis_outer_abs    = __counter(),
    ecm_msl_alert_axis_outer_slew   = __counter(),

    --radar display
    radar_storage_axis_abs          = __counter(),
    radar_storage_axis_slew         = __counter(),
    radar_brilliance_axis_abs       = __counter(),
    radar_brilliance_axis_slew      = __counter(),
    radar_detail_axis_abs           = __counter(),
    radar_detail_axis_slew          = __counter(),
    radar_gain_axis_abs             = __counter(),
    radar_gain_axis_slew            = __counter(),
    radar_reticle_axis_abs          = __counter(),
    radar_reticle_axis_slew         = __counter(),

    --additional accessibility axes
    combined_wheel_brake_axis       = __counter(),
    rudder_axis_left                = __counter(),
    rudder_axis_right               = __counter(),
    throttle_axis_slew              = __counter(),
    zoom_axis_in                    = __counter(),
    zoom_axis_out                   = __counter(),
    zoom_axis_slew                  = __counter(),
    zoom_axis_slew_in               = __counter(),
    zoom_axis_slew_out              = __counter(),

    -- radar altimiter
    radar_altitude_warning_axis_slew = __counter(),
}
