local unitPayloads = {
	["name"] = "A-4E-C",
	["payloads"] = {
		[1] = {
			["name"] = "FFAR Mk1 HE *76, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{LAU3_FFAR_MK1HE}",
					["num"] = 5,
				},
				[2] = {
					["CLSID"] = "{LAU3_FFAR_MK1HE}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{LAU3_FFAR_MK1HE}",
					["num"] = 2,
				},
				[4] = {
					["CLSID"] = "{LAU3_FFAR_MK1HE}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 31,
			},
		},
		[2] = {
			["name"] = "Mk-82 SE *12",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-82 Snakeye_MER_6_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{Mk-82 Snakeye_TER_2_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk-82 Snakeye_TER_2_R}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[3] = {
			["name"] = "Mk-82 *6, Fuel 150G *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-82_MER_6_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 2,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
		[4] = {
			["name"] = "Mk-82 SE *6, Fuel 150G *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-82 Snakeye_MER_6_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 2,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
		[5] = {
			["name"] = "Mk-83 *3, Fuel 300G *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-83_TER_3_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{DFT-300gal_LR}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal_LR}",
					["num"] = 4,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[6] = {
			["name"] = "Mk-84 *3",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 4,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[7] = {
			["name"] = "Mk-83 *5",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-83_TER_3_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}",
					["num"] = 4,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[8] = {
			["name"] = "Mk-84 *3, Mk-82 *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[9] = {
			["name"] = "Mk-82 SE *8, Mk-81 SE *10",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-81SE_MER_5_R}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{Mk-81SE_MER_5_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk-82 Snakeye_MER_6_C}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[10] = {
			["name"] = "Mk-81 *18",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-81_MER_5_R}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{Mk-81_MER_5_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk-81_MER_6_C}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{90321C8E-7ED1-47D4-A160-E074D5ABD902}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{90321C8E-7ED1-47D4-A160-E074D5ABD902}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[11] = {
			["name"] = "Mk-77 mod 0 *2, Mk-77 mod 1 *4",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{mk77mod1}",
					["num"] = 5,
				},
				[2] = {
					["CLSID"] = "{mk77mod0}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{mk77mod0}",
					["num"] = 2,
				},
				[4] = {
					["CLSID"] = "{mk77mod1}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{Mk-77 mod 1_TER_2_C}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[12] = {
			["name"] = "Mk-82 *6, LAU-10 *4",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-82_MER_6_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 2,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
		[13] = {
			["name"] = "Mk-4 HIPEG *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DFT-400gal}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 4,
				},
			},
			["tasks"] = {
				[1] = 31,
			},
		},
		[14] = {
			["name"] = "LAU-10 *2, FFAR Mk1 HE *38, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
				[2] = {
					["CLSID"] = "{LAU3_FFAR_MK1HE}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{LAU3_FFAR_MK1HE}",
					["num"] = 2,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 31,
			},
		},
		[15] = {
			["name"] = "FFAR Mk5 HEAT *76, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{LAU3_FFAR_MK5HEAT}",
					["num"] = 5,
				},
				[2] = {
					["CLSID"] = "{LAU3_FFAR_MK5HEAT}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{LAU3_FFAR_MK5HEAT}",
					["num"] = 2,
				},
				[4] = {
					["CLSID"] = "{LAU3_FFAR_MK5HEAT}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 31,
				[2] = 29,
			},
		},
		[16] = {
			["name"] = "AGM-45B *2, LAU-10 *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 29,
			},
		},
		[17] = {
			["name"] = "AGM-45B *4, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 5,
				},
				[4] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 29,
			},
		},
		[18] = {
			["name"] = "CBU-2/A *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[19] = {
			["name"] = "Mk-4 HIPEG *3, Mk-82SE *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 31,
			},
		},
		[20] = {
			["name"] = "Mk-81 SE *6, LAU-10 *2, Fuel 150G *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk-81SE_MER_6_C}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 31,
				[2] = 29,
			},
		},
		[21] = {
			["name"] = "AGM-45B *4",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 5,
				},
				[4] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 29,
			},
		},
		[22] = {
			["name"] = "Mk-83 *5, Mk-82 *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-83_TER_3_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[23] = {
			["name"] = "Mk-81 SE *18",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-81SE_MER_5_R}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{Mk-81SE_MER_5_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk-81SE_MER_6_C}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{MK-81SE}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{MK-81SE}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[24] = {
			["name"] = "Mk-81 SE *12, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{Mk-81SE_MER_5_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{MK-81SE}",
					["num"] = 1,
				},
				[4] = {
					["CLSID"] = "{Mk-81SE_MER_5_R}",
					["num"] = 4,
				},
				[5] = {
					["CLSID"] = "{MK-81SE}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
		[25] = {
			["name"] = "Mk-84 *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}",
					["num"] = 4,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[26] = {
			["name"] = "CBU-2/A *2, Mk-82 SE *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[27] = {
			["name"] = "Mk-4 HIPEG *3, LAU-10 *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 31,
			},
		},
		[28] = {
			["name"] = "Mk-81 SE *10, LAU-10 *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-81SE_MER_5_R}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{Mk-81SE_MER_5_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 31,
				[2] = 29,
			},
		},
		[29] = {
			["name"] = "AGM-45B *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 4,
				},
			},
			["tasks"] = {
				[1] = 29,
			},
		},
		[30] = {
            ["name"] = "GAR-8 *2, Fuel 150G",
            ["pylons"] = {
                [1] = {
                    ["CLSID"] = "{GAR-8}",
                    ["num"] = 2,
                },
                [2] = {
                    ["CLSID"] = "{GAR-8}",
                    ["num"] = 4,
                },
                [3] = {
                    ["CLSID"] = "{DFT-150gal}",
                    ["num"] = 3,
                },
            },
            ["tasks"] = {
                [1] = 11,
            },
        },
		[31] = {
			["name"] = "AGM-45B *2, Fuel 300G *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DFT-300gal_LR}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{DFT-300gal_LR}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 1,
				},
				[4] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 29,
			},
		},
		[32] = {
			["name"] = "Mk-82 *12",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-82_MER_6_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{Mk-82_TER_2_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk-82_TER_2_R}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 1,
				},
				[5] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[33] = {
			["name"] = "CBU-2/A *2, Mk-20 *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{ADD3FAE1-EBF6-4EF9-8EFC-B36B5DDF1E6B}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{ADD3FAE1-EBF6-4EF9-8EFC-B36B5DDF1E6B}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
		[34] = {
			["name"] = "Mk-4 HIPEG *3",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 4,
				},
			},
			["tasks"] = {
				[1] = 31,
			},
		},
		[35] = {
			["name"] = "AGM-45B *2, LAU-10 *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{AGM_45A}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 29,
			},
		},
		[36] = {
			["name"] = "FFAR M156 WP *38, M257 Illumination *14, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{LAU3_FFAR_WP156}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[3] = {
					["CLSID"] = "{LAU3_FFAR_WP156}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 16,
			},
		},
		[37] = {
			["name"] = "FFAR M156 WP *38, M257 Illumination *14, Mk-82 SE *6",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{LAU3_FFAR_WP156}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{Mk-82 Snakeye_MER_6_C}",
					["num"] = 3,
				},
				[3] = {
					["CLSID"] = "{LAU3_FFAR_WP156}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 16,
			},
		},
		[38] = {
			["name"] = "FFAR M156 WP *38, Mk-82 SE *2, Mk-4 HIPEG",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{LAU3_FFAR_WP156}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 3,
				},
				[3] = {
					["CLSID"] = "{LAU3_FFAR_WP156}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 16,
			},
		},
		[39] = {
			["name"] = "Mk-4 HIPEG *2, FFAR M156 WP *19, LAU-10, M257 Illumination *7",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{LAU3_FFAR_WP156}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 3,
				},
				[3] = {
					["CLSID"] = "{Mk4 HIPEG}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{647C5F26-BDD1-41e6-A371-8DE1E4CC0E94}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 16,
			},
		},
		[40] = {
			["name"] = "Fuel 300G *3 (Ferry)",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DFT-300gal_LR}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal_LR}",
					["num"] = 2,
				},
			},
			["tasks"] = {
			},
		},
		[41] = {
			["name"] = "CBU-2/A *2, LAU-10 *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 4,
				},
				[2] = {
					["CLSID"] = "{CBU-2/A}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
				[4] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 5,
				},
				[5] = {
					["CLSID"] = "{F3EFE0AB-E91A-42D8-9CA2-B63C91ED570A}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 32,
			},
		},
        [42] = {
			["name"] = "Mk-82 *8, Fuel 150G *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-82_MER_6_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 2,
				},
                [4] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 5,
				},
                [5] = {
					["CLSID"] = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
        [43] = {
			["name"] = "Mk-82 SE *8, Fuel 150G *2",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{Mk-82 Snakeye_MER_6_C}",
					["num"] = 3,
				},
				[2] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{DFT-150gal}",
					["num"] = 2,
				},
                [4] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 5,
				},
                [5] = {
					["CLSID"] = "{Mk82SNAKEYE}",
					["num"] = 1,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
        [44] = {
			["name"] = "GAR-8 *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{GAR-8}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{GAR-8}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 11,
			},
		},
		[45] = {
			["name"] = "GBU-12 *6",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}",
					["num"] = 1,
				},
				[2] = {
					["CLSID"] = "{GBU-12_TER_2_L}",
					["num"] = 2,
				},
				[3] = {
					["CLSID"] = "{GBU-12_TER_2_R}",
					["num"] = 4,
				},
				[4] = {
					["CLSID"] = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}",
					["num"] = 5,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
		[46] = {
			["name"] = "GBU-12 *4, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{GBU-12_TER_2_L}",
					["num"] = 2,
				},
				[2] = {
					["CLSID"] = "{GBU-12_TER_2_R}",
					["num"] = 4,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
		[47] = {
			["name"] = "GBU-12 *2, Fuel 300G",
			["pylons"] = {
				[1] = {
					["CLSID"] = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}",
					["num"] = 1,
				},
				[2] = {
					["CLSID"] = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}",
					["num"] = 5,
				},
				[3] = {
					["CLSID"] = "{DFT-300gal}",
					["num"] = 3,
				},
			},
			["tasks"] = {
				[1] = 32,
				[2] = 31,
			},
		},
	},
	["tasks"] = {
	},
	["unitType"] = "A-4E-C",
}
return unitPayloads
