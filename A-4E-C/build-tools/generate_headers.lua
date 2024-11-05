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


project_root = arg[1]
output_dir = project_root.."\\ExternalFM\\Common\\Common\\"


GenerateCommandDefs(project_root, output_dir)
GenerateDevices(project_root, output_dir)

