-- Simplified Aerodynamic Model by Helmo
-- mounting 3d model paths and texture paths

--mount_vfs_model_path    (current_mod_path.."/Shapes")
--mount_vfs_liveries_path (current_mod_path.."/Liveries")   -- mounted in entry.lua
--mount_vfs_texture_path  (current_mod_path.."/Textures")   -- mounted in entry.lua

--EDITING THIS FILE WILL CAUSE THE EFM TO FAIL.

local KG_TO_POUNDS  = 2.20462
local POUNDS_TO_KG  = 1/KG_TO_POUNDS
local FEET_TO_M     = 0.3048

--------------------------------------------Colt MK12 Gun----------------------------------------------------------------------------
local function coltMK12(tbl)

    tbl.category = CAT_GUN_MOUNT
    tbl.name      = "coltMK12"
    tbl.supply      =
    {
        shells = {"20x110mm HE-I", "20x110mm AP-I", "20x110mm AP-T"},
        mixes  = {
            {1,2,1,3},
            {1,1,1,1,1,3},
            {3},
        },   -- 50% HE-i, 25% AP-I, 25% AP-T
        count  = 100,
    }
    if tbl.mixes then
       tbl.supply.mixes = tbl.mixes
       tbl.mixes        = nil
    end
    tbl.gun =
    {
        max_burst_length    = 100000,
        rates               = {1000},
        recoil_coeff        = 0.7*1.3,
        barrels_count       = 1,
    }
    if tbl.rates then
       tbl.gun.rates        =  tbl.rates
       tbl.rates            = nil
    end
    tbl.ejector_pos             = tbl.ejector_pos or {0, 0, 0}
    tbl.ejector_pos_connector   = tbl.ejector_pos_connector     or  "Gun_point"
    tbl.ejector_dir             = {-1, -6, 0} -- left/right; back/front;?/?
    tbl.supply_position         = tbl.supply_position   or {0,  0.3, -0.3}
    tbl.aft_gun_mount           = false
    tbl.effective_fire_distance = 1500
    tbl.drop_cartridge          = 204
    tbl.muzzle_pos              = tbl.muzzle_pos            or  {0,0,0}     -- all position from connector
    tbl.muzzle_pos_connector    = tbl.muzzle_pos_connector  or  "Gun_point" -- all position from connector
    tbl.azimuth_initial         = tbl.azimuth_initial       or  0
    tbl.elevation_initial       = tbl.elevation_initial     or  0
    if  tbl.effects == nil then
        tbl.effects = {{ name = "FireEffect"     , arg = tbl.effect_arg_number or 436 },
                       { name = "HeatEffectExt"  , shot_heat = 7.823, barrel_k = 0.462 * 2.7, body_k = 0.462 * 14.3 },
                       { name = "SmokeEffect"}}
    end
    return declare_weapon(tbl)
end
---------------------------------------------------------------------------------------------------------------------------------------------

local function get_outboard_weapons( side )
    local rocketConnector = ""
    local shrikeConnector = ""
    if side == "L" then
        rocketConnector = "Pylon1RKT"
        shrikeConnector = "Pylon1b"
    elseif side == "R" then
        rocketConnector = "Pylon5RKT"
        shrikeConnector = "Pylon5b"
    end

    local tbl = {
        -- AIR AIR --
        { CLSID = "{GAR-8}",                                    connector = rocketConnector, arg_value = 0.2 },  -- AIM-9B, aligned to -3deg armament datum
        { CLSID = "{AIM-9P-ON-ADAPTER}",                        connector = rocketConnector, arg_value = 0.2 },  -- AIM-9P
        { CLSID = "{AIM-9P5-ON-ADAPTER}",                       connector = rocketConnector, arg_value = 0.2 },  -- AIM-9P5
        { CLSID = "{AIM-9P3-ON-ADAPTER}",                       connector = rocketConnector, arg_value = 0.2 },  -- AIM-9P3
        { CLSID = "{A4E-ASQ-T50-ON-ADAPTER}",                   connector = rocketConnector, arg_value = 0.2 },  -- ASQ-T50
        { CLSID = "{AIM-9J-ON-ADAPTER}",                        connector = rocketConnector, arg_value = 0.2 },  -- AIM-9J
        -- ROCKETS --
        --{ CLSID = "{3DFB7321-AB0E-11d7-9897-000476191836}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-61 Hydra WP156
        --{ CLSID = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-61 Hydra M151 HE
        { CLSID = "{A021F29D-18AB-4d3e-985C-FC9C60E35E9E}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra M151 HE
        { CLSID = "{4F977A2A-CD25-44df-90EF-164BFA2AE72F}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra M156 WP
        { CLSID = "{174C6E6D-0C3D-42ff-BCB3-0853CB371F5C}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk5 HEAT
        { CLSID = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra PI
        { CLSID = "{0877B74B-5A00-4e61-BA8A-A56450BA9E27}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Practice Smoke
        { CLSID = "{FC85D2ED-501A-48ce-9863-49D468DDD5FC}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk1 Practice
        { CLSID = "{65396399-9F5C-4ec3-A7D2-5A8F4C1D90C4}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk61 Practice
        { CLSID = "{1F7136CB-8120-4e77-B97B-945FF01FB67C}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra WTU-1/B Practice
        { CLSID = "{LAU3_FFAR_WP156}",                          connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 FFAR WP156
        { CLSID = "{LAU3_FFAR_MK1HE}",                          connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 FFAR Mk1 HE
        { CLSID = "{LAU3_FFAR_MK5HEAT}",                        connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 FFAR Mk5 HEAT
        { CLSID = "{LAU68_FFAR_WP156}",                         connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR WP156
        { CLSID = "{LAU68_FFAR_MK1HE}",                         connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR Mk1 HE
        { CLSID = "{LAU68_FFAR_MK5HEAT}",                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR Mk5 HEAT
        { CLSID = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-10 Zuni
        { CLSID = "LAU3_WP61",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_WP1B",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_HE5",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_WP156",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_HE151",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        -- MISSILES --
        { CLSID = "{LAU_34_AGM_45A}" }, -- AGM-45A SHRIKE
        { CLSID = "{C_A4E_AGM-45B_LAU34}"}, -- AGM-45B SHRIKE
        -- BOMBS --
        { CLSID = "{ADD3FAE1-EBF6-4EF9-8EFC-B36B5DDF1E6B}" },   -- Mk-20 Rockeye cluster bomb
        { CLSID = "{90321C8E-7ED1-47D4-A160-E074D5ABD902}" },   -- MK-81
        { CLSID = "{MK-81SE}" },                                -- Mk-81 Snakeye
        { CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" },   -- MK-82
        { CLSID = "{Mk82SNAKEYE}" },                            -- MK-82 Snakeye
        { CLSID = "{mk77mod1}" },                               -- Mk-77mod1 500 lb petroleum oil bomb
        { CLSID = "{AN_M30A1}" },                               -- AN-M30A1 100 lb GP HE (57 lb TNT)
        { CLSID = "{AN_M57}" },                                 -- AN-M57A1 250 lb GP HE (129 lb TNT)
        { CLSID = "{AN-M64}" },                                 -- AN-M64 500 lb GP HE (274 lb Comp B)
        { CLSID = "{AN-M81}" },                                 -- AN-M81 260 lb Fragmentation (34.1 lb Comp B)
        { CLSID = "{AN-M88}" },                                 -- AN-M88 216 lb Fragmentation (47 lb Comp B)
        -- SMOKE PODS --
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E741}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Red
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E742}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Green
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E743}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Blue
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E744}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod White
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E745}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Yellow
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E746}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Orange
        -- ILLUMINATION POD --
        { CLSID = "{CAE48299-A294-4bad-8EE6-89EFC5DCDF00}", connector = rocketConnector, arg_value = 0.2},  -- SUU-25
        -- CLEAN --
        { CLSID = "<CLEAN>", arg_value = 1 }, -- Remove pylon
    }
    return tbl
end

local function get_inboard_weapons( side )
    local rocketConnector = ""
    local shrikeConnector = ""
    if side == "L" then
        rocketConnector = "Pylon2RKT"
        shrikeConnector = "Pylon2b"
    elseif side == "R" then
        rocketConnector = "Pylon4RKT"
        shrikeConnector = "Pylon4b"
    end

    local tbl = {
        -- FUEL TANKS --
        { CLSID = "{DFT-300gal_LR}" },
        { CLSID = "{DFT-300gal_LR_EMPTY}" },
        -- { CLSID = "{DFT-300gal_LR}",attach_point_position = { -0.10, -0.008, 0.0}},  --another (proper?) posibility to fix 300 gal tank position/angle ?
        { CLSID = "{DFT-150gal}" },
        { CLSID = "{DFT-150gal_EMPTY}" },
        -- AIR AIR --
        { CLSID = "{GAR-8}",                                            connector = rocketConnector, arg_value = 0.2 },  -- AIM-9B, aligned to -3deg armament datum
        { CLSID = "{AIM-9P-ON-ADAPTER}",                                connector = rocketConnector, arg_value = 0.2 },  -- AIM-9P
        { CLSID = "{AIM-9P5-ON-ADAPTER}",                               connector = rocketConnector, arg_value = 0.2 },  -- AIM-9P5
        { CLSID = "{AIM-9P3-ON-ADAPTER}",                               connector = rocketConnector, arg_value = 0.2 },  -- AIM-9P3
        { CLSID = "{A4E-ASQ-T50-ON-ADAPTER}",                           connector = rocketConnector, arg_value = 0.2 },  -- ASQ-T50
        { CLSID = "{AIM-9J-ON-ADAPTER}",                                connector = rocketConnector, arg_value = 0.2 },  -- AIM-9J        
        -- ROCKETS --
        { CLSID = "{LAU3_FFAR_WP156}",                                  connector = rocketConnector, arg_value = 0.2 }, -- FFAR M156 WP
        { CLSID = "{LAU3_FFAR_MK1HE}",                                  connector = rocketConnector, arg_value = 0.2 }, -- FFAR Mk1 HE
        { CLSID = "{LAU3_FFAR_MK5HEAT}",                                connector = rocketConnector, arg_value = 0.2 }, -- FFAR Mk5 HEAT
        { CLSID = "{LAU-3 FFAR WP156_TER_2_"..side.."}",                connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-3 FFAR M156 WP
        { CLSID = "{LAU-3 FFAR Mk1 HE_TER_2_"..side.."}",               connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-3 FFAR Mk1 HE
        { CLSID = "{LAU-3 FFAR Mk5 HEAT_TER_2_"..side.."}",             connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-3 FFAR Mk5 HEAT
        { CLSID = "{LAU68_FFAR_WP156}",                                 connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR M156 WP
        { CLSID = "{LAU68_FFAR_MK1HE}",                                 connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR Mk1 HE
        { CLSID = "{LAU68_FFAR_MK5HEAT}",                               connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR Mk5 HEAT
        { CLSID = "{LAU-68 FFAR WP156_TER_2_"..side.."}",               connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 FFAR M156 WP
        { CLSID = "{LAU-68 FFAR Mk1 HE_TER_2_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 FFAR Mk1 HE
        { CLSID = "{LAU-68 FFAR Mk5 HEAT_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 FFAR Mk5 HEAT
        --{ CLSID = "{3DFB7321-AB0E-11d7-9897-000476191836}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-61 Hydra M156 WP
        --{ CLSID = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-61 Hydra M151 HE
        --{ CLSID = "{LAU-61 Hydra WP156_TER_2_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-61 Hydra M156 WP
        --{ CLSID = "{LAU-61 Hydra M151 HE_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-61 Hydra M151 HE
        { CLSID = "{A021F29D-18AB-4d3e-985C-FC9C60E35E9E}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra M151 HE
        { CLSID = "{4F977A2A-CD25-44df-90EF-164BFA2AE72F}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra M156 WP
        { CLSID = "{174C6E6D-0C3D-42ff-BCB3-0853CB371F5C}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk5 HEAT
        { CLSID = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra PI
        { CLSID = "{0877B74B-5A00-4e61-BA8A-A56450BA9E27}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Practice Smoke
        { CLSID = "{FC85D2ED-501A-48ce-9863-49D468DDD5FC}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk1 Practice
        { CLSID = "{65396399-9F5C-4ec3-A7D2-5A8F4C1D90C4}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk61 Practice
        { CLSID = "{1F7136CB-8120-4e77-B97B-945FF01FB67C}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra WTU-1/B Practice
        { CLSID = "{LAU-68 Hydra M151 HE_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra M151 HE
        { CLSID = "{LAU-68 Hydra WP156_TER_2_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra M156 WP
        { CLSID = "{LAU-68 Hydra M257 PI_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Para Illum
        { CLSID = "{LAU-68 Hydra M274 PS_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Practice Smoke
        { CLSID = "{LAU-68 Hydra Mk1 Practice_TER_2_"..side.."}",       connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Mk1 Practice
        { CLSID = "{LAU-68 Hydra Mk5 HEAT_TER_2_"..side.."}",           connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Mk5 HEAT
        { CLSID = "{LAU-68 Hydra Mk61 Practice_TER_2_"..side.."}",      connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Mk61 Practice
        { CLSID = "{LAU-68 Hydra WTU1B Practice_TER_2_"..side.."}",     connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra WTU-1/B Practice
        { CLSID = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-10 Zuni
        { CLSID = "{LAU-10 ZUNI_TER_2_"..side.."}",                     connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-10 Zuni
        
        { CLSID = "LAU3_WP61",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_WP1B",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_HE5",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_WP156",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_HE151",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "{LAU3_HE151_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP156_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_HE5_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP1B_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP61_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
       

        -- MISSILES --
        { CLSID = "{LAU_34_AGM_45A}" }, -- AGM-45A SHRIKE
        { CLSID = "{C_A4E_AGM-45B_LAU34}"}, -- AGM-45B SHRIKE
        -- BOMBS --
        { CLSID = "{ADD3FAE1-EBF6-4EF9-8EFC-B36B5DDF1E6B}" }, -- Mk-20 Rockeye cluster bomb
        { CLSID = "{90321C8E-7ED1-47D4-A160-E074D5ABD902}" }, -- MK-81
        { CLSID = "{MK-81SE}" },                              -- Mk-81 Snakeye
        { CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" }, -- MK-82
        { CLSID = "{Mk82SNAKEYE}" },                          -- MK-82 Snakeye
        { CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" }, -- MK-83
        { CLSID = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}" }, -- MK-84
        { CLSID = "{00F5DAC4-0466-4122-998F-B1A298E34113}" }, -- M-117
        { CLSID = "{mk77mod0}" },                             -- Mk-77mod0 750 lb petroleum oil bomb
        { CLSID = "{mk77mod1}" },                             -- Mk-77mod1 500 lb petroleum oil bomb
        { CLSID = "{AN_M30A1}" },                             -- AN-M30A1 100 lb GP HE (57 lb TNT)
        { CLSID = "{AN_M57}" },                               -- AN-M57A1 250 lb GP HE (129 lb TNT)
        { CLSID = "{AN-M64}" },                               -- AN-M64 500 lb GP HE (274 lb Comp B)
        { CLSID = "{AN_M65}" },                               -- AN-M65A1 1000 lb GP HE (595 lb Comp B)
        { CLSID = "{AN-M81}" },                               -- AN-M81 260 lb Fragmentation (34.1 lb Comp B)
        { CLSID = "{AN-M88}" },                               -- AN-M88 216 lb Fragmentation (47 lb Comp B)
        -- CLUSTER MUNITIONS --
        { CLSID = "{C_A4E_CBU-1A}" },                              -- CBU-1/A Cluster Dispenser (509x BLU-4/B anti-personnel cluster bomblets)
        { CLSID = "{C_A4E_CBU-2A}" },                              -- CBU-2/A Cluster Dispenser (360x BLU-3/B cluster bomblets)
        { CLSID = "{C_A4E_CBU-2BA}" },                             -- CBU-2B/A Cluster Dispenser (409x BLU-3/B cluster bomblets)
        { CLSID = "{C_A4E_CBU-1A_2x_TER_"..side.."}" },             -- CBU-1/A Cluster Dispenser x2 (509x BLU-4/B anti-personnel cluster bomblets)
        { CLSID = "{C_A4E_CBU-2A_2x_TER_"..side.."}" },             -- CBU-2/A Cluster Dispenser x2 (360x BLU-3/B cluster bomblets)
        { CLSID = "{C_A4E_CBU-2BA_2x_TER_"..side.."}" },            -- CBU-2B/A Cluster Dispenser x2 (409x BLU-3/B cluster bomblets)
        -- BOMB RACKS --
        { CLSID = "{Mk-20_TER_2_"..side.."}" },               -- Mk-20 Rockeye cluster bomb x2
        { CLSID = "{Mk-81_MER_5_"..side.."}" },               -- MER Mk-81 x5
        { CLSID = "{Mk-81SE_MER_5_"..side.."}" },             -- MER Mk-81 Snakeye x5
        { CLSID = "{Mk-82_TER_2_"..side.."}" },               -- TER Mk-82 x2
        { CLSID = "{Mk-82 Snakeye_TER_2_"..side.."}" },       -- TER Mk-82 Snakeye x2
        { CLSID = "{AN-M57_MER_5_"..side.."}" },              -- AN-M57A1 x5 250 lb GP HE (129 lb TNT)
        { CLSID = "{AN-M57_TER_2_"..side.."}" },              -- AN-M57A1 x2 250 lb GP HE (129 lb TNT)
        { CLSID = "{AN-M81_MER_5_"..side.."}" },              -- AN-M81 x5 260 lb Fragmentation (34.1 lb Comp B)
        { CLSID = "{AN-M88_MER_5_"..side.."}" },              -- AN-M88 x5 216 lb Fragmentation (47 lb Comp B)
        { CLSID = "{BDU-33_MER_5_"..side.."}" },              -- BDU-33 x5
        -- GUN PODS --
        { CLSID = "{Mk4 HIPEG}", connector = rocketConnector, arg_value = 0.2 },  -- Mk 4 Mod 0 HIPEG gun pod
        -- SMOKE PODS --
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E741}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Red
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E742}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Green
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E743}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Blue
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E744}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod White
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E745}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Yellow
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E746}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Orange
        -- ILLUMINATION POD --
        { CLSID = "{CAE48299-A294-4bad-8EE6-89EFC5DCDF00}", connector = rocketConnector, arg_value = 0.2},
        -- CLEAN --
        { CLSID = "<CLEAN>", arg_value = 1 },
    }
    return tbl
end

local function get_centerline_weapons( side )
    local rocketConnector = "Pylon3RKT"

    local tbl = {
        -- FUEL TANKS --
        { CLSID = "{DFT-400gal}" },
        { CLSID = "{DFT-300gal}" },
        { CLSID = "{DFT-150gal}" },
        { CLSID = "{DFT-400gal_EMPTY}" },
        { CLSID = "{DFT-300gal_EMPTY}" },
        { CLSID = "{DFT-150gal_EMPTY}" },
        -- { CLSID = "{D-704_BUDDY_POD}" },
        -- ROCKETS --
        { CLSID = "{LAU3_FFAR_WP156}",                                  connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 FFAR M156 WP
        { CLSID = "{LAU3_FFAR_MK1HE}",                                  connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 FFAR Mk1 HE
        { CLSID = "{LAU3_FFAR_MK5HEAT}",                                connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 FFAR Mk5 HEAT
        { CLSID = "{LAU-3 FFAR WP156_TER_2_"..side.."}",                connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-3 FFAR M156 WP
        { CLSID = "{LAU-3 FFAR Mk1 HE_TER_2_"..side.."}",               connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-3 FFAR Mk1 HE
        { CLSID = "{LAU-3 FFAR Mk5 HEAT_TER_2_"..side.."}",             connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-3 FFAR Mk5 HEAT
        { CLSID = "{LAU-3 FFAR WP156_TER_3_"..side.."}",                connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-3 FFAR M156 WP
        { CLSID = "{LAU-3 FFAR Mk1 HE_TER_3_"..side.."}",               connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-3 FFAR Mk1 HE
        { CLSID = "{LAU-3 FFAR Mk5 HEAT_TER_3_"..side.."}",             connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-3 FFAR Mk5 HEAT
        { CLSID = "{LAU68_FFAR_WP156}",                                 connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR M156 WP
        { CLSID = "{LAU68_FFAR_MK1HE}",                                 connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR Mk1 HE
        { CLSID = "{LAU68_FFAR_MK5HEAT}",                               connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 FFAR Mk5 HEAT
        { CLSID = "{LAU-68 FFAR WP156_TER_2_"..side.."}",               connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 FFAR M156 WP
        { CLSID = "{LAU-68 FFAR Mk1 HE_TER_2_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 FFAR Mk1 HE
        { CLSID = "{LAU-68 FFAR Mk5 HEAT_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 FFAR Mk5 HEAT
        { CLSID = "{LAU-68 FFAR WP156_TER_3_"..side.."}",               connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 FFAR M156 WP
        { CLSID = "{LAU-68 FFAR Mk1 HE_TER_3_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 FFAR Mk1 HE
        { CLSID = "{LAU-68 FFAR Mk5 HEAT_TER_3_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 FFAR Mk5 HEAT
        -- LAU-3 Hydras aren't loading in for some reason, research needed as to why
        { CLSID = "LAU3_WP156",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M156 WP
        { CLSID = "LAU3_HE5",                                         connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra Mk5 HEAT
        { CLSID = "LAU3_WP61",                                        connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra Mk61 Practice
        { CLSID = "LAU3_WP1B",                                        connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra WTU-1/B Practice
        { CLSID = "{3DFB7321-AB0E-11d7-9897-000476191836}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-61 Hydra M156 WP
        { CLSID = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-61 Hydra M151 HE
        --{ CLSID = "{LAU-61 Hydra WP156_TER_2_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-61 Hydra M156 WP
        --{ CLSID = "{LAU-61 Hydra M151 HE_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-61 Hydra M151 HE
        --{ CLSID = "{LAU-61 Hydra WP156_TER_3_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-61 Hydra M156 WP
        --{ CLSID = "{LAU-61 Hydra M151 HE_TER_3_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-61 Hydra M151 HE
        -- { CLSID = "{A76344EB-32D2-4532-8FA2-0C1BDC00747E}",             connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-61 Hydra M151 HE (DCS native)
        { CLSID = "{A021F29D-18AB-4d3e-985C-FC9C60E35E9E}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra M151 HE
        { CLSID = "{4F977A2A-CD25-44df-90EF-164BFA2AE72F}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra M156 WP
        { CLSID = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Para Illum
        { CLSID = "{0877B74B-5A00-4e61-BA8A-A56450BA9E27}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Practice Smk
        { CLSID = "{FC85D2ED-501A-48ce-9863-49D468DDD5FC}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk1 Practice
        { CLSID = "{174C6E6D-0C3D-42ff-BCB3-0853CB371F5C}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk5 HEAT
        { CLSID = "{65396399-9F5C-4ec3-A7D2-5A8F4C1D90C4}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra Mk61 Practice
        { CLSID = "{1F7136CB-8120-4e77-B97B-945FF01FB67C}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-68 Hydra WTU-1/B Practice
        { CLSID = "{LAU-68 Hydra M151 HE_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra M151 HE
        { CLSID = "{LAU-68 Hydra WP156_TER_2_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra M156 WP
        { CLSID = "{LAU-68 Hydra M257 PI_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Para Illum
        { CLSID = "{LAU-68 Hydra M274 PS_TER_2_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Practice Smoke
        { CLSID = "{LAU-68 Hydra Mk1 Practice_TER_2_"..side.."}",       connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Mk1 Practice
        { CLSID = "{LAU-68 Hydra Mk5 HEAT_TER_2_"..side.."}",           connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Mk5 HEAT
        { CLSID = "{LAU-68 Hydra Mk61 Practice_TER_2_"..side.."}",      connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra Mk61 Practice
        { CLSID = "{LAU-68 Hydra WTU1B Practice_TER_2_"..side.."}",     connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-68 Hydra WTU-1/B Practice
        { CLSID = "{LAU-68 Hydra M151 HE_TER_3_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra M151 HE
        { CLSID = "{LAU-68 Hydra WP156_TER_3_"..side.."}",              connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra M156 WP
        { CLSID = "{LAU-68 Hydra M257 PI_TER_3_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra Para Illum
        { CLSID = "{LAU-68 Hydra M274 PS_TER_3_"..side.."}",            connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra Practice Smoke
        { CLSID = "{LAU-68 Hydra Mk1 Practice_TER_3_"..side.."}",       connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra Mk1 Practice
        { CLSID = "{LAU-68 Hydra Mk5 HEAT_TER_3_"..side.."}",           connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra Mk5 HEAT
        { CLSID = "{LAU-68 Hydra Mk61 Practice_TER_3_"..side.."}",      connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra Mk61 Practice
        { CLSID = "{LAU-68 Hydra WTU1B Practice_TER_3_"..side.."}",     connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-68 Hydra WTU-1/B Practice
        { CLSID = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",             connector = rocketConnector, arg_value = 0.2 }, -- LAU-10 Zuni
        { CLSID = "{LAU-10 ZUNI_TER_2_"..side.."}",                     connector = rocketConnector, arg_value = 0.2 }, -- Dual LAU-10 Zuni
        { CLSID = "{LAU-10 ZUNI_TER_3_"..side.."}",                     connector = rocketConnector, arg_value = 0.2 }, -- Triple LAU-10 Zuni
        
        { CLSID = "LAU3_WP61",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_WP1B",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_HE5",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_WP156",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "LAU3_HE151",     connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra
        { CLSID = "{LAU3_HE151_TER_3_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP156_TER_3_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_HE5_TER_3_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP1B_TER_3_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP61_TER_3_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_HE151_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP156_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_HE5_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP1B_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE
        { CLSID = "{LAU3_WP61_TER_2_"..side.."}",                                       connector = rocketConnector, arg_value = 0.2 }, -- LAU-3 Hydra M151 HE


        
        -- BOMBS --
        { CLSID = "{ADD3FAE1-EBF6-4EF9-8EFC-B36B5DDF1E6B}" },   -- Mk-20 Rockeye cluster bomb
        { CLSID = "{90321C8E-7ED1-47D4-A160-E074D5ABD902}" },   -- MK-81
        { CLSID = "{MK-81SE}" },                                -- Mk-81 Snakeye
        { CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" },   -- MK-82
        { CLSID = "{Mk82SNAKEYE}" },                            -- MK-82 Snakeye
        { CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" },   -- MK-83
        { CLSID = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}" },   -- MK-84
        { CLSID = "{00F5DAC4-0466-4122-998F-B1A298E34113}" },   -- M117
        { CLSID = "{mk77mod0}" },                               -- Mk-77mod0 750 lb petroleum oil bomb
        { CLSID = "{mk77mod1}" },                               -- Mk-77mod1 500 lb petroleum oil bomb
        { CLSID = "{AN_M30A1}" },                               -- AN-M30A1 100 lb GP HE (57 lbs TNT)
        { CLSID = "{AN_M57}" },                                 -- AN-M57A1 250 lb GP HE (129 lbs TNT)
        { CLSID = "{AN-M64}" },                                 -- AN-M64 500 lb GP HE (274 lbs Comp B)
        { CLSID = "{AN_M65}" },                                 -- AN-M65A1 1000 lb GP HE (595 lb Comp B)
        { CLSID = "{AN-M66A2}" },                               -- AN-M66A2 2000 lb GP HE (1142 lb Comp B)
        { CLSID = "{AN-M81}" },                                 -- AN-M81 260 lb Fragmentation (34.1 lb Comp B)
        { CLSID = "{AN-M88}" },                                 -- AN-M88 216 lb Fragmentation (47 lb Comp B)
        -- BOMB RACKS --
        { CLSID = "{Mk-20_TER_3_"..side.."}" },                 -- Mk-20 Rockeye cluster bomb x3
        { CLSID = "{Mk-20_TER_2_"..side.."}" },                 -- Mk-20 Rockeye cluster bomb x2
        { CLSID = "{Mk-81_MER_6_"..side.."}" },
        { CLSID = "{Mk-81SE_MER_6_"..side.."}" },               -- MER Mk-81 Snakeye x6
        { CLSID = "{Mk-82_MER_6_"..side.."}" },
        { CLSID = "{Mk-82_MER_4_"..side.."}" },
        { CLSID = "{Mk-82_TER_3_"..side.."}" },
        { CLSID = "{Mk-82 Snakeye_MER_6_"..side.."}" },
        { CLSID = "{Mk-82 Snakeye_MER_4_"..side.."}" },
        { CLSID = "{Mk-82 Snakeye_TER_3_"..side.."}" },
        { CLSID = "{Mk-83_TER_3_"..side.."}" },
        { CLSID = "{Mk-83_TER_2_"..side.."}" },
        { CLSID = "{Mk-77 mod 1_TER_2_"..side.."}" },           -- Mk-77 mod 1 (500 lb) x2 petroleum oil bomb
        { CLSID = "{AN-M57_MER_6_"..side.."}" },                -- AN-M57A1 x6 250 lb GP HE (129 lb TNT)
        { CLSID = "{AN-M57_TER_3_"..side.."}" },                -- AN-M57A1 x3 250 lb GP HE (129 lb TNT)
        { CLSID = "{AN-M81_MER_6_"..side.."}" },                -- AN-M81 x6 260 lb Fragmentation (34.1 lb Comp B)
        { CLSID = "{AN-M88_MER_6_"..side.."}" },                -- AN-M88 x6 216 lb Fragmentation (47 lb Comp B)
        { CLSID = "{BDU-33_MER_6_"..side.."}" },              -- BDU-33 x5
        -- GUN PODS --
        { CLSID = "{Mk4 HIPEG}", connector = rocketConnector, arg_value = 0.2 },  -- Mk 4 Mod 0 HIPEG gun pod
        -- SMOKE PODS --
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E741}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Red
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E742}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Green
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E743}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Blue
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E744}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod White
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E745}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Yellow
        { CLSID = "{A4BCC903-06C8-47bb-9937-A30FEDB4E746}", connector = rocketConnector, arg_value = 0.2 }, -- Smoke Pod Orange
        -- ILLUMINATION POD --
        { CLSID = "{CAE48299-A294-4bad-8EE6-89EFC5DCDF00}", connector = rocketConnector, arg_value = 0.2},
        -- CLEAN --
        { CLSID = "<CLEAN>", arg_value = 1 },
    }
    return tbl
end

A_4E_C =  {
    Name                 =   'A-4E-C',
    DisplayName            = _('A-4E-C'),
    ViewSettings        = ViewSettings,
    -- enable A-4 for all countries.  It is CHEAP and easy to maintain
    Countries = {
        "Abkhazia",
        "Algeria",
        "Argentina",
        "Australia",
        "Austria",
        "Belarus",
        "Belgium",
        "Brazil",
        "Bulgaria",
        "Canada",
        "China",
        "Chile",
        "Croatia",
        "Cuba",
        "Czech Republic",
        "Cyprus",
        "Denmark",
        "Egypt",
        "Finland",
        "France",
        "Georgia",
        "Germany",
        "Ghana",
        "Greece",
        "Honduras",
        "Hungary",
        "India",
        "Indonesia",
        "Insurgents",
        "Iran",
        "Iraq",
        "Israel",
        "Italy",
        "Japan",
        "Jordan",
        "Kazakhstan",
        "Lebanon",
        "Libya",
        "Malaysia",
        "Mexico",
        "Morocco",
        "The Netherlands",
        "Nigeria",
        "North Korea",
        "Norway",
        "Oman",
        "Pakistan",
        "Peru",
        "Phllipines",
        "Poland",
        "Qatar",
        "Romania",
        "Russia",
        "Saudi Arabia",
        "Serbia",
        "Slovakia",
        "Slovenia",
        "South Africa",
        "South Korea",
        "South Ossetia",
        "Spain",
        "Sudan",
        "Sweden",
        "Switzerland",
        "Syria",
        "Thailand",
        "Tunisia",
        "Turkey",
        "UK",
        "Ukraine",
        "United Arab Emirates",
        "United Nations Peacekeepers",
        "USA",
        "USAF Aggressors",
        "Venezuela",
        "Vietnam",
        "Yemen"
    },

    HumanCockpit         = false,
    HumanCockpitPath    = current_mod_path..'/Cockpit/',
    Picture             = "A-4E-C.png",
    Rate                 = 40, -- RewardPoint in Multiplayer
    Shape                 = "A-4E",
    shape_table_data     =
    {
        {
            file       = 'A-4E';
            life       = 16; -- lifebar
            vis        = 3;  -- visibility gain.
            desrt    = 'Fighter-2-crush'; -- Name of destroyed object file name Alphajet-destr. This is a placeholder.
            fire       = {300, 3}; -- Fire on the ground after destoyed: 300sec 2m
            username = 'A-4E-C';
            index    =  WSTYPE_PLACEHOLDER;
            classname   = "lLandPlane";
            positioning = "BYNORMAL";
        },
        -- no need for this as we are using a built in destroyed model
        -- {
        --     name  = "Alphajet-destr";
        --     file  = "Alphajet-destr";
        --     fire  = {240, 2};  -- 240  2
        -- },
    },
    -------------------------
    -- add model draw args for network transmitting to this draw_args table (32 limit)
    net_animation ={
        0, -- front gear
        3, -- right gear
        5, -- left gear
        9, -- right flap
        10, -- left flap
        11, -- right aileron
        12, -- left aileron
        15, -- right elevator
        16, -- left elevator
        17, -- rudder

        2,  -- nose wheel steering
        21, -- SFM air brake
        13, -- right slat
        14, -- left slat
        25, -- tail hook
        38, -- canopy
        120, -- right spoiler
        123, -- left spoiler
        190, -- left (red) navigation wing-tip light
        191, -- right (green) navigation wing-tip light
        192, -- tail (white) light

        198, -- anticollision (flashing red) top light
        199, -- anticollision (flashing red) bottom light
        208, -- taxi light (white) right main gear door
        402, -- huffer
        500, -- model air brake
        501, -- RAT
        499, -- wheel chocks
         117, -- stabilizer
    },
    -------------------------
    mapclasskey = "P0091000025",
    attribute   = {wsType_Air, wsType_Airplane, wsType_Fighter, WSTYPE_PLACEHOLDER, "Multirole fighters", "Refuelable" },
    Categories  = {"{78EFB7A2-FD52-4b57-A6A6-3BF0E1D6555F}", "Interceptor",},
    -------------------------
    -- Operating Weight includes:  centerline rack, crew, engine oil, trapped fuel and oil, liquid oxygen, avionics pod, ECM, and misc equipment
    -- A-4E:  10,802 lbs operating weight
    --         + 314 lbs for 2x 20mm cannon (no ammo)
    --         + 140 lbs for 2x AERO 20A rack pylons on stations 2/4
    --         + 128 lbs for 2x AERO 20A rack pylons on stations 1/5
    --         +*398 lbs for 2x empty AERO-1D empty 300G fuel tanks
    --         +  97 lbs for armor plating
    --         +  32 lbs for wing spoilers
    --         +  76 lbs for J52-P-8A engine (versus J52-P-6A)
    --        ------
    -- TOTAL: 11,589 lbs with no ammo, no gas, and empty pylons

    M_empty                     =  11589*POUNDS_TO_KG,    -- see above calculation
    M_nominal                   =  17180*POUNDS_TO_KG,    -- combat weight per NATOPS
    M_max                       =  24500*POUNDS_TO_KG,    -- (Maximum Take Off Weight)
    M_fuel_max                  =  5440*POUNDS_TO_KG,     -- (Internal Fuel Only)             : 800G * ~6.8 lbs/gal for JP-5
    H_max                       =  43900*FEET_TO_M,       -- m  (Maximum Operational Ceiling) : Combat ceiling @ 14,500 lbs w/ 500 fpm climb max
    -------------------------
    length                      =  12.22,                 -- full lenght in m
    height                      =  4.57,                  -- height in m
    wing_area                   =  24.16,                 -- wing area in m2**
    wing_span                   =  8.38 ,                 -- wing span in m
    wing_tip_pos                =  {-2.5, -0.38,    4.2}, -- wingtip coords for visual effects
    wing_type                   =  0,                     -- FIXED_WING = 0 / VARIABLE_GEOMETRY = 1 / FOLDED_WING = 2 / ARIABLE_GEOMETRY_FOLDED = 3
    flaps_maneuver              =  0.5,                   -- Max flaps in take-off and maneuver (0.5 = 1st stage; 1.0 = 2nd stage) (for AI)
    has_speedbrake              =  true,

    RCS                         =  3.4,                   -- Radar Cross Section m2.  Proportionally scaled RCS of F-16's 4.0.
    IR_emission_coeff           =  0.5,                   -- Normal engine -- IR_emission_coeff = 1 is Su-27 without afterburner. It is reference.
    IR_emission_coeff_ab        =  0.5,                   -- With afterburner

    stores_number               =  5,                     -- Amount of pylons.

    CAS_min                     =  25.7,                  -- minimal indicated airspeed  m/s?  (50 knots per NATOPS)
    V_opt                       =  200,                   -- Cruise speed (for AI)
    V_take_off                  =  82.3,                  -- Take off speed in m/s (for AI - 150kts)
    V_land                      =  64.3,                  -- Land speed in m/s (for AI) (110 kn)
    V_max_sea_level             =  300.83,                -- Max speed at sea level in m/s (for AI)
    V_max_h                     =  300.8,                 -- Max speed at max altitude in m/s (for AI)
    Vy_max                      =  102.9,                 -- Max climb speed in m/s (for AI - 200 kts)
    Mach_max                    =  0.88,                  -- Max speed in Mach (for AI)
    Ny_min                      =  -3.0,                  -- Min G (for AI)
    Ny_max                      =  8.0,                   -- Max G (for AI)
    Ny_max_e                    =  8.0,                   -- Max G (for AI)
    -- AOA_take_off             =  0.27,                  -- AoA in take off radians (for AI) 16 degrees
    bank_angle_max              =  60,                    -- Max bank angle (for AI)
    range                       =  3200,                  -- Max range in km (for AI)

    thrust_sum_max              =  9300*POUNDS_TO_KG,     -- thrust in kg (J52 P8A: 9300 lb)**
    has_afteburner              =  false,
    has_differential_stabilizer =  false,
    thrust_sum_ab               =  9300*POUNDS_TO_KG,     -- thrust in kg (kN)**
    average_fuel_consumption    =  0.86,                  -- 0.86 TSFC
    is_tanker                   =  false,
    tanker_type                 =  2,                     -- Tanker type if the plane is tanker
    air_refuel_receptacle_pos   =  {6.966, -0.366, 0.486},

    launch_bar_connected_arg_value = 0.87,

    -----------------------------------------------------------------------
    ----------------- SUSPENSION CODE BEGINS
    -----------------------------------------------------------------------
    tand_gear_max = math.rad(180.0), --turns out we actually need this for the animation to line up
    --[[
    nose_gear_pos                            = {2.72, -2.78, 0}, -- {2.72, -2.37, 0},    --      2.72,       -2.28,    0
    main_gear_pos                            = {-0.79, -2.86, 1.18}, -- {-0.79, -2.42, 1.18},    --  0.79,   -2.35,    1.18
    tand_gear_max                            = 0.554,   -- // tangent on maximum yaw angle of front wheel

    nose_gear_amortizer_direct_stroke        = 0.05,    -- 1.878 - 1.878, -- down from nose_gear_pos !!!
    nose_gear_amortizer_reversal_stroke      = -0.32,   -- 1.348 - 1.878, -- up
    main_gear_amortizer_direct_stroke        = 0.0,     -- 1.592 - 1.592, -- down from main_gear_pos !!!
    main_gear_amortizer_reversal_stroke      = -0.43,   -- 1.192 - 1.592, -- up

    nose_gear_amortizer_normal_weight_stroke = -0.20,   -- 0.144
    main_gear_amortizer_normal_weight_stroke = -0.51,   --

    nose_gear_wheel_diameter                 = 0.441,   -- 0.441, --*
    main_gear_wheel_diameter                 = 0.609,   -- 0.609, --*
    brakeshute_name                          = 0,       -- Landing - brake chute visual shape after separation
    ]]--
    -----------------------------------------------------------------------
    ----------------- SUSPENSION CODE ENDS
    -----------------------------------------------------------------------

    engines_count    = 1,
    engines_nozzles =
    {
        [1] =
        {
            pos =     {-5.62,    0.163,    0}, -- nozzle coords
            elevation    =    0.0, -- AFB cone elevation

            -- Diameter is 0 to hide AB for AI. AB is used for catapult simulation.
            -- If AB is no longer used for catapult then diameter can be set for exhaust smoke.
            -- diameter    =    0.0, -- AFB cone diameter.
            diameter    =    0.675, -- AFB cone diameter
            exhaust_length_ab    =    0.01, -- lenght in m
            exhaust_length_ab_K    =    0.707, -- AB animation
            smokiness_level     =     0.2,
            afterburner_circles_count = 0,
        }, -- end of [1]
    }, -- end of engines_nozzles

    sounderName         = "Aircraft/Planes/A-4E-C",

    crew_size    = 1,
    crew_members =
    {
        [1] =
        {
            ejection_seat_name    =    17,
            drop_canopy_name    =    "A-4E_canopy", --23,
            pos =         {3.077,    -0.03,    0}, --changes the position of the cockpit view {3.077,    0.574,    0}
            canopy_pos = {3.077,    0.674,    0},
            -- canopy_pos = {2.677,2.677,0},
            --ejection_play_arg = 149,
            --can_be_playable     = true,
            --ejection_through_canopy = true,
            --ejection_added_speed = {-5,15,0},
            --ejection_order          = 2,
            --role                  = "pilot",
            --role_display_name    = _("Pilot"),
            g_suit                =  5.0 -- I'm assuming there are different levels of suits which black you out at different G's. We should try and experiment with different ones.
        }, -- end of [1]
    }, -- end of crew_members

    mechanimations = {
        Door0 = {
            {Transition = {"Close", "Open"},  Sequence = {{C = {{"Arg", 38, "to", 0.9, "in", 9.5},},},}, Flags = {"Reversible"},},
            {Transition = {"Open", "Close"},  Sequence = {{C = {{"Arg", 38, "to", 0.0, "in", 5.0},},},}, Flags = {"Reversible", "StepsBackwards"},},
            {Transition = {"Any", "Bailout"}, Sequence = {{C = {{"JettisonCanopy", 0},},},},},
        },
        -- dummy animation for carrier ops. array sizes need to match or the animator will throw an error.
        -- animations need to be defined with a dummy arg even if they are not applicable.
        -- both launchbar and foldable wings are required.
        LaunchBar = { 
            {Transition = {"Retract", "Extend"}, Sequence = {{C = {{"ChangeDriveTo", "HydraulicGravityAssisted"}, {"VelType", 3}, {"Arg", 85, "to", 0.881, "in", 4.4}}}}},
            {Transition = {"Retract", "Stage"},  Sequence = {{C = {{"ChangeDriveTo", "HydraulicGravityAssisted"}, {"VelType", 3}, {"Arg", 85, "to", 0.815, "in", 4.4}}}}},
            {Transition = {"Any", "Retract"},  Sequence = {{C = {{"ChangeDriveTo", "Hydraulic"}, {"VelType", 2}, {"Arg", 85, "to", 0.000, "in", 4.5}}}}},
            {Transition = {"Extend", "Stage"},   Sequence = {
                    {C = {{"ChangeDriveTo", "Mechanical"}, {"Sleep", "for", 0.000}}},
                    {C = {{"Arg", 85, "from", 0.881, "to", 0.766, "in", 0.600}}},
                    {C = {{"Arg", 85, "from", 0.766, "to", 0.753, "in", 0.200}}},
                    {C = {{"Sleep", "for", 0.15}}},
                    {C = {{"Arg", 85, "from", 0.753, "to", 0.784, "in", 0.1, "sign", 2}}},
                    {C = {{"Arg", 85, "from", 0.784, "to", 0.881, "in", 1.0}}},
                },
            },
            {Transition = {"Stage", "Pull"},  Sequence = {
                    {C = {{"ChangeDriveTo", "Mechanical"}, {"VelType", 2}, {"Arg", 85,"from", 0.881, "to", launch_bar_connected_arg_value_, "in", 0.27}}},
                    }
            },
            {Transition = {"Stage", "Extend"},   Sequence = {{C = {{"ChangeDriveTo", "HydraulicGravityAssisted"}, {"VelType", 3}, {"Arg", 85, "from", 0.815, "to", 0.881, "in", 0.2}}}}},
        },
        FoldableWings = {
            {Transition = {"Retract", "Extend"}, Sequence = {{C = {{"Arg", 85, "to", 0.0, "in", 5.0}}}}, Flags = {"Reversible"}},
            {Transition = {"Extend", "Retract"}, Sequence = {{C = {{"Arg", 85, "to", 1.0, "in", 5.0}}}}, Flags = {"Reversible", "StepsBackwards"}},
        },
    },
---------------------------------------------------------------------------------------------------------------------------------------------
    fires_pos =
    {
        [1] =     {-0.232,    1.262,    0},     -- Fuselage
        [2] =     {-0.2,    -0.5,    0.84},     -- wing (inner?) right, WING_R_IN
        [3] =     {-0.75,    -0.5,    -0.8},    -- wing (inner?) left, WING_L_IN
        [4] =     {-0.32,    0.265,    1.774},  -- Wing center Right? {-0.82,    0.265,    2.774},
        [5] =     {-0.32,    0.265,    -1.774}, -- Wing center Left?  {-0.82,    0.265,    -2.774},
        [6] =     {-1.0,    -0.5,    4.0},      -- Wing outer Right? {-0.82,    0.255,    4.274}, probably WING_R_OUT
        [7] =     {-1.0,    -0.5,    -4.0},     -- Wing outer Left?  {-0.82,    0.255,    -4.274}, probably WING_L_OUT
        [8] =     {-5.6,    0.185,    0},       -- High Altitude Contrails
        [9] =     {-5.5,    0.2,    0},         -- left engine
        [10] =     {-7.728,    0.039,    0.5},  -- Right Engine? {0.304,    -0.748,    0.442},
        [11] =     {-7.728,    0.039,    -0.5}, -- ?
    }, -- end of fires_pos
---------------------------------------------------------------------------------------------------------------------------------------------
    -- countermeasures
    -- SingleChargeTotal         = 0,
    -- CMDS_Incrementation     = 1,
    -- ChaffDefault             = 0,
    -- ChaffChargeSize         = 1,
    -- FlareDefault             = 0,
    -- FlareChargeSize         = 1,
    -- CMDS_Edit                 = false,
    -- chaff_flare_dispenser     = {
    -- }, -- end of chaff_flare_dispenser
    -- countermeasures
    -- SingleChargeTotal       = 128,
    -- CMDS_Incrementation     = 12,
    -- ChaffDefault            = 64,
    -- ChaffChargeSize         = 1,
    -- FlareDefault            = 64,
    -- FlareChargeSize         = 1,
    -- CMDS_Edit               = true,

    passivCounterm = {
        CMDS_Edit = true,
        SingleChargeTotal = 60,
        chaff = {default = 30, increment = 30, chargeSz = 1},
        flare = {default = 30, increment = 30, chargeSz = 1},
    },

    chaff_flare_dispenser     = {
        -- althought the index here starts from 1. When calling drop_flares or drop_chaff, the index begins from 0
        -- { dir =  {Z, Y, X}, pos =  {Z, Y, X}, }  -- Z=back/fwd,Y=down/up(+),X=left/right
        -- { dir =  {-1, -0.1, -0.1}, pos =  {-2.867, -0.6, -0.216}, }, -- Flares L
        -- { dir =  {-1, -0.1,  0.1}, pos =  {-2.867, -0.6,  0.216}, }, -- Flares R
        -- { dir =  {-1, -1, 0}, pos =  {-4.296, -0.429, 0}, }, -- Chaff aft 0
        -- { dir =  {-1, -1, 0}, pos =  {-2.296, -0.429, 0}, }, -- Chaff fwd 1
        [1] = { dir =  {0, -1, 0}, pos =  {-2.2, -0.8, 0.3}, }, -- Fwd Dispenser
        -- [2] = { dir =  {0, -1, 0}, pos =  {-3.9, -0.8, -0.3}, }, -- Aft Dispenser
    },

    --sensors
    detection_range_max        = 250,
    radar_can_see_ground    =    true,
    CanopyGeometry = {
        azimuth   = {-160.0, 160.0}, -- pilot view horizontal (AI)
        elevation = {-50.0, 90.0} -- pilot view vertical (AI)
    },
    Sensors = {
        --RADAR = "AN/APG-53A",
        IRST = "OLS-27",
        OPTIC = "Shkval",--necessite un profil 25T.
        RWR = "Abstract RWR"
    },
    Countermeasures = {
        ECM = "AN/ALQ-126"
    },

    HumanRadio = {
        frequency = 254.0, -- Maykop (Caucasus) or Nellis (NTTR)
        editable = true,
        minFrequency = 225.000,
        maxFrequency = 399.900,
        modulation = MODULATION_AM
    },

    panelRadio = {
        [1] = {
            name = _("AN/ARC-51A"),
            range = {
                {min = 225.0, max = 399.9}
            },
            channels = {  -- matches L-39C except for channel 8, which was changed to a Georgian airport and #20 which is NTTR only (for now).  This radio goes 1-20 not 0-19.
                [1] = { name = _("Channel 1"),      default = 264.0, modulation = _("AM"), connect = true}, -- mineralnye-vody (URMM) : 264.0
                [2] = { name = _("Channel 2"),      default = 265.0, modulation = _("AM")},                 -- nalchik (URMN) : 265.0
                [3] = { name = _("Channel 3"),      default = 256.0, modulation = _("AM")},                 -- sochi-adler (URSS) : 256.0
                [4] = { name = _("Channel 4"),      default = 254.0, modulation = _("AM")},                 -- maykop-khanskaya (URKH), nellis (KLSV) : 254.0
                [5] = { name = _("Channel 5"),      default = 250.0, modulation = _("AM")},                 -- anapa (URKA) : 250.0
                [6] = { name = _("Channel 6"),      default = 270.0, modulation = _("AM")},                 -- beslan (URMO) : 270.0
                [7] = { name = _("Channel 7"),      default = 257.0, modulation = _("AM")},                 -- krasnodar-pashkovsky (URKK) : 257.0
                [8] = { name = _("Channel 8"),      default = 258.0, modulation = _("AM")},                 -- sukhumi-babushara (UGSS) : 255.0
                [9] = { name = _("Channel 9"),      default = 262.0, modulation = _("AM")},                 -- kobuleti (UG5X) : 262.0
                [10] = { name = _("Channel 10"),    default = 259.0, modulation = _("AM")},                 -- gudauta (UG23) : 259.0
                [11] = { name = _("Channel 11"),    default = 268.0, modulation = _("AM")},                 -- tbilisi-soganlug (UG24) : 268.0
                [12] = { name = _("Channel 12"),    default = 269.0, modulation = _("AM")},                 -- tbilisi-vaziani (UG27) : 269.0
                [13] = { name = _("Channel 13"),    default = 260.0, modulation = _("AM")},                 -- batumi (UGSB) : 260.0
                [14] = { name = _("Channel 14"),    default = 263.0, modulation = _("AM")},                 -- kutaisi-kopitnari (UGKO) : 263.0
                [15] = { name = _("Channel 15"),    default = 261.0, modulation = _("AM")},                 -- senaki-kolkhi (UGKS) :  261.0
                [16] = { name = _("Channel 16"),    default = 267.0, modulation = _("AM")},                 -- tbilisi-lochini (UGTB) : 267.0
                [17] = { name = _("Channel 17"),    default = 251.0, modulation = _("AM")},                 -- krasnodar-center (URKI), creech (KINS) : 251.0
                [18] = { name = _("Channel 18"),    default = 253.0, modulation = _("AM")},                 -- krymsk (URKW), mccarran (KLAS) : 253.0
                [19] = { name = _("Channel 19"),    default = 266.0, modulation = _("AM")},                 -- mozdok (XRMF) : 266.0
                [20] = { name = _("Channel 20"),    default = 252.0, modulation = _("AM")},                 -- N/A, groom lake/homey (KXTA) : 252.0
            }
        },
    },

    LandRWCategories =
    {
        [1] =
        {
            Name = "AircraftCarrier",
        }, -- end of [1]
    }, -- end of LandRWCategories

    -- WingSpan = "8.38",--*
    -- MaxFuelWeight = "2498.4",
    -- MaxHeight = "12880",
    -- MaxSpeed = "300",
    -- MaxTakeOffWeight = "11136",
    -- Picture = "A-4E.png",
    -- Rate = "40",
    -- Shape = "A-4E",

    TakeOffRWCategories =
    {
        [1] =
        {
            Name = "AircraftCarrier With Catapult",
        }, -- end of [1]
    }, -- end of TakeOffRWCategories

    WorldID =  WSTYPE_PLACEHOLDER, -- A_4E,

    Failures = {
        -- ACTUAL FAILURES
        { id = 'Left Gear Jam',          label = _('Left Gear Jam'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Right Gear Jam',          label = _('Right Gear Jam'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Nose Gear Jam',          label = _('Nose Gear Jam'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        
        { id = 'Left Gear Actuator Failure',          label = _('Left Gear Actuator Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Right Gear Actuator Failure',          label = _('Right Gear Actuator Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Nose Gear Actuator Failure',          label = _('Nose Gear Actuator Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        
        { id = 'Pitot Tube',          label = _('Pitot Tube Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Static Port',          label = _('Static Port Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
      
        { id = 'Radar Receiver',          label = _('Radar Receiver Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        
        { id = 'Boost Pump',          label = _('Boost Pump Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Wing Pump',          label = _('Wing Tank Pump Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        
        { id = 'Elevator Actuator',          label = _('Elevator Actuator Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Aileron Left Actuator',          label = _('Left Aileron Actuator Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Aileron Right Actuator',          label = _('Right Aileron Actuator Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Rudder Actuator',          label = _('Rudder Actuator Failure'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        
        { id = 'Wing Tank',          label = _('Wing Tank Leak'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        { id = 'Centre Tank',          label = _('Fuselage Tank Leak'), enable = false, hh = 0, mm = 0, mmint = 1, prob = 100 },
        
    },
    -- Aircraft Additional Properties
    AddPropAircraft = {
        {
            id = "HideECMPanel",
            control = "checkbox",
            label = _("Remove ECM control panel"),
            defValue = false,
            weightWhenOn = -80
        },
        {
            id = "Auto_Catapult_Power",
            control = "checkbox",
            label = _("Automatic Catapult Power Mode (for modded aircraft carriers)"),
            defValue = false,
            weightWhenOn = -80
        },
        {
            id = "Night_Vision",
            control = "checkbox",
            label = _("Enable Nightvision"),
            defValue = false,
            weightWhenOn = -80
        },
        { id = "CBU2ATPP", control = 'comboList', label = _('CBU-2/A Tubes Per Pulse'),
            values = {
                {id =  0, dispName = _("1 tube")},
                {id =  1, dispName = _("2 tubes")},
                {id =  2, dispName = _("3 tubes")},
                {id =  3, dispName = _("4 tubes")},
                {id =  4, dispName = _("6 tubes")},
                {id =  5, dispName = _("17 tubes (salvo)")},
            },
            defValue  = 0,
            wCtrl     = 150,
            playerOnly = true
        },
        { id = "CBU2BATPP", control = 'comboList', label = _('CBU-2B/A Tubes Per Pulse'),
            values = {
                {id =  0, dispName = _("2 tubes")},
                {id =  1, dispName = _("4 tubes")},
                {id =  2, dispName = _("6 tubes")},
            },
            defValue  = 0,
            wCtrl     = 150,
            playerOnly = true
        },
        { id = "CMS_BURSTS", control = 'comboList', label = _('CMS BURSTS'),
            values = {
                {id =  1, dispName = _("1")},
                {id =  2, dispName = _("2")},
                {id =  3, dispName = _("3")},
                {id =  4, dispName = _("4")},
            },
            defValue  = 1,
            wCtrl     = 150,
            playerOnly = true
        },
        { id = "CMS_BURST_INTERVAL", control = 'comboList', label = _('CMS BURST INTERVAL'),
            values = {
                {id =  1, dispName = _("0.2 seconds")},
                {id =  2, dispName = _("0.3 seconds")},
                {id =  3, dispName = _("0.4 seconds")},
                {id =  4, dispName = _("0.5 seconds")},
            },
            defValue  = 1,
            wCtrl     = 150,
            playerOnly = true
        },
        { id = "CMS_SALVOS", control = 'comboList', label = _('CMS SALVOS'),
            values = {
                {id =  1, dispName = _("8")},
                {id =  2, dispName = _("12")},
                {id =  3, dispName = _("16")},
                {id =  4, dispName = _("20")},
                {id =  5, dispName = _("24")},
                {id =  6, dispName = _("28")},
                {id =  7, dispName = _("32")},
            },
            defValue  = 1,
            wCtrl     = 150,
            playerOnly = true
        },
        { id = "CMS_SALVO_INTERVAL", control = 'comboList', label = _('CMS SALVO INTERVAL'),
            values = {
                {id =  1, dispName = _("2 seconds")},
                {id =  2, dispName = _("4 seconds")},
                {id =  3, dispName = _("6 seconds")},
                {id =  4, dispName = _("8 seconds")},
                {id =  5, dispName = _("10 seconds")},
                {id =  6, dispName = _("12 seconds")},
                {id =  7, dispName = _("14 seconds")},
            },
            defValue  = 1,
            wCtrl     = 150,
            playerOnly = true
        },
    },
---------------------------------------------------------------------------------------------------------------------------------------------
    Guns = {
            coltMK12({muzzle_pos_connector = "GUN_POINT_1",
                rates = {1020},
                --mixes = {{2,1,1,1,1,1}},
                effect_arg_number = 434,
                supply_position = {2, -0.3, -0.4},
                ejector_pos_connector = "GUN_EJECT_1",
                }),
            coltMK12({muzzle_pos_connector = "GUN_POINT_2",
                rates = {1020},
                --mixes = {{2,1,1,1,1,1}},
                effect_arg_number = 434,
                supply_position = {2, -0.3, -0.4},
                ejector_pos_connector = "GUN_EJECT_2",
                }),
    },

    ammo_type_default = 1,
    ammo_type = {
        _("CM Combat Mix"),
        _("HEI High Explosive Incendiary"),
        _("AP-T")
    },

---------------------------------------------------------------------------------------------------------------------------------------------
    Pylons =     {
        pylon(1, 0, -0.609, -0.762, -2.845, --
            {
               use_full_connector_position = true, connector = "Pylon1", arg = 308, arg_value = 0,
            },
            get_outboard_weapons("L")
        ),
        pylon(2, 0, -0.047, -0.97, -1.899,
            {
               use_full_connector_position = true, connector = "Pylon2", arg = 309, arg_value = 0,
            },
            get_inboard_weapons("L")
        ),
        pylon(3, 0, 0.11, -0.90, 0,
            {
               use_full_connector_position = true, connector = "Pylon3", arg = 310, arg_value = 0,
            },
            get_centerline_weapons("C")
        ),
        pylon(4, 0, -0.047, -0.97, 1.899,
            {
               use_full_connector_position = true, connector = "Pylon4", arg = 311, arg_value = 0,
            },
            get_inboard_weapons("R")
        ),
        pylon(5, 0, -0.609, -0.762, 2.845,
            {
               use_full_connector_position = true, connector = "Pylon5", arg = 312, arg_value = 0,
            },
            get_outboard_weapons("R")
        ),
    },
---------------------------------------------------------------------------------------------------------------------------------------------
    Tasks = {       -- defined in db_units_planes.lua, nothing is #15
        aircraft_task(CAP),                 -- Task #11 in ME
        aircraft_task(CAS),                 -- Task #31
        aircraft_task(SEAD),                -- Task #29
        aircraft_task(Reconnaissance),
        aircraft_task(GroundAttack),        -- Task #32
        aircraft_task(AFAC),                -- Task #16
        aircraft_task(RunwayAttack),
        aircraft_task(AntishipStrike),
        aircraft_task(Refueling),           -- Task #13
        aircraft_task(Escort),
    },
    DefaultTask = aircraft_task(CAS),
---------------------------------------------------------------------------------------------------------------------------------------------
    SFM_Data = {
        aerodynamics = -- Cx = Cx_0 + Cy^2*B2 +Cy^4*B4
        {
            Cy0         = 0.0,      -- zero AoA lift coefficient
            Mzalfa      = 6.2,      -- coefficients for pitch agility
            Mzalfadt    = 0.7,      -- coefficients for pitch agility
            kjx         = 4.5,      -- Inertia parametre X - Dimension (clean) airframe drag coefficient at X (Top) Simply the wing area in square meters (as that is a major factor in drag calculations) - smaller = massive inertia
            kjz         = 0.00125,  -- Inertia parametre Z - Dimension (clean) airframe drag coefficient at Z (Front) Simply the wing area in square meters (as that is a major factor in drag calculations)
            Czbe        = -0.016,   -- coefficient, along Z axis (perpendicular), affects yaw, negative value means force orientation in FC coordinate system
            cx_gear     = 0.07,     -- coefficient, drag, gear ??
            cx_flap     = 0.08,     -- coefficient, drag, full flaps -- 0.006 for first 10 degrees
            cy_flap     = 0.21,     -- coefficient, normal force, lift, flaps -- 0.095 for first 10 degrees
            cx_brk      = 0.12,     -- coefficient, drag speedbrake (0.04 for speedbrake, extra 0.08 to emulate the spoilers (see spoilers.lua and airbrakes.lua))
            --[[  OLD table
            table_data = {
            --       M       Cx0       Cya      B        B4          Omxmax   Aldop      Cymax

                    {0.0,    0.012,    0.10,    0.04,    0.03,         0.50,    14,        1.0,    },
                    {0.4,    0.0145,   0.10,    0.04,    0.03,        10.56,    14,        1.4,    },
                    {0.5,    0.015,    0.09,    0.04,    0.03,        11.56,    14,        1.5,    },
                    {0.6,    0.015,    0.08,    0.04,    0.03,        12.56,    14,        1.6,    },
                    {0.7,    0.015,    0.07,    0.04,    0.03,        11.56,    14,        1.5,    },
                    {0.8,    0.015,    0.06,    0.04,    0.03,        10.56,    14,        1.4,    }, -- Cx0
                    {0.85,   0.015,    0.06,    0.04,    0.03,         9.56,    14,        1.4,    }, -- 0.030
                    {0.9,    0.045,    0.05,    0.04,    0.03,         9.56,    14,        1.4,    }, -- 0.060
            }--]]

            -- slat extension is automatic below 200 KCAS, linear to 100 KCAS
            -- effect of slats is higher AoA possible, higher drag, higher lift
            -- slat Cd at M0.6 is ~0.016 for 20 degree slat extension, with linear mapping
            -- slat Cl at M0.6 is ~0.06/degree for 20 degree slat extension, 2/3 comes from the first 10 degrees

            --[[
            -- attempt #1 from naca report
            table_data = {
            --       M       Cx0        Cya      B      B4          Omxmax      Aldop   Cymax
                    {0.00,   0.0320,    0.066,   0.04,  0.03,        0.50,      14.50,      1.11,    },
                    {0.15,   0.0320,    0.066,   0.04,  0.03,       10.56,      14.50,      1.11,    },   -- 20 degree slat extension at sea level
                    {0.225,  0.0240,    0.064,   0.04,  0.03,       10.56,      12.50,      0.89,    },   -- 10 degree slat extension at sea level
                    {0.30,   0.0160,    0.060,   0.04,  0.03,       10.56,      10.50,      0.77,    },   -- 0 degree slat extension at sea level
                    {0.40,   0.0160,    0.060,   0.04,  0.03,       10.56,      10.30,      0.75,    },
                    {0.50,   0.0160,    0.060,   0.04,  0.03,       11.56,      10.20,      0.73,    },
                    {0.60,   0.0160,    0.060,   0.04,  0.03,       12.56,      10.10,      0.71,    },
                    {0.70,   0.0163,    0.062,   0.04,  0.03,       11.56,       9.90,      0.68,    },
                    {0.80,   0.0165,    0.066,   0.04,  0.03,       10.56,       8.75,      0.65,    },
                    {0.85,   0.0180,    0.070,   0.04,  0.03,        9.56,       8.25,      0.60,    },
                    {0.88,   0.0190,    0.078,   0.04,  0.03,        9.56,       8.25,      0.68,    },
                    {0.9,    0.0200,    0.079,   0.04,  0.03,        9.56,       6.50,      0.72,    },
                    {1.0,    0.0200,    0.073,   0.04,  0.03,        9.56,       6.50,      0.74,    },
                    {1.1,    0.0200,    0.065,   0.04,  0.03,        9.56,       6.80,      0.74,    },
                }
            --]]
            -- now correcting for parasitic drag (drag index) -- roughly 1.5x at the top end to model a drag index of ~40 when empty
            -- removed 10 degree slat line, was causing SFM interpolation bug
            -- Cya max M0.15 of 0.95 results in approach noflap=137-140, fullflap=120-123   targets:  143/126 @ 14,000#
            -- test: change Cya 0.96 -> 0.92 for M0.0 and M0.15, leave Cya 0.71 for M0.30, test at 14000#
                    -- result:  138-141 noflap, 121-123 flaps
            -- test: Cya 0.92 -> 0.84 for M<=0.15, 0.71->0.66 M0.3, 14K#
                    -- result:  145-147 noflap, 126-127 flaps
            -- test: Cya normalization 0.60 @ M0.40, 0.61 @ 0.30, 14K#
                    -- result:  145-147 noflap, 126-127 flaps
            -- test: Cya 0.84->0.85 M<=0.15, 14K#
                    -- result:  144-147 noflap, 125-126 flaps       close!
            -- test: Cya 0.85->0.86, Cyflap 0.22->0.21, 14000#
                    -- result:  143-146 noflap, 126-127 flaps       close for 14K#
            -- test: Cya 0.86->0.87 M<=0.15
                    -- result:  142-145 noflap, 125-126 flaps       done for 14K# (on target)
            -- test: weight 12K#, target: 135/116.5
                    -- result:  131-133 noflap, 115-116 flaps       done for 12K# (~2% too little lift w/o flaps)
            -- test: weight 16K#, target: 153/134
                    -- result:  152-156 noflap, 134-135 flaps       done for 16K# (on target)

            --[[
            table_data = {
            --       M       Cx0        Cya      B      B4          Omxmax      Aldop       Cymax
                    {0.00,   0.0220,    0.087,   0.149,  0.00,         0.5,      13.15,      1.11,    },
                    {0.15,   0.0220,    0.087,   0.149,  0.00,         1.0,      13.15,      1.11,    },   -- 20 degree slat extension at sea level
                    {0.30,   0.0160,    0.061,   0.149,  0.00,         4.5,      11.50,      0.77,    },   -- 0 degree slat extension at sea level
                    {0.40,   0.0160,    0.060,   0.149,  0.00,         6.5,      10.30,      0.75,    },
                    {0.50,   0.0160,    0.060,   0.149,  0.00,         8.0,      10.20,      0.73,    },
                    {0.60,   0.0160,    0.060,   0.149,  0.00,         8.1,      10.10,      0.71,    },
                    {0.70,   0.0190,    0.062,   0.149,  0.00,         8.3,       9.90,      0.68,    },
                    {0.80,   0.0200,    0.066,   0.149,  0.00,         8.3,       8.75,      0.65,    },
                    {0.85,   0.0215,    0.070,   0.149,  0.00,         8.1,       8.25,      0.60,    },
                    {0.88,   0.0245,    0.078,   0.169,  0.00,         7.8,       8.25,      0.68,    },
                    {0.9,    0.0310,    0.079,   0.179,  0.00,         7.6,       6.50,      0.72,    },
                    {1.0,    0.0350,    0.073,   0.352,  0.00,         7.6,       6.50,      0.74,    },
                    {1.1,    0.0370,    0.065,   0.460,  0.00,         7.6,       6.80,      0.74,    },
                }
            --]]

            table_data = {
            --       M       Cx0        Cya      B      B4          Omxmax      Aldop       Cymax
                    {0.00,   0.0220,    0.087,   0.149,  0.00,         0.5,     22.91,      1.40, },
                    {0.15,   0.0220,    0.087,   0.149,  0.00,         1.0,     22.91,      1.40, },   -- 20 degree slat extension at sea level
                    {0.30,   0.0160,    0.061,   0.149,  0.00,         4.5,     22.91,      1.30, },   -- 0 degree slat extension at sea level
                    {0.40,   0.0160,    0.060,   0.149,  0.00,         6.5,     22.91,      1.22, },
                    {0.48,   0.0160,    0.060,   0.149,  0.00,         7.5,     22.91,      1.05, },
                    {0.50,   0.0160,    0.060,   0.149,  0.00,         8.0,     22.34,      1.00, },
                    {0.55,   0.0160,    0.060,   0.149,  0.00,         8.0,     20.91,      0.96, },
                    {0.60,   0.0160,    0.060,   0.149,  0.00,         8.1,     18.33,      0.91, },
                    {0.65,   0.0175,    0.061,   0.149,  0.00,         8.2,     22.63,      0.89, },
                    {0.70,   0.0190,    0.062,   0.149,  0.00,         8.3,     25.21,      0.88, },
                    {0.80,   0.0200,    0.066,   0.149,  0.00,         8.3,     23.60,      0.86, },
                    {0.85,   0.0215,    0.070,   0.149,  0.00,         8.1,     21.77,      0.80, },
                    {0.88,   0.0245,    0.078,   0.169,  0.00,         7.8,     19.00,      0.76, },
                    {0.9,    0.0310,    0.079,   0.179,  0.00,         7.6,     18.33,      0.76, },
                    {0.95,   0.0335,    0.075,   0.280,  0.00,         7.6,     13.18,      0.76, },
                    {1.0,    0.0350,    0.073,   0.352,  0.00,         7.6,     10.30,      0.76, },
                    {1.1,    0.0370,    0.065,   0.460,  0.00,         7.6,     10.10,      0.76, },
                }

            -- M - Mach number
            -- Cx0 - Coefficient, drag, profile, of the airplane
            -- Cya - Normal force coefficient of the wing and body of the aircraft in the normal direction to that of flight. Inversely proportional to the available G-loading at any Mach value. (lower the Cya value, higher G available) per 1 degree AOA
            -- B2 - Polar 2nd power coeff
            -- B4 - Polar 4th power coeff
            -- Omxmax - roll rate, rad/s
            -- Aldop - Alfadop Max AOA at current M - departure threshold
            -- Cymax - Coefficient, lift, maximum possible (ignores other calculations if current Cy > Cymax)
        }, -- end of aerodynamics
        engine =
        {
            Nmg     = 55.0,    -- RPM at idle
            MinRUD  = 0,    -- Min state of the throttle
            MaxRUD  = 1,    -- Max state of the throttle
            MaksRUD = 0.999,    -- Military power state of the throttle
            ForsRUD = 0.99999,    -- Afterburner state of the throttle
            typeng  = 0,
            --[[
                E_TURBOJET = 0
                E_TURBOJET_AB = 1
                E_PISTON = 2
                E_TURBOPROP = 3
                E_TURBOFAN    = 4
                E_TURBOSHAFT = 5
            --]]
            hMaxEng = 15,    -- Max altitude for safe engine operation in km
            dcx_eng = 0.0114,    -- Engine drag coeficient
            -- Affects drag of engine when shutdown
            -- cemax/cefor affect sponginess of elevator/inertia at slow speed
            -- affects available g load apparently
            cemax   = 0.037,    -- not used for fuel calulation , only for AI routines to check flight time ( fuel calculation algorithm is built in )
            cefor   = 0.037,    -- not used for fuel calulation , only for AI routines to check flight time ( fuel calculation algorithm is built in )
            dpdh_m  = 6000,    --  altitude coefficient for max thrust
            dpdh_f  = 14000.0,    --  altitude coefficient for AB thrust

            table_data =
            {
            --   M          Pmax
                {0.0,       0.0,0.0}, -- dummy table, required for 2.0+ engine module load
                {2.0,       0.0,0.0},
            }, -- end of table_data
            -- M - Mach number
            -- Pmax - Engine thrust at military power - kilo Newton
            -- Pfor - Engine thrust at AFB
            extended = -- added new abilities for engine performance setup. thrust data now can be specified as 2d table by Mach number and altitude. thrust specific fuel consumption tuning added as well
            {
                -- matching TSFC to mil thrust consumption at altitude at mach per NATOPS navy trials
                TSFC_max =  -- thrust specific fuel consumption by altitude and Mach number for RPM  100%, 2d table
                {
                    M          = {0, 0.5, 0.8, 0.9, 1.0},
                    H         = {0, 3048, 6096, 9144, 12192},
                    TSFC     = {-- M 0      0.5     0.8       0.9     1.0
                                {   0.86,  0.92,  1.012,    1.012,  1.003}, --H = 0       -- SL
                                {   0.86,  0.99,  1.025,    1.025,  1.016}, --H = 3048    -- 10000'
                                {   0.86,  0.96,  1.008,    1.008,  0.999}, --H = 6096    -- 20000'
                                {   0.86,  0.95,  0.984,    0.984,  0.974}, --H = 9144    -- 30000'
                                {   0.86,  0.94,  0.976,    0.976,  0.967}, --H = 12192   -- 40000'
                    }
                },

                 TSFC_afterburner =  -- afterburning thrust specific fuel consumption by altitude and Mach number RPM  100%, 2d table
                 {
                     M          = {0,0.3,0.5,0.7,1.0},
                     H         = {0,1000,3000,10000},
                     TSFC     = {-- M 0  0.3 0.5  0.7  1.0
                                 {   1,   1,  1,   1,   1}, --H = 0
                                 {   1,   1,  1,   1,   1}, --H = 1000
                                 {   1,   1,  1,   1,   1}, --H = 3000
                                 {   1,   1,  1,   1,   1}, --H = 10000
                     }
                 },

                -- per ADA057325:
                -- SFC = 0.836 (0% bleed) to 1.415 (15.44% bleed) at low throttle
                -- SFC = 0.777 (0% bleed) to 0.964 (16.84% bleed) at MIL throttle
                -- modeling as 5% bleed, so low power loses 22% efficiency:
                TSFC_throttle_responce =  -- correction to TSFC for different engine RPM, 1d table
                {
                    RPM = {0, 50, 55, 75, 100},
                    K   = {1, 1.05, 1.22, 1.05, 1.00},   -- Static SL TSFC now part of table above
                    --K   = {1, 1, 1, 1, 1},
                },

                --[[
                thrust_max = -- thrust interpolation table by altitude and mach number, 2d table
                 {
                     M          = {0,.1,0.3,0.5,0.7,0.8,0.9,1.1},
                     H         = {0,250,4572,7620,10668,13716,16764,19812},
                     thrust     = {-- M   0         0.1       0.3       0.5       0.7      0.8     0.9       1.1
                                 {   61370,  59460,  57023, 36653,  36996,  37112,  36813,  34073 },--H = 0 (sea level)
                                 {   41370,  39460,  37023, 36653,  36996,  37112,  36813,  34073 },--H = 250 (sea level)
                                 {   27254,  25799,  24203, 24599,  26227,  27254,  28353,  29785 },--H = 4572 (15kft)
                                 {   20818,  19203,  17548, 17473,  18638,  19608,  20684,  22873 },--H = 7620 (25kft)
                                 {   10876,  11076,  11556, 12193,  13024,  13674,  14434,  16098 },--H = 10668 (35kft)
                                 {   6025,   6379,   6837,  7433,   8194,   8603,   9101,   10075 },--H = 13716 (45kft)
                                 {   3336,   3554,   3990,  4484,   5000,   5307,   5596,   6232  },--H = 16764 (55kft)
                                 {   1904,   2042,   2433,  2798,   3212,   3483,   3639,   4097  },--H = 19812 (65kft)
                     },
                 },]]--

                thrust_max = -- thrust interpolation table by altitude and mach number, 2d table.  Modified for carrier takeoffs at/around 71 foot deck height
                {
                    M       =   {0, 0.1, 0.225, 0.23, 0.3, 0.5, 0.7, 0.8, 0.9, 1.1},
                    H       =   {0, 19, 20, 23, 24, 250, 4572, 7620, 10668, 13716, 16764, 19812},
                    thrust  =  {-- M    0     0.1    0.225   0.23,   0.3    0.5     0.7     0.8     0.9     1.1
                                {   41370,  39460,  38060,  38056,  37023,  36653,  36996,  37112,  36813,  34073 }, --H = 0 (sea level)
                                {   41370,  39460,  38060,  38056,  37023,  36653,  36996,  37112,  36813,  34073 }, --H = 19 (~62.3 feet)
                                {   41370,  39460,  38060,  38056,  37023,  36653,  36996,  37112,  36813,  34073 }, --H = 20 (~66.6 feet)
                                {   41370,  39460,  38060,  38056,  37023,  36653,  36996,  37112,  36813,  34073 }, --H = 23 (~75.5 feet)
                                {   41370,  39460,  38060,  38056,  37023,  36653,  36996,  37112,  36813,  34073 }, --H = 24 (~78.7 feet)
                                {   41370,  39460,  38060,  38056,  37023,  36653,  36996,  37112,  36813,  34073 }, --H = 250 (820 feet)
                                {   27254,  25799,  24765,  24761,  24203,  24599,  26227,  27254,  28353,  29785 }, --H = 4572 (15kft)
                                {   20818,  19203,  18130,  18127,  17548,  17473,  18638,  19608,  20684,  22873 }, --H = 7620 (25kft)
                                {   10876,  11076,  11128,  11130,  11556,  12193,  13024,  13674,  14434,  16098 }, --H = 10668 (35kft)
                                {   6025,   6379,    6676,   6680,  6837,   7433,   8194,   8603,   9101,   10075 }, --H = 13716 (45kft)
                                {   3336,   3554,    3837,   3840,  3990,   4484,   5000,   5307,   5596,   6232  }, --H = 16764 (55kft)
                                {   1904,   2042,    2296,   2300,  2433,   2798,   3212,   3483,   3639,   4097  }, --H = 19812 (65kft)
                               },
                },



                  thrust_afterburner = -- afterburning thrust interpolation table by altitude and mach number, 2d table
                 {
                     M          = {0,    0.20,    0.21,    1.0},
                     H       =   {0, 15, 16, 23, 24, 250, 19812},
                     thrust     = { -- M 0  0.3 0.5  0.7  1.0
                                 {   41370,       41370,  41370,   41370,},     -- H = 0
                                 {   41370,       41370,  41370,   41370,},     -- H = 15
                                 {   250000,       250000,  41370,   41370,},   -- H = 16
                                 {   250000,       250000,  41370,   41370,},   -- H = 23
                                 {   41370,       38060,  38060,   36813,},     -- H = 24
                                 {   41370,       38060,  38060,   36813,},     -- H = 250
                                 {   1904,       2296,  2296,   3639,},         -- H = 19812
                     }
                 },

                --rpm_acceleration_time_factor = -- time factor for engine governor  ie RPM += (desired_RPM - RPM ) * t(RPM) * dt
                --{
                --    RPM  = {0, 50, 100},
                --    t    = {0.3,0.3,0.3}
                --},
                --rpm_deceleration_time_factor = -- time factor for engine governor
                --{
                --    RPM  = {0, 50, 100},
                --    t    = {0.3,0.3,0.3}
                --},
                rpm_throttle_responce = -- required RPM according to throttle position
                {
                    throttle = {0   ,0.85  ,1.0},
                    RPM      = {55  ,97.2  ,100},
                },
                thrust_rpm_responce = -- thrust = K(RPM) * thrust_max(M,H)
                {
                    RPM = {0  ,55   ,55.1   ,57.6   ,65.8   ,74.1   ,78.2   ,82.3   ,90.5   ,98.8   ,100},
                    K   = {0  ,0.00 ,0.051  ,0.059  ,0.101  ,0.176  ,0.248  ,0.349  ,0.670  ,0.963  ,1},
                },
            },
        }, -- end of engine
    },
---------------------------------------------------------------------------------------------------------------------------------------------
    --damage , index meaning see in  Scripts\Aircrafts\_Common\Damage.lua
    -- Damage = {
    --             [0] = {critical_damage = 5, args = {82}},                            -- 0 - nose center
    --             [3] = {critical_damage = 10, args = {65}},                           -- 3 - cockpit
    --             [8] = {critical_damage = 10},                                        -- 8 - front gear
    --             [11] = {critical_damage = 3},                                        -- 11 - engine in left
    --             [12] = {critical_damage = 3},                                        -- 12 - engine in right
    --             [15] = {critical_damage = 10},                                       -- 15 - gear left
    --             [16] = {critical_damage = 10},                                       -- 16 - gear right
    --             [17] = {critical_damage = 3},                                        -- 17 - motogondola left (left engine out, left ewu)
    --             [18] = {critical_damage = 3},                                        -- 18 - motogondola right (right engine out, right ewu)
    --             [25] = {critical_damage = 5, args = {53}},                           -- 25 - eleron left
    --             [26] = {critical_damage = 5, args = {54}},                           -- 26 - eleron right
    --             [35] = {critical_damage = 10, args = {67}, deps_cells = {25, 37}},   -- 35 - wing in left
    --             [36] = {critical_damage = 10, args = {68}, deps_cells = {26, 38}},   -- 36 - wing in right
    --             [37] = {critical_damage = 4, args = {55}},                           -- 37 - flap in left
    --             [38] = {critical_damage = 4, args = {56}},                           -- 38 - flap in right
    --             [43] = {critical_damage = 4, args = {61}, deps_cells = {53}},        -- 43 - fin bottom left
    --             [44] = {critical_damage = 4, args = {62}, deps_cells = {54}},        -- 44 - fin bottom right
    --             [47] = {critical_damage = 5, args = {63}, deps_cells = {51}},        -- 47 - stabilizer in left
    --             [48] = {critical_damage = 5, args = {64}, deps_cells = {52}},        -- 48 - stabilizer in right
    --             [51] = {critical_damage = 2, args = {59}},                           -- 51 - elevator in left
    --             [52] = {critical_damage = 2, args = {60}},                           -- 52 - elevator in right
    --             [53] = {critical_damage = 2, args = {57}},                           -- 53 - rudder left
    --             [54] = {critical_damage = 2, args = {58}},                           -- 54 - rudder right
    --             [55] = {critical_damage = 5, args = {81}},                           -- 55 - tail
    --             [83]    = {critical_damage = 3, args = {134}},                       -- nose wheel
    --             [84]    = {critical_damage = 3, args = {136}},                       -- left wheel
    --             [85]    = {critical_damage = 3, args = {135}},                       -- right wheel
    -- },

    Damage = verbose_to_dmg_properties(
    {
        ["NOSE_CENTER"]             = {critical_damage = 3}, -- 0
        ["NOSE_LEFT_SIDE"]          = {critical_damage = 3}, -- 1
        ["NOSE_RIGHT_SIDE"]         = {critical_damage = 3}, -- 2
        ["NOSE_BOTTOM"]             = {critical_damage = 3}, -- 59

        ["COCKPIT"]                 = {critical_damage = 1}, -- 3
        ["CABIN_LEFT_SIDE"]         = {critical_damage = 3}, -- 4
        ["CABIN_RIGHT_SIDE"]        = {critical_damage = 3}, -- 5
        ["CABIN_BOTTOM"]            = {critical_damage = 3}, -- 6

        ["GUN"]                     = {critical_damage = 2}, -- 7 refuelling probe?
        ["PITOT"]                   = {critical_damage = 1}, -- 60

        ["WHEEL_F"]                 = {critical_damage = 3}, -- 83

        ["FUSELAGE_LEFT_SIDE"]      = {critical_damage = 3}, -- 9
        ["FUSELAGE_RIGHT_SIDE"]     = {critical_damage = 3}, --10
        ["FUSELAGE_TOP"]            = {critical_damage = 3}, -- 99 avionics hump?
        ["FUSELAGE_BOTTOM"]         = {critical_damage = 4}, --82
        ["ENGINE"]                  = {critical_damage = 2, args = {600}},-- 11

        -- ["MTG_L"]                   = {critical_damage = 3}, -- 17 left engine nacelle
        -- ["MTG_R"]                   = {critical_damage = 3}, -- 18 right engine nacelle

        ["AIR_BRAKE_L"]             = {critical_damage = 1}, -- 19
        ["AIR_BRAKE_R"]             = {critical_damage = 1}, -- 20

        ["WING_L_IN"]               = {critical_damage = 5, deps_cells = {"WING_L_CENTER"}}, -- 35
        ["WING_L_CENTER"]           = {critical_damage = 4, deps_cells = {"WING_L_PART_CENTER", "FLAP_L", "WING_L_OUT"}}, -- 29
        ["WING_L_PART_CENTER"]      = {critical_damage = 1.5, args = {604}}, -- 27 -- spoiler
        ["WING_L_OUT"]              = {critical_damage = 3, deps_cells = {"AILERON_L"}}, -- 23
        ["FLAP_L"]                  = {critical_damage = 2}, -- 37
        ["AILERON_L"]               = {critical_damage = 1, args = {603}}, --25
        ["WHEEL_L"]                 = {critical_damage = 3}, -- 84

        ["WING_R_IN"]               = {critical_damage = 5, deps_cells = {"WING_R_CENTER"}}, -- 36
        ["WING_R_CENTER"]           = {critical_damage = 4, deps_cells = {"WING_R_PART_CENTER", "FLAP_R", "WING_R_OUT"}}, -- 30
        ["WING_R_PART_CENTER"]      = {critical_damage = 1.5, args = {605}}, -- 28 -- spoiler
        ["WING_R_OUT"]              = {critical_damage = 3, deps_cells = {"AILERON_R"}}, -- 24
        ["FLAP_R"]                  = {critical_damage = 2}, -- 38
        ["AILERON_R"]               = {critical_damage = 1, args = {606}}, --26
        ["WHEEL_R"]                 = {critical_damage = 3}, -- 85

        ["TAIL"]                    = {critical_damage = 2}, -- 55
        ["TAIL_LEFT_SIDE"]          = {critical_damage = 3}, -- 56
        ["TAIL_RIGHT_SIDE"]         = {critical_damage = 3}, -- 57
        -- ["TAIL_BOTTOM"]             = {critical_damage = 3}, --58
        ["STABILIZATOR_L"]          = {critical_damage = 2, deps_cells = {"ELEVATOR_L"}, args = {602}}, -- 47
        ["ELEVATOR_L"]              = {critical_damage = 1}, -- 51
        ["STABILIZATOR_R"]          = {critical_damage = 2, deps_cells = {"ELEVATOR_R"}}, -- 48
        ["ELEVATOR_R"]              = {critical_damage = 1}, -- 52
        ["RUDDER"]                  = {critical_damage = 1}, --53

        ["FIN_L_TOP"]               = {critical_damage = 4}, --53
        ["FIN_L_BOTTOM"]            = {critical_damage = 4, deps_cells = {"RUDDER", "FIN_L_TOP"}, args = {601}}, --53
        -- ["HOOK"]                    = {critical_damage = 2}, -- 98
    }),



    DamageParts =
    {
        -- [1] = "a4_dmg_wing_right",     -- Right Wing
        -- [2] = "a4_dmg_wing_left",     -- Left Wing
        -- [3] = "a4_dmg_fus_front",     -- nose
        -- [4] = "a4_dmg_fus_back",     -- tail
    },
---------------------------------------------------------------------------------------------------------------------------------------------
    lights_data = {
        typename = "collection",
        lights = {
            -- STROBES
            [1] = {
                typename = "collection",
                lights = {
                            {typename = "argnatostrobelight", argument = 204, period = 1.2, phase_shift = 0},
                            {typename = "argnatostrobelight", argument = 205, period = 1.2, phase_shift = 0.5},
                },
            },
            -- SPOTS / TAXI & LANDING
            [2] = {
                typename = "collection",
                lights = {  {typename  = "argumentlight", argument  = 208}, -- taxi light
                },
            },
            -- NAVLIGHTS
            [3] = {
                typename = "collection",
                lights = {  {typename  = "argumentlight", argument  = 190}, -- red
                            {typename  = "argumentlight", argument  = 191}, -- green
                            {typename  = "argumentlight", argument  = 192}, -- white
                },
            },
            -- FORMATION
            [4] = {},
            -- TIPS
            [5] = {},
            -- REFUEL
            [6] = {
                typename = "collection",
                lights = {  {typename  = "argumentlight", argument  = 193}, -- probe light
                },
            },
            -- ANTI-COLLISION
            [7] = {},
        }, -- end of lights
    }, -- end of lights_data
}

add_aircraft(A_4E_C)
