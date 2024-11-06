-- This allows the use of require statements. require uses . instead of / for folder sepparators.
-- Require only loads the lua once saving loading time.
common_scripts = LockOn_Options.common_script_path:gsub('/', '.')
package.path = package.path .. ";" .. LockOn_Options.script_path .. "?.lua"