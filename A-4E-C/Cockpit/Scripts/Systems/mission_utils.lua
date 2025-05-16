dofile(LockOn_Options.script_path.."ConfigurePackage.lua")


require(common_scripts.."tools")
require("utils")

function get_qnh()
    return mission["weather"]["qnh"]
end

function find_mobile_tacan_and_icls()
    local tacan_to_id = {}
    local icls_to_id = {}

    

    for i,v in ipairs(mission.coalition.blue.country) do
        
        if v.ship then
            local groups = v.ship.group
            append_beacons_to_id(groups, tacan_to_id, icls_to_id)
        end

        if v.plane then
            local groups = v.plane.group
            append_beacons_to_id(groups, tacan_to_id, icls_to_id)
        end

        if v.vehicle then
            local groups = v.vehicle.group
            append_beacons_to_id(groups, tacan_to_id, icls_to_id)
        end

    end

    for i,v in ipairs(mission.coalition.red.country) do
        
        if v.ship then
            local groups = v.ship.group
            append_beacons_to_id(groups, tacan_to_id, icls_to_id)
        end

        if v.plane then
            local groups = v.plane.group
            append_beacons_to_id(groups, tacan_to_id, icls_to_id)
        end

        if v.vehicle then
            local groups = v.vehicle.group
            append_beacons_to_id(groups, tacan_to_id, icls_to_id)
        end

    end

    return tacan_to_id, icls_to_id
end

function find_min_id()


    local min = 1000000

    stack = {{key = nil, value = mission, depth = 0}}
    explored = {}

    while stack do
        local stack_item = table.remove(stack)
        
        if stack_item == nil then
            break
        end

        local key = stack_item.key
        local item = stack_item.value
        local depth = stack_item.depth
        
        

        if type(item) == "table" then
            if not explored[tostring(item)] then
                for i,v in pairs(item) do
                    table.insert(stack, {key = i, value = v, depth = depth+1 })
                end
                explored[tostring(item)] = true
            end

            
        else
            if key == "unitId" then
                if item < min then
                    min = item
                end
            end
        end

    end

    return min
end

function addDashes(name)
    local number = name:sub(-2)
    print_message_to_user(tostring(number))

    local callsign = name:sub(1, -3)
    print_message_to_user(tostring(callsign))

    callsign = callsign .. number:sub(1,1) .. "-" .. number:sub(2,2)
    print_message_to_user(tostring(callsign))
    return callsign
end

function append_beacons_to_id(groups, tacan_to_id, icls_to_id)
    for key,value in ipairs(groups) do
        local tasks = value["tasks"]
        local points = value["route"]["points"]

        --local tacan_value, callsign, override_id 
        
        local group_beacon_data = search_waypoints_for_beacons(points)
        if tasks then
            search_for_task_beacons(tasks, group_beacon_data)
        end
        local unit_id = value["units"][1]["unitId"]
        local unit_type = value["units"][1]["type"]

        for i,unit in ipairs(group_beacon_data) do
            local unit_id_to_use = unit_id
            if unit.unitid then
                unit_id_to_use = unit.unitid
            end

            local name = find_name_by_id(value["units"], unit_id_to_use)

            local table_to_use = tacan_to_id

            if unit.type == "icls" then
                append_group_beacon_data(icls_to_id, unit.channel, unit_id_to_use, name, unit.callsign, false, unit_type)
            else
                append_group_beacon_data(tacan_to_id, unit.channel, unit_id_to_use, name, unit.callsign, unit.air_to_air, unit_type)
            end
        end
    end
end

function append_group_beacon_data(t, channel, unit_id, name, callsign, air_to_air, unit_type)
    if t[channel] == nil then
        t[channel] = {}
        t[channel][1] = { id = unit_id, name = name, callsign = callsign, air_to_air = air_to_air, type = unit_type }
    else
        local len = #t[channel]
        t[channel][len+1] = { id = unit_id, name = name, callsign = callsign, air_to_air = air_to_air, type = unit_type }
    end
end


function find_name_by_id(units, unit_id)
    name = units[1]["name"]

    for i,v in ipairs(units) do
        if v["unitId"] == unit_id then
            name = v["name"]
            break
        end
    end

    return name
end

function search_waypoints_for_beacons(points)

    local group_beacon_data = {}

    for wpt_num,waypoint in ipairs(points) do
        
        if waypoint["task"] and waypoint["task"]["params"] then

            local params = waypoint["task"]["params"]

            if params["tasks"] then

                local tasks = params["tasks"]
                
                search_for_task_beacons(tasks, group_beacon_data)
                
            end
        end
    end
    
    return group_beacon_data
end

function search_for_task_beacons(tasks, group_beacon_data)

    for task_num, task in ipairs(tasks) do

        if task["params"] and task["params"]["action"] then
            local action = task["params"]["action"]

            if action["id"] == "ActivateBeacon" then
                local air_to_air = action["params"]["AA"]
                print_message_to_user(air_to_air)
                if air_to_air == nil then
                    air_to_air = true
                end

                group_beacon_data[#group_beacon_data + 1 ] = {
                    air_to_air = air_to_air,
                    channel = action["params"]["channel"],
                    callsign = action["params"]["callsign"],
                    unitid = action["params"]["unitId"],
                    type = "tacan"
                }


            elseif action["id"] == "ActivateICLS" then
                group_beacon_data[#group_beacon_data + 1] = {
                    channel = action["params"]["channel"],
                    callsign = "",
                    uintid = action["params"]["unitId"],
                    type = "icls"
                }
            end
        end
    end
end

function recursively_search_value(table, search_value)
    local i,v = next(table, nil)

    while i do
        if v == search_value then
            return i,v
        end

        i,v = next(table, i)
    end

    return nil, nil

end