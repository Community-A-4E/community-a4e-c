
require("EFM_Data_Bus")

local sensor_data = get_efm_sensor_data_overrides()

-- calculates the "forward azimuth" bearing of a great circle route from x1,y1 to x2,y2 in true heading degrees
function forward_azimuth_bearing(x1,y1,x2,y2)
    local lat1r = math.rad(x1)
    local lon1r = math.rad(y1)
    local lat2r = math.rad(x2)
    local lon2r = math.rad(y2)

    local y = math.sin(lon2r-lon1r) * math.cos(lat2r)
    local x = math.cos(lat1r)*math.sin(lat2r) - math.sin(lat1r)*math.cos(lat2r)*math.cos(lon2r-lon1r)
    local brng = math.deg(math.atan2(y, x))

    return brng
end

function true_bearing_deg_from_xz(x1,z1,x2,z2)
    return ( math.deg(math.atan2(z2-z1,x2-x1)) %360 )  -- true bearing in degrees
end

function true_bearing_viall_from_xz(x1, z1, x2, z2)
    local geopos1 = lo_to_geo_coords(x1, z1)
    local geopos2 = lo_to_geo_coords(x2, z2)

    return forward_azimuth_bearing(geopos1.lat, geopos1.lon, geopos2.lat, geopos2.lon)
end

function get_true()
    -- getHeading() returns straight radians heading where positive is counter-clockwise from north = 0,
    -- thus we must subtract returned value from 360 to get a "compass" heading
    local trueheading = (360 - math.deg( sensor_data.getTrueHeading() ) ) % 360
    return trueheading
end

function get_magnetic()
    -- getMagneticHeading() returns heading where 0 is north, pi/2 = east, pi = south, etc.
    -- so we can straight convert to degrees
    local maghead = math.deg( sensor_data.getMagneticHeading() ) % 360
    return maghead
end

-- returns declination based on current plane position.  negative is easterly declination, subtract from TH to get MH
function get_declination()
    local mh = sensor_data.getMagneticHeading()
    local th = 2*math.pi - sensor_data.getHeading()
    local dec = math.deg(th-mh)
    if dec > 180 then
        dec = dec - 360
    end
    return dec
end

function get_calculated_true_heading(offset)
    result = sensor_data.getMagneticHeading() + math.rad(offset)
    return result 
end

-- measures the deviation between grid north (delta x, fixed z) and "true" north in lat/long at that point
function get_true_deviation_from_grid(x,z)
    return true_bearing_viall_from_xz(x-1000, z, x+1000, z)
end