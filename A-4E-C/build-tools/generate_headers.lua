project_root = arg[1]
package.path = package.path .. ';' .. project_root .. "\\build-tools\\?.lua"
package.cpath = package.cpath .. ';' .. project_root .. "\\build-tools\\?.dll"

function GenerateHeader(file_path, template, ...)
    local arg = {...}
    local s = string.format(template, table.unpack(arg))
    local file = io.open(file_path, "w+")
    file:write(s)
    file:close()
end

-- Generate Commands.h
function GenerateCommandDefs(project_root, output_dir)
    command_path = project_root.."\\Cockpit\\Scripts\\command_defs.lua"
    dofile(command_path)

    local template = [[
// ================================================================================== //
// THIS FILE IS AUTO-GENERATED
// ALL CHANGES WILL BE LOST
// ================================================================================== //
// SEE Cockpit/Scripts/device_commands.lua for the origin
#pragma once

enum Command
{
%s
};
]]

    local key_commands = {}
    for name, value in pairs(Keys) do
        table.insert(key_commands, string.format("    KEYS_%s = %d", name:upper(), value))
    end

    key_commands = table.concat(key_commands, ',\n')
    
    local dev_commands = {}
    for name, value in pairs(device_commands) do
        table.insert(dev_commands, string.format("    DEVICE_COMMANDS_%s = %d", name:upper(), value))
    end

    dev_commands = table.concat(dev_commands, ',\n')

    local enums = table.concat({key_commands, dev_commands}, ',\n')

    GenerateHeader(output_dir.."Commands.h", template, enums)
end

-- Generate Commands.h
function GenerateDevices(project_root, output_dir)
    device_path = project_root .. "\\Cockpit\\Scripts\\devices.lua"
    dofile(device_path)

    local template = [[
// ================================================================================== //
// THIS FILE IS AUTO-GENERATED
// ALL CHANGES WILL BE LOST
// ================================================================================== //
// SEE Cockpit/Scripts/devices.lua for the origin
#pragma once

enum Devices
{
%s
};
]]

    local device_list = {}
    for name, value in pairs(devices) do
        table.insert(device_list, string.format("    DEVICES_%s = %d", name, value))
    end

    device_list = table.concat(device_list, ',\n')
    GenerateHeader(output_dir .. "Devices.h", template, device_list)
end

function ToArray(hash)
    local array = {}

    for i = 1, #hash, 2 do
        table.insert(array, '0x'..hash:sub(i, i + 1))
    end
    
    return array
end

function GenerateHashes(project_root, output_dir)
    local template = [[
// ================================================================================== //
// THIS FILE IS AUTO-GENERATED
// ALL CHANGES WILL BE LOST
// ================================================================================== //
// SEE build-tools/generate_headers.lua for the origin
#pragma once

static const char* files[] = {
%s
};

static const unsigned char hash[%d] = { %s };
]]


    local md5 = require('md5')
    
    local files = {
        "entry.lua",
        "A-4E-C.lua",
        "Cockpit/Scripts/EFM_Data_Bus.lua",
        "Entry/Suspension.lua",
        "Weapons/A4E_Weapons.lua"
    }

    local s = ""

    for i, v in ipairs(files) do
        local path = project_root .. '\\' .. v
        local f = ""
        for line in io.lines(path) do
            s = s .. line
            f = f .. line
        end
    end

    local hash = md5.hash(s)

    print( "Important File Hash -> " .. hash)
    local array = ToArray(hash)
    local size = #array

    for i, v in ipairs(files) do
        files[i] = string.format("    \"%s\"", v)
    end
    
    array = table.concat(array, ',')
    files = table.concat(files, ',\n')
    GenerateHeader(output_dir .. "Hashes.h", template, files, size, array)
end

output_dir = project_root.."\\ExternalFM\\Common\\Common\\"


GenerateCommandDefs(project_root, output_dir)
GenerateDevices(project_root, output_dir)
GenerateHashes(project_root, output_dir)

