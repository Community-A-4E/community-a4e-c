mount_vfs_texture_archives("Bazar/Textures/AvionicsCommon")
-- mount_vfs_texture_archives(LockOn_Options.script_path.."../Resources/Model/Textures/WunderluftTextures")

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.common_script_path.."tools.lua")
dofile(LockOn_Options.script_path.."materials.lua")

--	items in <...> are optional
--
-- MainPanel = {"NAME_OF_CLASS",
--				"INIT_SCRIPT_FILE",
--				<{devices.LINKED_DEVICE1, devices.LINKED_DEVICE2, ...},>
--			   }

--MainPanel = {"ccMainPanel",
--			 LockOn_Options.script_path.."mainpanel_init.lua",
--				{{"engine_system",devices.ENGINE_SYSTEM}},
 --           }


layoutGeometry = {}

MainPanel = {"ccMainPanel",LockOn_Options.script_path.."mainpanel_init.lua",
{
    --{"INTERCOM", devices.INTERCOM},
    --{"UHF_Radio", devices.UHF_RADIO},
    --{"OxygenSystem", devices.TEMP3},
    --{"avSimpleElectricSystem", devices.ELECTRIC_SYSTEM}, -- DCS.log: ERROR   COCKPITBASE: devices_keeper::link_all: unable to find link target 'avSimpleElectricSystem' for device 'MAIN_PANEL'
    --{"LightSystem", devices.TEMP1},
--[[
    {
    devices.INTERCOM, -- DCS.log: ERROR   COCKPITBASE: devices_keeper::link_all: unable to find link target '28' for device 'MAIN_PANEL'
    devices.UHF_RADIO,
    devices.ELECTRIC_SYSTEM,
    },
--]]
},
}

-- Avionics devices initialization example
--	items in <...> are optional
--
-- creators[DEVICE_ID] = {"NAME_OF_CONTROLLER_CLASS",
--						  <"CONTROLLER_SCRIPT_FILE",>
--						  <{devices.LINKED_DEVICE1, devices.LINKED_DEVICE2, ...},>
--						  <"INPUT_COMMANDS_SCRIPT_FILE",>
--						  <{{"NAME_OF_INDICATOR_CLASS", "INDICATOR_SCRIPT_FILE"}, ...}>
--						 }
creators                          = {}
creators[devices.ILS]           = {"avILS",               LockOn_Options.script_path.."Systems/ils.lua", {devices.ELECTRIC_SYSTEM}}
--creators[devices.TACAN]           = {"eqSidewinder",               LockOn_Options.script_path.."Systems/tacan.lua", {devices.INTERCOM, devices.ELECTRIC_SYSTEM}}
--creators[devices.TACAN]           = {"avTACAN_ARN118",               LockOn_Options.script_path.."Systems/tacan.lua", {devices.ELECTRIC_SYSTEM}}
--creators[devices.TACAN_CTRL]      = {"avTACAN_ARN118_CtrlPanel",               LockOn_Options.script_path.."Systems/tacan_ctrl.lua", {devices.TACAN}}
creators[devices.WEAPON_SYSTEM]   = {"avSimpleWeaponSystem"  ,LockOn_Options.script_path.."Systems/weapon_system.lua"}
creators[devices.AVIONICS]        = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/avionics.lua"}
creators[devices.CLOCK]           = {"avLuaDevice"           ,LockOn_Options.script_path.."clock.lua"}
creators[devices.ELECTRIC_SYSTEM] = {"avSimpleElectricSystem",LockOn_Options.script_path.."Systems/electric_system.lua",}
creators[devices.HYDRAULIC_SYSTEM]= {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/hydraulic_system.lua"}
creators[devices.SLATS]           = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/slats.lua"}
creators[devices.AIRBRAKES]       = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/airbrakes.lua"}
creators[devices.FLAPS]           = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/flaps.lua"}
creators[devices.GEAR]            = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/gear.lua"}    -- covers gear & hook
creators[devices.SPOILERS]        = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/spoilers.lua"}
creators[devices.EXTANIM]         = {"avLuaDevice"           ,LockOn_Options.script_path.."externalanimations.lua"}
creators[devices.CANOPY]          = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/canopy.lua"}
creators[devices.HUFFER]          = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/huffer.lua"}
creators[devices.HUD]             = {"avLuaDevice"           ,LockOn_Options.script_path.."HUD/hud_disp.lua"}
creators[devices.RADARWARN]       = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/radarwarn.lua"}
creators[devices.ENGINE]          = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/engine.lua"}
creators[devices.BYPASS_FAN]      = {"avLuaDevice"           ,LockOn_Options.script_path.."bypass_fan.lua"}
creators[devices.GUNSIGHT]        = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/gunsight.lua"}
creators[devices.RADAR]           = {"avLuaDevice"           ,LockOn_Options.script_path.."RADAR/apg53a.lua"}
creators[devices.EXT_LIGHTS]      = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/ext_lights.lua"}
creators[devices.NAV]             = {"avLuaDevice"           ,LockOn_Options.script_path.."Nav/nav.lua"}
creators[devices.TRIM]            = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/trim.lua"}
creators[devices.AFCS]            = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/afcs2.lua"}
creators[devices.RADIO]           = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/radio_controls2.lua"}
creators[devices.INTERCOM]        = {"avIntercom"            ,LockOn_Options.script_path.."intercom.lua"                           ,{devices.UHF_RADIO, devices.UHF_RADIO_GUARD} }
creators[devices.UHF_RADIO]       = {"avUHF_ARC_164"         ,LockOn_Options.script_path.."uhf_radio.lua"                             ,{devices.INTERCOM    ,devices.ELECTRIC_SYSTEM} }
creators[devices.UHF_RADIO_GUARD] = {"avUHF_ARC_164"         ,LockOn_Options.script_path.."uhf_radio.lua"                             ,{devices.INTERCOM    ,devices.ELECTRIC_SYSTEM} }
--creators[devices.CARRIER]         = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/carrier.lua"}
creators[devices.RWR]             = {"avSimpleRWR"           ,LockOn_Options.script_path.."Systems/rwr.lua"}
creators[devices.COUNTERMEASURES] = {"avSimpleWeaponSystem"  ,LockOn_Options.script_path.."Systems/countermeasures.lua"}
--creators[devices.SFMEXTENDER]     = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/sfm_extender.lua"}
creators[devices.SHRIKE]          = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/shrike.lua"                        ,{devices.RWR}}
creators[devices.SOUNDSYSTEM]     = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/sound_system.lua"}
--creators[devices.ILS]             = {"avLuaDevice"           ,LockOn_Options.script_path.."Nav/ils.lua"}
creators[devices.NVG]             = {"avNightVisionGoggles"  ,LockOn_Options.script_path.."HELMET/NVG.lua"                            ,{}}
creators[devices.EFM_DATA_BUS]		= {"avLuaDevice", LockOn_Options.script_path.."EFM_Data_Bus.lua"}
creators[devices.MCL]             = {"avLuaDevice", LockOn_Options.script_path.."Nav/ara63_mcl.lua"}
creators[devices.ADI_AJB3A]       = {"avLuaDevice", LockOn_Options.script_path.."Systems/adi_ajb3a.lua"}
creators[devices.NVG_CONTROLS]       = {"avLuaDevice", LockOn_Options.script_path.."HELMET/NVG_Controls.lua"}
creators[devices.SEAT]            = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/seat.lua"}
creators[devices.TACAN]            = {"avLuaDevice"           ,LockOn_Options.script_path.."Nav/tacan.lua"}
--creators[devices.RWR_APR25]       = {"avLuaDevice"           ,LockOn_Options.script_path.."APR-25_RWR/rwr_apr-25.lua"}

-- creators[devices.TEST]        = {"avLuaDevice"                        ,LockOn_Options.script_path.."test_device.lua"}
-- creators[devices.ADI]         = {"avBaseIKP"                          ,LockOn_Options.script_path.."adi.lua"}
-- creators[devices.INTERCOM]    = {"avIntercom"                         ,LockOn_Options.script_path.."dummy_radio.lua"     ,{{"avUHF_ARC_164"           ,devices.UHF_RADIO}} }
-- creators[devices.UHF_RADIO]   = {"avUHF_ARC_164"                      ,LockOn_Options.script_path.."uhf_radio.lua"       ,{{"avIntercom"              ,devices.INTERCOM}} }
-- creators[devices.TEMP1]       = {"avBasicLightSystem"                 ,LockOn_Options.script_path.."dump_device.lua"     , {{"ElecInterface"          , devices.ELECTRIC_SYSTEM}} }
-- creators[devices.TEMP2]       = {"avBasicHearingSensitivityInterface" ,LockOn_Options.script_path.."dump_device.lua"     , {{"Oxygen"                 , devices.TEMP3}} }
-- creators[devices.TEMP3]       = {"avBasicOxygenSystemInterface"       ,LockOn_Options.script_path.."dump_device.lua"     , {{"HearingSensitivity"     , devices.TEMP2}} }
-- creators[devices.OXYGEN]      = {"avBasicOxygenSystemInterface"       ,LockOn_Options.script_path.."dump_device.lua"     , {devices.TEMP2}            , LockOn_Options.script_path.."oxygen_system.lua" }

-- creators[devices.TEMP1]       = {"avBasicLightSystem"                 ,LockOn_Options.script_path.."dump_device.lua"     , {devices.ELECTRIC_SYSTEM} }
-- creators[devices.TEMP2]       = {"avBasicHearingSensitivityInterface" ,LockOn_Options.script_path.."dump_device.lua"     , {devices.OXYGEN} }
-- creators[devices.TEMP3]       = {"avUHF_ARC_164"                      ,LockOn_Options.script_path.."dump_device.lua" }

-- creators[devices.NAV_TERRAIN] = {"avLuaDevice"                        ,LockOn_Options.script_path.."Nav/terrainmask.lua"}

-- Indicators

tmp_tpl = {sz_I = 0.0, sx_I = 1.0, sy_I = 0.0, rz_I = 0.0, ry_I =0.0}

indicators                  = {}
indicators[#indicators + 1] = {"ccIndicator" ,            LockOn_Options.script_path.."HUD/Indicator/init.lua"      ,                 nil, {{"PNT_HUD_CENTER"  ,"PNT_HUD_DOWN"  ,"PNT_HUD_RIGHT"}}}
indicators[#indicators + 1] = {"ccIndicator" ,            LockOn_Options.script_path.."HUD/Indicator/init_debug.lua",                 nil, {{"PNT_RADAR_CENTER","PNT_RADAR_DOWN","PNT_RADAR_RIGHT"}}} -- debug
indicators[#indicators + 1] = {"ccIndicator" ,            LockOn_Options.script_path.."RADAR/Indicator/init.lua"    ,                 nil, {{"PNT_RADAR_CENTER","PNT_RADAR_DOWN","PNT_RADAR_RIGHT"}}}
indicators[#indicators + 1] = {"ccControlsIndicatorBase", LockOn_Options.script_path.."ControlsIndicator/ControlsIndicator.lua",      nil}
indicators[#indicators + 1] = {"ccIndicator" ,            LockOn_Options.script_path.."AN_ARC51/indicator/frequency_labels_init.lua", nil, {{"PNT_RADIO_CENTER","PNT_RADIO_DOWN","PNT_RADIO_RIGHT"}}}


-- NEW RWR INDICATOR
--indicators[#indicators + 1] = {"ccIndicator",
--                               LockOn_Options.script_path.."APR-25_RWR/Indicators/Indicator.lua",
--                               nil,
--                               {{},{sx = -0.395, sy = -0.46, sz = 0.234, rz = -9}}}

--RADAROFF indicators[#indicators + 1] = {"ccIndicator",LockOn_Options.script_path.."RADAR/Indicator/init.lua",--init script
--RADAROFF   nil,--id of parent device
--RADAROFF   {
--RADAROFF 	{}, -- initial geometry anchor , triple of connector names
--RADAROFF 	{sx_l =  0,  -- center position correction in meters (forward , backward)
--RADAROFF 	 sy_l =  0,  -- center position correction in meters (up , down)
--RADAROFF 	 sz_l =  0.3,  -- center position correction in meters (left , right)
--RADAROFF 	 sh   =  0,  -- half height correction
--RADAROFF 	 sw   =  0,  -- half width correction
--RADAROFF 	 rz_l =  0,  -- rotation corrections
--RADAROFF 	 rx_l =  0,
--RADAROFF 	 ry_l =  0}
--RADAROFF   }
--RADAROFF } --RADAR

dofile(LockOn_Options.common_script_path.."KNEEBOARD/declare_kneeboard_device.lua")
dofile(LockOn_Options.common_script_path.."PADLOCK/PADLOCK_declare.lua")
