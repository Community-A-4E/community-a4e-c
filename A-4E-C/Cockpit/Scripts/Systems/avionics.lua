local dev = GetSelf()
dofile(LockOn_Options.script_path .. "ConfigurePackage.lua")

require(common_scripts.."devices_defs")
require("devices")
require("Systems.stores_config")
require("command_defs")
require("Systems.electric_system_api")
require("utils")
require("EFM_Data_Bus")
require("Systems.air_data_computer")
require("sound_params") 
require("Systems.mission")
require("Systems.mission_utils")

local update_time_step = 0.05
make_default_activity(update_time_step)--update will be called 20 times per second

startup_print("avionics: load")

local once_per_second_refresh = 1/update_time_step
local once_per_second = once_per_second_refresh
local five_times_per_second_refresh = 1/update_time_step
local five_times_per_second = five_times_per_second_refresh

local sensor_data = get_efm_sensor_data_overrides()
local efm_data_bus = get_efm_data_bus()


sensor_data.mod_fuel_flow = function()
	local org_fuel_flow = sensor_data.getEngineLeftFuelConsumption() 
	if org_fuel_flow > 0.9743 then org_fuel_flow = 0.9743 end
	return org_fuel_flow
end


-- Const

--local degrees_per_radian = 57.2957795
--local feet_per_meter_per_minute = 196.8
local meters_to_feet = 3.2808399
local mgH_to_pa = 3386.39
local MM_TO_INCHES = 0.0393701
local GALLON_TO_KG = 3.785 * 0.8
local KG_TO_POUNDS = 2.20462
local MPS_TO_KNOTS = 1.94384
local RADIANS_TO_DEGREES = 57.2958


local refueling_rate = (200/KG_TO_POUNDS) * update_time_step -- nominal = 200lbs/sec * tick size
local refueling_rate_upper_limit = refueling_rate * 1.2
local refueling_rate_lower_limit = refueling_rate * 0.8
local refueling_rate_tank_change = refueling_rate_upper_limit * 2

local iCommandPlaneEject = 83

-- Variables
--local ias = get_param_handle("D_IAS")

-----------------------------------------------------------------------------
-- AVIONICS SUITE POWER-UP WHINE
function update_avionics_power()
    if get_elec_primary_ac_ok() and get_elec_external_power() then
        sound_params.snd_inst_avionics_whine:set(1.0)
    else
        sound_params.snd_inst_avionics_whine:set(0.0)
    end
end

-----------------------------------------------------------------------------
-- AN/AJB-3A All-Attitude Indicator (gauge #19)

local adi_pitch = get_param_handle("ADI_PITCH")
local adi_roll = get_param_handle("ADI_ROLL")
local adi_hdg = get_param_handle("ADI_HDG")
local adi_off = get_param_handle("ADI_OFF")
local adi_slip = get_param_handle("ADI_SLIP")
local adi_turn = get_param_handle("ADI_TURN")
local backup_compass = get_param_handle("COMPASS_HDG")


-----------------------------------------------------------------------------
-- altimeter (gauge #41)

local ALT_PRESSURE_MAX = 30.99 -- in Hg
local ALT_PRESSURE_MIN = 29.10 -- in Hg
local ALT_PRESSURE_STD = 29.92 -- in Hg

local alt_needle = get_param_handle("D_ALT_NEEDLE") -- 0 to 1000
local alt_10k = get_param_handle("D_ALT_10K") -- 0 to 100,000
local alt_1k = get_param_handle("D_ALT_1K") -- 0 to 10,000
local alt_100s = get_param_handle("D_ALT_100S") -- 0 to 1000
local alt_adj_NNxx = get_param_handle("ALT_ADJ_NNxx") -- first digits, 29-30 is input
local alt_adj_xxNx = get_param_handle("ALT_ADJ_xxNx") -- 3rd digit, 0-10 input
local alt_adj_xxxN = get_param_handle("ALT_ADJ_xxxN") -- 4th digit, 0-10 input

local alt_setting = ALT_PRESSURE_STD
local alt_pressure_moving = 0
-----------------------------------------------------------------------------
-- fuel gauge (gauge #29)

local fuelgauge = get_param_handle("D_FUEL") -- 0 to 6800 lbs
local fuelflowgauge = get_param_handle("D_FUEL_FLOW")
local gauge_fuel_flow = WMA(0.15, 0)

local fuelQtyInternal = 0 -- internal fuel in pounds
local fuelQtyExternal = 0 -- external fuel in pounds
local fuelQtyTotal = 0    -- total fuel in pounds
local fuelQty = 0         -- fuel to display in pounds
local fuelLastQtyExternal = 0 -- used to pin the external fuel amount when engine shuts off for accurate display while rearming


local totalFuel = 0
local lastFuel = 0
local slowFuel = 10000

local initINT = 0
local initEXT = 0

local showingInternal = true        -- default to showing internal fuel
local refuelingOccurred = false 

-----------------------------------------------------------------------------
-- airspeed indicator (gauge #44)

local ias_needle = get_param_handle("D_IAS_DEG")    -- 0 to 360 degrees of rotation
local ias_mach = get_param_handle("D_IAS_MACH_DEG") -- 0 to 360 degrees of rotation

-----------------------------------------------------------------------------
-- flaps indicator (gauge #23)
local flaps_ind = get_param_handle("D_FLAPS_IND")   -- 0 to 1, 1 = fully down

-----------------------------------------------------------------------------
-- standby attitude gyro (gauge #33)
local attgyro_stby_pitch = get_param_handle("ATTGYRO_STBY_PITCH")
local attgyro_stby_roll = get_param_handle("ATTGYRO_STBY_ROLL")
local attgyro_stby_off = get_param_handle("ATTGYRO_STBY_OFF")
local attgyro_stby_horiz = get_param_handle("ATTGYRO_STBY_HORIZ")
local attgyro_stby_pushed = false
local standby_val = 0.0

-----------------------------------------------------------------------------
-- cabin altitude indicator (misc panel, arg #710)
local cabin_altitude = get_param_handle("CABIN_ALT")

-----------------------------------------------------------------------------
-- liquid oxygen indicator (gauge #44, arg #760)
local lo2_quantity = get_param_handle("LIQUID_O2")
local lo2_warning = get_param_handle("D_OXYGEN_LOW")
local lo2_flag = get_param_handle("D_OXYGEN_OFF")
local oxygen_reset = 9.7
local oxygen = oxygen_reset
local oxygen_gauge_val = WMA(0.15,oxygen)
--plusnine oxygen system
--enabled variable for system use (switch on)
local oxygen_enabled = false

-----------------------------------------------------------------------------
-- glareshield wheels light (arg #154)
local glareshield_WHEELS = get_param_handle("D_GLARE_WHEELS")
local glareshield_wheels_value = 0

-----------------------------------------------------------------------------
-- airspeed kts and Mach indexers (arg #882, #883)
local IAS_knots_indexer = get_param_handle("D_IAS_IDX")
local IAS_mach_indexer = get_param_handle("D_MACH_IDX")
local IAS_knots_indexer_val = 0
local IAS_mach_indexer_val = 0
local IAS_knots_indexer_gauge = WMA(0.15,0)
local IAS_mach_indexer_gauge = WMA(0.15,0)
local IAS_index_pushed = false

-----------------------------------------------------------------------------
-- master test
local master_test_param = get_param_handle("D_MASTER_TEST")

-----------------------------------------------------------------------------
-- AoA indicators on the dash
local aoa_green = get_param_handle("AOA_GREEN")
local aoa_yellow = get_param_handle("AOA_YELLOW")
local aoa_red = get_param_handle("AOA_RED")
local glide_slope = get_param_handle("GLIDE_SLOPE")

-----------------------------------------------------------------------------
-- Accelerometer (G-meter) indicator on the dash
local accel_cur = get_param_handle("ACCEL_CUR")
local accel_max = get_param_handle("ACCEL_MAX")
local accel_min = get_param_handle("ACCEL_MIN")
local accel_wma = WMA(0.25,1.0)
local accel_val_max = 1.0
local accel_val_min = 1.0

-----------------------------------------------------------------------------
-- Cockpit Lighting
local lights_int_floodwhite = get_param_handle("LIGHTS-FLOOD-WHITE")
local lights_int_floodred = get_param_handle("LIGHTS-FLOOD-RED")
local lights_int_instruments = get_param_handle("LIGHTS-INST")
local lights_int_console = get_param_handle("LIGHTS-CONSOLE")

local FLOODRED_DIM = 0.2
local FLOODRED_MED = 0.35
local FLOODRED_BRIGHT = 0.48

local lights_floodwhite_val = 0
local lights_floodred_val = FLOODRED_DIM
local lights_instruments_val = 0
local lights_console_val = 0

local inst_lights_first_on_time = 0
local inst_lights_warmup_time = 1.5 -- time it takes for the incandescent light bulbs to warm up
local inst_lights_max_brightness_multiplier = 0
local inst_lights_are_cold = true
local intlight_instruments_moving = 0

local console_lights_first_on_time = 0
local console_lights_warmup_time = 2 -- time it takes for the incandescent light bulbs to warm up
local console_lights_max_brightness_multiplier = 0
local console_lights_are_cold = true
local intlight_console_moving = 0

local red_floodlights_first_on_time = 0
local red_floodlights_warmup_time = 2.8 -- time it takes for the incandescent light bulbs to warm up
local red_floodlights_max_brightness_multiplier = 0
local red_floodlights_are_cold = true

local white_floodlights_first_on_time = 0
local white_floodlights_warmup_time = 2.8 -- time it takes for the incandescent light bulbs to warm up
local white_floodlights_max_brightness_multiplier = 0
local white_floodlights_are_cold = true
local intlight_whiteflood_moving = 0

local AOA_indexer_brightness = 1.0
-----------------------------------------------------------------------------
-- Vertical Velocity Indicator
vvi = get_param_handle("VVI")
local vvi_wma = WMA(0.025,0)     -- 0.025 per tick, 20 ticks/sec, 2 seconds to fully adapt


local auto_catapult_power = false

-----------------------------------------------------------------------------
-- Gauge Initialisation

alt_10k:set(0.0)
alt_1k:set(0.0)
alt_100s:set(0.0)
alt_needle:set(0.0)
lo2_quantity:set(oxygen)

dev:listen_command(Keys.FuelGaugeExt)
dev:listen_command(Keys.FuelGaugeInt)
dev:listen_command(device_commands.FuelGaugeExtButton)
dev:listen_command(device_commands.AltPressureKnob)
dev:listen_command(Keys.AltPressureInc)
dev:listen_command(Keys.AltPressureDec)
dev:listen_command(device_commands.ias_index_button)
dev:listen_command(device_commands.ias_index_knob)
dev:listen_command(device_commands.stby_att_index_button)
dev:listen_command(device_commands.stby_att_index_knob)
dev:listen_command(device_commands.master_test)
dev:listen_command(device_commands.intlight_whiteflood)
dev:listen_command(device_commands.intlight_whiteflood_AXIS)
dev:listen_command(device_commands.intlight_whiteflood_axis_slew)
dev:listen_command(device_commands.intlight_instruments)
dev:listen_command(device_commands.intlight_instruments_AXIS)
dev:listen_command(device_commands.intlight_instruments_axis_slew)
dev:listen_command(device_commands.intlight_console)
dev:listen_command(device_commands.intlight_console_AXIS)
dev:listen_command(device_commands.intlight_console_axis_slew)
dev:listen_command(device_commands.intlight_brightness)
dev:listen_command(Keys.IntLightWhiteFlood)
dev:listen_command(Keys.intlight_whiteflood_startup)
dev:listen_command(Keys.intlight_whiteflood_startdown)
dev:listen_command(Keys.intlight_whiteflood_stop)
dev:listen_command(Keys.IntLightInstruments)
dev:listen_command(Keys.intlight_instruments_startup)
dev:listen_command(Keys.intlight_instruments_startdown)
dev:listen_command(Keys.intlight_instruments_stop)
dev:listen_command(Keys.IntLightConsole)
dev:listen_command(Keys.intlight_console_startup)
dev:listen_command(Keys.intlight_console_startdown)
dev:listen_command(Keys.intlight_console_stop)
dev:listen_command(Keys.IntLightBrightness)
--plusnine oxygen system
dev:listen_command(device_commands.oxygen_switch)
dev:listen_command(Keys.OxygenToggle)
dev:listen_command(Keys.AltPressureStartUp)
dev:listen_command(Keys.AltPressureStartDown)
dev:listen_command(Keys.AltPressureStop)
dev:listen_command(Keys.cat_power_toggle)

dev:listen_event("WeaponRearmComplete")
dev:listen_event("UnlimitedWeaponStationRestore")

function dump_table(t)
    for key,value in pairs(t) do
        print(key,value)
    end
end

--fuel weight to pass to kneeboard
kneeboard_fuel_int = get_param_handle("kneeboard_fuel_int")
kneeboard_fuel_ext = get_param_handle("kneeboard_fuel_ext")

-- update loadout page
function update_kneeboard_fuel()
    --print_message_to_user("Updating Kneeboard Fuel Notation")
    --print_message_to_user("INTERNAL: " .. initINT .. " LBS.")
    --print_message_to_user("EXTERNAL: " .. initEXT .. " LBS.")
    kneeboard_fuel_int:set(initINT)
    kneeboard_fuel_ext:set(initEXT)
end

-- refresh kneeboard loadout page if rearming occurs
function CockpitEvent(event, val)
    if event == "WeaponRearmComplete" or event == "UnlimitedWeaponStationRestore" then
        enumerate_fueltanks()
    end
end

function enumerate_fueltanks()
    local fuel = 0
    local weap = GetDevice(devices.WEAPON_SYSTEM)
    local total = sensor_data.getTotalFuelWeight()*KG_TO_POUNDS

    for i=2, 4, 1 do -- iterate on stations 2,3,4
        local station = weap:get_station_info(i-1)
        if station.CLSID == "{DFT-150gal}" then
            fuel = fuel + ((150*GALLON_TO_KG)*KG_TO_POUNDS)
        elseif station.CLSID == "{DFT-300gal_LR}" or station.CLSID == "{DFT-300gal}" then
            fuel = fuel + ((300*GALLON_TO_KG)*KG_TO_POUNDS)
        elseif station.CLSID == "{DFT-400gal}" then
            fuel = fuel + ((400*GALLON_TO_KG)*KG_TO_POUNDS)
        elseif station.CLSID == "{D-704_BUDDY_POD}" then
            fuel = fuel + ((300*GALLON_TO_KG)*KG_TO_POUNDS)
        end
    end

    -- set initial values, both in pounds
    initEXT = fuel
    initINT = total - initEXT
    fuelLastQtyExternal = initEXT
    lastFuel = total -- initializes detection of refueling in update()
    gauge_fuel_flow:set_current_val(sensor_data.getEngineLeftFuelConsumption())
    update_kneeboard_fuel()
end

function post_initialize()

    load_tempmission_file()
    alt_setting = get_qnh() * MM_TO_INCHES

    log.write( "A-4E-C", log.INFO, "Version 2.1.1 Initialized...")

    auto_catapult_power = get_aircraft_property("Auto_Catapult_Power")
    --efm_data_bus.fm_setCatMode(auto_catapult_power)

    local abstime = get_absolute_model_time()
    local hours = abstime / 3600.0

    if hours <= 6 or hours >= 17 then
        dev:performClickableAction(device_commands.intlight_console, 1.0, false)
        dev:performClickableAction(device_commands.intlight_instruments, 1.0, false)
    end

    startup_print("avionics: postinit start")

    local dev = GetSelf()
    enumerate_fueltanks()
    reset_oxygen(oxygen)
    rearmingInProgress = false
    dev:performClickableAction(device_commands.stby_att_index_knob, standby_val, false)
    dev:performClickableAction(device_commands.AOA_dimming_wheel_AXIS, AOA_indexer_brightness, false)

    -- add hot or cold start differences here
    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
    elseif birth == "GROUND_COLD" then
    end

    startup_print("avionics: postinit end")

end

function SetCommand(command,value)
    -- "primary" control is the clickable device, key commands trigger the clickable actions...
    if command == Keys.FuelGaugeInt and not showingInternal then
        dev:performClickableAction(device_commands.FuelGaugeExtButton, 0, false)

    elseif command == Keys.FuelGaugeExt and showingInternal then
        dev:performClickableAction(device_commands.FuelGaugeExtButton, 1, false)

    elseif command == device_commands.FuelGaugeExtButton and value == 1 and showingInternal then
        showingInternal = false

    elseif command == device_commands.FuelGaugeExtButton and value == 0 and not showingInternal then
        showingInternal = true

    elseif command == Keys.AltPressureInc then
        alt_setting = alt_setting + 0.01
        if alt_setting >= ALT_PRESSURE_MAX then
            alt_setting = ALT_PRESSURE_MAX
        end

    elseif command == Keys.AltPressureDec then
        alt_setting = alt_setting - 0.01
        if alt_setting <= ALT_PRESSURE_MIN then
            alt_setting = ALT_PRESSURE_MIN
        end
        
    elseif command == device_commands.AltPressureKnob then
        alt_setting = alt_setting + ((value / 0.05)*0.02)
        if alt_setting >= ALT_PRESSURE_MAX then
            alt_setting = ALT_PRESSURE_MAX
        elseif alt_setting <= ALT_PRESSURE_MIN then
            alt_setting = ALT_PRESSURE_MIN
        end
    elseif command == Keys.AltPressureStartUp then
        alt_pressure_moving = 1
    elseif command == Keys.AltPressureStartDown then
        alt_pressure_moving = -1
    elseif command == Keys.AltPressureStop then
        alt_pressure_moving = 0
    elseif command == device_commands.ias_index_button then
        IAS_index_pushed=true and value==1 or false
    elseif command == device_commands.ias_index_knob then
        local idx
        if IAS_index_pushed then
            idx=IAS_mach_indexer_val
        else
            idx=IAS_knots_indexer_val
        end
        idx=idx+value
        if idx<0 then
            idx=0
        end
        if idx>1.0 then
            idx=1.0
        end
        if IAS_index_pushed then
            IAS_mach_indexer_val=idx
        else
            IAS_knots_indexer_val=idx
        end
    elseif command == device_commands.stby_att_index_button then
        attgyro_stby_pushed=true and value==1 or false
    elseif command == device_commands.stby_att_index_knob then
        --print_message_to_user("stby att: cage("..tostring(attgyro_stby_pushed).."), ="..tostring(value))
        if attgyro_stby_pushed then
            standby_val=standby_val+value
            if standby_val<-1 then
                standby_val=-1
            end
            if standby_val>1.0 then
                standby_val=1.0
            end
        end
    elseif command == device_commands.master_test then
        -- set param which can be read by all the other various systems responding to master test
        master_test_param:set(value)
        -- OIL low light pg 1-16
        -- FIRE warning light pg 1-26
        --[[  pg 3-10
        Depress master TEST switch to check angle-of-attack
        index light, LAWS, LABS, WHEELS, FIRE,
        OBST, ladder caution lights, pilot advisory, armament
        advisory, radar altimeter and OIL LOW lights,
        fuel quantity indicating circuits, and oxygen low level
        warning light. The fuel quantity indicator will
        rotate to zero while the liquid oxygen indicator will
        rotate counterclockwise with warning light on, if less
        than 1 liter of liquid oxygen remains.
        --]]
        -- oxygen level counterclockwise 1-41
        -- all 3 AoA indexer lights 1-46
        -- trigger LAWS warning pg 1-48 (in lieu of press-to-test knob next to radar altimeter)

    elseif command == device_commands.intlight_instruments then
        lights_instruments_val = value
    elseif command == device_commands.intlight_instruments_CHANGE then
        dev:performClickableAction(device_commands.intlight_instruments, clamp(lights_instruments_val + value,0,1), false)
    elseif command == Keys.intlight_instruments_startup then
        intlight_instruments_moving = 1/50
    elseif command == Keys.intlight_instruments_startdown then
        intlight_instruments_moving = -1/50
    elseif command == Keys.intlight_instruments_stop then
        intlight_instruments_moving = 0
    elseif command == device_commands.intlight_instruments_axis_slew then
        if value < -0.001 and value > -0.001 then
            intlight_instruments_moving = 0
        else
            intlight_instruments_moving = value/30
        end
    elseif command == device_commands.intlight_instruments_AXIS then
        dev:performClickableAction(device_commands.intlight_instruments, (value+1)*0.5, false)

    elseif command == device_commands.intlight_console then
        lights_console_val = value
    elseif command == device_commands.intlight_console_CHANGE then
        dev:performClickableAction(device_commands.intlight_console, clamp(lights_console_val+value,0,1), false)
    elseif command == Keys.intlight_console_startup then
        intlight_console_moving = 1/50
    elseif command == Keys.intlight_console_startdown then
        intlight_console_moving = -1/30
    elseif command == Keys.intlight_console_stop then
        intlight_console_moving = 0
    elseif command == device_commands.intlight_console_axis_slew then
        if value < -0.001 and value > -0.001 then
            intlight_console_moving = 0
        else
            intlight_console_moving = value/30
        end
    elseif command == device_commands.intlight_console_AXIS then
        dev:performClickableAction(device_commands.intlight_console, (value+1)*0.5, false)
        
    elseif command == device_commands.intlight_brightness then
        local x = value
        if x == 1.0 then
            lights_floodred_val = FLOODRED_BRIGHT
        elseif x == 0 then
            lights_floodred_val = FLOODRED_DIM
        elseif x == -1 then
            lights_floodred_val = FLOODRED_MED
        end

    elseif command == Keys.IntLightBrightness then
        if lights_floodred_val == FLOODRED_BRIGHT then
            dev:performClickableAction(device_commands.intlight_brightness, -1, false)
        elseif lights_floodred_val == FLOODRED_MED then
            dev:performClickableAction(device_commands.intlight_brightness, 0, false)
        else
            dev:performClickableAction(device_commands.intlight_brightness, 1, false)
        end

    elseif command == device_commands.intlight_whiteflood then
        lights_floodwhite_val = value
    elseif command == device_commands.intlight_whiteflood_CHANGE then
        dev:performClickableAction(device_commands.intlight_whiteflood, clamp(lights_floodwhite_val+value,0,1), false)
    elseif command == Keys.intlight_whiteflood_startup then
        intlight_whiteflood_moving = 1/50
    elseif command == Keys.intlight_whiteflood_startdown then
        intlight_whiteflood_moving = -1/50
    elseif command == Keys.intlight_whiteflood_stop then
        intlight_whiteflood_moving = 0
    elseif command == device_commands.intlight_whiteflood_axis_slew then
        if value < 0.001 and value > -0.001 then
            intlight_whiteflood_moving = 0
        else
            intlight_whiteflood_moving = value/30
        end
    elseif command == device_commands.intlight_whiteflood_AXIS then
        dev:performClickableAction(device_commands.intlight_whiteflood, (value+1)*0.5, false)

    elseif command == Keys.AccelReset then
        dev:performClickableAction(device_commands.accel_reset, 1, false)
    elseif command == device_commands.accel_reset then
        accel_val_max = 1.0
        accel_val_min = 1.0
    elseif command == device_commands.CPT_secondary_ejection_handle then
        for i = 0, 2, 1 do
            dispatch_action(nil, iCommandPlaneEject)
        end
    elseif command == device_commands.AOA_dimming_wheel_AXIS then
        AOA_indexer_brightness = LinearTodB((value + 1) / 2)
    --plusnine oxygen system
    elseif command == device_commands.oxygen_switch then
        oxygen_enabled = (value == 1.0)
        --more verbose version
        --if value == 1.0 then
        --    oxygen_enabled = true
        --  else
        --    oxygen_enabled = false
        --  end
    elseif command == Keys.OxygenToggle then
        dev:performClickableAction(device_commands.oxygen_switch,oxygen_enabled and 0 or 1,false)
    elseif command == Keys.cat_power_toggle then
        efm_data_bus.fm_toggleCatMode()
    else
        print("Unknown command:"..command.." Value:"..value)
    end
end

local currentDisplayedFuel=WMA(0.15,initINT)
local fuel_test=0
function update_fuel_gauge()
    totalFuel = sensor_data.getTotalFuelWeight()*KG_TO_POUNDS -- get new total fuel
    --local flow = sensor_data.getEngineLeftFuelConsumption()
	local flow = sensor_data.mod_fuel_flow()

    if not get_elec_primary_ac_ok() then
        flow=0.0001 --avoid using 0 to avoid the "flow==0" logic below
    end
    local tas = sensor_data.getTrueAirSpeed()

    if flow == 0 and tas == 0 and lastFuel ~= totalFuel then
        -- limited to changes in fuel levels when motionless with no fuel flow
        local delta = lastFuel - totalFuel  -- negative delta means fuel was removed during refueling

        if math.abs(delta) >= refueling_rate_lower_limit and math.abs(delta) <= refueling_rate_upper_limit then
            -- internal refueling in progress, update as normally
            refuelingOccurred = 1 -- trigger full recalc on engine restart
        elseif math.abs(delta) >= refueling_rate_tank_change then
            -- external refueling change, update external amount for proper display
            fuelLastQtyExternal = fuelLastQtyExternal - delta
            refuelingOccurred = 1 -- trigger full recalc on engine restart
        end
    end

    if slowFuel < lastFuel then
        -- fuel is flowing in, begin fuel sloshing
        sound_params.snd_cont_fuel_intake:set(1.0)
    end

    lastFuel = totalFuel

    if flow == 0 then
        -- engine is off, any change in fuel is a function of refueling so pin the external amount
        -- shown, unless the delta is big enough to trigger detection of a tank swap.
        -- rearming will trigger a re-enumeration of tanks AFTER refueling is done.
        -- TODO: this may not handle fuel dumping with engine off in mid-air  (is that a thing?)
        fuelQtyExternal = fuelLastQtyExternal
        fuelQtyInternal = totalFuel - fuelQtyExternal
    elseif totalFuel < initINT or initEXT == 0 then
        -- externals empty/gone when current fuel drops below the initial internal amount
        fuelQtyInternal = totalFuel
        fuelQtyExternal = 0
        fuelLastQtyExternal = 0
    else
        -- externals still have fuel in them
        fuelQtyInternal = initINT
        fuelQtyExternal = totalFuel - initINT
        fuelLastQtyExternal = fuelQtyExternal
    end

    if not get_elec_mon_primary_ac_ok() then
        fuelQtyInternal = 0
    end
    if not get_elec_primary_dc_ok() then
        fuelQtyExternal = 0
        if fuelQtyInternal>1400 then -- internal wing tanks are on primary DC, internal fuselage tank is on monitored primary AC, if only DC is off then wing tanks aren't shown (NATOPS 1-22)
            fuelQtyInternal=1400
        end
    end
    -- establish the fuel amount we want to display
    --fuelQty = showingInternal and fuelQtyInternal or fuelQtyExternal
	
	fuelQty = efm_data_bus.fm_getInternalFuel()*KG_TO_POUNDS
	
	if (showingInternal == false) then
		fuelQty = efm_data_bus.fm_getExternalFuel()*KG_TO_POUNDS
	end

    -- move needle towards value we're trying to show
    if master_test_param:get()==0 then
        fuelgauge:set(currentDisplayedFuel:get_WMA(fuelQty))
        fuel_test=fuelQty
    else
        fuelgauge:set(currentDisplayedFuel:get_WMA(fuel_test))
        fuel_test=fuel_test-(2000*update_time_step)  -- 2000lbs/second
        if fuel_test<0 then
            fuel_test=0
        end
    end

    fuelflowgauge:set(gauge_fuel_flow:get_WMA(flow))
end

function update_fuel_5s()
    --fuel intake dropoff, release fuel sloshing
    if slowFuel >= lastFuel then
        sound_params.snd_cont_fuel_intake:set(0.0)
    end  
    slowFuel = totalFuel
end

function update_ias_mach()
    local ias = sensor_data.getIndicatedAirSpeed()*MPS_TO_KNOTS
    local needle = 0

    -- KNOT needle marking positions are now:
    -- 0-50 knots: 0
    -- 50- 80 knots: 0-20.8791 deg
    -- 80-700 knots: x = 153.05ln(knots) - 649.79

    if ias < 50 then
        needle = 0
    elseif ias <= 80 then
        needle = (ias-50) * 20.8791/30    -- linear for initial region, 30 knot spread = 20.8791 degrees of dial
    elseif ias <= 733 then
        needle = math.fmod( ((153.05 * math.log(ias)) - 649.79), 360 )
    else
        needle = 360                -- just max it out
    end

    ias_needle:set(needle)

    -- MACH dial marking positions:
    -- .5 - 1.5: degrees = 165.47ln(mach) + 349.68
    -- 1.5 - 2.9: degrees = 95.148ln(mach) + 378.22
    -- (see google drive for this inner gauge under assets / 2d / cockpit instruments / 44_airspeed_mach.png )

    -- so mach 0.5 is positioned on the dial at 165.47*ln(0.5) + 349.68 degrees
    -- our algorithm will be:
    -- 1) figure out where the IAS needle is pointing (degrees)
    -- 2) figure out where on the mach disc is pointed at by our current mach
    -- 3) rotate the mach disc by the right amount, to match

    local mach = efm_data_bus.fm_getMeasuredMach()
    local disc = 0
    
    if mach <= 0.5 then
        disc = 165.47 * math.log(mach) + 349.68 - needle
        if disc < 0 then
            disc = 0  -- don't let disc roll negative
        end
    elseif mach > 0.5 and mach <= 1.5 then
        disc = math.fmod( 165.47 * math.log(mach) + 349.68 - needle, 360)
    else
        disc = math.fmod( 95.148 * math.log(mach) + 378.22 - needle, 360)
    end

    ias_mach:set(disc)
    IAS_knots_indexer:set(IAS_knots_indexer_gauge:get_WMA(IAS_knots_indexer_val))
    IAS_mach_indexer:set(IAS_mach_indexer_gauge:get_WMA(IAS_mach_indexer_val))
end

function update_flaps_indicator()
    local value = math.min(get_aircraft_draw_argument_value(9), 0.98)   -- 1.00 is reserved for the "OFF" state
    flaps_ind:set(value)  -- use right flaps (9) as the input to gauge
end

local standby_off_value = WMA(0.15, 0)
local standby_gauge = WMA(0.15, 0)
local adi_off_value = WMA(0.15, 0)
local adi_slip_value = WMA(0.30, 0)
local adi_turnrate_prev_heading=sensor_data.getMagneticHeading()*RADIANS_TO_DEGREES
local adi_turnrate_diff_time=0.2 -- seconds, how often to calculate rate of turn
local adi_turnrate_time_step=0
local adi_latest_turnrate=0
local adi_turn_value = WMA(0.15, 0)

function update_attitude_gyros()
    local standby_off_target=0
    if not get_elec_primary_ac_ok() then  -- TODO : take into account standby gyro
        standby_off_target=1
    end
    attgyro_stby_off:set(standby_off_value:get_WMA(standby_off_target))
    local adi_off_target=0
    if not get_elec_primary_ac_ok() or not get_elec_primary_dc_ok() then  -- TODO: take into account gyro
        adi_off_target=1
    end
    adi_off:set(adi_off_value:get_WMA(adi_off_target))

    attgyro_stby_horiz:set(standby_gauge:get_WMA(standby_val))

    local pitch = sensor_data.getPitch()*RADIANS_TO_DEGREES
    local roll = sensor_data.getRoll()*RADIANS_TO_DEGREES
    local heading = sensor_data.getMagneticHeading()*RADIANS_TO_DEGREES
    local slip = math.deg(sensor_data.getAngleOfSlide())/18.5  -- 18.5 is about the max slide value when applying full rudder
    if slip>1 then
        slip=1
    elseif slip<-1 then
        slip=-1
    end
    --[[
    The turn- and- slip indicators are located below the
    sphere and are an integral part of the all-attitude
    indicator . A one-needle width deflection of the turn
    indicator will result in a standard rate, 2- minute,
    360- degree turn. Full deflection (two -needle widths )
    results in a 1- minute , 360- degree turn. The turn
    indicator is electrically driven and will operate on
    emergency generator .
    --]]
    adi_turnrate_time_step = adi_turnrate_time_step + update_time_step
    if adi_turnrate_time_step >= adi_turnrate_diff_time then
        -- update turn rate
        local delta=heading - adi_turnrate_prev_heading
        if delta<-180 then
            delta=delta+360
        elseif delta>180 then
            delta=delta-360
        end
        adi_latest_turnrate=delta/adi_turnrate_time_step  -- degrees/second
        adi_latest_turnrate=adi_latest_turnrate/6 -- full deflection at 6deg/second
        if adi_latest_turnrate>1 then
            adi_latest_turnrate=1
        elseif adi_latest_turnrate<-1 then
            adi_latest_turnrate=-1
        end

        adi_turnrate_prev_heading = heading
        adi_turnrate_time_step=0
    end


    heading = ((heading+270) % 360)   -- ADI texture has W at "0" rotation, so add 270 degrees to actual
    backup_compass:set((360 - heading) %360)

    if not get_elec_primary_ac_ok() then
        return -- TODO: should pitch/roll just freeze like this, or should standby ADI pitch/roll settle towards zero when power is lost?
    end

    adi_pitch:set(-pitch*2)
    adi_roll:set(roll)
    adi_hdg:set(heading)
    adi_slip:set(adi_slip_value:get_WMA(slip))
    adi_turn:set(adi_turn_value:get_WMA(adi_latest_turnrate))

    --TODO need to add offsets/calibration to the gyro at some point

    attgyro_stby_pitch:set(-pitch)    -- -90 to 90 degrees, rolling "up" indicates climb
    attgyro_stby_roll:set(roll)      -- -180 to 180 degrees
end


function update_altimeter()
    -- altimeter
    Air_Data_Computer:setAltSetting(alt_setting*mgH_to_pa)
    local alt = Air_Data_Computer:getBaroAlt()*meters_to_feet --sensor_data.getBarometricAltitude()*meters_to_feet

    local altNNxx = math.floor(alt_setting)         -- for now just make it discrete
    local altxxNx = math.floor(alt_setting*10) % 10
    local altxxxN = math.floor(alt_setting*100) % 10

    -- first update the selected setting value displayed
    alt_adj_NNxx:set(altNNxx)
    alt_adj_xxNx:set(altxxNx)
    alt_adj_xxxN:set(altxxxN)

    -- based on setting, adjust displayed altitude
    local alt_adj = (alt_setting - ALT_PRESSURE_STD)*1000   -- 1000 feet per inHg / 10 feet per .01 inHg -- if we set higher pressure than actual => altimeter reads higher
    
    alt_10k:set(alt % 100000)
    alt_1k:set(alt % 10000)
    alt_100s:set(alt % 1000)
    alt_needle:set(alt % 1000)

    --continuous knob motion
    if alt_pressure_moving ~= 0 then
        alt_setting = clamp(alt_setting + 0.005 * alt_pressure_moving, ALT_PRESSURE_MIN, ALT_PRESSURE_MAX)
    end
end


--[[
Per figure 1-26 in NATOPS, when the AC panel's RAM/NORMAL switch is in the NORMAL
position, cockpit pressure will be maintained as follows:

barometric altitude     cockpit altitude
-------------------     -----------------------
0-7999'                 same as barometric
8000-16,999'            8000'
17,000' and above       3.3psi above barometric
                
formulas:
    p = p0 * e^(-h/h0)
    h = -h0 * ln(p/p0)
    
where p is in bars and h is in km above earth's surface.  For earth, p0 = 1 and
h0 = 7, because at 7km altitude, the air pressure is e^-1 bars.

reduce to:
   
    p = e^(-h/7)
    h = -7*ln(p)
               
--]]
local cabin_alt_val=WMA(0.15, (sensor_data.getBarometricAltitude() / 1000)*3280.84 )
function update_cabin_pressure_indicator()
    local canopy_closed = (sensor_data.getCanopyPos()<0.01) and true or false

    local bars_to_psi = 14.5038
    local feet_per_km = 3280.84

    local alt_in_km = sensor_data.getBarometricAltitude() / 1000
    local alt_in_feet = alt_in_km * feet_per_km
    local p = math.exp(-alt_in_km/7)

    if canopy_closed then
        if alt_in_feet < 0 then
            cabin_alt = 0
        elseif alt_in_feet < 8000 then
            cabin_alt = alt_in_feet
        elseif alt_in_feet < 17000 then
            cabin_alt = 8000
        else
            local cabin_p = (p * bars_to_psi) + 3.3
            local cabin_p_bars = cabin_p / bars_to_psi
            cabin_alt_km = -7 * math.log(cabin_p_bars)
            cabin_alt = cabin_alt_km * feet_per_km
        end
    else
        cabin_alt = alt_in_feet     -- canopy jettisoned or RAM air enabled to vent cockpit
    end
    if (not (get_elec_primary_ac_ok() and get_elec_primary_dc_ok())) then
        cabin_alt=0
    end

    cabin_altitude:set(cabin_alt_val:get_WMA(cabin_alt))
end


--
-- simple function call to reset liquid O2 to maximum
--
function reset_oxygen()
    lo2_quantity:set(oxygen_reset)
end

--
-- Figure 1-12 in NATOPS (page 1-42) documents oxygen use as a function of cabin pressure altitude
-- 
-- data from the table is slightly non-linear, which doesn't quite make sense.  Will model as straight
-- cabin pressure differential mapped (loosely) to the table values
function update_oxygen_1s()
    local feet_per_km = 3280.84
    local cabin_alt = cabin_altitude:get()
    local cabin_alt_km = cabin_alt/feet_per_km
    local p = math.exp(-cabin_alt_km/7) --pressure in bars

    local lox_per_sec = 10*p/(7.0 * 3600) -- calibrated to 7 hours for 10L of liquid O2

    if lox_per_sec == 0 then
        lox_per_sec = 0.000001
    end
    
    --print_message_to_user("oxy: "..oxygen.."  burn: "..lox_per_sec)

    oxygen = oxygen - lox_per_sec   -- update master variable
    if not get_elec_mon_primary_ac_ok() then
        lo2_flag:set(1)
    else
        lo2_flag:set(0)
    end

end

local oxygen_test=0
function update_oxygen()
    if master_test_param:get()==0 then
        local oxyval=oxygen
        if not get_elec_mon_primary_ac_ok() then
            oxyval = 0
        end
        lo2_quantity:set(oxygen_gauge_val:get_WMA(oxyval))
        if oxygen<1 and get_elec_mon_primary_ac_ok() then
            lo2_warning:set(1)
        else
            lo2_warning:set(0)
        end
        oxygen_test=oxyval
    else
        local oxyval=oxygen_gauge_val:get_WMA(oxygen_test)
        lo2_quantity:set(oxyval)
        oxygen_test = oxygen_test - 0.5
        if oxyval<1 and get_elec_mon_primary_ac_ok() then
            lo2_warning:set(1)
        else
            lo2_warning:set(0)
        end
        if oxygen_test<0 then
            oxygen_test=0
        end
    end
end

local wf_counter = 0
local wf_fpmin = 120

function wheels_light_flash()
    wf_counter = wf_counter + (update_time_step*(wf_fpmin/60))
    if wf_counter > wf_fpmin then
        wf_counter = 0
    end

    local a,b = math.modf(wf_counter)
    -- adjust duty cycle here if needed
    if b < 0.5 then
        return 1
    else
        return 0
    end
end

--
-- NATOPS page 1-29, Landing Gear Handle describes this behavior
-- assuming 0.5s toggle
--
-- TODO: Connect to flaps lever and flap position, once flap lever is implemented

function update_wheels_light()
    local rpm=sensor_data.getEngineLeftRPM()
    local flaps=get_aircraft_draw_argument_value(9)
    local gear=get_aircraft_draw_argument_value(0)
    local x = wheels_light_flash()

    if rpm < 92 and flaps > 0 and gear == 0 and get_elec_primary_ac_ok() then
        glareshield_wheels_value = x
    else
        glareshield_wheels_value = 0
    end
    glareshield_WHEELS:set(glareshield_wheels_value)
end

function update_gear_wow()
    -- landing touchdown wheel noise
    local wown = sensor_data.getWOW_NoseLandingGear()
    local wowl = sensor_data.getWOW_LeftMainLandingGear()
    local wowr = sensor_data.getWOW_RightMainLandingGear()
    if wown == 1 then
        --print_message_to_user("N: ".. wown)
        sound_params.snd_inst_wheels_touchdown_n:set(1.0)
    end
    if wowl == 1 then
        --print_message_to_user("L: ".. wown)
        sound_params.snd_inst_wheels_touchdown_l:set(1.0)
    end
    if wowr == 1 then
        --print_message_to_user("R: ".. wown)
        sound_params.snd_inst_wheels_touchdown_r:set(1.0)
    end
end

function update_gear_wow_1s()
    -- landing touchdown wheel noise
    local wown = sensor_data.getWOW_NoseLandingGear()
    local wowl = sensor_data.getWOW_LeftMainLandingGear()
    local wowr = sensor_data.getWOW_RightMainLandingGear()
    if wown == 0 and wowl == 0 and wowr == 0 then
        sound_params.snd_inst_wheels_touchdown_n:set(0.0)
        sound_params.snd_inst_wheels_touchdown_l:set(0.0)
        sound_params.snd_inst_wheels_touchdown_r:set(0.0)
    end
end

-- temporary functions to deal with master test of lights that aren't handled elsewhere yet
local test_glare_labs       = get_param_handle("D_GLARE_LABS")
local test_glare_iff        = get_param_handle("D_GLARE_IFF")
local test_glare_fire       = get_param_handle("D_GLARE_FIRE")
local test_ladder_fuelboost = get_param_handle("D_FUELBOOST_CAUTION")
local test_ladder_conthyd   = get_param_handle("D_CONTHYD_CAUTION")
local test_ladder_utilhyd   = get_param_handle("D_UTILHYD_CAUTION")
local test_ladder_fueltrans = get_param_handle("D_FUELTRANS_CAUTION")
local test_oil_low          = get_param_handle("D_OIL_LOW")
local test_advisory_inrange = get_param_handle("D_ADVISORY_INRANGE")
local test_advisory_setrange= get_param_handle("D_ADVISORY_SETRANGE")
local test_advisory_dive    = get_param_handle("D_ADVISORY_DIVE")
local ladder_brightness_param = get_param_handle("D_LADDER_BRIGHTNESS")
local glareshield_brightness_param = get_param_handle("D_GLARE_BRIGHTNESS")
local indicator_brightness_param = get_param_handle("D_INDICATOR_BRIGHTNESS")
local AoA_brightness_param = get_param_handle("D_AOA_BRIGHTNESS")

function update_test()
    if master_test_param:get() == 1 and get_elec_primary_ac_ok() then
        test_glare_labs:set(1)
        test_glare_iff:set(1)
        test_glare_fire:set(1)
        glareshield_WHEELS:set(1)
        --test_ladder_fuelboost:set(1)
        --test_ladder_fueltrans:set(1)
        test_oil_low:set(1)
        test_advisory_inrange:set(1)
        test_advisory_setrange:set(1)
        test_advisory_dive:set(1)
		
    else
        --Commented out lights which are updated by other systems
        --This is to prevent flicker.
        --test_glare_labs:set(0)
	    test_glare_iff:set(0)
        test_glare_fire:set(0)
        --glareshield_WHEELS:set(glareshield_wheels_value)
        --test_ladder_fuelboost:set(0)
        --test_ladder_fueltrans:set(0)
        test_oil_low:set(0)
        --test_advisory_inrange:set(0)
        test_advisory_setrange:set(0)
        test_advisory_dive:set(0)
    end
end

--[[
NATOPS:
The indicator in the cockpit will be in operation dur-
ing the entire flight to present angle- of - attack infor-
mation. The angle - of -attack transducer is also
connected to APG - 53A radar system . The indexer
lights and the external approach lights, powered by
the ac primary bus , operate automatically when the
landing gear is down and locked, the arresting hook
is extended , and the aircraft is in flight or up on
jacks. All approach lights go out , upon landing, by
means of a landing gear strut compress switch
(squat switch) .
--]]

local gs_lastx = 0
local gs_lasty = 0
local gs_lastz = 0
local glideslope_param = WMA(0.1)

function update_glideslope()
    local curx,cury,curz = sensor_data.getSelfCoordinates()
    local dx = gs_lastx - curx
    local dy = gs_lasty - cury
    local dz = gs_lastz - curz

    local gs

    if dx ~= 0 or dz ~= 0 then
        gs = math.deg( math.atan( dy / math.sqrt(dx*dx + dz*dz) ) )
    else
        gs = 0
    end

    glide_slope:set( glideslope_param:get_WMA(gs) )

    gs_lastx = curx
    gs_lasty = cury
    gs_lastz = curz
end




local aoa = WMA(0.1)

function update_aoa_ladder()
    -- TODO: external approach lights
    local gear = get_aircraft_draw_argument_value(0)

    local aoa_tmp = aoa:get_WMA(efm_data_bus.fm_getAOAUnits())
    -- ideal AoA is 17-18 units
    --
    -- 18.5 - 30.0 units:   green only
    -- 18.0 - 18.5 units:   green and yellow
    -- 17.0 - 18.0 units:   yellow only
    -- 16.5 - 17.0 units:   yellow and red
    --  0.0 - 16.5 units:   red only
    if get_elec_primary_ac_ok() then
        if master_test_param:get()==1 then
            aoa_green:set(1)
            aoa_yellow:set(1)
            aoa_red:set(1)
        else
            if gear > 0 and get_elec_retraction_release_airborne() then
                aoa_green:set(   (aoa_tmp >= 18.0)                          and 1 or 0 )
                aoa_yellow:set( ((aoa_tmp >= 16.5) and (aoa_tmp <= 18.5)) and 1 or 0 )
                aoa_red:set(     (aoa_tmp <= 17.0)                          and 1 or 0 )
            else
                aoa_green:set(0)
                aoa_yellow:set(0)
                aoa_red:set(0)
            end
        end
    else
        aoa_green:set(0)
        aoa_yellow:set(0)
        aoa_red:set(0)
    end

    update_glideslope()
end

function lighting_warmup(lights_on_duration, lights_warmup_time)
    return (math.atan( 20 * (lights_on_duration / lights_warmup_time))) / 1.52
end

function update_int_lights()
    -- red floodlights, console, and instrument lighting are powered by the primary dc bus
    if get_elec_primary_ac_ok() then
        if inst_lights_are_cold and (lights_instruments_val > 0) then
            inst_lights_first_on_time = get_model_time()
            inst_lights_are_cold = false
        end

        if console_lights_are_cold and (lights_console_val > 0) then
            console_lights_first_on_time = get_model_time()
            red_floodlights_first_on_time = get_model_time()
            console_lights_are_cold = false
        end

        -- lights power on effect
        local inst_lights_on_duration = get_model_time() - inst_lights_first_on_time
        if inst_lights_on_duration < inst_lights_warmup_time then
            inst_lights_max_brightness_multiplier = lighting_warmup(inst_lights_on_duration, inst_lights_warmup_time)
        else
            -- inst_lights_max_brightness_multiplier = 1
        end

        local console_lights_on_duration = get_model_time() - console_lights_first_on_time
        if console_lights_on_duration < console_lights_warmup_time then
            console_lights_max_brightness_multiplier = lighting_warmup(console_lights_on_duration, console_lights_warmup_time)
        else
            -- console_lights_max_brightness_multiplier = 1
        end

        local red_floodlights_on_duration = get_model_time() - red_floodlights_first_on_time
        if red_floodlights_on_duration < red_floodlights_warmup_time then
            red_floodlights_max_brightness_multiplier = lighting_warmup(red_floodlights_on_duration, red_floodlights_warmup_time)
        else
            -- red_floodlights_max_brightness_multiplier = 1
        end

        lights_int_instruments:set(lights_instruments_val * inst_lights_max_brightness_multiplier)
        lights_int_console:set(lights_console_val * console_lights_max_brightness_multiplier)

        -- red floods are conditional upon console knob enabled
        if lights_console_val > 0 then
            lights_int_floodred:set(lights_floodred_val * red_floodlights_max_brightness_multiplier)
        else
            if get_cockpit_draw_argument_value(114) > 0 then
                lights_int_floodred:set(0)
            end
        end
    else
        lights_int_instruments:set(0)
        lights_int_console:set(0)
        lights_int_floodred:set(0)
    end
    
    -- white floodlights are powered by the forward monitors ac bus
    if get_elec_fwd_mon_ac_ok() then
        if white_floodlights_are_cold and (lights_floodwhite_val > 0) then
            white_floodlights_first_on_time = get_model_time()
            white_floodlights_are_cold = false
        end

        local white_floodlights_on_duration = get_model_time() - white_floodlights_first_on_time
        if white_floodlights_on_duration < white_floodlights_warmup_time then
            white_floodlights_max_brightness_multiplier = lighting_warmup(white_floodlights_on_duration, white_floodlights_warmup_time)
        else
            -- white_floodlights_max_brightness_multiplier = 1
        end

        lights_int_floodwhite:set(lights_floodwhite_val * white_floodlights_max_brightness_multiplier)
    else
        lights_int_floodwhite:set(0)
    end
end


function update_accelerometer()
    local g = sensor_data.getVerticalAcceleration()

    accel_cur:set(accel_wma:get_WMA(g))

    if accel_wma:get_current_val() > accel_val_max then
        accel_val_max = accel_wma:get_current_val()
    end
    if accel_wma:get_current_val() < accel_val_min then
        accel_val_min = accel_wma:get_current_val()
    end

    accel_max:set(accel_val_max)
    accel_min:set(accel_val_min)
end


function update_vvi()
    v = sensor_data.getVerticalVelocity()

    local max = 1829    -- 6000 feet/minute in meters

    -- don't allow the VVI WMA to accumulate huge lag when flying at high angles
    if v > max then
        v = max
    elseif v < -max then
        v = -max
    end

    vvi:set(vvi_wma:get_WMA(v))
end

function update_fuel_lights()

end

local LADDER_BRIGHTNESS_HIGH = 1.0
local LADDER_BRIGHTNESS_LOW = 0.2
local GLARESHIELD_BRIGHTNESS_HIGH = 1.0
local GLARESHIELD_BRIGHTNESS_LOW = 0.5
--
-- master update function for all avionics
---
function update()
    efm_data_bus.fm_setGForce(sensor_data.getVerticalAcceleration())
	efm_data_bus.fm_setRadarAltitude(sensor_data.getRadarAltitude())

    update_avionics_power()
    update_altimeter()
    update_accelerometer()
    update_vvi()
    update_fuel_gauge()
    update_ias_mach()
    update_flaps_indicator()
    update_attitude_gyros()
    update_cabin_pressure_indicator()
    update_oxygen()
    update_test()
    update_wheels_light()
    update_gear_wow()
    update_aoa_ladder()
    update_int_lights()

    indicator_brightness_param:set(1.0)
    AoA_brightness_param:set(AOA_indexer_brightness)
    
    -- setup ladder light brightness
    if lights_instruments_val > 0.02 then
        ladder_brightness_param:set(LADDER_BRIGHTNESS_LOW)
    else
        ladder_brightness_param:set(LADDER_BRIGHTNESS_HIGH)
    end

    if lights_instruments_val > 0.1 then
        glareshield_brightness_param:set(GLARESHIELD_BRIGHTNESS_LOW)
    else
        glareshield_brightness_param:set(GLARESHIELD_BRIGHTNESS_HIGH)
    end

    -- group once-per-second updates into a single call conditional for efficiency, to be used for slowly-updating gauges
    once_per_second = once_per_second - 1
    if once_per_second % 20 == 0 then
        -- print_message_to_user("1 time per second!")
        update_oxygen_1s()
        update_gear_wow_1s()
        -- add others here
        once_per_second = once_per_second_refresh
    end

    five_times_per_second = five_times_per_second - 1
    if five_times_per_second % 4 == 0 then
        --print_message_to_user("5 times per second!")
        update_fuel_5s()
        -- add others here
        five_times_per_second = five_times_per_second_refresh
    end

    if refuelingOccurred then
        local flow = sensor_data.getEngineLeftFuelConsumption()
        --print("RPM: "..rpm)
        if flow > 0 then
            -- we've started engine again and fuel flow is non-zero, thus refueling/rearming must be complete.  This means
            -- it's safe to do a full re-calculate fuel state because we know they can't change anymore.  In theory this
            -- catches any glitches in the incremental fuel update code
            enumerate_fueltanks()
            --reset_oxygen() -- I am eliminating this from the normal rearm for now, because managing LO2 is much more complicated
            refuelingOccurred = false
        end
    end

    -- slew and continuous knob updates
    if intlight_whiteflood_moving ~= 0 then
        dev:performClickableAction(device_commands.intlight_whiteflood, clamp(lights_floodwhite_val+intlight_whiteflood_moving,0,1), false)
    end
    if intlight_instruments_moving ~= 0 then
        dev:performClickableAction(device_commands.intlight_instruments, clamp(lights_instruments_val+intlight_instruments_moving,0,1), false)
    end
    if intlight_console_moving ~= 0 then
        dev:performClickableAction(device_commands.intlight_console, clamp(lights_console_val+intlight_console_moving,0,1), false)
    end

end

startup_print("avionics: load end")
need_to_be_closed = false -- close lua state after initialization


-- getAngleOfAttack
-- getAngleOfSlide
-- getBarometricAltitude
-- getCanopyPos
-- getCanopyState
-- getEngineLeftFuelConsumption --
-- getEngineLeftRPM
-- getEngineLeftTemperatureBeforeTurbine
-- getEngineRightFuelConsumption
-- getEngineRightRPM
-- getEngineRightTemperatureBeforeTurbine
-- getFlapsPos
-- getFlapsRetracted
-- getHeading
-- getHelicopterCollective
-- getHelicopterCorrection
-- getHorizontalAcceleration
-- getIndicatedAirSpeed
-- getLandingGearHandlePos
-- getLateralAcceleration
-- getLeftMainLandingGearDown
-- getLeftMainLandingGearUp
-- getMachNumber
-- getMagneticHeading
-- getNoseLandingGearDown
-- getNoseLandingGearUp
-- getPitch
-- getRadarAltitude
-- getRateOfPitch
-- getRateOfRoll
-- getRateOfYaw
-- getRightMainLandingGearDown
-- getRightMainLandingGearUp
-- getRoll
-- getRudderPosition
-- getSelfAirspeed
-- getSelfCoordinates
-- getSelfVelocity
-- getSpeedBrakePos
-- getStickPitchPosition
-- getStickRollPosition
-- getThrottleLeftPosition
-- getThrottleRightPosition
-- getTotalFuelWeight  
-- getTrueAirSpeed
-- getVerticalAcceleration
-- getVerticalVelocity
-- getWOW_LeftMainLandingGear
-- getWOW_NoseLandingGear
-- getWOW_RightMainLandingGear



