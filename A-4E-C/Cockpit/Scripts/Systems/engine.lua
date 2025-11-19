local Engine     = GetSelf()
local dev = Engine
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."EFM_Data_Bus.lua")
dofile(LockOn_Options.script_path.."sound_params.lua")
dofile(LockOn_Options.script_path.."ControlsIndicator/ControlsIndicator_api.lua") 

function debug_print(x)
    --print_message_to_user(x)
end

local update_rate = 0.05
make_default_activity(update_rate)

local sensor_data = get_efm_sensor_data_overrides()
local efm_data_bus = get_efm_data_bus()


sensor_data.mod_fuel_flow = function()
	local org_fuel_flow = sensor_data.getEngineLeftFuelConsumption() 
	--if org_fuel_flow > 0.9743 then org_fuel_flow = 0.9743 end
	return org_fuel_flow
end

local iCommandEnginesStart  = 309
local iCommandEnginesStop   = 310
local iCommandPlaneFuelOff  = 80
local iCommandPlaneFuelOn   = 79

local pressure_ratio = get_param_handle("PRESSURE_RATIO")
local oil_pressure = get_param_handle("OIL_PRESSURE")
local egt_c = get_param_handle("EGT_C")
local engine_heat_stress = get_param_handle("ENGINE_HEAT_STRESS")
local manual_fuel_control_warn_param = get_param_handle("MANUAL_FUEL_CONTROL_WARN")

local throttle_position = get_param_handle("THROTTLE_POSITION")
local throttle_position_wma = WMA(0.35, 0)
local iCommandPlaneThrustCommon = 2004

local ENGINE_OFF = 0
local ENGINE_IGN = 1
local ENGINE_STARTING = 2
local ENGINE_RUNNING = 3
local engine_state = ENGINE_OFF
local EMER_FUEL_SHUTOFF = false -- state of emergency fuel shutoff control 
local EMER_FUEL_SHUTOFF_CATCH = false -- state of emergency fuel shutoff catch 

local THROTTLE_OFF = 0
local THROTTLE_IGN = 1
local THROTTLE_ADJUST = 2
local throttle_state = THROTTLE_ADJUST

local manual_fuel_control_mode = 1
local manual_fuel_control_mode_sw = 0

local igniter_timer = 0
local igniter_max = 400 -- set timer maximum in seconds * 20

local fuel_transfer_bypass_state = 0
local fuel_transfer_bypass_valve = 0

local drop_tank_press_switch = 0
local fuel_dump_switch = 0

local throttle_slew = 0
local throttle_rate = get_plugin_option_value("A-4E-C","throttleRate","local") * 0.02 -- THROTTLE RATE, 1.0 to 5.0 percent, increments of 0.1, defined in the special menu, to a percentage change to apply
local throttle_accelerating = 0
local throttle_acceleration_default = get_plugin_option_value("A-4E-C","throttleAcceleration","local") * 0.0002 -- THROTTLE ACCELERATION tuning
local throttle_accelerating_duration = 0 --additional acceleration from cumulative duration
local throttle_acceleration_rate = throttle_acceleration_default -- set default and await input

------------------------------------------------
----------------  CONSTANTS  -------------------
------------------------------------------------

------------------------------------------------
-----------  AIRCRAFT DEFINITION  --------------
------------------------------------------------

Engine:listen_command(device_commands.push_starter_switch)
Engine:listen_command(Keys.Engine_Start)
Engine:listen_command(Keys.Engine_Stop)
Engine:listen_command(device_commands.ENGINE_manual_fuel_shutoff)
--Engine:listen_command(device_commands.throttle_axis)
Engine:listen_command(Keys.Fuel_Transfer_Bypass_Toggle)
Engine:listen_command(Keys.FuelControl)
Engine:listen_command(Keys.drop_tank_press_cycle)
Engine:listen_command(Keys.fuel_dump_cycle)

Engine:listen_command(Keys.throttle_position_off)
Engine:listen_command(Keys.throttle_position_ign)
Engine:listen_command(Keys.throttle_position_run)

Engine:listen_command(Keys.throttle_inc)
Engine:listen_command(Keys.throttle_dec)
Engine:listen_command(Keys.throttle_acc)
Engine:listen_command(device_commands.throttle_axis_slew)

function post_initialize()

    dev:performClickableAction(device_commands.push_starter_switch,0,false)
    local throttle_clickable_ref = get_clickable_element_reference("PNT_80")
    local sensor_data = get_base_data()
    local throttle = sensor_data.getThrottleLeftPosition()
    local manual_fuel_shutoff_clickable_ref = get_clickable_element_reference("PNT_130")
    manual_fuel_shutoff_clickable_ref:hide(true)

    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" then
		 efm_data_bus.fm_setIgnition(1.0)
        engine_state = ENGINE_RUNNING
        throttle_state = THROTTLE_ADJUST
        throttle_clickable_ref:hide(throttle>0.01)
        dev:performClickableAction(device_commands.throttle_click,1,false)
        dev:performClickableAction(device_commands.ENGINE_manual_fuel_shutoff,0,false)
        throttle_position:set(0)
    elseif birth=="AIR_HOT" then
        efm_data_bus.fm_setIgnition(1.0)
        engine_state = ENGINE_RUNNING
        throttle_state = THROTTLE_ADJUST
        dev:performClickableAction(device_commands.throttle_click,1,false)
        throttle_clickable_ref:hide(throttle>0.01)
        throttle_position:set(0)
    elseif birth=="GROUND_COLD" then
        efm_data_bus.fm_setIgnition(0.0)
        engine_state = ENGINE_OFF
        throttle_state = THROTTLE_OFF
        throttle_clickable_ref:hide(false)
        throttle_position:set(-1)
        dev:performClickableAction(device_commands.throttle_click,-1,false)
    end
end

--[[
pilot controlled ground start sequence:
1. connect external power and huffer (request ground power ON from ground crew)
2. Throttle to OFF position
3. Press starter switch (dispatch iCommandEnginesStart), this is supposed to let in external compressor air to drive engine
4. When RPM at 5%, move throttle to ignition (otherwise if by say 14% without ignition, dispatch iCommandEnginesStop [or to be fancy, try to control RPM to remain around this level by dispatching repeated start/stop])
5. When RPM at 15%, move throttle to idle (otherwise if by say 22% without idle position, dispatch iCommandEnginesStop [or to be fancy, try to control RPM to to pre-ignition level by dispatching repeated start/stop])
6. When RPM gets to 55%, request ground power OFF
--]]

local start_button_popup_timer = 0
function SetCommand(command,value)
	local rpm = sensor_data.getEngineLeftRPM()
    local throttle = sensor_data.getThrottleLeftPosition()

    if command==device_commands.push_starter_switch then
        if value==1 then
            if (engine_state==ENGINE_OFF) and get_elec_external_power() and EMER_FUEL_SHUTOFF == false then -- initiate ground start procedure 
				 --dispatch_action(nil,iCommandEnginesStart)
				 efm_data_bus.fm_setBleedAir(1.0)
            elseif (engine_state==ENGINE_OFF) and rpm<50 and rpm>10 and get_elec_primary_ac_ok() and get_elec_primary_dc_ok() and throttle_state==THROTTLE_IGN  and EMER_FUEL_SHUTOFF == false  then -- initiate air start
                engine_state = ENGINE_STARTING
                dispatch_action(nil,iCommandEnginesStart)
				 efm_data_bus.fm_setBleedAir(1.0)
            else
                start_button_popup_timer = 0.3
            end
        end
        if value==0 then
			 efm_data_bus.fm_setBleedAir(0.0)
            if (engine_state==ENGINE_IGN or engine_state==ENGINE_STARTING) and rpm<50 and get_elec_external_power() then -- abort ground start procedure
                engine_state=ENGINE_OFF
                dispatch_action(nil,iCommandEnginesStop)
            end
        end
    elseif command==Keys.Engine_Start then
        Engine:performClickableAction(device_commands.push_starter_switch,1,false)
    elseif command==Keys.Engine_Stop then
        Engine:performClickableAction(device_commands.push_starter_switch,0,false)
        debug_print("engine has been turned off")
        throttle_state = THROTTLE_OFF
        engine_state = ENGINE_OFF
        dispatch_action(nil,iCommandEnginesStop)
        dev:performClickableAction(device_commands.throttle_click,-1,false)
        --elseif command==device_commands.throttle_axis then
        ---- value is -1 for throttle full forwards, 1 for throttle full back
        ----local throt = (2-(value+1))/2.0
        --local throt = value
        ----print_message_to_user("throt"..string.format("%.2f",throt))
        --dispatch_action(nil, iCommandPlaneThrustCommon, throt)
    elseif command==Keys.throttle_inc then
        dispatch_action(nil, iCommandPlaneThrustCommon, -2.0 * throttle + 1.0 - throttle_rate) -- normalise this transform for a percentage application to the -1 to 1 throttle axis
    elseif command==Keys.throttle_dec then
        dispatch_action(nil, iCommandPlaneThrustCommon, -2.0 * throttle + 1.0 + throttle_rate) -- normalise this transform for a percentage application to the -1 to 1 throttle axis
    elseif command==Keys.throttle_acc then
        throttle_accelerating = value
        if value == 0 then
            throttle_acceleration_rate = throttle_acceleration_default -- reset the rate to the default
            throttle_accelerating_duration = 0 -- reset the accelleration duration to 0
        end
    elseif command==device_commands.throttle_axis_slew then
        throttle_slew = value
    elseif command==device_commands.throttle_click then
        -- validate that throttle is not in adjust range
        if sensor_data.getThrottleLeftPosition() > 0.3 then 
            return
        end
        if value==0 and throttle_state==THROTTLE_ADJUST and throttle<=0.01 then
            -- click to IGN from adjust
            throttle_state = THROTTLE_IGN
			efm_data_bus.fm_setIgnition(1.0)
            elseif value==0 and throttle_state==THROTTLE_OFF then
            -- click to IGN from OFF
            throttle_state = THROTTLE_IGN
			efm_data_bus.fm_setIgnition(1.0)
        elseif value==-1 and throttle_state==THROTTLE_IGN then
            -- click to OFF from IGN
            throttle_state = THROTTLE_OFF
			efm_data_bus.fm_setIgnition(0.0)
            if rpm>=55 and engine_state == ENGINE_RUNNING then
                debug_print("engine has been turned off")
                dispatch_action(nil,iCommandEnginesStop)
                engine_state = ENGINE_OFF
            end
        elseif value==1 and throttle_state==THROTTLE_IGN then
            -- click to ADJUST from IGN
            throttle_state = THROTTLE_ADJUST
			efm_data_bus.fm_setIgnition(1.0)
        end
    elseif command == device_commands.throttle_click_ITER then
        -- validate that throttle is not in adjust range else cancel action
        if sensor_data.getThrottleLeftPosition() > 0.3 then
            return
        end
        -- value should be +1 or -1
        if value == -1 or value == 1 then
            -- get current throttle state to iterate over
            local current_throttle_click_position = 0
            if throttle_state == THROTTLE_OFF then current_throttle_click_position = -1
                elseif throttle_state == THROTTLE_IGN then current_throttle_click_position = 0
                elseif throttle_state == THROTTLE_ADJUST then current_throttle_click_position = 1 
                end
            -- iterate value of click position
            local new_throttle_click_value = current_throttle_click_position + value
            -- print_message_to_user("new.."..new_throttle_click_value)
            -- validate throttle click value is within range
            if new_throttle_click_value > 1 then new_throttle_click_value = 1
                elseif new_throttle_click_value < -1 then new_throttle_click_value = -1
            end
            dev:performClickableAction(device_commands.throttle_click, new_throttle_click_value, false)
        end
    elseif command == Keys.throttle_position_off then
        dev:performClickableAction(device_commands.throttle_click, -1, false)
    elseif command == Keys.throttle_position_ign then
        dev:performClickableAction(device_commands.throttle_click, 0, false)
    elseif command == Keys.throttle_position_run then
        dev:performClickableAction(device_commands.throttle_click, 1, false)
    elseif command==device_commands.ENGINE_manual_fuel_shutoff then
        local manual_fuel_shutoff_catch_clickable_ref = get_clickable_element_reference("PNT_131")
        -- if fuel is cut off, shutdown engines and prevent engines from restarting until lever is reset.
        if value == 1 then
            dispatch_action(nil,iCommandEnginesStop)
            engine_state = ENGINE_OFF
			 efm_data_bus.fm_setIgnition(0.0)
            Engine:performClickableAction(device_commands.push_starter_switch,0,false) -- pop up start button
            EMER_FUEL_SHUTOFF = true
            manual_fuel_shutoff_catch_clickable_ref:hide(true)
        else
            EMER_FUEL_SHUTOFF = false
            manual_fuel_shutoff_catch_clickable_ref:hide(false)
        end
    elseif command==device_commands.ENGINE_manual_fuel_shutoff_catch then
        -- catch needs to in the raise position before the manual fuel cutoff lever is allowed to be pulled.
        local manual_fuel_shutoff_clickable_ref = get_clickable_element_reference("PNT_130")
        if value == 1 then 
            manual_fuel_shutoff_clickable_ref:hide(false)
        else
            manual_fuel_shutoff_clickable_ref:hide(true)
        end
    elseif command == device_commands.ENGINE_wing_fuel_sw then
        --print_message_to_user("Fuel Dump Switch: "..value)
        fuel_dump_switch = value
        if value == 1 then
            -- activate fuel dump
            efm_data_bus.fm_setDumpingFuel(1.0)
            --dispatch_action(nil, iCommandPlaneFuelOn)
        elseif value == -1 then
            efm_data_bus.fm_setDumpingFuel(0.0)
            -- position: emer trans
            -- TODO implement logic
        elseif value == 0 then
            efm_data_bus.fm_setDumpingFuel(0.0)
            -- position: off
            --dispatch_action(nil, iCommandPlaneFuelOff)
        end
    elseif command == device_commands.ENGINE_fuel_control_sw then
        --print_message_to_user("Fuel Control Switch: "..value)
        manual_fuel_control_mode_sw = value
        if value == 1 then
            -- position: manual
        elseif value == 0 then
            -- position: primary
        end
    elseif command == device_commands.ENGINE_drop_tanks_sw then
        --print_message_to_user("Drop Tanks Switch: "..value)
        drop_tank_press_switch = value
        if value == 1 then
            -- position: off
        elseif value == 0 then
            -- position: press
        elseif value == -1 then
            -- position: flight refuel
        end
    elseif command == Keys.fuel_dump_cycle then
        if fuel_dump_switch == 0 then
            dev:performClickableAction(device_commands.ENGINE_wing_fuel_sw, 1, false)
        elseif fuel_dump_switch == 1.0 then
            dev:performClickableAction(device_commands.ENGINE_wing_fuel_sw, -1, false)
        else
            dev:performClickableAction(device_commands.ENGINE_wing_fuel_sw, 0, false)
        end
    elseif command == Keys.drop_tank_press_cycle then
        if drop_tank_press_switch == 0 then
            dev:performClickableAction(device_commands.ENGINE_drop_tanks_sw, -1, false)
        elseif drop_tank_press_switch == 1.0 then
            dev:performClickableAction(device_commands.ENGINE_drop_tanks_sw, 0, false)
        else
            dev:performClickableAction(device_commands.ENGINE_drop_tanks_sw, 1, false)
        end
    elseif command == Keys.Fuel_Transfer_Bypass_Toggle then
        fuel_transfer_bypass_valve = fuel_transfer_bypass_state
        dev:performClickableAction((device_commands.fuel_transfer_bypass), ((fuel_transfer_bypass_state * -1) +1), false)
        fuel_transfer_bypass_state = (fuel_transfer_bypass_valve * -1) +1
    elseif command == Keys.FuelControl then
        dev:performClickableAction((device_commands.ENGINE_fuel_control_sw), ((manual_fuel_control_mode_sw * -1) +1), false)
    else
        -- print_message_to_user("engine unknown cmd: "..command.."="..tostring(value))
    end


end

local egt_c_val=WMA(0.02)
-- update EGT as a function of calculated thrust
function update_egt()
    local mach = sensor_data.getMachNumber()
    local alt = sensor_data.getBarometricAltitude()
    --local thrust = sensor_data.getEngineLeftFuelConsumption()*2.20462*3600
	local thrust = sensor_data.mod_fuel_flow()*2.20462*3600
	local throttle = sensor_data.getThrottleLeftPosition()

    -- SFC is 20% higher at M0.8 compared to M0.0 at 10,000'
    -- SFC reduces by ~3.7% per 3300m delta from 10,000' at M0.8
    local sfc_mod_mach
    if mach <= 0.8 then
        sfc_mod_mach = ((mach-0.8) * .2) + 1
    else
        sfc_mod_mach = 1.2
    end

    local alt_delta = math.abs(alt - 3300)
    local sfc_mod_alt = 1.0 - (0.037*(alt_delta/3300))
    thrust = thrust * sfc_mod_mach * sfc_mod_alt
    --print_message_to_user("thrust: "..thrust)

	--print_message_to_user("debug: "..engine_state)	

    if thrust > 8400 then
        output_egt = (thrust-8400)*0.0633 + 593
    elseif thrust > 6800 then
        output_egt = (thrust-6800)*0.0481 + 516

    --elseif thrust > 0 then
    --    output_egt = thrust*0.0274 + 325
 	elseif thrust > 0 and engine_state==ENGINE_STARTING then --Nov 2025, during engine start EGT greater than at idle 455C max
        output_egt = thrust*0.0274 + 400    
	elseif thrust > 0 and throttle_state~=THROTTLE_IGN then --Nov 2025, no EGT when throttle on IGN (no fuel)
        output_egt = thrust*0.0274 + 325   

	else
        output_egt = 0
    end

    --print_message_to_user("EGT_o: "..output_egt)

    egt_c:set(egt_c_val:get_WMA(output_egt))
end

function update_igniter() 
    -- this is just sound code and does not affect engine operation in any way
    -- as-is, you have 20 seconds of sparks total once you move into IGN, 
    -- If you move into ADJUST earlor if it's sparked for a total of 20 seconds, 
    -- the throttle must be returned to the OFF position for this sound to play again.
    -- Once an ignition hook from the EFM is complete, this code can go away with a clear and simple hook.
    local igniter_countup = igniter_timer
    if throttle_state==THROTTLE_OFF then -- throttle OFF, reset system for a new startup attempt
        sound_params.snd_inst_engine_igniter_whirr:set(0.0)
        sound_params.snd_alws_engine_igniter_spark:set(0.0)
        igniter_timer = 0
    elseif throttle_state==THROTTLE_IGN and get_elec_primary_ac_ok() and get_elec_primary_dc_ok() then
        if igniter_timer == 0 then
            igniter_timer = 1  -- start ignition timer
            sound_params.snd_inst_engine_igniter_whirr:set(1.0)
        elseif igniter_timer >= 1 then
            if igniter_timer < igniter_max then -- set above
                sound_params.snd_alws_engine_igniter_spark:set(1.0)
                sound_params.snd_inst_engine_igniter_whirr:set(1.0) -- play initial sound again returning from ADJ
                igniter_timer = igniter_countup + 1 -- count it up
            else -- timer maximum, disable igniter sounds
               sound_params.snd_inst_engine_igniter_whirr:set(0.0)
               sound_params.snd_alws_engine_igniter_spark:set(0.0)
            end
        end
    elseif throttle_state==THROTTLE_ADJUST then -- throttle in run, disable igniter sounds
        sound_params.snd_inst_engine_igniter_whirr:set(0.0)
        sound_params.snd_alws_engine_igniter_spark:set(0.0)
        igniter_timer = igniter_max
    end
end

local rpm_deci = get_param_handle("RPM_DECI")

function update_rpm()
    -- idle at 55% internal, max 103%
    -- draw .534 at 55%, draw 1.0 at 100%
    --local rpm=sensor_data.getEngineLeftRPM()

	rpm=sensor_data.getEngineLeftRPM()
    rpm=rpm/10.0
    rpm=rpm-math.floor(rpm)
    rpm_deci:set(rpm)
end

function update_engine_noise()
    -- airway valve opens to allow huffer air for the first time
    local rpm = sensor_data.getEngineLeftRPM()
    if rpm > 1 then
        sound_params.snd_inst_engine_wind_up:set(1.0)
    else
        sound_params.snd_inst_engine_wind_up:set(0.0)
    end
    -- additional INTERNAL engine sounds are encoded from:
    -- /Cockpit/Scripts/Systems/sound_system.lua
    -- additional INTERNAL engine sounds are encoded from:
    -- /Sounds/Sounders/Aircraft/Engines/Engine.lua
end

local oil_pressure_psi=WMA(0.15,0)
--[[
NATOPS:
Engine oil pressure is shown on the oil pressure indicator
(figures FO-1 and FO- 2) on the instrument panel.
Normal oil pressure is 40 to 50 psi. Minimum oil
pressure for ground IDLE is 35psi.
NOTE:
- Maneuvers producing acceleration near zero
"g" may cause a temporary loss of oil pressure.
Absence of oil pressure for a maximum
of 10 seconds is permissible.
- Oil pressure indications are available on
emergency generator.

OIL PRESSURE VARIATION
The oil pressure indication at IDLE RPM should be
normal (40 to 50 psi); however, a minimum of 35 psi
for ground operation is acceptable. If the indication
is less than 35 psi at 60 percent rpm, shut down the
engine to determine the reason for the lack of, or
low, oil pressure.
- Even though certain maneuvers normally
cause a momentary loss of oil pressure,
maximum operating time with an oil pressure
indicating less than 40 psi in flight is
1 minute. If oil pressure is not recovered
in 1 minute, the flight should be terminated
as soon as practicable.
- Maneuvers producing acceleration near zero
g may cause complete loss of oil pressure
temporarily. Absence of oil pressure for
a maximum of 10 seconds is permissible.
- If the oil pressure indicator reads high (over
50 psi), the throttle setting should be made as
soon as possible, and the cause investigated.
NOTE:
During starting and initial runup, the maximum
allowable oil pressure is 50 psi.
--]]
function update_oil_pressure()
    local rpm = sensor_data.getEngineLeftRPM()
    
    local oil_pressure_nominal
    if get_elec_26V_ac_ok() then -- will have power on main and emergency generator
        if rpm < 55 then
            oil_pressure_target=35
        else
            -- oil pressure 40-45 based on RPM
            oil_pressure_target = 5 * (rpm-55)/45 + 40
        end

        local stress = engine_heat_stress:get()
        oil_pressure_target = oil_pressure_target + stress * (40/100) -- up to 40psi oil pressure due to heat buildup
    else
        oil_pressure_target=0
    end

    oil_pressure:set(oil_pressure_psi:get_WMA(oil_pressure_target))
end


-- pressure ratio is essentially thrust
-- MIL thrust (9310 lbf) is a PR of 2.83 = 4137N
-- to figure out current thrust, we need to divide fuel consumption by SFC to get force
-- Nov 2025: however SFC changes with altitude, used manual Fig 11-24 to estimate SFC with altitude
local pressure_ratio_val=WMA(0.15,0)

function update_pressure_ratio()
    local prt = 1.2

local alt = sensor_data.getBarometricAltitude()

    if get_elec_fwd_mon_ac_ok() then -- no power on emergency generator
        --prt = (sensor_data.getEngineLeftFuelConsumption()*3600/0.86) / 4137
		
		sfc_corr_alt = 0.86 + (-0.000023813 * (alt*3.28) + 0.0442013904) --sfc (0.86 sea level) corrected for altitude
		
		--print_message_to_user("debug: "..sfc_corr_alt)
		prt = (sensor_data.mod_fuel_flow()*3600/sfc_corr_alt) / 4137
		
        --print_message_to_user("pct max thrust: "..prt)
        prt = (prt*1.83) + 1
        --print_message_to_user("pr: "..prt)
    end

    pressure_ratio:set(pressure_ratio_val:get_WMA(prt))
end

local life_s_accum = 0
function accumulate_temp()
    local temp = egt_c:get()

    -- 30 min max @ 649 C (dc = 55.6 C)     -- accumulate 1 degree*sec up to 650
    -- 8 minute max @ 677 C (dC = 83.35 C)  -- accumulate 2 degree*sec beyond 650

    -- from excel:  lifetime y = 28563e^(-0.049 x) where x is degrees C above 593.5
    
    -- accumulate 1/lifeseconds per second while hot

    if temp > 593.5 then
        life_s_accum = life_s_accum + (100 / (28563 * math.exp(-0.049 * (temp-593.5))))
    else
        life_s_accum = life_s_accum + (temp-593.5)/1000
    end

    if life_s_accum <= 0 then
        life_s_accum = 0
    end

    engine_heat_stress:set(life_s_accum)
end

function update_fuel_control_mode()
    -- check fuel control switch state
    if manual_fuel_control_mode_sw == 1 then
        manual_fuel_control_mode = 1
    elseif manual_fuel_control_mode_sw == 0 then
        -- check if engine conditions allow for primary fuel control
        -- fuel system switches to PRIMARY when engine rpm approximately 5 to 10 percent rpm
        local engine_rpm = sensor_data.getEngineLeftRPM()
        if engine_rpm > 8 then
            manual_fuel_control_mode = 0
        else
            manual_fuel_control_mode = 1
        end
    end

    -- update indicator
    if manual_fuel_control_mode == 1 and get_elec_primary_ac_ok() then
        manual_fuel_control_warn_param:set(1)
    else
        manual_fuel_control_warn_param:set(0)
    end
end

local prev_rpm=0
local prev_throttle_pos=0
local once_per_sec = 1/update_rate
function update()
	local rpm = sensor_data.getEngineLeftRPM()
    local throttle = sensor_data.getThrottleLeftPosition()
    local gear = get_aircraft_draw_argument_value(0) -- nose gear

    update_igniter()
    update_rpm()
    update_engine_noise()
    update_oil_pressure()
    update_pressure_ratio()
    update_egt()
    update_fuel_control_mode()

    if throttle_accelerating ~= 0 then
        --throttle is accelerating, increase and record the acceleration rate, starting from 1% of the throttle step setting
        throttle_accelerating_duration = clamp(throttle_accelerating_duration + throttle_acceleration_rate, 0.01, 1)
        --increase or decrease throttle at acceleration direction and rate
        dispatch_action(nil, iCommandPlaneThrustCommon, -2.0 * throttle + 1.0 - throttle_accelerating * throttle_accelerating_duration)
        --print_message_to_user("Throttle: " .. throttle .. " | Delta (abs): " .. throttle_accelerating_duration)
    elseif throttle_slew ~= 0 then
        --increase or decrease throttle using direction and rate
        local throttle_slew_rate = throttle_slew * 0.125
        dispatch_action(nil, iCommandPlaneThrustCommon, -2.0 * throttle + 1.0 - throttle_slew_rate)
        --print_message_to_user("Throttle: " .. throttle .. " | Delta (abs): " .. throttle_slew_rate)
    end

    once_per_sec = once_per_sec - 1
    if once_per_sec <= 0 then
        accumulate_temp()
        once_per_sec = 1/update_rate
    end

	if (engine_state==ENGINE_STARTING) and rpm > 50 then
        Engine:performClickableAction(device_commands.push_starter_switch,0,false) -- pop up start button
    end
    if start_button_popup_timer > 0 then
        start_button_popup_timer = start_button_popup_timer - update_rate
        if start_button_popup_timer <= 0 then
            start_button_popup_timer = 0
            Engine:performClickableAction(device_commands.push_starter_switch,0,false) -- pop up start button
        end
    end

    if prev_rpm ~= rpm then
        if rpm >= 55 then
            if engine_state == ENGINE_STARTING then
                engine_state = ENGINE_RUNNING
            end
        else
            if rpm>=5 and engine_state == ENGINE_OFF then
                if rpm>14 and get_cockpit_draw_argument_value(100)>0.99 then
                    debug_print("failed to ignite engine")
                    dispatch_action(nil,iCommandEnginesStop)
                    Engine:performClickableAction(device_commands.push_starter_switch,0,false) -- pop up start button
                elseif throttle_state==THROTTLE_IGN and get_cockpit_draw_argument_value(100)>0.99 then
                    engine_state = ENGINE_IGN
                    debug_print("igniting engine")
                end
            end
            if rpm>=22 and (engine_state == ENGINE_IGN or throttle_state ~= THROTTLE_ADJUST) and get_cockpit_draw_argument_value(100)>0.99 then
                debug_print("failed to IDLE throttle")
                Engine:performClickableAction(device_commands.push_starter_switch,0,false) -- pop up start button
            end
            if rpm>=15 and engine_state == ENGINE_IGN and get_cockpit_draw_argument_value(100)>0.99 then
                if throttle_state==THROTTLE_ADJUST then
                    debug_print("starting engine")
                    engine_state = ENGINE_STARTING
                end
            end
            if (engine_state == ENGINE_IGN or engine_state == ENGINE_STARTING) and throttle_state==THROTTLE_OFF and get_cockpit_draw_argument_value(100)>0.99 then
                debug_print("abort engine start")
                Engine:performClickableAction(device_commands.push_starter_switch,0,false) -- pop up start button
            end
        end
        if rpm<54 and engine_state == ENGINE_RUNNING then
            debug_print("engine has gone off")
            engine_state = ENGINE_OFF
        end
        if rpm>=55 and engine_state == ENGINE_RUNNING and throttle_state==THROTTLE_OFF then
            debug_print("engine has been turned off")
            dispatch_action(nil,iCommandEnginesStop)
            engine_state = ENGINE_OFF
        end

        prev_rpm = rpm
    end

    if throttle_state == THROTTLE_OFF then
        throttle = -1
    elseif throttle_state == THROTTLE_IGN then
        throttle = -0.7
    elseif throttle_state == THROTTLE_ADJUST then
        local throttle_clickable_ref = get_clickable_element_reference("PNT_80")
        throttle_clickable_ref:hide(throttle>0.01)
    end

    local throttle_pos = throttle_position_wma:get_WMA(throttle)
    if prev_throttle_pos ~= throttle_pos then
        if throttle <= 0.01 then
            local throttle_clickable_ref = get_clickable_element_reference("PNT_80")
            throttle_clickable_ref:update() -- ensure it is clickable at the correct position
        end
        prev_throttle_pos = throttle_pos
    end
	efm_data_bus.fm_setEngineThrottle(throttle_pos)
    throttle_position:set(throttle_pos)

    ControlsIndicator_api:setThrottle(throttle_pos)
end


need_to_be_closed = false -- close lua state after initialization
