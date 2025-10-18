-- A4EHook.lua
-- Purpose:
--   Enforces A-4E-C mod version compatibility on multiplayer servers/clients for DCS.
--   Clients report their local A-4E-C plugin version to the server via RPC.
--   The server stores versions per-player and prevents slot changes to A-4E-C if versions mismatch.
--
-- Key concepts:
--   - Client: sends its A-4E-C version to the server upon connect.
--   - Server: records each player's version and validates when players try to take an A-4E-C slot.
--   - RPC: simple remote procedure call mechanism used to send versions to the server.
--
-- by Special K

local base		    = _G
local RPC   	    = base.require('RPC')
local a4e_hook 	    = a4e_hook or {}
local a4e_versions  = {}

-- Returns the plugin descriptor for the A-4E-C mod from the global plugin list.
-- Output:
--   table or nil: plugin object with fields shortName, version, etc.
function get_plugin()
	for _, plugin in pairs(base.plugins) do
		if plugin.shortName == 'A-4E-C' then
			return plugin
		end
	end
end

-- Client-side callback: invoked when the player connects.
-- Behavior:
--   - No-op on server (server doesn't need to register itself this way).
--   - On client, finds the local A-4E-C plugin and RPCs its version to the server.
function a4e_hook.onPlayerConnect()
	if DCS.isServer() then
		return
	end
	plugin = get_plugin()
	if not plugin then
	    return
	end
    log.write('A4EHook', log.DEBUG, "Version: " .. plugin.version)
	-- Use pcall to avoid hard failure if RPC fails (e.g., race or connectivity issue).
	pcall(RPC.sendEvent, net.get_server_id() , "registerA4EVersion", plugin.version)
end

-- Server-side callback: triggered when a player attempts to change to a slot.
-- Params:
--   id (number): player id
--   side (number): coalition/side index (unused here)
--   slot (string): unit name/type reference for the slot
-- Behavior:
--   - If the target slot is an A-4E-C aircraft, ensure the player's reported version
--     matches the server's a4e_hook.myversion. If not, deny the slot change.
-- Return:
--   false to deny the slot change; nil to allow normal processing.
function a4e_hook.onPlayerTryChangeSlot(id, side, slot)
	log.write('A4EHook', log.DEBUG, "onPlayerTryChangeSlot()")
	if DCS.getUnitTypeAttribute(DCS.getUnitType(slot), "DisplayName") == 'A-4E-C' then
		if a4e_versions[id] ~= a4e_hook.myversion then
			net.send_chat_to("You need to use A-4E-C version " .. a4e_hook.myversion .. " to join this slot.", id)
			return false
		else
			log.write('A4EHook', log.DEBUG, "Version matches, player is allowed to join this slot.")
		end
	end
end

-- Server-side callback: resets a player's reported A-4E-C version.
-- Params:
--   id (number): player id (sender)
function a4e_hook.onPlayerDisconnect(id, err_code)
    a4e_versions[id] = nil
end

-- RPC endpoint on the server: records a player's reported A-4E-C version.
-- Params:
--   id (number): player id (sender)
--   version (string): player's local A-4E-C plugin version
function RPC.method.registerA4EVersion(id, version)
	log.write('A4EHook', log.DEBUG, 'Registering id=' .. id .. ', version=' .. version)
	a4e_versions[id] = version
end

-- Register our callbacks with DCS so onPlayerConnect/onPlayerTryChangeSlot are invoked.
DCS.setUserCallbacks(a4e_hook)

-- Server-only initialization: capture server's A-4E-C version for comparison.
if DCS.isServer() then
	plugin = get_plugin()
	if plugin then
        a4e_hook.myversion = plugin.version
    else
    	log.write('A4EHook', log.ERROR, 'A-4E-C not installed correctly!')
    end
end
