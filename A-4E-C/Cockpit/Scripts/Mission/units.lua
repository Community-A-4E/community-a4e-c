-- LockOn_Options = {
--     script_path = "C:\\Users\\JNelson\\Saved Games\\DCS.openbeta\\Mods\\Aircraft\\A-4E-C\\Cockpit\\Scripts\\",
--     common_script_path = ""
-- }
dofile(LockOn_Options.script_path .. "ConfigurePackage.lua")
require('utils')
require('Mission.mission')

--require('mission_example')

-- Recursively Searches all matching entries on the given path.
-- for a table with the key value pair.
function find_tables_on_path(t, path, output, log_fn)
    output = output or {}

    if path == nil then
        table.insert(output, t)
        return
    end

    local category, path = string_split_first(path, '.')

    if category == '[]' then
        for i, v in pairs(t) do
            if type(v) == 'table' then
                find_tables_on_path(v, path, output, log_fn)
            end
        end
    elseif t[category] and type(t[category]) == 'table' then
        find_tables_on_path(t[category], path, output, log_fn)
    end

    return output
end

local units = {
    planes = {},
    ships = {},
    vehicles = {},
    all_units = {},
    tacan_beacons = {},
    icls_beacons = {}
}

local planes = find_tables_on_path(mission, "coalition.[].country.[].plane.group.[].units.[]")
local ships = find_tables_on_path(mission, "coalition.[].country.[].ship.group.[].units.[]")
local vehicles = find_tables_on_path(mission, "coalition.[].country.[].vehicle.group.[].units.[]")
local all_units = find_tables_on_path(mission, "coalition.[].country.[].[].group.[].units.[]")

local groups = find_tables_on_path(mission, "coalition.[].country.[].[].group.[]")
--local tasks = find_tables_on_path(mission, "coalition.[].country.[].[].group.[].route.points.[].task.params.tasks.[].params.action")

--points.[].params.tasks.[].params.action

function add_units(target, t)
    for i, v in ipairs(t) do
        if v.unitId then
            target[v.unitId] = v
        end
    end
end

add_units(units.planes, planes)
add_units(units.ships, ships)
add_units(units.vehicles, vehicles)
add_units(units.all_units, all_units)

for group_idx, group in ipairs(groups) do

    local tasks = find_tables_on_path(group, "route.points.[].task.params.tasks.[].params.action")

    local unit_id = group["units"][1]["unitId"]

    for i,v in ipairs(tasks) do
        if v["id"] then
            if v["id"] == "ActivateICLS" then
                if v.params and v.params.channel then
                    if units.icls_beacons[v.params.channel] == nil then
                        units.icls_beacons[v.params.channel] = {}
                    end
                    
                    if v.params["unitId"] == nil then
                        v.params["unitId"] = unit_id
                    end

                    table.insert(units.icls_beacons[v.params.channel], v.params)
                end
            elseif v["id"] == "ActivateBeacon" then
                if v.params and v.params.channel then
                    if units.tacan_beacons[v.params.channel] == nil then
                        units.tacan_beacons[v.params.channel] = {}
                    end

                    if v.params["unitId"] == nil then
                        v.params["unitId"] = unit_id
                    end

                    table.insert(units.tacan_beacons[v.params.channel], v.params)
                end
            end
        end
    end
end

for i, v in pairs(units.tacan_beacons) do
    
    local beacons = {}
    for i1, beacon in ipairs(v) do
        local unit = units.all_units[beacon.unitId]
        if unit then
            table.insert(beacons, "    "..unit.name)
        end
    end

    beacons = table.concat(beacons, '\n')
    print(string.format("Channel: %d\n%s", i, beacons))
end

function units:get_plane(mission_id)
    return units.planes[mission_id]
end

return units