dofile(LockOn_Options.script_path.."ConfigurePackage.lua")
require('Mission.beacons')


local units = require('Mission.units')

local TCN_UNIT_STATIC = 0
local TCN_UNIT_PLANE = 1
local TCN_UNIT_VEHICLE = 2
local TCN_UNIT_SHIP = 3


local tacans = {}
for i, v in pairs(beacons) do
    -- Source beacons.lua in various maps
    if v.type == BEACON_TYPE_VORTAC or v.type == BEACON_TYPE_TACAN then
        if getTACANFrequency(v.channel, 'X') == v.frequency then --check xray tacan
            if tacans[v.channel] == nil then
                tacans[v.channel] = {}
            end
            table.insert(tacans[v.channel], {
                position = { x = v.position[1], y = v.position[2], z = v.position[3] },
                callsign = v.callsign,
                name = v.display_name,
                bearing = true,
                air_to_air = false,
                unit_type = TCN_UNIT_STATIC,
                -- unit_id -> nil for static beacons
            })
        end
    end
end

for channel, beacons in pairs(units.tacan_beacons) do
    
    for index, beacon in pairs(beacons) do
        if beacon.unitId ~= nil then
            if units.all_units[beacon.unitId] then
                if tacans[channel] == nil then
                    tacans[channel] = {}
                end

                local unit_type = TCN_UNIT_STATIC
                if units.planes[beacon.unitId] ~= nil then
                    unit_type = TCN_UNIT_PLANE
                elseif units.ships[beacon.unitId] ~= nil then
                    unit_type = TCN_UNIT_SHIP
                elseif units.vehicles[beacon.unitId] ~= nil then
                    unit_type = TCN_UNIT_VEHICLE
                end

                -- Insert this tacan
                table.insert(tacans[channel], {
                    position = { x = 0, y = 0, z = 0 },
                    callsign = beacon.callsign,
                    name = units.all_units[beacon.unitId].name,
                    bearing = beacon.bearing,
                    air_to_air = beacon.AA,
                    unit_id = beacon.unitId,
                    unit_type = unit_type,
                })
            end
        end
    end
end


return tacans