dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."Systems/hydraulic_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."EFM_Data_Bus.lua")
dofile(LockOn_Options.script_path.."sound_params.lua")

-- "continuous" flaps behavior
--
-- behavior documentation: NAVAIR 01-40AVC-1 section 1-30, 15 July 1969, "WING FLAPS"
-- flap blowback begins at 230kts IAS to prevent structural damage
--
-- design summary:
--   single key press (F) starts motion, and a 2nd keypress stops movement of the flaps
--   executing explicit Flaps Up/Down command moves to the other extreme position, and ignores prior state
--   if flaps were stopped manually, the next flaps command (F) will resume movement towards the furthest endpoint
--   flaps lever will re-center (off) if driven by keyboard when endpoint is reached

local dev = GetSelf()

local update_time_step = 0.006
make_default_activity(update_time_step)

local sensor_data = get_efm_sensor_data_overrides()
local efm_data_bus = get_efm_data_bus()

local rate_met2knot = 0.539956803456
local ias_knots = 0 -- * rate_met2knot

local FlapExtensionTimeSeconds = 6      -- flaps take 6 seconds to extend/retract fully

--Creating local variables
local FLAPS_STATE	=	0 -- 0 = retracted, 0.5 = takeoff, 1.0 = landing -- "current" flap position		
local FLAPS_TARGET  =   0 -- 0 = retracted, 0.5 = takeoff, 1.0 = landing -- "future" flap position
local FLAPS_TARGET_LAST = 0
local MOVING = 0          -- 1 = we "want" movement to a new position

local fromKeyboard = false

local FLAP_MAX_DEFLECTION = 50
local FLAP_BLOWBACK_PSI = 3650

local flaps_ind = get_param_handle("D_FLAPS_IND")

dev:listen_command(Keys.PlaneFlaps)
dev:listen_command(Keys.PlaneFlapsOn)
dev:listen_command(Keys.PlaneFlapsOff)
dev:listen_command(Keys.PlaneFlapsStop)
dev:listen_command(Keys.PlaneFlapsUpHotas)
dev:listen_command(Keys.PlaneFlapsDownHotas)
dev:listen_command(device_commands.flaps)


-- utility function, returns the effective frontal area ratio of the flap based on the animation state
function CalcFrontalAreaRatio(flap_state)
    local sin = 0
    local area = 0

    sin = math.sin( math.rad(flap_state * FLAP_MAX_DEFLECTION) )
    area = sin*sin -- frontal area = sin^2(theta)
    return area
end


-- utility function, based on openoffice table, calibrated to 3650psi at 230kts, blowback trigger point per NAVAIR manual
function RelativePressureOnFlaps(flap_state)
    local a = CalcFrontalAreaRatio(flap_state)
    local k = 8.504932 -- calculated ratio of v^2*a to 3650 (valve pressure limit) that initiates valve relief in A4 flap actuator
    local valve_pressure = 0

    ias_knots = sensor_data.getTrueAirSpeed() * 3.6 * rate_met2knot
    valve_pressure = ias_knots * ias_knots * a / k
    return valve_pressure
end

-- summary of lever behavior:
--   -1 extends flaps, 1 retracts flaps, 0 stops flap movement
--   primary action is based on lever behavior/clicking, and keys will map to lever behavior w/ limit functions

function SetCommand(command,value)
    if command == device_commands.flaps then
        if value == 1 then
            -- target: retraction
            MOVING = 1
            FLAPS_TARGET = 0
            FLAPS_TARGET_LAST= 1
        elseif value == -1 then
            -- target: extension
            MOVING = 1
            FLAPS_TARGET = 1
            FLAPS_TARGET_LAST = 0
        else
            MOVING = 0
            FLAPS_TARGET = FLAPS_STATE
            FLAPS_TARGET_LAST = -1
        end
    elseif command == Keys.PlaneFlapsStop then
        dev:performClickableAction(device_commands.flaps, 0, false)
    elseif command == Keys.PlaneFlapsOn then
        fromKeyboard = true
        dev:performClickableAction(device_commands.flaps, -1, false)    -- target: extension
    elseif command == Keys.PlaneFlapsUpHotas then
        dev:performClickableAction(device_commands.flaps, 1, false)    -- target: extension
    elseif command == Keys.PlaneFlapsOff then
        fromKeyboard = true
        dev:performClickableAction(device_commands.flaps, 1, false)     -- target: retraction
    elseif command == Keys.PlaneFlapsDownHotas then
        dev:performClickableAction(device_commands.flaps, -1, false)     -- target: retraction
    elseif command == Keys.PlaneFlaps then
        if MOVING == 1 then
            fromKeyboard = false
            dev:performClickableAction(device_commands.flaps, 0, false)
        else
            fromKeyboard = true
            if FLAPS_TARGET >= 0.5 then
                dev:performClickableAction(device_commands.flaps, 1, false)
            else
                dev:performClickableAction(device_commands.flaps, -1, false)
            end
        end
    end
end


local flaps_increment = update_time_step / FlapExtensionTimeSeconds -- sets the speed of flap animation
function update()
    local delta
    -- first test for velocity limit which triggers at ~230kts IAS
    if RelativePressureOnFlaps(FLAPS_STATE) > FLAP_BLOWBACK_PSI then
        FLAPS_STATE = FLAPS_STATE - flaps_increment -- force flaps in if too much pressure on them
    -- make primary adjustment if needed
    elseif FLAPS_STATE ~= FLAPS_TARGET then
        if get_hyd_utility_ok() then
            if MOVING == 1 then
                sound_params.snd_cont_flaps_mov:set(1.0)
                sound_params.snd_inst_flaps_stop:set(0.0)
                -- we intended to move the flaps, and they're out of position...
                if math.abs(FLAPS_STATE - FLAPS_TARGET) < flaps_increment then
                    FLAPS_STATE = FLAPS_TARGET
                elseif FLAPS_STATE < FLAPS_TARGET then
                    FLAPS_STATE = FLAPS_STATE + flaps_increment
                else
                    FLAPS_STATE = FLAPS_STATE - flaps_increment
                end
            else
                -- moving == 0 because we reached our endpoint BUT high velocity retracted the flaps, so re-enable
                -- the intent to move because we still have more extension as our target.  Only triggers when desiring
                -- more extension and when last command wasn't an explicit halt
                if FLAPS_TARGET > FLAPS_STATE and FLAPS_TARGET_LAST ~= -1 then
                    MOVING = 1
                end
            end
        end
    else
        -- we reached our target, either via a stop command, a duplicate command, or completing extension/retraction...
        if FLAPS_TARGET == 0 or FLAPS_TARGET == 1 then
            FLAPS_TARGET_LAST = FLAPS_TARGET -- when you reach endpoint, reverse direction
            if fromKeyboard then
                fromKeyboard = false
                dev:performClickableAction(device_commands.flaps, 0, false) -- reset lever
            end
        end
        MOVING = 0 -- reaching desired position disables the intent to move
        sound_params.snd_cont_flaps_mov:set(0.0)
        sound_params.snd_inst_flaps_stop:set(1.0)
	end
	
    -- handle rounding errors induced by non-modulo increment remainders
    if FLAPS_STATE < 0 then
        FLAPS_STATE = 0
    elseif FLAPS_STATE > 1 then
        FLAPS_STATE = 1
    end
	
	flaps_ind:set(FLAPS_STATE)
	efm_data_bus.fm_setFlaps(FLAPS_STATE)


    local wing_fold = 0.0
    -- Less than 10% flaps -> wings folded
    if FLAPS_STATE <= 0.1 then
        wing_fold = 1.0
    end

	set_aircraft_draw_argument_value(8, wing_fold )
	--set_aircraft_draw_argument_value(10,FLAPS_STATE)
	
end

need_to_be_closed = false -- close lua state after initialization
