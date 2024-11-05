-- This allows the use of require statements. require uses . instead of / for folder sepparators.
-- Require only loads the lua once saving loading time.
package.path = package.path..";"..LockOn_Options.script_path.."?.lua"
package.path = package.path..";"..LockOn_Options.common_script_path.."?.lua"