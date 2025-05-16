filename = get_terrain_related_data("beacons") or get_terrain_related_data("beaconsFile")

if filename ~= nil then
    dofile(filename)
end