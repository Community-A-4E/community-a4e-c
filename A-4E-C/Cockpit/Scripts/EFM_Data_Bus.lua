dofile(LockOn_Options.script_path .. "ConfigurePackage.lua")
Scooter = require('Scooter')

local optionsData_cockpitShake = get_plugin_option_value("A-4E-C", "cockpitShake", "local")
local optionsData_wheelBrakeAssist = get_plugin_option_value("A-4E-C", "wheelBrakeAssist", "local")

local fm_gear_nose = get_param_handle("FM_GEAR_NOSE")
local fm_gear_left = get_param_handle("FM_GEAR_LEFT")
local fm_gear_right = get_param_handle("FM_GEAR_RIGHT")

local fm_flaps = get_param_handle("FM_FLAPS")
local fm_brakes = get_param_handle("FM_BRAKES")
local fm_spoilers = get_param_handle("FM_SPOILERS")

local fm_throttle_position = get_param_handle("FM_THROTTLE_POSITION")
local fm_engine_throttle_position = get_param_handle("FM_ENGINE_THROTTLE_POSITION")
local fm_ignition = get_param_handle("FM_IGNITION")
local fm_bleed_air = get_param_handle("FM_BLEED_AIR")

local fm_stick_pitch = get_param_handle("STICK_PITCH")
local fm_stick_roll = get_param_handle("STICK_ROLL")
local fm_rudder_pedals = get_param_handle("RUDDER_PEDALS")

local fm_stick_input_pitch = get_param_handle("FM_STICK_INPUT_PITCH")
local fm_stick_input_roll = get_param_handle("FM_STICK_INPUT_ROLL")

local fm_pitch_trim = get_param_handle("PITCH_TRIM")
local fm_roll_trim = get_param_handle("ROLL_TRIM")
local fm_rudder_trim = get_param_handle("RUDDER_TRIM")
local fm_yaw_damper = get_param_handle("FM_YAW_DAMPER")

local fm_nws = get_param_handle("FM_NWS")

local fm_internal_fuel = get_param_handle("FM_INTERNAL_FUEL")
local fm_external_fuel = get_param_handle("FM_EXTERNAL_FUEL")

local fm_cockpitShake = get_param_handle("FM_COCKPIT_SHAKE")

local fm_airspeed = get_param_handle("FM_AIRSPEED")

local fm_RPM = get_param_handle("RPM")

local fm_beta = get_param_handle("FM_BETA")
local fm_aoa = get_param_handle("FM_AOA")
local fm_aoa_units = get_param_handle("FM_AOA_UNITS")

local fm_slantRange = get_param_handle("FM_SLANT_RANGE")
local fm_validSolution = get_param_handle("FM_VALID_SOLUTION")
local fm_setTarget = get_param_handle("FM_SET_TARGET")
local fm_radarAltitude = get_param_handle("FM_RADAR_ALTITUDE")
local fm_gunsightAngle = get_param_handle("FM_GUNSIGHT_ANGLE")
local fm_target_set = get_param_handle("FM_TARGET_SET")
local fm_in_range = get_param_handle("FM_IN_RANGE")
local fm_cp741_power = get_param_handle("FM_CP741_POWER")

local fm_dumping_fuel = get_param_handle("FM_DUMPING_FUEL")


local ptr_radio = get_param_handle("THIS_RADIO_PTR")
local ptr_intercom = get_param_handle("THIS_INTERCOM_PTR")
local ptr_elec = get_param_handle("THIS_ELEC_PTR")

local fm_radio_power = get_param_handle("FM_RADIO_POWER")

local fm_avionics_alive = get_param_handle("FM_AVIONICS_ALIVE")

local fm_l_tank_capacity = get_param_handle("FM_L_TANK_CAPACITY")
local fm_c_tank_capacity = get_param_handle("FM_C_TANK_CAPACITY")
local fm_r_tank_capacity = get_param_handle("FM_R_TANK_CAPACITY")

local fm_slat_left = get_param_handle("FM_SLAT_LEFT")
local fm_slat_right = get_param_handle("FM_SLAT_RIGHT")

local fm_using_FFB = get_param_handle("FM_USING_FFB")

local fm_gForce = get_param_handle("FM_GFORCE")

local fm_fuel_flow = get_param_handle("FM_FUEL_FLOW")

local fm_tcn_x = get_param_handle("FM_TCN_X")
local fm_tcn_y = get_param_handle("FM_TCN_Y")
local fm_tcn_z = get_param_handle("FM_TCN_Z")
local fm_tcn_valid = get_param_handle("FM_TCN_VALID")
local fm_tcn_object_id = get_param_handle("FM_TCN_OBJECT_ID")
local fm_tcn_object_name = get_param_handle("FM_TCN_OBJECT_NAME")
local fm_icls_heading = get_param_handle("FM_ICLS_HEADING")

local fm_acceleration_x = get_param_handle("FM_ACCELERATION_X")
local fm_acceleration_y = get_param_handle("FM_ACCELERATION_Y")
local fm_acceleration_z = get_param_handle("FM_ACCELERATION_Z")

local fm_cas = get_param_handle("FM_CAS")
local fm_mach = get_param_handle("ADC_MACH")

local fm_radar_disabled = get_param_handle("FM_RADAR_DISABLED")
local fm_wheel_brake_assist = get_param_handle("FM_WHEEL_BRAKE_ASSIST")

local fm_cat_auto_mode = get_param_handle("FM_CAT_AUTO_MODE")

local tanks = {
    [1] = fm_l_tank_capacity,
    [2] = fm_c_tank_capacity,
    [3] = fm_r_tank_capacity,
}

function fm_setCatMode(value)
    fm_cat_auto_mode:set(value and 1.0 or 0.0)
end

function fm_toggleCatMode(value)
    local cur = fm_cat_auto_mode:get()
    if cur == 1.0 then
        cur = 0.0
        print_message_to_user("Catapult Power Mode - DEFAULT (Forrestal, Stennis, SuperCarrier)")
    else
        cur = 1.0
        print_message_to_user("Catapult Power Mode - AUTO (carrier mods)")
    end
    fm_cat_auto_mode:set(cur)
end

function fm_setRadarDisabled(value)
    fm_radar_disabled:set(value)
end

--Mask for tank states
function fm_setTankState(idx, value)
    tanks[idx]:set(value)
end

function fm_setTacanName(value)
    fm_tcn_object_name:set(value)
end

function fm_setTacanID(value)
    fm_tcn_object_id:set(value)
end


function fm_setGForce(value)
    fm_gForce:set(value)
end

function fm_setRadioPTR(value)
    ptr_radio:set(value)
end

function fm_setIntercomPTR(value)
    ptr_intercom:set(value)
end

function fm_setElecPTR(value)
    ptr_elec:set(value)
end

function fm_setAvionicsAlive(value)
    fm_avionics_alive:set(value)
end

function fm_setNoseGear(value)
    fm_gear_nose:set(value)
end

function fm_setLeftGear(value)
    fm_gear_left:set(value)
end

function fm_setRightGear(value)
    fm_gear_right:set(value)
end

function fm_setFlaps(value)
    fm_flaps:set(value)
end

function fm_setBrakes(value)
    fm_brakes:set(value)
end

function fm_setSpoilers(value)
    fm_spoilers:set(value)
end

function fm_setEngineThrottle(value)
    fm_engine_throttle_position:set(value)
end

function fm_setIgnition(value)
    fm_ignition:set(value)
end

function fm_setBleedAir(value)
    fm_bleed_air:set(value)
end

function fm_setPitchTrim(value)
    fm_pitch_trim:set(value)
end

function fm_setRollTrim(value)
    fm_roll_trim:set(value)
end

function fm_setRudderTrim(value)
    fm_rudder_trim:set(value)
end

function fm_setYawDamper(value)
    fm_yaw_damper:set(value)
end

function fm_setNWS(value)
    fm_nws:set(value)
end

function fm_setCockpitShake(value)
    fm_cockpitShake:set(value)
end

function fm_setRadarSlantRange(value)
    fm_slantRange:set(value)
end

function fm_setSetTarget(value)
    fm_setTarget:set(value)
end

function fm_setRadarAltitude(value)
    fm_radarAltitude:set(value)
end

function fm_setGunsightAngle(value)
    fm_gunsightAngle:set(value)
end

function fm_setDumpingFuel(value)
    fm_dumping_fuel:set(value)
end

function fm_setRadioPower(value)
    fm_radio_power:set(value)
end

function fm_setCP741Power(value)
    fm_cp741_power:set(value)
end

function fm_setWheelBrakeAssist(value)
    fm_wheel_brake_assist:set(value and 1.0 or 0.0)
end

function fm_getFuelFlow()
    return fm_fuel_flow:get()
end

function fm_getUsingFFB()
    return fm_using_FFB:get()
end

function fm_getGunsightAngle()
    return fm_gunsightAngle:get()
end

function fm_getValidSolution()
    return fm_validSolution:get() > 0.5
end

function fm_getEngineRPM()
    return fm_RPM:get()
end

function fm_getAirspeed()
    return fm_airspeed:get()
end

function fm_getThrottle()
    return fm_throttle_position:get()
end

function fm_getInternalFuel()
    return fm_internal_fuel:get()
end

function fm_getExternalFuel()
    return fm_external_fuel:get()
end

function fm_getIgnition()
    return fm_ignition:get()
end

function fm_getBeta()
    return fm_beta:get()
end

function fm_getAOA()
    return fm_aoa:get()
end

function fm_getAOAUnits()
    return fm_aoa_units:get()
end

function fm_getTargetSet()
    return fm_target_set:get() > 0.5
end

function fm_getPitchInput()
	return fm_stick_input_pitch:get()
end

function fm_getRollInput()
	return fm_stick_input_roll:get()
end

function fm_getRudderInput()
    return fm_rudder_pedals:get()
end

function fm_getSlatLeft()
    return fm_slat_left:get()
end

function fm_getSlatRight()
    return fm_slat_right:get()
end

function fm_getInRange()
    return fm_in_range:get()
end

function fm_getTacanPosX()
    return fm_tcn_x:get()
end

function fm_getTacanPosY()
    return fm_tcn_y:get()
end

function fm_getTacanPosZ()
    return fm_tcn_z:get()
end

function fm_tacanValid()
    return fm_tcn_valid:get() > 0.5
end

function fm_getICLSHeading()
    return fm_icls_heading:get()
end

function fm_getWorldAcceleration()
    return fm_acceleration_x:get(), fm_acceleration_y:get(), fm_acceleration_z:get()
end

function fm_getCalibratedAirSpeed()
    return fm_cas:get()
end

function fm_getMeasuredMach()
    return fm_mach:get()
end

fm_setCockpitShake(2.0 * optionsData_cockpitShake/100.0)
fm_setWheelBrakeAssist(optionsData_wheelBrakeAssist)

function get_efm_data_bus()
    local efm_data_bus = {
        param_handles = {}
    }

    efm_data_bus.__index = efm_data_bus
    setmetatable(efm_data_bus, efm_data_bus)

    --fm_cockpitShake:set(optionsData_cockpitShake/100.0)
    efm_data_bus.fm_setNoseGear = fm_setNoseGear
    efm_data_bus.fm_setLeftGear = fm_setLeftGear
    efm_data_bus.fm_setRightGear = fm_setRightGear
    efm_data_bus.fm_setFlaps = fm_setFlaps
    efm_data_bus.fm_setBrakes = fm_setBrakes
    efm_data_bus.fm_setSpoilers = fm_setSpoilers
    efm_data_bus.fm_setEngineThrottle = fm_setEngineThrottle
    efm_data_bus.fm_setIgnition = fm_setIgnition
    efm_data_bus.fm_setBleedAir = fm_setBleedAir
    efm_data_bus.fm_setPitchTrim = fm_setPitchTrim
    efm_data_bus.fm_setRollTrim = fm_setRollTrim
    efm_data_bus.fm_setRudderTrim = fm_setRudderTrim
    efm_data_bus.fm_setYawDamper = fm_setYawDamper
    efm_data_bus.fm_setNWS = fm_setNWS
    efm_data_bus.fm_setCockpitShake = fm_setCockpitShake
    efm_data_bus.fm_setRadarSlantRange = fm_setRadarSlantRange
    efm_data_bus.fm_setSetTarget = fm_setSetTarget
    efm_data_bus.fm_setRadarAltitude = fm_setRadarAltitude
    efm_data_bus.fm_setGunsightAngle = fm_setGunsightAngle
    efm_data_bus.fm_setDumpingFuel = fm_setDumpingFuel
    efm_data_bus.fm_setRadioPower = fm_setRadioPower
    efm_data_bus.fm_setAvionicsAlive = fm_setAvionicsAlive
    efm_data_bus.fm_setElecPTR = fm_setElecPTR
    efm_data_bus.fm_setIntercomPTR = fm_setIntercomPTR
    efm_data_bus.fm_setRadioPTR = fm_setRadioPTR
    efm_data_bus.fm_setTankState = fm_setTankState
    efm_data_bus.fm_setCP741Power = fm_setCP741Power
    efm_data_bus.fm_setGForce = fm_setGForce
    efm_data_bus.fm_setRadarDisabled = fm_setRadarDisabled
    efm_data_bus.fm_toggleCatMode = fm_toggleCatMode
    efm_data_bus.fm_setCatMode = fm_setCatMode


    efm_data_bus.fm_getGunsightAngle = fm_getGunsightAngle
    efm_data_bus.fm_getInternalFuel = Scooter.GetFuelQtyInternal
    efm_data_bus.fm_getExternalFuel = Scooter.GetFuelQtyExternal
    efm_data_bus.fm_getAOAUnits = Scooter.GetAlphaUnits
    efm_data_bus.fm_getValidSolution = Scooter.GetValidSolution
    efm_data_bus.fm_getTargetSet = Scooter.GetTargetSet
	efm_data_bus.fm_getPitchInput = Scooter.GetStickInputPitch
    efm_data_bus.fm_getRollInput = Scooter.GetStickInputRoll
    efm_data_bus.fm_getRudderInput = Scooter.GetRudderInput
    efm_data_bus.fm_getSlatLeft = Scooter.GetLeftSlat
    efm_data_bus.fm_getSlatRight = Scooter.GetRightSlat
    efm_data_bus.fm_getUsingFFB = Scooter.GetFFBEnabled
    efm_data_bus.fm_getMeasuredMach = fm_getMeasuredMach
    

    

    efm_data_bus.get_param = function(self, name)
        if self.param_handles[name] then
            return self.param_handles[name]:get()
        else
            self.param_handles[name] = get_param_handle(name)
            return self.param_handles[name]:get()
        end
    end

    efm_data_bus.set_param = function(self, name, value)
        if self.param_handles[name] then
            return self.param_handles[name]:set(value)
        else
            self.param_handles[name] = get_param_handle(name)
            return self.param_handles[name]:set(value)
        end
    end

    efm_data_bus.get_integrity = function(self, name)
        name = "DamageObject<"..name..">"
        if self.param_handles[name] then
            return self.param_handles[name]:get()
        else
            self.param_handles[name] = get_param_handle(name)
            return self.param_handles[name]:get()
        end
    end


    return efm_data_bus
   
end

local EFM_enabled = true

function get_efm_sensor_data_overrides()
    --Get the original data
    local data = get_base_data()

    if EFM_enabled then
        data.getEngineLeftRPM = Scooter.GetRPMPercent
        data.getEngineLeftFuelConsumption = Scooter.GetFuelFlow
        data.getThrottleLeftPosition = fm_getThrottle
        data.getTrueAirSpeed = fm_getAirspeed
        data.getAngleOfSlide = Scooter.GetBeta
        data.getAngleOfAttack = Scooter.GetAlpha
        data.getIndicatedAirSpeed = fm_getCalibratedAirSpeed
    end

    return data
end
