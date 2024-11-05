local cscripts = folder.."../../Cockpit/Scripts/"
dofile(cscripts.."devices.lua")
dofile(cscripts.."command_defs.lua")

local res = external_profile("Config/Input/Aircrafts/common_joystick_binding.lua")

join(res.keyCommands,{

    ---------------------------------------------
    -- Communications ---------------------------
    --------------------------------------------- 
    {down = iCommandPilotGestureSalute,                      name = _('Pilot Salute'),                                category = {_('Communications')}},
    {down = iCommandPlaneShipTakeOff,                        name = _('Catapult Hook-Up'),                            category = {_('Communications')}},
    {down = Keys.cat_power_toggle,                           name = _('Catapult Power Mode - DEFAULT/AUTO'),          category = {_('Communications')}},
    {down = Keys.ToggleSlatsLock,                            name = _('Slats - LOCK/UNLOCK'),                         category = {_('Communications')}},
    {down = Keys.ChangeCBU2AQuantity, value_down = 1,        name = _('CBU-2/A Release Quantity - 1/2/3'),            category = {_('Communications'), _('Kneeboard'), _('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.ChangeCBU2BAQuantity, value_down = 1,       name = _('CBU-2B/A Release Quantity - 1/2/3/4/6/SALVO'), category = {_('Communications'), _('Kneeboard'), _('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.ChangeCmsBursts, value_down = 1,            name = _('Countermeasures Bursts'),                      category = {_('Communications'), _('Kneeboard'), _('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.ChangeCmsBurstInterval, value_down = 1,     name = _('Countermeasures Burst Interval'),              category = {_('Communications'), _('Kneeboard'), _('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.ChangeCmsSalvos, value_down = 1,            name = _('Countermeasures Salvos'),                      category = {_('Communications'), _('Kneeboard'), _('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.ChangeSalvoInterval, value_down = 1,        name = _('Countermeasures Salvo Interval'),              category = {_('Communications'), _('Kneeboard'), _('AN/ALE-29A Chaff Dispensing System')}},
    {down = iCommandPlaneRefuelingReadyPreContact,           name = _('A/A refueling - "Ready for precontact" radio call'), category = _('Communications')},
    {down = iCommandAWACSTankerBearing,                      name = _('Ask AWACS available tanker'),                  category = _('Communications')},

    ---------------------------------------------
    -- Sensors ----------------------------------
    --------------------------------------------- 
    {down = Keys.nvg_toggle,       name = _('NVG Night Vision Goggle - Toggle'),           category = {_('Sensors')}},
    {down = iCommandPlane_Helmet_Brightess_Up,      name = _('NVG Night Vision Goggle Gain - Increase'),    category = {_('Sensors')}},
    {down = iCommandPlane_Helmet_Brightess_Down,    name = _('NVG Night Vision Goggle Gain - Decrease'),    category = {_('Sensors')}},
  
    ---------------------------------------------
    -- View Cockpit -----------------------------
    ---------------------------------------------
    {down = iCommandViewLeftMirrorOn, up = iCommandViewLeftMirrorOff,       name = _('Mirror Left  - ON else OFF'),     category = {_('View Cockpit')}},
    {down = iCommandViewRightMirrorOn, up = iCommandViewRightMirrorOff,     name = _('Mirror Right - ON else OFF'),     category = {_('View Cockpit')}},
    {down = iCommandToggleMirrors,                                          name = _('Mirrors - ON/OFF'),               category = {_('View Cockpit')}},

    ---------------------------------------------
    -- Systems ----------------------------------
    ---------------------------------------------
    {down = iCommandPlaneEject,                                             name = _('Alternate Ejection Handle (3 times)'),    category = {_('Systems'), _('Emergency')}},
    {down = Keys.BrakesOn, up = Keys.BrakesOff,                             name = _('Wheel Brake - ON else OFF'),              category = {_('Systems')}},
	{down = Keys.BrakesOnLeft, up = Keys.BrakesOffLeft,						name = _('Wheel Brake Left - ON else OFF'), 	    category = {_('Systems')}},
	{down = Keys.BrakesOnRight, up = Keys.BrakesOffRight,					name = _('Wheel Brake Right - ON else OFF'),        category = {_('Systems')}},

    ---------------------------------------------
    -- Flight Control -------------------------
    ---------------------------------------------
    {down = iCommandPlaneUpStart, up = iCommandPlaneUpStop,                             name = _('Aircraft Pitch - DOWN'),           category = {_('Control Stick'), _('Flight Control')}},
    {down = iCommandPlaneDownStart, up = iCommandPlaneDownStop,                         name = _('Aircraft Pitch - UP'),             category = {_('Control Stick'), _('Flight Control')}},
    {down = iCommandPlaneLeftStart, up = iCommandPlaneLeftStop,                         name = _('Aircraft Roll - LEFT'),            category = {_('Control Stick'), _('Flight Control')}},
    {down = iCommandPlaneRightStart, up = iCommandPlaneRightStop,                       name = _('Aircraft Roll - RIGHT'),           category = {_('Control Stick'), _('Flight Control')}},
    {down = iCommandPlaneLeftRudderStart, up = iCommandPlaneLeftRudderStop,             name = _('Aircraft Rudder - LEFT'),          category = {_('Control Stick'), _('Flight Control')}},
    {down = iCommandPlaneRightRudderStart, up = iCommandPlaneRightRudderStop,           name = _('Aircraft Rudder - RIGHT'),         category = {_('Control Stick'), _('Flight Control')}},

    ---------------------------------------------
    -- Stick ------------------------------------
    ---------------------------------------------
    {pressed = Keys.TrimUp, up = Keys.TrimStop,                                         name = _('Trim Switch - NOSE UP'),          category = {_('Control Stick'), _('Flight Control')}},
    {pressed = Keys.TrimDown, up = Keys.TrimStop,                                       name = _('Trim Switch - NOSE DOWN'),        category = {_('Control Stick'), _('Flight Control')}},
    {pressed = Keys.TrimLeft, up = Keys.TrimStop,                                       name = _('Trim Switch - LEFT WING DOWN'),   category = {_('Control Stick'), _('Flight Control')}},
    {pressed = Keys.TrimRight, up = Keys.TrimStop,                                      name = _('Trim Switch - RIGHT WING DOWN'),  category = {_('Control Stick'), _('Flight Control')}},
    {pressed = Keys.TrimCancel, up = Keys.TrimStop,                                     name = _('Trim Reset (Hold)'),              category = {_('Control Stick'), _('Flight Control')}},
    {combos = {{key = 'JOY_BTN1'}}, down = Keys.PlaneFireOn, up = Keys.PlaneFireOff,    name = _('Gun-Rocket Trigger'),                category = {_('Control Stick'), _('Weapons')}},
    {combos = {{key = 'JOY_BTN2'}}, down = Keys.PickleOn, up = Keys.PickleOff,          name = _('Bomb Release Button'),               category = {_('Control Stick'), _('Weapons')}},
    {down = Keys.AFCSOverride,                                                          name = _('Autopilot Override (AFCS Emergency Disconnect)'),              category = {_('Control Stick'), _('AFCS Control Panel')}},
    {down = Keys.ToggleStick,                                                           name = _('Control Stick - HIDE/SHOW'),         category = {_('Control Stick'), _('View Cockpit')}},
    -- {down = Keys.nws_engage, up = Keys.nws_disengage,                                   name = _('Nose Wheel Steering - ON else OFF'), category = {_('Control Stick'), _('Systems')}},

    ---------------------------------------------
    -- Throttle Panel ------------------------
    ---------------------------------------------
    {down = Keys.throttle_inc,                                              name = _('Throttle Position - Increment'),                  category = {_('Throttle Panel'), _('Flight Control')}},
    {down = Keys.throttle_dec,                                              name = _('Throttle Position - Decrement'),                  category = {_('Throttle Panel'), _('Flight Control')}},
    {pressed = iCommandThrottleIncrease, up = iCommandThrottleStop,         name = _('Throttle Position Continuous - Increase'),        category = {_('Throttle Panel'), _('Flight Control')}},
    {pressed = iCommandThrottleDecrease, up = iCommandThrottleStop,         name = _('Throttle Position Continuous - Decrease'),        category = {_('Throttle Panel'), _('Flight Control')}},
    {down = Keys.throttle_acc, value_down = 1, up = Keys.throttle_acc, value_up = 0, name = _('Throttle Position Continuous - Increase (Custom Throttle Rate)'), category = {_('Throttle Panel'), _('Flight Control'), _('Accessibility')}},
    {down = Keys.throttle_acc, value_down = -1, up = Keys.throttle_acc, value_up = 0, name = _('Throttle Position Continuous - Decrease (Custom Throttle Rate)'), category = {_('Throttle Panel'), _('Flight Control'), _('Accessibility')}},

    {down = device_commands.throttle_click_ITER, value_down = 1, cockpit_device_id = devices.ENGINE,    name = _('Throttle Position Lock - Step Up (OFF/IGN/IDLE)'),                category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = device_commands.throttle_click_ITER, value_down = -1, cockpit_device_id = devices.ENGINE,   name = _('Throttle Position Lock - Step Down (OFF/IGN/IDLE)'),              category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_off,                                                                 name = _('Throttle Position Lock - OFF'),                                   category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_off, up = Keys.throttle_position_ign,                                name = _('Throttle Position Lock - OFF else IGN'),                          category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_off, up = Keys.throttle_position_run,                                name = _('Throttle Position Lock - OFF else RUN'),                          category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_ign,                                                                 name = _('Throttle Position Lock - IGN'),                                   category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_ign, up = Keys.throttle_position_off,                                name = _('Throttle Position Lock - IGN else OFF'),                          category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_ign, up = Keys.throttle_position_run,                                name = _('Throttle Position Lock - IGN else RUN'),                          category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_run,                                                                 name = _('Throttle Position Lock - RUN'),                                   category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_run, up = Keys.throttle_position_ign,                                name = _('Throttle Position Lock - RUN else IGN'),                          category = {_('Throttle Panel'), _('Engine Control Panel')}},
    {down = Keys.throttle_position_run, up = Keys.throttle_position_off,                                name = _('Throttle Position Lock - RUN else OFF'),                          category = {_('Throttle Panel'), _('Engine Control Panel')}},

    {down = Keys.ExtLightMaster, value_down = 1,                                                        name = _('Master Exterior Lights Switch - ON'),             category = {_('Throttle Panel'), _('Throttle Grip'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightMaster, value_down = 0,                                                        name = _('Master Exterior Lights Switch - OFF'),            category = {_('Throttle Panel'), _('Throttle Grip'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightMasterToggle,                                                                  name = _('Master Exterior Lights Switch - ON/OFF'),         category = {_('Throttle Panel'), _('Throttle Grip'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightMaster, value_down = 1, up = Keys.ExtLightMaster, value_up = 0,                name = _('Master Exterior Lights Switch - ON else OFF'),    category = {_('Throttle Panel'), _('Throttle Grip'), _('Exterior Lights Panel')}},
    {down = iCommandPlaneAirBrake,                                                                      name = _('Speedbrake Switch - OPEN/CLOSE'),                 category = {_('Throttle Panel'), _('Throttle Grip'), _('Flight Control')}},
    {down = iCommandPlaneAirBrakeOn, up = iCommandPlaneAirBrakeOff,                                     name = _('Speedbrake Switch - OPEN else CLOSE'),            category = {_('Throttle Panel'), _('Throttle Grip'), _('Flight Control')}},
    {down = iCommandPlaneAirBrakeOff, up = iCommandPlaneAirBrakeOn,                                     name = _('Speedbrake Switch - CLOSE else OPEN'),            category = {_('Throttle Panel'), _('Throttle Grip'), _('Flight Control')}},
    {down = iCommandPlaneAirBrakeOn,                                                                    name = _('Speedbrake Switch - OPEN'),                       category = {_('Throttle Panel'), _('Throttle Grip'), _('Flight Control')}},
    {down = iCommandPlaneAirBrakeOff,                                                                   name = _('Speedbrake Switch - CLOSE'),                      category = {_('Throttle Panel'), _('Throttle Grip'), _('Flight Control')}},

    {pressed = Keys.TrimLeftRudder, up = Keys.TrimStop,                                                 name = _('Rudder Trim Switch - Rudder Left'),               category = {_('Throttle Panel'), _('Flight Control')}},
    {pressed = Keys.TrimRightRudder, up = Keys.TrimStop,                                                name = _('Rudder Trim Switch - Rudder Right'),              category = {_('Throttle Panel'), _('Flight Control')}},

    -- Flap Switch
    {down = iCommandPlaneFlaps,                                                                         name = _('Flap Handle - UP/DOWN'),                         category = {_('Throttle Panel'), _('Flight Control')}},
    {down = iCommandPlaneFlapsOn,                                                                       name = _('Flap Handle - DOWN'),                            category = {_('Throttle Panel'), _('Flight Control')}},
    {down = iCommandPlaneFlapsOff,                                                                      name = _('Flap Handle - UP'),                              category = {_('Throttle Panel'), _('Flight Control')}},
    {down = Keys.PlaneFlapsStop,                                                                        name = _('Flap Handle - STOP'),                            category = {_('Throttle Panel'), _('Flight Control')}},
    {down = Keys.PlaneFlapsDownHotas, up = Keys.PlaneFlapsStop,                                         name = _('Flap Handle - DOWN else STOP'),                  category = {_('Throttle Panel'), _('Flight Control')}},
    {down = Keys.PlaneFlapsUpHotas, up = Keys.PlaneFlapsStop,                                           name = _('Flap Handle - UP else STOP'),                    category = {_('Throttle Panel'), _('Flight Control')}},

    ---------------------------------------------
    -- AN/ALE-29A Chaff Control Panel -----------
    ---------------------------------------------
    {down = Keys.CmBankSelectRotate,                                                                                                            name = _('Chaff Dispenser Select - Cycle'),         category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBankSelectToggle,                                                                                                            name = _('Chaff Dispenser Select - Toggle 1/2'),    category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBankSelect, value_down = -1,                                                                                                 name = _('Chaff Dispenser Select - 1'),             category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBankSelect, value_down = -1, up = Keys.CmBankSelect, value_up = 0,                                                           name = _('Chaff Dispenser Select - 1 else BOTH'),   category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBankSelect, value_down = 1,                                                                                                  name = _('Chaff Dispenser Select - 2'),             category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBankSelect, value_down = 1, up = Keys.CmBankSelect, value_up = 0,                                                            name = _('Chaff Dispenser Select - 2 else BOTH'),   category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBankSelect, value_down = 0,                                                                                                  name = _('Chaff Dispenser Select - BOTH'),          category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = device_commands.cm_auto, up = device_commands.cm_auto, cockpit_device_id = devices.COUNTERMEASURES, value_down = 1.0, value_up = 0, name = _('Chaff AUTO Pushbutton (ALE-29A Salvo)'),  category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBank1AdjUp,                                                                                                                  name = _('Chaff Dispenser 1 Counter - Increase'),   category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBank1AdjDown,                                                                                                                name = _('Chaff Dispenser 1 Counter - Decrease'),   category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBank2AdjUp,                                                                                                                  name = _('Chaff Dispenser 2 Counter - Increase'),   category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmBank2AdjDown,                                                                                                                name = _('Chaff Dispenser 2 Counter - Decrease'),   category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = Keys.CmPowerToggle,                                                                                                                 name = _('Chaff Power Switch - PWR/OFF'),           category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = device_commands.cm_pwr, up = device_commands.cm_pwr, cockpit_device_id = devices.COUNTERMEASURES, value_down = 1.0, value_up = 0,   name = _('Chaff Power Switch - PWR else OFF'),      category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = device_commands.cm_pwr, cockpit_device_id = devices.COUNTERMEASURES, value_down = 1.0,                                              name = _('Chaff Power Switch - PWR'),               category = {_('AN/ALE-29A Chaff Dispensing System')}},
    {down = device_commands.cm_pwr, cockpit_device_id = devices.COUNTERMEASURES, value_down = 0.0,                                              name = _('Chaff Power Switch - OFF'),               category = {_('AN/ALE-29A Chaff Dispensing System')}},

    ---------------------------------------------
    -- ECM Control Panel / AN/APR-25 Radar Homing and Warning System
    ---------------------------------------------
    {down = device_commands.ecm_selector_knob, value_down = 0.0, cockpit_device_id = devices.RWR,                                                       name = _('AN/APR-25 Function Selector - OFF'),          category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_selector_knob, value_down = 0.33, cockpit_device_id = devices.RWR,                                                      name = _('AN/APR-25 Function Selector - STBY'),         category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_selector_knob, value_down = 0.66, cockpit_device_id = devices.RWR,                                                      name = _('AN/APR-25 Function Selector - REC'),          category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_selector_knob, value_down = 0.99, cockpit_device_id = devices.RWR,                                                      name = _('AN/APR-25 Function Selector - RPT'),          category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_select_cw,                                                                                                                         name = _('AN/APR-25 Function Selector Switch - CW'),    category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_select_ccw,                                                                                                                        name = _('AN/APR-25 Function Selector Switch - CCW'),   category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_apr27_off, value_down = 1.0, value_up = 0.0,                                                                                       name = _('APR-27 Switch - ON/OFF'),                     category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr27_off, value_down = 1.0, cockpit_device_id = devices.RWR,                                                           name = _('APR-27 Switch - ON'),                         category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr27_off, value_down = 0.0, cockpit_device_id = devices.RWR,                                                           name = _('APR-27 Switch - OFF'),                        category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr27_off, up = device_commands.ecm_apr27_off, value_down = 1.0, value_up = 0.0, cockpit_device_id = devices.RWR,       name = _('APR-27 Switch - ON else OFF'),                category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_apr25_off, value_down = 1.0, value_up = 0.0,                                                                                       name = _('APR-25 Switch - ON/OFF'),                     category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr25_off, up = device_commands.ecm_apr25_off, value_down = 1.0, value_up = 0.0, cockpit_device_id = devices.RWR,       name = _('APR-25 Switch - ON else OFF'),                category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr25_off, value_down = 1.0, cockpit_device_id = devices.RWR,                                                           name = _('APR-25 Switch - ON'),                         category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr25_off, value_down = 0.0, cockpit_device_id = devices.RWR,                                                           name = _('APR-25 Switch - OFF'),                        category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr25_audio, up = device_commands.ecm_apr25_audio, value_down = 1.0, value_up = 0.0, cockpit_device_id = devices.RWR,   name = _('Audio ALQ Switch - APR-27 else APR-25'),      category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr25_audio, value_down = 1.0, cockpit_device_id = devices.RWR,                                                         name = _('Audio ALQ Switch - APR-27'),                  category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = device_commands.ecm_apr25_audio, value_down = 0.0, cockpit_device_id = devices.RWR,                                                         name = _('Audio ALQ Switch - APR-25'),                  category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_OuterKnobInc,                                                                                                                      name = _('Missile Alert Volume - Rotary Increment'),    category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_OuterKnobDec,                                                                                                                      name = _('Missile Alert Volume - Rotary Decrement'),    category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_OuterKnobStartUp, up = Keys.ecm_OuterKnobStop,                                                                                     name = _('Missile Alert Volume - Continuous Increase'), category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_OuterKnobStartDown, up = Keys.ecm_OuterKnobStop,                                                                                   name = _('Missile Alert Volume - Continuous Decrease'), category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_InnerKnobInc,                                                                                                                      name = _('PRF Volume - Rotary Increment'),              category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_InnerKnobDec,                                                                                                                      name = _('PRF Volume - Rotary Decrement'),              category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_InnerKnobStartUp, up = Keys.ecm_InnerKnobStop,                                                                                     name = _('PRF Volume - Continuous Increase'),           category = {_('AN/APR-25 RHWS (ECM)')}},
    {down = Keys.ecm_InnerKnobStartDown, up = Keys.ecm_InnerKnobStop,                                                                                   name = _('PRF Volume - Continuous Decrease'),           category = {_('AN/APR-25 RHWS (ECM)')}}, 
    {down = device_commands.ecm_systest_upper, up = device_commands.ecm_systest_upper, value_down = 1.0, value_up = 0.0, cockpit_device_id = devices.RWR,   name = _('APR-27 Test'),                            category = {_('AN/APR-25 RHWS (ECM)')}}, 
    {down = device_commands.ecm_systest_lower, up = device_commands.ecm_systest_lower, value_down = 1.0, value_up = 0.0, cockpit_device_id = devices.RWR,   name = _('APR-27 Light'),                           category = {_('AN/APR-25 RHWS (ECM)')}}, 

    ---------------------------------------------
    -- Instrument Panel -------------------------
    ---------------------------------------------
    -- Gunsight Control Panel
    {down = Keys.GunsightElevationInc, value_down = 1.0, value_up = 0.0,                                                                                        name = _('Gunsight Elevation Control - Rotary Increment'),      category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightElevationDec, value_down = 1.0, value_up = 0.0,                                                                                        name = _('Gunsight Elevation Control - Rotary Decrement'),      category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightElevationStartUp, up = Keys.GunsightElevationStop,                                                                                     name = _('Gunsight Elevation Control - Continuous Increase'),   category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightElevationStartDown, up = Keys.GunsightElevationStop,                                                                                   name = _('Gunsight Elevation Control - Continuous Decrease'),   category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightBrightnessInc, value_down = 1.0, value_up = 0.0,                                                                                       name = _('Gunsight Light Control - Rotary Increment'),          category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightBrightnessDec, value_down = 1.0, value_up = 0.0,                                                                                       name = _('Gunsight Light Control - Rotary Decrement'),          category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightBrightnessStartUp, up = Keys.GunsightBrightnessStop,                                                                                   name = _('Gunsight Light Control - Continuous Increase'),       category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightBrightnessStartDown, up = Keys.GunsightBrightnessStop,                                                                                 name = _('Gunsight Light Control - Continuous Decrease'),       category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = Keys.GunsightDayNightToggle,                                                                                                                        name = _('Gunsight Day-Night Switch - DAY/NIGHT'),              category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {down = device_commands.GunsightDayNight, up = device_commands.GunsightDayNight, value_down = 1.0, value_up = 0.0, cockpit_device_id = devices.GUNSIGHT,    name = _('Gunsight Day-Night Switch - DAY else NIGHT'),         category = {_('Instrument Panel'), _('Gunsight Panel')}},

    -- Stopwatch
    {down = device_commands.clock_stopwatch, up = device_commands.clock_stopwatch, value_down = 1.0, value_up = 0.0, cockpit_device_id = devices.CLOCK, name = _('Elapsed-Time Clock - START/STOP/RESET'), category = {_('Instrument Panel'), _('Systems')}},

    -- Altimeter
    {down = Keys.AltPressureInc,                                                                                            name = _('Altimeter Pressure - Rotary Increment'),         category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.AltPressureDec,                                                                                            name = _('Altimeter Pressure - Rotary Decrement'),         category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.AltPressureStartUp, up = Keys.AltPressureStop,                                                             name = _('Altimeter Pressure - Continuous Increase'),      category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.AltPressureStartDown, up = Keys.AltPressureStop,                                                           name = _('Altimeter Pressure - Continuous Decrease'),      category = {_('Instrument Panel'), _('Systems')}},

    -- APN-141 Radar Altimeter
    {down = Keys.RadarAltToggle,                                                                                            name = _('Radar Altitude Warning - ON/OFF'),                category = {_('Instrument Panel'), _('Systems'), _('AN/APN-141 Radar Altimeter')}},
    {down = Keys.RadarAltWarningUp,                                                                                         name = _('Radar Altitude Warning - Rotary Increment'),      category = {_('Instrument Panel'), _('Systems'), _('AN/APN-141 Radar Altimeter')}},
    {down = Keys.RadarAltWarningDown,                                                                                       name = _('Radar Altitude Warning - Rotary Decrement'),      category = {_('Instrument Panel'), _('Systems'), _('AN/APN-141 Radar Altimeter')}},
    {down = Keys.RadarAltWarningStartUp, up = Keys.RadarAltWarningStop,                                                     name = _('Radar Altitude Warning - Continuous Increase'),   category = {_('Instrument Panel'), _('Systems'), _('AN/APN-141 Radar Altimeter')}},
    {down = Keys.RadarAltWarningStartDown, up = Keys.RadarAltWarningStop,                                                   name = _('Radar Altitude Warning - Continuous Decrease'),   category = {_('Instrument Panel'), _('Systems'), _('AN/APN-141 Radar Altimeter')}},

    -- Landing Gear Handle
    {down = Keys.PlaneGear,                                                                                                 name = _('Landing Gear Handle - UP/DOWN'),                  category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.PlaneGearUp,                                                                                               name = _('Landing Gear Handle - UP'),                       category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.PlaneGearDown,                                                                                             name = _('Landing Gear Handle - DOWN'),                     category = {_('Instrument Panel'), _('Systems')}},
    {down = iCommandPlaneGearUp, up = iCommandPlaneGearDown,                                                                name = _('Landing Gear Handle - UP else DOWN'),             category = {_('Instrument Panel'), _('Systems')}},

    -- Arresting Hook Handle
    {down = Keys.PlaneHook,                                                                                                 name = _('Arresting Hook Handle - UP/DOWN'),                     category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.PlaneHookUp,                                                                                               name = _('Arresting Hook Handle - UP'),                          category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.PlaneHookDown,                                                                                             name = _('Arresting Hook Handle - DOWN'),                        category = {_('Instrument Panel'), _('Systems')}},
    {down = Keys.PlaneHookUp, up = Keys.PlaneHookDown,                                                                      name = _('Arresting Hook Handle - UP else DOWN'),                category = {_('Instrument Panel'), _('Systems')}},

    -- Miscellaneous Switches Panel
    {down = Keys.RadarTCPlanProfile, value_down = 1,                                                                                           name = _('Radar Terrain Clearance - PROFILE'),            category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarTCPlanProfile, value_down = 0,                                                                                           name = _('Radar Terrain Clearance - PLAN'),               category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarTCPlanProfile, value_down = -1,                                                                                          name = _('Radar Terrain Clearance - PROFILE/PLAN'),       category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarTCPlanProfile, value_down = 1, up = Keys.RadarTCPlanProfile, value_up = 0,                                               name = _('Radar Terrain Clearance - PROFILE else PLAN'),  category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarRangeLongShort, value_down = 1,                                                                                          name = _('Radar Range Switch - LONG'),                    category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarRangeLongShort, value_down = 0,                                                                                          name = _('Radar Range Switch - SHORT'),                   category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarRangeLongShort, value_down = -1,                                                                                         name = _('Radar Range Switch - LONG/SHORT'),              category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarRangeLongShort, value_down = 1, up = Keys.RadarRangeLongShort, value_up = 0,                                             name = _('Radar Range Switch - LONG else SHORT'),         category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/APG-53A Radar')}},

    {down = device_commands.bdhi_mode, value_down = -1, cockpit_device_id = devices.NAV,                                                       name = _('BDHI Switch - NAV PAC'),                        category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/ASN-41 Navigation Computer'), _('AN/ARN-52 TACAN')}},
    {down = device_commands.bdhi_mode, value_down = 0, cockpit_device_id = devices.NAV,                                                        name = _('BDHI Switch - TACAN'),                          category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/ASN-41 Navigation Computer'), _('AN/ARN-52 TACAN')}},
    {down = device_commands.bdhi_mode, value_down = 1, cockpit_device_id = devices.NAV,                                                        name = _('BDHI Switch - NAV CMPTR'),                      category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/ASN-41 Navigation Computer'), _('AN/ARN-52 TACAN')}},
    {down = device_commands.bdhi_mode, value_down = -1, up = device_commands.bdhi_mode, value_up = 0, cockpit_device_id = devices.NAV,         name = _('BDHI Switch - NAV PAC else TACAN'),             category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/ASN-41 Navigation Computer'), _('AN/ARN-52 TACAN')}},
    {down = device_commands.bdhi_mode, value_down = 1, up = device_commands.bdhi_mode, value_up = 0, cockpit_device_id = devices.NAV,          name = _('BDHI Switch - NAV CMPTR else TACAN'),           category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('AN/ASN-41 Navigation Computer'), _('AN/ARN-52 TACAN')}},

    {down = device_commands.master_test, up = device_commands.master_test, value_down = 1, value_up = 0, cockpit_device_id = devices.AVIONICS, name = _('Master Test Switch - ON else OFF'),             category = {_('Instrument Panel'), _('Miscellaneous Switches Panel')}},

    {down = Keys.MissileVolumeInc,                                      name = _('Shrike/Sidewinder Volume Knob - Rotary Increment'),           category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('Weapons')}},
    {down = Keys.MissileVolumeDec,                                      name = _('Shrike/Sidewinder Volume Knob - Rotary Decrement'),           category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('Weapons')}},
    {down = Keys.MissileVolumeStartUp, up = Keys.MissileVolumeStop,     name = _('Shrike/Sidewinder Volume Knob - Continuous Increase'),        category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('Weapons')}},
    {down = Keys.MissileVolumeStartDown, up = Keys.MissileVolumeStop,   name = _('Shrike/Sidewinder Volume Knob - Continuous Decrease'),        category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('Weapons')}},

    {down = Keys.FuelGaugeExt,                                          name = _('Internal-External Fuel Switch - EXT'),                        category = {_('Instrument Panel'), _('Miscellaneous Switches Panel')}},
    {down = Keys.FuelGaugeInt,                                          name = _('Internal-External Fuel Switch - INT'),                        category = {_('Instrument Panel'), _('Miscellaneous Switches Panel')}},
    {down = Keys.FuelGaugeExt, up = Keys.FuelGaugeInt,                  name = _('Internal-External Fuel Switch - EXT else INT'),               category = {_('Instrument Panel'), _('Miscellaneous Switches Panel')}},

    -- Radar Indicator
    {down = Keys.Radar_Bril_Step_Inc,                                   name = _('Radar Indicator Brilliance Knob - Increment'),            category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Bril_Step_Dec,                                   name = _('Radar Indicator Brilliance Knob - Decrement'),            category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Bril_Cont_Up, up = Keys.Radar_Bril_Cont_Stop,    name = _('Radar Indicator Brilliance Knob - Continuous Increase'),  category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Bril_Cont_Down, up = Keys.Radar_Bril_Cont_Stop,  name = _('Radar Indicator Brilliance Knob - Continuous Decrease'),  category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Stor_Step_Inc,                                   name = _('Radar Indicator Storage Knob - Increment'),               category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Stor_Step_Dec,                                   name = _('Radar Indicator Storage Knob - Decrement'),               category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Stor_Cont_Up, up = Keys.Radar_Stor_Cont_Stop,    name = _('Radar Indicator Storage Knob - Continuous Increase'),     category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Stor_Cont_Down, up = Keys.Radar_Stor_Cont_Stop,  name = _('Radar Indicator Storage Knob - Continuous Decrease'),     category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Gain_Step_Inc,                                   name = _('Radar Indicator Gain Knob - Increment'),                  category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Gain_Step_Dec,                                   name = _('Radar Indicator Gain Knob - Decrement'),                  category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Gain_Cont_Up, up = Keys.Radar_Gain_Cont_Stop,    name = _('Radar Indicator Gain Knob - Continuous Increase'),        category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Gain_Cont_Down, up = Keys.Radar_Gain_Cont_Stop,  name = _('Radar Indicator Gain Knob - Continuous Decrease'),        category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Det_Step_Inc,                                    name = _('Radar Indicator Detail Knob - Increment'),                category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Det_Step_Dec,                                    name = _('Radar Indicator Detail Knob - Decrement'),                category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Det_Cont_Up, up = Keys.Radar_Det_Cont_Stop,      name = _('Radar Indicator Detail Knob - Continuous Increase'),      category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Det_Cont_Down, up = Keys.Radar_Det_Cont_Stop,    name = _('Radar Indicator Detail Knob - Continuous Decrease'),      category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Ret_Step_Inc,                                    name = _('Radar Indicator Reticle Knob - Increment'),               category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Ret_Step_Dec,                                    name = _('Radar Indicator Reticle Knob - Decrement'),               category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Ret_Cont_Up, up = Keys.Radar_Ret_Cont_Stop,      name = _('Radar Indicator Reticle Knob - Continuous Increase'),     category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {down = Keys.Radar_Ret_Cont_Down, up = Keys.Radar_Ret_Cont_Stop,    name = _('Radar Indicator Reticle Knob - Continuous Decrease'),     category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},

    -- Armament Panel 
    {down = device_commands.arm_bomb, value_down = 1, cockpit_device_id = devices.WEAPON_SYSTEM,                                                    name = _('Bomb Arm Switch - NOSE & TAIL'),              category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_bomb, value_down = 0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                    name = _('Bomb Arm Switch - OFF'),                      category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_bomb, value_down = -1, cockpit_device_id = devices.WEAPON_SYSTEM,                                                   name = _('Bomb Arm Switch - TAIL'),                     category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_bomb, value_down = -1, up = device_commands.arm_bomb, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,      name = _('Bomb Arm Switch - TAIL else OFF'),            category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_bomb, value_down = 1, up = device_commands.arm_bomb, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,       name = _('Bomb Arm Switch - NOSE & TAIL else OFF'),     category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.BombArmSwitch,                                                                                                                     name = _('Bomb Arm Switch - Cycle'),                    category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},

    {down = Keys.Station1,                                                                                                                          name = _('Station 1 Selector - READY/OFF'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.Station2,                                                                                                                          name = _('Station 2 Selector - READY/OFF'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.Station3,                                                                                                                          name = _('Station 3 Selector - READY/OFF'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.Station4,                                                                                                                          name = _('Station 4 Selector - READY/OFF'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.Station5,                                                                                                                          name = _('Station 5 Selector - READY/OFF'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},

    {down = device_commands.arm_station1, value_down = 1.0, up = device_commands.arm_station1, value_up = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,   name = _('Station 1 Selector - READY else OFF'),    category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station1, value_down = 1.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 1 Selector - READY'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station1, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 1 Selector - OFF'),               category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station2, value_down = 1.0, up = device_commands.arm_station2, value_up = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,   name = _('Station 2 Selector - READY else OFF'),    category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station2, value_down = 1.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 2 Selector - READY'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station2, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 2 Selector - OFF'),               category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station3, value_down = 1.0, up = device_commands.arm_station3, value_up = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,   name = _('Station 3 Selector - READY else OFF'),    category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station3, value_down = 1.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 3 Selector - READY'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station3, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 3 Selector - OFF'),               category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station4, value_down = 1.0, up = device_commands.arm_station4, value_up = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,   name = _('Station 4 Selector - READY else OFF'),    category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station4, value_down = 1.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 4 Selector - READY'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station4, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 4 Selector - OFF'),               category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station5, value_down = 1.0, up = device_commands.arm_station5, value_up = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,   name = _('Station 5 Selector - READY else OFF'),    category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station5, value_down = 1.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 5 Selector - READY'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_station5, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                      name = _('Station 5 Selector - OFF'),               category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},

    {down = device_commands.arm_func_selector,  cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 0.0,                                        name = _('Weapon Function Selector - OFF'),            category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_func_selector,  cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 0.1,                                        name = _('Weapon Function Selector - ROCKETS'),        category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_func_selector,  cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 0.2,                                        name = _('Weapon Function Selector - GM UNARM'),       category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_func_selector,  cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 0.3,                                        name = _('Weapon Function Selector - SPRAY TANK'),     category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_func_selector,  cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 0.4,                                        name = _('Weapon Function Selector - LABS'),           category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_func_selector,  cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 0.5,                                        name = _('Weapon Function Selector - BOMBS & GM ARM'), category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_func_selector,  cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 0.6,                                        name = _('Weapon Function Selector - CMPTR'),          category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.ArmsFuncSelectorCCW,                                                                                                               name = _('Weapon Function Selector Switch - CCW'),     category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.ArmsFuncSelectorCW,                                                                                                                name = _('Weapon Function Selector Switch - CW'),      category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    
    {down = Keys.GunsReadyToggle,                                                                                                                   name = _('Guns Charging Switch - READY/SAFE'),         category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_gun, value_down = 1, up = device_commands.arm_gun, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,         name = _('Guns Charging Switch - READY else SAFE'),    category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_gun, value_down = 1, cockpit_device_id = devices.WEAPON_SYSTEM,                                                     name = _('Guns Charging Switch - READY'),              category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_gun, value_down = 0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                     name = _('Guns Charging Switch - SAFE'),               category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = Keys.MasterArmToggle,                                                                                                                   name = _('Master Armament Switch - ON/OFF'),           category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_master, value_down = 1, up = device_commands.arm_master, value_up = 0, cockpit_device_id = devices.ELECTRIC_SYSTEM, name = _('Master Armament Switch - ON else OFF'),      category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_master, value_down = 1, cockpit_device_id = devices.ELECTRIC_SYSTEM,                                                name = _('Master Armament Switch - ON'),               category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},
    {down = device_commands.arm_master, value_down = 0, cockpit_device_id = devices.ELECTRIC_SYSTEM,                                                name = _('Master Armament Switch - OFF'),              category = {_('Instrument Panel'), _('Armament Panel'), _('Weapons')}},

    {down = Keys.ArmsEmerSelCW,                                                                         name = _('Emergency Release Selector Switch - CW'),     category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = Keys.ArmsEmerSelCCW,                                                                        name = _('Emergency Release Selector Switch - CCW'),    category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = device_commands.arm_emer_sel, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Emergency Release Selector - WNG'),           category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = device_commands.arm_emer_sel, value_down = 0.1, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Emergency Release Selector - 1'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = device_commands.arm_emer_sel, value_down = 0.2, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Emergency Release Selector - 2'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = device_commands.arm_emer_sel, value_down = 0.3, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Emergency Release Selector - 3'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = device_commands.arm_emer_sel, value_down = 0.4, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Emergency Release Selector - 4'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = device_commands.arm_emer_sel, value_down = 0.5, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Emergency Release Selector - 5'),             category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},
    {down = device_commands.arm_emer_sel, value_down = 0.6, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Emergency Release Selector - AL'),            category = {_('Instrument Panel'), _('Armament Panel'), _('Emergency')}},

    -- Aircraft Weapons Release System Panel
    {down = Keys.AWRSMultiplierToggle,                                                                                                                              name = _('AWRS Multiplier Switch - 10X/1X'),                category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_multiplier, up = device_commands.AWRS_multiplier, cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 1.0, value_up = 0.0,     name = _('AWRS Multiplier Switch - 10X else 1X'),           category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_multiplier, value_down = 1.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Multiplier Switch - 10X'),                   category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_multiplier, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Multiplier Switch - 1X'),                    category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRSQtySelIncrease,                                                                                                                                name = _('AWRS Quantity Selector Switch - CW/Increase'),    category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRSQtySelDecrease,                                                                                                                                name = _('AWRS Quantity Selector Switch - CCW/Decrease'),   category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.00, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 01/OFF'),         category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.05, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 02'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.10, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 03'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.15, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 04'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.20, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 05'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.25, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 06'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.30, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 09'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.35, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 12'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.40, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 15'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.45, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 20'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.50, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 30'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_quantity, value_down = 0.55, cockpit_device_id = devices.WEAPON_SYSTEM,                                                            name = _('AWRS Quantity Selector Switch - 40'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRSModeSelCW,                                                                                                                                     name = _('AWRS Mode Selector Switch - CW'),                 category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRSModeSelCCW,                                                                                                                                    name = _('AWRS Mode Selector Switch - CCW'),                category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_stepripple, value_down = 0.0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Mode Selector Switch - STEP-SALVO'),         category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_stepripple, value_down = 0.1, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Mode Selector Switch - STEP-PAIRS'),         category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_stepripple, value_down = 0.2, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Mode Selector Switch - STEP-SINGLE'),        category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_stepripple, value_down = 0.3, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Mode Selector Switch - RIPPLE-SINGLE'),      category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_stepripple, value_down = 0.4, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Mode Selector Switch - RIPPLE-PAIRS'),       category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_stepripple, value_down = 0.5, cockpit_device_id = devices.WEAPON_SYSTEM,                                                           name = _('AWRS Mode Selector Switch - RIPPLE-SALVO'),       category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRS_Drop_Interval_Inc,                                                                                                                            name = _('AWRS Drop Interval Knob - Rotary Increment'),     category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRS_Drop_Interval_Dec,                                                                                                                            name = _('AWRS Drop Interval Knob - Rotary Decrement'),     category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRS_Drop_Interval_StartUp, up = Keys.AWRS_Drop_Interval_Stop,                                                                                     name = _('AWRS Drop Interval Knob - Continuous Increase'),  category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = Keys.AWRS_Drop_Interval_StartDown, up = Keys.AWRS_Drop_Interval_Stop,                                                                                   name = _('AWRS Drop Interval Knob - Continuous Decrease'),  category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.00, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 020 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.05, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 030 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.10, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 040 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.15, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 050 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.20, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 060 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.25, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 070 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.30, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 080 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.35, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 090 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.40, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 100 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.45, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 110 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.50, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 120 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.55, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 130 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.60, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 140 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.65, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 150 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.70, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 160 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.75, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 170 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.80, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 180 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.85, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 190 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {down = device_commands.AWRS_drop_interval, value_down = 0.90, cockpit_device_id = devices.WEAPON_SYSTEM,                                                       name = _('AWRS Drop Interval Knob - 200 ms'),               category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},

    -- T-Handles
    {down = device_commands.emer_bomb_release, up = device_commands.emer_bomb_release, cockpit_device_id = devices.WEAPON_SYSTEM, value_down = 1.0, value_up = 0.0,                                                 name = _('Emergency Stores Release Handle'),    category = {_('Instrument Panel'), _('Emergency')}},
    {down = device_commands.emer_gear_release, up = device_commands.emer_gear_release, cockpit_device_id = devices.GEAR, value_down = 1.0, value_up = 0.0,                                                          name = _('Emergency Landing Gear Release Handle'),    category = {_('Instrument Panel'), _('Emergency')}},
    {down = device_commands.man_flt_control_override, up = device_commands.man_flt_control_override, cockpit_device_id = devices.HYDRAULIC_SYSTEM, value_down = 1.0, value_up = 0.0,                                name = _('Manual Flight Control Handle'), category = {_('Instrument Panel'), _('Emergency')}},
    {down = device_commands.emer_gen_deploy, cockpit_device_id = devices.ELECTRIC_SYSTEM, value_down = 1.0,                                                                                                         name = _('Emergency Generator Release Handle'),     category = {_('Instrument Panel'), _('Emergency')}},
    {down = device_commands.speedbrake_emer, up = device_commands.speedbrake_emer, value_down = 1, value_up = 0, cockpit_device_id = devices.AIRBRAKES,                                                             name = _('Emergency Speedbrake Knob'),      category = {_('Console Left'), _('Emergency')}},

    ---------------------------------------------
    -- Left Console -----------------------------
    ---------------------------------------------    
    -- Gunpods Control Panel
    {down = Keys.GunpodCharge,                                                                                                                                      name = _('Gunpod Switch - Cycle'),                          category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_chargeclear, value_down = 1, up = device_commands.gunpod_chargeclear, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,   name = _('Gunpod Switch - CHARGE else OFF'),                category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_chargeclear, value_down = -1, up = device_commands.gunpod_chargeclear, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Gunpod Switch - CLEAR else OFF'),                 category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_chargeclear, value_down = -1, cockpit_device_id = devices.WEAPON_SYSTEM,                                                         name = _('Gunpod Switch - CLEAR'),                          category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_chargeclear, value_down = 0, cockpit_device_id = devices.WEAPON_SYSTEM,                                                          name = _('Gunpod Switch - OFF'),                            category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_chargeclear, value_down = 1, cockpit_device_id = devices.WEAPON_SYSTEM,                                                          name = _('Gunpod Switch - CHARGE'),                         category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = Keys.GunpodLeft,                                                                                                                                        name = _('Gunpod Station LH Switch - READY/SAFE'),          category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_l, value_down = 1, up = device_commands.gunpod_l, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,                       name = _('Gunpod Station LH Switch - READY else SAFE'),     category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = Keys.GunpodCenter,                                                                                                                                      name = _('Gunpod Station CTR Switch - READY/SAFE'),         category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_c, value_down = 1, up = device_commands.gunpod_c, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,                       name = _('Gunpod Station CTR Switch - READY else SAFE'),    category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = Keys.GunpodRight,                                                                                                                                       name = _('Gunpod Station RH Switch - READY/SAFE'),          category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},
    {down = device_commands.gunpod_r, value_down = 1, up = device_commands.gunpod_r, value_up = 0, cockpit_device_id = devices.WEAPON_SYSTEM,                       name = _('Gunpod Station RH Switch - READY else SAFE'),     category = {_('Console Left'), _('Gunpods Control Panel'), _('Weapons')}},

    -- APC Control Panel
    {down = Keys.APCEngageStbyOff, value_down = -1,                                           name = _('APC Power Switch - OFF'),                   category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCEngageStbyOff, value_down = 0,                                            name = _('APC Power Switch - STBY'),                  category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCEngageStbyOff, value_down = 1,                                            name = _('APC Power Switch - ENGAGE'),                category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCEngageStbyOff, value_down = -1, up = Keys.APCEngageStbyOff, value_up = 0, name = _('APC Power Switch - OFF else STBY'),         category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCEngageStbyOff, value_down = 1, up = Keys.APCEngageStbyOff, value_up = 0,  name = _('APC Power Switch - ENGAGE else STBY'),      category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCHotStdCold, value_down = -1,                                              name = _('APC Temperature Switch - COLD'),            category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCHotStdCold, value_down = 0,                                               name = _('APC Temperature Switch - STD'),             category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCHotStdCold, value_down = 1,                                               name = _('APC Temperature Switch - HOT'),             category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCHotStdCold, value_down = -1, up = Keys.APCHotStdCold, value_up = 0,       name = _('APC Temperature Switch - COLD else STD'),   category = {_('Console Left'), _('APC Control Panel')}},
    {down = Keys.APCHotStdCold, value_down = 1, up = Keys.APCHotStdCold, value_up = 0,        name = _('APC Temperature Switch - HOT else STD'),    category = {_('Console Left'), _('APC Control Panel')}},
    
    -- JATO Control Panel
    {down = Keys.SpoilersArmToggle,                                                           name = _('Spoiler Arm Switch - ARM/OFF'),             category = {_('Console Left'), _('JATO Control Panel'), _('Systems')}},
    {down = Keys.SpoilersArmOn,                                                               name = _('Spoiler Arm Switch - ARM'),                 category = {_('Console Left'), _('JATO Control Panel'), _('Systems')}},
    {down = Keys.SpoilersArmOff,                                                              name = _('Spoiler Arm Switch - OFF'),                 category = {_('Console Left'), _('JATO Control Panel'), _('Systems')}},
    {down = Keys.SpoilersArmOn, up = Keys.SpoilersArmOff,                                     name = _('Spoiler Arm Switch - ARM else OFF'),        category = {_('Console Left'), _('JATO Control Panel'), _('Systems')}},
    {down = Keys.JATOFiringButton,                                                            name = _('JATO Firing Button (ALE-29A Burst)'),       category = {_('Console Left'), _('JATO Control Panel'), _('Systems'), _('AN/ALE-29A Chaff Dispensing System')}},

    -- Engine Control Panel
    {down = Keys.Engine_Start,                                                                                                                                      name = _('Engine Starter Switch - START'),                                      category = {_('Console Left'), _('Engine Control Panel'), _('Emergency')}},
    {down = Keys.Engine_Stop,                                                                                                                                       name = _('Engine Starter Switch - ABORT'),                                      category = {_('Console Left'), _('Engine Control Panel'), _('Emergency')}},
    {down = device_commands.ENGINE_drop_tanks_sw, value_down = 1, cockpit_device_id = devices.ENGINE,                                                               name = _('Drop Tank Pressurization Switch - OFF'),                              category = {_('Console Left'), _('Engine Control Panel'), _('Refueling')}},
    {down = device_commands.ENGINE_drop_tanks_sw, value_down = 0, cockpit_device_id = devices.ENGINE,                                                               name = _('Drop Tank Pressurization Switch - PRESS'),                            category = {_('Console Left'), _('Engine Control Panel'), _('Refueling')}},
    {down = device_commands.ENGINE_drop_tanks_sw, value_down = -1, cockpit_device_id = devices.ENGINE,                                                              name = _('Drop Tank Pressurization Switch - FLIGHT REFUEL'),                    category = {_('Console Left'), _('Engine Control Panel'), _('Refueling')}},
    {down = device_commands.ENGINE_drop_tanks_sw, up = device_commands.ENGINE_drop_tanks_sw, value_down = 1, value_up = 0, cockpit_device_id = devices.ENGINE,      name = _('Drop Tank Pressurization Switch - OFF else PRESS'),                   category = {_('Console Left'), _('Engine Control Panel'), _('Refueling')}},
    {down = device_commands.ENGINE_drop_tanks_sw, up = device_commands.ENGINE_drop_tanks_sw, value_down = -1, value_up = 0, cockpit_device_id = devices.ENGINE,     name = _('Drop Tank Pressurization Switch - FLIGHT REFUEL else PRESS'),         category = {_('Console Left'), _('Engine Control Panel'), _('Refueling')}},
    {down = Keys.drop_tank_press_cycle,                                                                                                                             name = _('Drop Tank Pressurization Switch - Cycle'),                            category = {_('Console Left'), _('Engine Control Panel'), _('Refueling')}},
    {down = Keys.FuelControl,                                                                                                                                       name = _('Fuel Control Switch - MANUAL/PRIMARY'),                               category = {_('Console Left'), _('Engine Control Panel'), _('Emergency')}},
    {down = device_commands.ENGINE_fuel_control_sw, up = device_commands.ENGINE_fuel_control_sw, value_down = 1, value_up = 0, cockpit_device_id = devices.ENGINE,  name = _('Fuel Control Switch - MANUAL else PRIMARY'),                          category = {_('Console Left'), _('Engine Control Panel'), _('Emergency')}},
    {down = device_commands.ENGINE_fuel_control_sw, value_down = 1, cockpit_device_id = devices.ENGINE,                                                             name = _('Fuel Control Switch - MANUAL'),                                       category = {_('Console Left'), _('Engine Control Panel'), _('Emergency')}},
    {down = device_commands.ENGINE_fuel_control_sw, value_down = 0, cockpit_device_id = devices.ENGINE,                                                             name = _('Fuel Control Switch - PRIMARY'),                                      category = {_('Console Left'), _('Engine Control Panel'), _('Emergency')}},
    {down = Keys.fuel_dump_cycle,                                                                                                                                   name = _('Fuel Dump Switch - Cycle'),                                           category = {_('Console Left'), _('Engine Control Panel')}},
    {down = device_commands.ENGINE_wing_fuel_sw, value_down = 1, up = device_commands.ENGINE_wing_fuel_sw, value_up = 0, cockpit_device_id = devices.ENGINE,        name = _('Fuel Dump Switch - DUMP else OFF'),                                   category = {_('Console Left'), _('Engine Control Panel')}},
    {down = device_commands.ENGINE_wing_fuel_sw, value_down = 1, cockpit_device_id = devices.ENGINE,                                                                name = _('Fuel Dump Switch - DUMP'),                                            category = {_('Console Left'), _('Engine Control Panel')}},
    {down = device_commands.ENGINE_wing_fuel_sw, value_down = 0, cockpit_device_id = devices.ENGINE,                                                                name = _('Fuel Dump Switch - OFF'),                                             category = {_('Console Left'), _('Engine Control Panel')}},
    {down = device_commands.ENGINE_wing_fuel_sw, value_down = -1, up = device_commands.ENGINE_wing_fuel_sw, value_up = 0, cockpit_device_id = devices.ENGINE,       name = _('Fuel Dump Switch - EMER TRANS else OFF'),                             category = {_('Console Left'), _('Engine Control Panel')}},
    {down = device_commands.ENGINE_wing_fuel_sw, value_down = -1, cockpit_device_id = devices.ENGINE,                                                               name = _('Fuel Dump Switch - EMER TRANS'),                                      category = {_('Console Left'), _('Engine Control Panel')}},
    -- {down = iCommandPlaneFuelOn, up = iCommandPlaneFuelOff,                                                                                                      name = _('Fuel Dump Switch - ON else OFF'),                                     category = {_('Console Left'), _('Engine Control Panel')}},
    
    -- AN/APG-53A Radar Control Panel
    {down = Keys.RadarModeOFF,                                                          name = _('AN/APG-53A Radar Mode - OFF'),                           category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeSTBY,                                                         name = _('AN/APG-53A Radar Mode - STBY'),                          category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeSearch,                                                       name = _('AN/APG-53A Radar Mode - SRCH'),                          category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeTC,                                                           name = _('AN/APG-53A Radar Mode - TC'),                            category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeA2G,                                                          name = _('AN/APG-53A Radar Mode - A/G'),                           category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeSearch, up = Keys.RadarModeTC,                                name = _('AN/APG-53A Radar Mode - SRCH else TC'),                  category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeA2G, up = Keys.RadarModeTC,                                   name = _('AN/APG-53A Radar Mode - A/G else TC'),                   category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarMode,                                                             name = _('AN/APG-53A Radar Mode Selector - Cycle'),                category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeCW,                                                           name = _('AN/APG-53A Radar Mode Selector - Rotary CW'),            category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarModeCCW,                                                          name = _('AN/APG-53A Radar Mode Selector - Rotary CCW'),           category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarAoAComp, value_down = 1,                                          name = _('Radar AoA Compensation Switch - ON'),                    category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarAoAComp, value_down = 0,                                          name = _('Radar AoA Compensation Switch - OFF'),                   category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarAoAComp, value_down = -1,                                         name = _('Radar AoA Compensation Switch - ON/OFF'),                category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarAoAComp, value_down = 1, up = Keys.RadarAoAComp, value_up = 0,    name = _('Radar AoA Compensation Switch - ON else OFF'),           category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarVolume, value_down = 1,                                           name = _('Radar Obstacle Tone Volume - Rotary Increment'),         category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarVolume, value_down = 0,                                           name = _('Radar Obstacle Tone Volume - Rotary Decrement'),         category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarVolumeStartUp, up = Keys.RadarVolumeStop,                         name = _('Radar Obstacle Tone Volume - Continuous Increase'),      category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarVolumeStartDown, up = Keys.RadarVolumeStop,                       name = _('Radar Obstacle Tone Volume - Continuous Decrease'),      category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarTiltInc,                                                          name = _('Radar Antenna Tilt - Rotary CW'),                        category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarTiltDec,                                                          name = _('Radar Antenna Tilt - Rotary CCW'),                       category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarTiltStartUp, up = Keys.RadarTiltStop,                             name = _('Radar Antenna Tilt - Continuous CW'),                    category = {_('Console Left'), _('AN/APG-53A Radar')}},
    {down = Keys.RadarTiltStartDown, up = Keys.RadarTiltStop,                           name = _('Radar Antenna Tilt - Continuous CCW'),                   category = {_('Console Left'), _('AN/APG-53A Radar')}},

    -- AFCS Panel
    {down = device_commands.afcs_standby, value_down = 1, up = device_commands.afcs_standby, value_up = 0, cockpit_device_id = devices.AFCS,    name = _('AFCS Standby Switch - STANDBY else OFF'),                                 category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = Keys.AFCSStandbyToggle,                                                                                                             name = _('AFCS Standby Switch - STANDBY/OFF'),                                      category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_standby, value_down = 1, cockpit_device_id = devices.AFCS,                                                     name = _('AFCS Standby Switch - STANDBY'),                                          category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_standby, value_down = 0, cockpit_device_id = devices.AFCS,                                                     name = _('AFCS Standby Switch - OFF'),                                              category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = Keys.AFCSStabAugToggle,                                                                                                             name = _('AFCS Stability Augmentation Switch (Yaw Damper) - STAB AUG/OFF'),         category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_stab_aug, value_down = 1, up = device_commands.afcs_stab_aug, value_up = 0, cockpit_device_id = devices.AFCS,  name = _('AFCS Stability Augmentation Switch (Yaw Damper) - STAB AUG else OFF'),    category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_stab_aug, value_down = 0, cockpit_device_id = devices.AFCS,                                                    name = _('AFCS Stability Augmentation Switch (Yaw Damper) - OFF'),                  category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_stab_aug, value_down = 1, cockpit_device_id = devices.AFCS,                                                    name = _('AFCS Stability Augmentation Switch (Yaw Damper) - STAB AUG'),             category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = Keys.AFCSEngageToggle,                                                                                                              name = _('AFCS Engage Switch - ENGAGE/OFF'),                                        category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_engage, value_down = 1, up = device_commands.afcs_engage, value_up = 0, cockpit_device_id = devices.AFCS,      name = _('AFCS Engage Switch - ENGAGE else OFF'),                                   category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_engage, value_down = 0, cockpit_device_id = devices.AFCS,                                                      name = _('AFCS Engage Switch - OFF'),                                               category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_engage, value_down = 1, cockpit_device_id = devices.AFCS,                                                      name = _('AFCS Engage Switch - ENGAGE'),                                            category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = Keys.AFCSAltitudeToggle,                                                                                                            name = _('AFCS Altitude Switch - ALT/OFF'),                                         category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_alt, value_down = 1, up = device_commands.afcs_alt, value_up = 0, cockpit_device_id = devices.AFCS,            name = _('AFCS Altitude Switch - ALT else OFF'),                                    category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_alt, value_down = 0, cockpit_device_id = devices.AFCS,                                                         name = _('AFCS Altitude Switch - OFF'),                                             category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_alt, value_down = 1, cockpit_device_id = devices.AFCS,                                                         name = _('AFCS Altitude Switch - ALT'),                                             category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = Keys.AFCSHeadingToggle,                                                                                                             name = _('AFCS Heading Select Switch - HDG SEL/OFF'),                               category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_hdg_sel, value_down = 1, up = device_commands.afcs_hdg_sel, value_up = 0, cockpit_device_id = devices.AFCS,    name = _('AFCS Heading Select Switch - HDG SEL else OFF'),                          category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_hdg_sel, value_down = 0, cockpit_device_id = devices.AFCS,                                                     name = _('AFCS Heading Select Switch - OFF'),                                       category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_hdg_sel, value_down = 1, cockpit_device_id = devices.AFCS,                                                     name = _('AFCS Heading Select Switch - HDG SEL'),                                   category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_hdg_set, value_down = 1, cockpit_device_id = devices.AFCS,                                                     name = _('AFCS Heading Select Pull-to-Set Knob - Rotary Increment'),                category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = device_commands.afcs_hdg_set, value_down = -1, cockpit_device_id = devices.AFCS,                                                    name = _('AFCS Heading Select Pull-to-Set Knob - Rotary Decrement'),                category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = Keys.afcs_hdg_set_start_up, up = Keys.afcs_hdg_set_stop,                                                                            name = _('AFCS Heading Select Pull-to-Set Knob - Continuous Increase'),             category = {_('Console Left'), _('AFCS Control Panel')}},
    {down = Keys.afcs_hdg_set_start_down, up = Keys.afcs_hdg_set_stop,                                                                          name = _('AFCS Heading Select Pull-to-Set Knob - Continuous Decrease'),             category = {_('Console Left'), _('AFCS Control Panel')}},

    -- Oxygen and Anti-G Panel
    {down = device_commands.oxygen_switch, value_down = 1, cockpit_device_id = devices.AVIONICS,                                                    name = _('Oxygen Switch - ON'),             category = {_('Console Left'), _('Systems')}},
    {down = device_commands.oxygen_switch, value_down = 0, cockpit_device_id = devices.AVIONICS,                                                    name = _('Oxygen Switch - OFF'),            category = {_('Console Left'), _('Systems')}},
    {down = device_commands.oxygen_switch, value_down = 1, up = device_commands.oxygen_switch, value_up = 0, cockpit_device_id = devices.AVIONICS,  name = _('Oxygen Switch - ON else OFF'),    category = {_('Console Left'), _('Systems')}},
    {down = Keys.OxygenToggle,                                                                                                                      name = _('Oxygen Switch - ON/OFF'),         category = {_('Console Left'), _('Systems')}},

    -- Canopy Control
    {down = Keys.Canopy,                                                        name = _('Canopy Lever - OPEN/CLOSE'),      category = {_('Console Left')}},
    {down = Keys.canopy_open,                                                   name = _('Canopy Lever - OPEN'),            category = {_('Console Left')}},
    {down = Keys.canopy_close,                                                  name = _('Canopy Lever - CLOSE'),           category = {_('Console Left')}},
    {down = Keys.canopy_close, up = Keys.canopy_open,                           name = _('Canopy Lever - CLOSE else OPEN'), category = {_('Console Left')}},

    ---------------------------------------------
    -- Right Console ----------------------------
    ---------------------------------------------
    -- APN-153 Doppler Radar Control Panel
    {down = device_commands.doppler_select, value_down = 0.0, cockpit_device_id = devices.NAV,  name = _('AN/APN-153 Doppler Navigation Radar Mode - OFF'),             category = {_('Console Right'), _('AN/APN-153 Doppler Navigation Radar')}},
    {down = device_commands.doppler_select, value_down = 0.1, cockpit_device_id = devices.NAV,  name = _('AN/APN-153 Doppler Navigation Radar Mode - STBY'),            category = {_('Console Right'), _('AN/APN-153 Doppler Navigation Radar')}},
    {down = device_commands.doppler_select, value_down = 0.2, cockpit_device_id = devices.NAV,  name = _('AN/APN-153 Doppler Navigation Radar Mode - LAND'),            category = {_('Console Right'), _('AN/APN-153 Doppler Navigation Radar')}},
    {down = device_commands.doppler_select, value_down = 0.3, cockpit_device_id = devices.NAV,  name = _('AN/APN-153 Doppler Navigation Radar Mode - SEA'),             category = {_('Console Right'), _('AN/APN-153 Doppler Navigation Radar')}},
    {down = device_commands.doppler_select, value_down = 0.4, cockpit_device_id = devices.NAV,  name = _('AN/APN-153 Doppler Navigation Radar Mode - TEST'),            category = {_('Console Right'), _('AN/APN-153 Doppler Navigation Radar')}},
    {down = Keys.NavDopplerCW,                                                                  name = _('AN/APN-153 Doppler Navigation Radar Mode Selector - CW'),     category = {_('Console Right'), _('AN/APN-153 Doppler Navigation Radar')}},
    {down = Keys.NavDopplerCCW,                                                                 name = _('AN/APN-153 Doppler Navigation Radar Mode Selector - CCW'),    category = {_('Console Right'), _('AN/APN-153 Doppler Navigation Radar')}},

    -- Navigation Control Panel
    {down = device_commands.ppos_lat_push, up = device_commands.ppos_lat_push, cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Present Latitude Push-to-Set Knob - PUSH'),  category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.ppos_lon_push, up = device_commands.ppos_lon_push, cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Present Longitude Push-to-Set Knob - PUSH'), category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.ppos_lat,                                       cockpit_device_id = devices.NAV, value_pressed = -0.015,        name = _('Present Latitude Push-to-Set Knob - CCW'),   category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.ppos_lat,                                       cockpit_device_id = devices.NAV, value_pressed = 0.015,         name = _('Present Latitude Push-to-Set Knob - CW'),    category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.ppos_lon,                                       cockpit_device_id = devices.NAV, value_pressed = -0.015,        name = _('Present Longitude Push-to-Set Knob - CCW'),  category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.ppos_lon,                                       cockpit_device_id = devices.NAV, value_pressed = 0.015,         name = _('Present Longitude Push-to-Set Knob - CW'),   category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},

    {down = device_commands.dest_lat_push, up = device_commands.dest_lat_push, cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Destination Latitude Push-to-Set Knob - PUSH'),       category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.dest_lon_push, up = device_commands.dest_lon_push, cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Destination Longitude Push-to-Set Knob - PUSH'),      category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.dest_lat,                                       cockpit_device_id = devices.NAV, value_pressed = -0.015,        name = _('Destination Latitude Push-to-Set Knob - CCW'),        category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.dest_lat,                                       cockpit_device_id = devices.NAV, value_pressed = 0.015,         name = _('Destination Latitude Push-to-Set Knob - CW'),         category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.dest_lon,                                       cockpit_device_id = devices.NAV, value_pressed = -0.015,        name = _('Destination Longitude Push-to-Set Knob - CCW'),       category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.dest_lon,                                       cockpit_device_id = devices.NAV, value_pressed = 0.015,         name = _('Destination Longitude Push-to-Set Knob - CW'),        category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},

    {down = device_commands.dest_lat_slew, up = device_commands.dest_lat_slew, cockpit_device_id = devices.NAV, value_down = -1, value_up = 0, name = _('Destination Latitude Slew Knob - CCW'),               category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.dest_lat_slew, up = device_commands.dest_lat_slew, cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Destination Latitude Slew Knob - CW'),                category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.dest_lon_slew, up = device_commands.dest_lon_slew, cockpit_device_id = devices.NAV, value_down = -1, value_up = 0, name = _('Destination Longitude Slew Knob - CCW'),              category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.dest_lon_slew, up = device_commands.dest_lon_slew, cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Destination Longitude Slew Knob - CW'),               category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},

    {down = device_commands.asn41_magvar_push,    up = device_commands.asn41_magvar_push,    cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Magnetic Variation Push-to-Set Knob - PUSH'), category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.asn41_magvar,                                                 cockpit_device_id = devices.NAV, value_pressed = -0.015,        name = _('Magnetic Variation Push-to-Set Knob - CCW'),  category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.asn41_magvar,                                                 cockpit_device_id = devices.NAV, value_pressed = 0.015,         name = _('Magnetic Variation Push-to-Set Knob - CW'),   category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},

    {down = device_commands.asn41_windspeed_push, up = device_commands.asn41_windspeed_push, cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Wind Speed Push-to-Set Knob - PUSH'),         category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.asn41_windspeed,                                              cockpit_device_id = devices.NAV, value_pressed = -0.015,        name = _('Wind Speed Push-to-Set Knob - CCW'),          category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.asn41_windspeed,                                              cockpit_device_id = devices.NAV, value_pressed = 0.015,         name = _('Wind Speed Push-to-Set Knob - CW'),           category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},

    {down = device_commands.asn41_winddir_push,   up = device_commands.asn41_winddir_push,   cockpit_device_id = devices.NAV, value_down = 1,  value_up = 0, name = _('Wind Direction Push-to-Set Knob - PUSH'),     category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.asn41_winddir,                                                cockpit_device_id = devices.NAV, value_pressed = -0.015,        name = _('Wind Direction Push-to-Set Knob - CCW'),      category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {pressed = device_commands.asn41_winddir,                                                cockpit_device_id = devices.NAV, value_pressed = 0.015,         name = _('Wind Direction Push-to-Set Knob - CW'),       category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},

    {down = device_commands.nav_select, value_down = 0.0, cockpit_device_id = devices.NAV,  name = _('AN/ASN-41 Function Selector - TEST'),         category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.nav_select, value_down = 0.1, cockpit_device_id = devices.NAV,  name = _('AN/ASN-41 Function Selector - OFF'),          category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.nav_select, value_down = 0.2, cockpit_device_id = devices.NAV,  name = _('AN/ASN-41 Function Selector - STBY'),         category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.nav_select, value_down = 0.3, cockpit_device_id = devices.NAV,  name = _('AN/ASN-41 Function Selector - D1'),           category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = device_commands.nav_select, value_down = 0.4, cockpit_device_id = devices.NAV,  name = _('AN/ASN-41 Function Selector - D2'),           category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = Keys.NavSelectCW,                                                               name = _('AN/ASN-41 Function Selector Switch - CW'),    category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},
    {down = Keys.NavSelectCCW,                                                              name = _('AN/ASN-41 Function Selector Switch - CCW'),   category = {_('Console Right'), _('AN/ASN-41 Navigation Computer')}},

    -- AN/ARN-52 TACAN Control Panel
    {down = device_commands.tacan_mode,  cockpit_device_id = devices.NAV, value_down = 0.0, name = _('AN/ARN-52 TACAN Mode - OFF'),                 category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = device_commands.tacan_mode,  cockpit_device_id = devices.NAV, value_down = 0.1, name = _('AN/ARN-52 TACAN Mode - REC'),                 category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = device_commands.tacan_mode,  cockpit_device_id = devices.NAV, value_down = 0.2, name = _('AN/ARN-52 TACAN Mode - T/R'),                 category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = device_commands.tacan_mode,  cockpit_device_id = devices.NAV, value_down = 0.3, name = _('AN/ARN-52 TACAN Mode - A/A'),                 category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanModeInc,                                                              name = _('AN/ARN-52 TACAN Mode Switch - CW'),           category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanModeDec,                                                              name = _('AN/ARN-52 TACAN Mode Switch - CCW'),          category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanChMajorInc,                                                           name = _('TACAN Channel 10s - Increase'),               category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanChMajorDec,                                                           name = _('TACAN Channel 10s - Decrease'),               category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanChMinorInc,                                                           name = _('TACAN Channel 1s - Increase'),                category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanChMinorDec,                                                           name = _('TACAN Channel 1s - Decrease'),                category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.NavReset,                                                                  name = _('TACAN and NDB Channel Reset'),                category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanVolumeInc,                                                            name = _('TACAN Volume - Rotary Increase'),             category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanVolumeDec,                                                            name = _('TACAN Volume - Rotary Decrease'),             category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanVolumeStartUp, up = Keys.TacanVolumeStop,                             name = _('TACAN Volume - Continuous Increase'),         category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {down = Keys.TacanVolumeStartDown, up = Keys.TacanVolumeStop,                           name = _('TACAN Volume - Continuous Decrease'),         category = {_('Console Right'), _('AN/ARN-52 TACAN')}},

    -- Seat Position Adjustment
    {down = device_commands.seat_adjustment, up = device_commands.seat_adjustment, cockpit_device_id = devices.SEAT, value_down = 1, value_up = 0,      name = _('Seat Adjustment Switch - UP else OFF'),   category = {_('Console Right'), _('View Cockpit')}},
    {down = device_commands.seat_adjustment, up = device_commands.seat_adjustment, cockpit_device_id = devices.SEAT, value_down = -1, value_up = 0,     name = _('Seat Adjustment Switch - DOWN else OFF'), category = {_('Console Right'), _('View Cockpit')}},

    -- MCL
    {down = device_commands.mcl_power_switch, up = device_commands.mcl_power_switch, cockpit_device_id = devices.MCL, value_down = 1, value_up = 0,     name = _('MCL Power Switch - BIT else ON'),         category = {_('Console Right'), _('AN/ARA-63 MCL (ICLS)')}},
    {down = device_commands.mcl_power_switch, cockpit_device_id = devices.MCL, value_down = 0,                                                          name = _('MCL Power Switch - ON'),                  category = {_('Console Right'), _('AN/ARA-63 MCL (ICLS)')}},
    {down = device_commands.mcl_power_switch, cockpit_device_id = devices.MCL, value_down = -1,                                                         name = _('MCL Power Switch - OFF'),                 category = {_('Console Right'), _('AN/ARA-63 MCL (ICLS)')}},
    {down = Keys.MCL_Power_Toggle,                                                                                                                      name = _('MCL Power Switch - ON/OFF'),              category = {_('Console Right'), _('AN/ARA-63 MCL (ICLS)')}},
    {down = Keys.MCL_Chan_Inc,                                                                                                                          name = _('MCL Channel Selector - CW/Increase'),     category = {_('Console Right'), _('AN/ARA-63 MCL (ICLS)')}},
    {down = Keys.MCL_Chan_Dec,                                                                                                                          name = _('MCL Channel Selector - CCW/Decrease'),    category = {_('Console Right'), _('AN/ARA-63 MCL (ICLS)')}},

    -- Fuel Transfer Bypass Switch
    {down = device_commands.fuel_transfer_bypass, cockpit_device_id = devices.ENGINE, value_down = 0,                                                           name = _('Fuel Transfer Switch - NORMAL'),              category = {_('Console Right'), _('Refueling')}},
    {down = device_commands.fuel_transfer_bypass, cockpit_device_id = devices.ENGINE, value_down = 1,                                                           name = _('Fuel Transfer Switch - BYPASS'),              category = {_('Console Right'), _('Refueling')}},
    {down = device_commands.fuel_transfer_bypass, up = device_commands.fuel_transfer_bypass, cockpit_device_id = devices.ENGINE, value_down = 1, value_up = 0,  name = _('Fuel Transfer Switch - BYPASS else NORMAL'),  category = {_('Console Right'), _('Refueling')}},
    {down = Keys.Fuel_Transfer_Bypass_Toggle,                                                                                                                   name = _('Fuel Transfer Switch - BYPASS/NORMAL'),       category = {_('Console Right'), _('Refueling')}},

    -- Interior Lights Panel
    {down = device_commands.intlight_whiteflood_CHANGE,                                     cockpit_device_id = devices.AVIONICS,  value_down = 0.1,                    name = _('White Floodlights Control - Rotary Increment'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_whiteflood_CHANGE,                                     cockpit_device_id = devices.AVIONICS,  value_down = -0.1,                   name = _('White Floodlights Control - Rotary Decrement'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = Keys.intlight_whiteflood_startup, up = Keys.intlight_whiteflood_stop,           cockpit_device_id = devices.AVIONICS,                                       name = _('White Floodlights Control - Continuous Increase'),            category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = Keys.intlight_whiteflood_startdown, up = Keys.intlight_whiteflood_stop,         cockpit_device_id = devices.AVIONICS,                                       name = _('White Floodlights Control - Continuous Decrease'),            category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_instruments_CHANGE,                                    cockpit_device_id = devices.AVIONICS,  value_down = 0.1,                    name = _('Instrument Lights Control - Rotary Increment'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_instruments_CHANGE,                                    cockpit_device_id = devices.AVIONICS,  value_down = -0.1,                   name = _('Instrument Lights Control - Rotary Decrement'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = Keys.intlight_instruments_startup, up = Keys.intlight_instruments_stop,         cockpit_device_id = devices.AVIONICS,                                       name = _('Instrument Lights Control - Continuous Increase'),            category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = Keys.intlight_instruments_startdown, up = Keys.intlight_instruments_stop,       cockpit_device_id = devices.AVIONICS,                                       name = _('Instrument Lights Control - Continuous Decrease'),            category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_console_CHANGE,                                        cockpit_device_id = devices.AVIONICS,  value_down = 0.1,                    name = _('Console Lights Control - Rotary Increment'),                  category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_console_CHANGE,                                        cockpit_device_id = devices.AVIONICS,  value_down = -0.1,                   name = _('Console Lights Control - Rotary Decrement'),                  category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = Keys.intlight_console_startup, up = Keys.intlight_console_stop,                 cockpit_device_id = devices.AVIONICS,                                       name = _('Console Lights Control - Continuous Increase'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = Keys.intlight_console_startdown, up = Keys.intlight_console_stop,               cockpit_device_id = devices.AVIONICS,                                       name = _('Console Lights Control - Continuous Decrease'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_brightness,                                            cockpit_device_id = devices.AVIONICS,  value_down = 1.0,                    name = _('Instrument Lights Brightness Switch - BRIGHT'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_brightness,                                            cockpit_device_id = devices.AVIONICS,  value_down = 0.0,                    name = _('Instrument Lights Brightness Switch - DIM'),                  category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_brightness,                                            cockpit_device_id = devices.AVIONICS,  value_down = -1.0,                   name = _('Instrument Lights Brightness Switch - MEDIUM'),               category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_brightness, up = device_commands.intlight_brightness,  cockpit_device_id = devices.AVIONICS,  value_down = 1.0, value_up = 0.0,    name = _('Instrument Lights Brightness Switch - BRIGHT else DIM'),      category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = device_commands.intlight_brightness, up = device_commands.intlight_brightness,  cockpit_device_id = devices.AVIONICS,  value_down = -1.0, value_up = 0.0,   name = _('Instrument Lights Brightness Switch - MEDIUM else DIM'),      category = {_('Console Right'), _('Interior Lights Panel')}},
    {down = Keys.IntLightBrightness,                                                                                                                                    name = _('Instrument Lights Brightness - Cycle'),                       category = {_('Console Right'), _('Interior Lights Panel')}},
    
    -- Exterior Lights Panel
    {down = Keys.ExtLightProbeCycle,                                                                   name = _('Probe Light - Cycle'),                  category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightProbe, value_down = 1,                                                        name = _('Probe Light Switch - BRIGHT'),          category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightProbe, value_down = -1,                                                       name = _('Probe Light Switch - DIM'),             category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightProbe, value_down = 0,                                                        name = _('Probe Light Switch - OFF'),             category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightProbe, value_down = 1, up = Keys.ExtLightProbe, value_up = 0,                 name = _('Probe Light Switch - BRIGHT else OFF'), category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightProbe, value_down = -1, up = Keys.ExtLightProbe, value_up = 0,                name = _('Probe Light Switch - DIM else OFF'),    category = {_('Console Right'), _('Exterior Lights Panel')}},

    {down = Keys.ExtLightTaxi, value_down = 1,                                                         name = _('Taxi Light Switch - ON'),               category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTaxi, value_down = 0,                                                         name = _('Taxi Light Switch - OFF'),              category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTaxiToggle,                                                                   name = _('Taxi Light Switch - ON/OFF'),           category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTaxi, value_down = 1, up = Keys.ExtLightTaxi, value_up = 0,                   name = _('Taxi Light Switch - ON else OFF'),      category = {_('Console Right'), _('Exterior Lights Panel')}},

    {down = Keys.ExtLightAnticollision, value_down = 1,                                                name = _('Anti-Collision Light Switch - ON'),          category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightAnticollision, value_down = 0,                                                name = _('Anti-Collision Light Switch - OFF'),         category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightAnticollisionToggle,                                                          name = _('Anti-Collision Light Switch - ON/OFF'),      category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightAnticollision, value_down = 1, up = Keys.ExtLightAnticollision, value_up = 0, name = _('Anti-Collision Light Switch - ON else OFF'), category = {_('Console Right'), _('Exterior Lights Panel')}},

    {down = Keys.ExtLightNavCycle,                                                                     name = _('Navigation Lights - Cycle'),                   category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightNav, value_down = 1,                                                          name = _('Navigation Lights Switch - BRIGHT'),           category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightNav, value_down = -1,                                                         name = _('Navigation Lights Switch - DIM'),              category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightNav, value_down = 0,                                                          name = _('Navigation Lights Switch - OFF'),              category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightNav, value_down = 1, up = Keys.ExtLightNav, value_up = 0,                     name = _('Navigation Lights Switch - BRIGHT else OFF'),  category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightNav, value_down = -1, up = Keys.ExtLightNav, value_up = 0,                    name = _('Navigation Lights Switch - DIM else OFF'),     category = {_('Console Right'), _('Exterior Lights Panel')}},

    {down = Keys.ExtLightTailCycle,                                                                    name = _('Tail Light - Cycle'),                   category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTail, value_down = 1,                                                         name = _('Tail Light Switch - BRIGHT'),           category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTail, value_down = -1,                                                        name = _('Tail Light Switch - DIM'),              category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTail, value_down = 0,                                                         name = _('Tail Light Switch - OFF'),              category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTail, value_down = 1, up = Keys.ExtLightTail, value_up = 0,                   name = _('Tail Light Switch - BRIGHT else OFF'),  category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightTail, value_down = -1, up = Keys.ExtLightTail, value_up = 0,                  name = _('Tail Light Switch - DIM else OFF'),     category = {_('Console Right'), _('Exterior Lights Panel')}},

    {down = Keys.ExtLightFuselageCycle,                                                                name = _('Fuselage Light - Cycle'),                    category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFuselage, value_down = 1,                                                     name = _('Fuselage Light Switch - BRIGHT'),            category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFuselage, value_down = -1,                                                    name = _('Fuselage Light Switch - DIM'),               category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFuselage, value_down = 0,                                                     name = _('Fuselage Light Switch - OFF'),               category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFuselage, value_down = 1, up = Keys.ExtLightFuselage, value_up = 0,           name = _('Fuselage Light Switch - BRIGHT else OFF'),   category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFuselage, value_down = -1, up = Keys.ExtLightFuselage, value_up = 0,          name = _('Fuselage Light Switch - DIM else OFF'),      category = {_('Console Right'), _('Exterior Lights Panel')}},

    {down = Keys.ExtLightFlashSteady, value_down = 1,                                                  name = _('Lighting Flash/Steady Switch - FLSH'),           category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFlashSteady, value_down = 0,                                                  name = _('Lighting Flash/Steady Switch - STDY'),           category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFlashSteadyToggle,                                                            name = _('Lighting Flash/Steady Switch - FLSH/STDY'),      category = {_('Console Right'), _('Exterior Lights Panel')}},
    {down = Keys.ExtLightFlashSteady, value_down = 1, up = Keys.ExtLightFlashSteady, value_up = 0,     name = _('Lighting Flash/Steady Switch - FLSH else STDY'), category = {_('Console Right'), _('Exterior Lights Panel')}},
	
	-- AN/ARC-51A UHF Radio
	{down = Keys.radio_ptt,                                                                     name = _('Radio Microphone Push to Talk (PTT)'),    category = {_('Throttle Panel'), _('Throttle Grip'), _('Communications'), _('AN/ARC-51A UHF Radio')}},
	{down = iCommandVoIPRadioPushToTalkEnableDisableVoice, value_down = 1, up = iCommandVoIPRadioPushToTalkEnableDisableVoice, value_up = 0, name = _('Radio Microphone Push to Talk VOIP (PTT) - Transmit'), category = {_('Throttle Panel'), _('Throttle Grip'), _('Communications'), _('AN/ARC-51A UHF Radio')}},
	{down = iCommandVoIPRadioPushToTalkEnableDisableVoice_1, value_down = 1, up = iCommandVoIPRadioPushToTalkEnableDisableVoice_1, value_up = 0, name = _('Radio Microphone Push to Talk VOIP (PTT) - Guard'), category = {_('Throttle Panel'), _('Throttle Grip'), _('Communications'), _('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHF10MHzInc,                                                                   name = _('Radio Frequency 10 MHz - Increase'),      category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHF10MHzDec,                                                                   name = _('Radio Frequency 10 MHz - Decrease'),      category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHF1MHzInc,                                                                    name = _('Radio Frequency 1 MHz - Increase'),       category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHF1MHzDec,                                                                    name = _('Radio Frequency 1 MHz - Decrease'),       category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHF50kHzInc,                                                                   name = _('Radio Frequency 50 kHz - Increase'),      category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHF50kHzDec,                                                                   name = _('Radio Frequency 50 kHz - Decrease'),      category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFPresetChannelInc,                                                           name = _('Radio Preset Channel Knob - Increase'),   category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFPresetChannelDec,                                                           name = _('Radio Preset Channel Knob - Decrease'),   category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFFreqModeInc,                                                                name = _('Radio Frequency Mode Switch - CW'),       category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFFreqModeDec,                                                                name = _('Radio Frequency Mode Switch - CCW'),      category = {_('AN/ARC-51A UHF Radio')}},
    {down = device_commands.arc51_xmitmode, value_down = 1, cockpit_device_id = devices.RADIO,  name = _('Radio Frequency Mode - PRESET CHAN'),     category = {_('AN/ARC-51A UHF Radio')}},
    {down = device_commands.arc51_xmitmode, value_down = 0, cockpit_device_id = devices.RADIO,  name = _('Radio Frequency Mode - MANUAL'),          category = {_('AN/ARC-51A UHF Radio')}},
    {down = device_commands.arc51_xmitmode, value_down = -1, cockpit_device_id = devices.RADIO, name = _('Radio Frequency Mode - GD XMIT'),         category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFModeInc,                                                                    name = _('AN/ARC-51A UHF Radio Mode Switch - CW'),  category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFModeDec,                                                                    name = _('AN/ARC-51A UHF Radio Mode Switch - CCW'), category = {_('AN/ARC-51A UHF Radio')}},
    {down = device_commands.arc51_mode, value_down = 0.0, cockpit_device_id = devices.RADIO,    name = _('AN/ARC-51A UHF Radio Mode - OFF'),        category = {_('AN/ARC-51A UHF Radio')}},
    {down = device_commands.arc51_mode, value_down = 0.1, cockpit_device_id = devices.RADIO,    name = _('AN/ARC-51A UHF Radio Mode - T/R'),        category = {_('AN/ARC-51A UHF Radio')}},
    {down = device_commands.arc51_mode, value_down = 0.2, cockpit_device_id = devices.RADIO,    name = _('AN/ARC-51A UHF Radio Mode - T/R + G'),    category = {_('AN/ARC-51A UHF Radio')}},
    {down = device_commands.arc51_mode, value_down = 0.3, cockpit_device_id = devices.RADIO,    name = _('AN/ARC-51A UHF Radio Mode - ADF'),        category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFVolumeInc,                                                                  name = _('Radio Volume - Rotary Increment'),        category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFVolumeDec,                                                                  name = _('Radio Volume - Rotary Decrement'),        category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFVolumeStartUp, up = Keys.UHFVolumeStop,                                     name = _('Radio Volume - Continuous Increase'),     category = {_('AN/ARC-51A UHF Radio')}},
    {down = Keys.UHFVolumeStartDown, up = Keys.UHFVolumeStop,                                   name = _('Radio Volume - Continuous Decrease'),     category = {_('AN/ARC-51A UHF Radio')}},

    ---------------------------------------------
    -- Accessibility / Gamepads
    ---------------------------------------------
    {down = Keys.modifier_left_down, up = Keys.modifier_left_up,                                name = _('UI Override - Right Shoulder (LCtrl + Mouse 1/Left Click)'), category = {_('Accessibility')}},
    {down = Keys.modifier_right_down, up = Keys.modifier_right_up,                              name = _('UI Override - Left Shoulder (LShift + Mouse 2/Right Click)'), category = {_('Accessibility')}},

    ---------------------------------------------
    -- Special for Joysticks and Warthog Throttle
    ---------------------------------------------
    {down = Keys.AFCSHotasPath,                             name = _('AFCS Path Mode'),                                                 category = {_('Console Left'), _('AFCS Control Panel'), _('Special For Joystick')}},
    {down = Keys.AFCSHotasAltHdg,                           name = _('AFCS Altitude + Heading Modes'),                                  category = {_('Console Left'), _('AFCS Control Panel'), _('Special For Joystick')}},
    {down = Keys.AFCSHotasAlt,                              name = _('AFCS Altitude Mode'),                                             category = {_('Console Left'), _('AFCS Control Panel'), _('Special For Joystick')}},
    {down = Keys.AFCSHotasPath, up = Keys.AFCSHotasAltHdg,  name = _('AFCS Path Mode else Altitude + Heading (Warthog Throttle)'),      category = {_('Console Left'), _('AFCS Control Panel'), _('Special For Joystick')}},
    {down = Keys.AFCSHotasAlt, up = Keys.AFCSHotasAltHdg,   name = _('AFCS Altitude Mode else Altitude + Heading (Warthog Throttle)'),  category = {_('Console Left'), _('AFCS Control Panel'), _('Special For Joystick')}},
    {down = Keys.AFCSHotasEngage,                           name = _('AFCS Engage (Warthog Throttle)'),                                 category = {_('Console Left'), _('AFCS Control Panel'), _('Special For Joystick')}},

})

-- joystick axes 
join(res.axisCommands,{

    {combos = defaultDeviceAssignmentFor("roll"), action = iCommandPlaneRoll,           name = _('Roll'),                           category = {_('Flight Control')}},
    {combos = defaultDeviceAssignmentFor("pitch"), action = iCommandPlanePitch,         name = _('Pitch'),                          category = {_('Flight Control')}},
	{combos = defaultDeviceAssignmentFor("rudder"), action = iCommandPlaneRudder,		name = _('Rudder'),                         category = {_('Flight Control')}},
    {action = device_commands.rudder_axis_left, cockpit_device_id = devices.TRIM,       name = _('Rudder - Left (Dual-Axis)'),      category = {_('Flight Control'), _('Accessibility')}},
    {action = device_commands.rudder_axis_right, cockpit_device_id = devices.TRIM,      name = _('Rudder - Right (Dual-Axis)'),     category = {_('Flight Control'), _('Accessibility')}},

    {combos = defaultDeviceAssignmentFor("thrust"), action = iCommandPlaneThrustCommon, name = _('Throttle'),                       category = {_('Flight Control')}},
    {action = device_commands.throttle_axis_slew, cockpit_device_id = devices.ENGINE,   name = _('Throttle - Slew'),                category = {_('Flight Control'), _('Accessibility')}},

    {action = device_commands.wheelbrake_AXIS,                                          name = _('Wheel Brake'),                    category = {_('Systems')}},
    {action = device_commands.left_wheelbrake_AXIS,                                     name = _('Wheel Brake Left'),               category = {_('Systems')}},
    {action = device_commands.right_wheelbrake_AXIS,                                    name = _('Wheel Brake Right'),              category = {_('Systems')}},
    {action = device_commands.combined_wheel_brake_axis,                    name = _('Wheel Brake Differential (Single-Axis)'),     category = {_('Systems'), _('Accessibility')}},

    {action = device_commands.zoom_axis_in, cockpit_device_id = devices.SEAT,       name = _('Zoom View In (Dual Axis)'),           category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {action = device_commands.zoom_axis_out, cockpit_device_id = devices.SEAT,      name = _('Zoom View Out (Dual Axis)'),          category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {action = device_commands.zoom_axis_slew, cockpit_device_id = devices.SEAT,     name = _('Zoom View - Slew'),                   category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {action = device_commands.zoom_axis_slew_in, cockpit_device_id = devices.SEAT,  name = _('Zoom View In - Slew (Dual-Axis)'),    category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {action = device_commands.zoom_axis_slew_out, cockpit_device_id = devices.SEAT, name = _('Zoom View Out - Slew (Dual-Axis)'),   category = {_('View'), _('View Cockpit'), _('Accessibility')}},

    {combos = {{key = 'TRACKIR_PITCH'}}, action = iHeadTrackerPitchNormed,              name = _('Head Tracker : Pitch'),            category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {combos = {{key = 'TRACKIR_YAW'}}, action = iHeadTrackerYawNormed,                  name = _('Head Tracker : Yaw'),              category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {combos = {{key = 'TRACKIR_ROLL'}}, action = iHeadTrackerRollNormed,                name = _('Head Tracker : Roll'),             category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    
    {combos = {{key = 'TRACKIR_X'}}, action = iHeadTrackerPosZNormed,                   name = _('Head Tracker : Right/Left'),       category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {combos = {{key = 'TRACKIR_Y'}}, action = iHeadTrackerPosYNormed,                   name = _('Head Tracker : Up/Down'),          category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    {combos = {{key = 'TRACKIR_Z'}}, action = iHeadTrackerPosXNormed,                   name = _('Head Tracker : Forward/Backward'), category = {_('View'), _('View Cockpit'), _('Accessibility')}},
    
    ---------------------------------------------
    -- ECM Control Panel / AN/APR-25 Radar Homing and Warning System
    --------------------------------------------- 
    {action = device_commands.ecm_msl_alert_axis_inner_abs, cockpit_device_id = devices.RWR,            name = _('AN/APR-25 PRF Volume - Absolute'),            category = {_('AN/APR-25 RHWS (ECM)')}}, 
    {action = device_commands.ecm_msl_alert_axis_inner_slew, cockpit_device_id = devices.RWR,           name = _('AN/APR-25 PRF Volume - Slew'),                category = {_('AN/APR-25 RHWS (ECM)')}}, 
    {action = device_commands.ecm_msl_alert_axis_outer_abs, cockpit_device_id = devices.RWR,            name = _('AN/APR-25 Missile Alert Volume - Absolute'),  category = {_('AN/APR-25 RHWS (ECM)')}}, 
    {action = device_commands.ecm_msl_alert_axis_outer_slew, cockpit_device_id = devices.RWR,           name = _('AN/APR-25 Missile Alert Volume - Slew'),      category = {_('AN/APR-25 RHWS (ECM)')}}, 

    -- AN/APN-141 Radar Altimeter    
    {action = device_commands.radar_altitude_warning_axis_slew, cockpit_device_id = devices.RADARWARN,  name = _('Radar Altitude Warning - Slew'),              category = {_('Instrument Panel'), _('Systems'), _('AN/APN-141 Radar Altimeter')}},

    -- Miscellaneous Switches Panel
    {action = device_commands.shrike_sidewinder_volume_abs, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('Shrike/Sidewinder Volume Knob - Absolute'),   category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('Weapons')}},
    {action = device_commands.shrike_sidewinder_volume_slew, cockpit_device_id = devices.WEAPON_SYSTEM, name = _('Shrike/Sidewinder Volume Knob - Slew'),       category = {_('Instrument Panel'), _('Miscellaneous Switches Panel'), _('Weapons')}},

    -- Radar Indicator
    {action = device_commands.radar_storage_axis_abs, cockpit_device_id = devices.RADAR,                name = _('Radar Indicator Storage Knob - Absolute'),    category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_storage_axis_slew, cockpit_device_id = devices.RADAR,               name = _('Radar Indicator Storage Knob - Slew'),        category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_brilliance_axis_abs, cockpit_device_id = devices.RADAR,             name = _('Radar Indicator Brilliance Knob - Absolute'), category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_brilliance_axis_slew, cockpit_device_id = devices.RADAR,            name = _('Radar Indicator Brilliance Knob - Slew'),     category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_detail_axis_abs, cockpit_device_id = devices.RADAR,                 name = _('Radar Indicator Detail Knob - Absolute'),     category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_detail_axis_slew, cockpit_device_id = devices.RADAR,                name = _('Radar Indicator Detail Knob - Slew'),         category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_gain_axis_abs, cockpit_device_id = devices.RADAR,                   name = _('Radar Indicator Gain Knob - Absolute'),       category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_gain_axis_slew, cockpit_device_id = devices.RADAR,                  name = _('Radar Indicator Gain Knob - Slew'),           category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_reticle_axis_abs, cockpit_device_id = devices.RADAR,                name = _('Radar Indicator Reticle Knob - Absolute'),    category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},
    {action = device_commands.radar_reticle_axis_slew, cockpit_device_id = devices.RADAR,               name = _('Radar Indicator Reticle Knob - Slew'),        category = {_('Instrument Panel'), _('AN/APG-53A Radar Indicator')}},

    -- Radar Control Panel
    {action = device_commands.radar_angle_axis, cockpit_device_id = devices.RADAR,                      name = _('AN/APG-53A Radar Antenna Tilt - Slew'),       category = {_('Console Left'), _('Radar Control Panel'), _('AN/APG-53A Radar')}},
    {action = device_commands.radar_angle_axis_abs, cockpit_device_id = devices.RADAR,                  name = _('AN/APG-53A Radar Antenna Tilt - Absolute'),   category = {_('Console Left'), _('Radar Control Panel'), _('AN/APG-53A Radar')}},

    -- AN/ARN-52 TACAN Control Panel
    {action = device_commands.tacan_volume_axis_abs, cockpit_device_id = devices.NAV,                   name = _('TACAN Volume - Absolute'),                    category = {_('Console Right'), _('AN/ARN-52 TACAN')}},
    {action = device_commands.tacan_volume_axis_slew, cockpit_device_id = devices.NAV,                  name = _('TACAN Volume - Slew'),                        category = {_('Console Right'), _('AN/ARN-52 TACAN')}},

    -- Interior Lights Panel
    {action = device_commands.intlight_instruments_AXIS, cockpit_device_id = devices.AVIONICS,          name = _('Instrument Lights Control - Absolute'),       category = {_('Console Right'), _('Interior Lights Panel')}},
    {action = device_commands.intlight_instruments_axis_slew, cockpit_device_id = devices.AVIONICS,     name = _('Instrument Lights Control - Slew'),           category = {_('Console Right'), _('Interior Lights Panel')}},
    {action = device_commands.intlight_console_AXIS, cockpit_device_id = devices.AVIONICS,              name = _('Console Lights Control - Absolute'),          category = {_('Console Right'), _('Interior Lights Panel')}},
    {action = device_commands.intlight_console_axis_slew, cockpit_device_id = devices.AVIONICS,         name = _('Console Lights Control - Slew'),              category = {_('Console Right'), _('Interior Lights Panel')}},
    {action = device_commands.intlight_whiteflood_AXIS, cockpit_device_id = devices.AVIONICS,           name = _('White Floodlights Control - Absolute'),       category = {_('Console Right'), _('Interior Lights Panel')}},
    {action = device_commands.intlight_whiteflood_axis_slew, cockpit_device_id = devices.AVIONICS,      name = _('White Floodlights Control - Slew'),           category = {_('Console Right'), _('Interior Lights Panel')}},

    -- Aircraft Weapons Release System Panel
    {action = device_commands.AWRS_drop_interval_AXIS, cockpit_device_id = devices.WEAPON_SYSTEM,       name = _('AWRS Drop Interval Knob - Absolute'),         category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    {action = device_commands.awrs_drop_interval_axis_slew, cockpit_device_id = devices.WEAPON_SYSTEM,  name = _('AWRS Drop Interval Knob - Slew'),             category = {_('Instrument Panel'), _('AWE-1 Aircraft Weapons Release System'), _('Weapons')}},
    
    -- Gunsight Panel
    {action = device_commands.gunsight_brightness_axis, cockpit_device_id = devices.GUNSIGHT,           name = _('Gunsight Light Control - Slew'),              category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {action = device_commands.gunsight_brightness_axis_abs, cockpit_device_id = devices.GUNSIGHT,       name = _('Gunsight Light Control - Absolute'),          category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {action = device_commands.gunsight_elevation_axis, cockpit_device_id = devices.GUNSIGHT,            name = _('Gunsight Elevation Control - Slew'),          category = {_('Instrument Panel'), _('Gunsight Panel')}},
    {action = device_commands.gunsight_elevation_axis_abs, cockpit_device_id = devices.GUNSIGHT,        name = _('Gunsight Elevation Control - Absolute'),      category = {_('Instrument Panel'), _('Gunsight Panel')}},

    --UI Override
    {action = device_commands.mouse_x,                                                                  name = _('UI Override - Mouse Cursor X'),               category = {_('UI Override'), _('Accessibility')}},
    {action = device_commands.mouse_y,                                                                  name = _('UI Override - Mouse Cursor Y'),               category = {_('UI Override'), _('Accessibility')}},

    
})
return res