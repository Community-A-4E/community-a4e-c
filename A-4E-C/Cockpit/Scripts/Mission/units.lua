dofile(LockOn_Options.script_path .. "ConfigurePackage.lua")
require('utils')
require('Mission.mission')

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
    planes = {}
}

local planes = find_tables_on_path(mission, "coalition.[].country.[].plane.group.[].units.[]")

for i,v in ipairs(planes) do
    units.planes[v["unitId"]] = v
end

function units:get_plane(mission_id)
    return units.planes[mission_id]
end

return units