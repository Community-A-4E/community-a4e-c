dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.common_script_path.."ViewportHandling.lua")
dofile(LockOn_Options.script_path.."utils.lua")

startup_print("radar HUD: load")

indicator_type       = indicator_types.COMMON----------------------
init_pageID     = 1
purposes 	   = {render_purpose.GENERAL,render_purpose.HUD_ONLY_VIEW}
--subset ids
BASE    = 1
INDICATION = 2

page_subsets  = {
[BASE]    		= LockOn_Options.script_path.."RADAR/Indicator/base_page.lua",
[INDICATION]    = LockOn_Options.script_path.."RADAR/Indicator/indication_page.lua",
}
pages = 
{
	{
	 BASE,
	 INDICATION
	 },
}

--[[
opacity_sensitive_materials =
{
"BLOB_TEXTURE"
}

color_sensitive_materials =
{
"BLOB_TEXTURE"
}

brightness_sensitive_materials =
{
"BLOB_TEXTURE"
}

day_color    = {0, 0, 255/255, 255/255}
night_color  = {243/255, 116/255, 13/255, 255/255}
--]]

update_screenspace_diplacement(SelfWidth/SelfHeight,false)
dedicated_viewport_arcade = dedicated_viewport

try_find_assigned_viewport("A4E_RADAR", "RIGHT_MFCD")

startup_print("radar HUD: load end")
