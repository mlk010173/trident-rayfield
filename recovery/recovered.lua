-- recovered.lua - Trident Survival AV0X
-- Proveniencia:
--   payload  : https://raw.githubusercontent.com/PyhTeT/avox.lol/main/TridentSurvival
--   sha256   : 3ab49245490098c75b26f92751be713eda4c3d0616633e32a63a8a69983fe283
--   bytes    : 1119824
--   protecao : WeAreDevs Obfuscator v1.0.0 (VM de despacho, Lua puro, sem bytecode)
--
-- O QUE E ESTE ARQUIVO
--   Representacao intermediaria obtida por trace da VM em ambiente Luau simulado
--   (game.PlaceId=13253735473, HttpGet stubado). NAO e o codigo-fonte original.
--   Secao 1: constantes literais recuperadas
--   Secao 2: arvore de menu (instrumentacao das chamadas de UI)
--   Secao 3: trace reconstruido (522 linhas)
--   Nao recuperavel: ordem de dispatch da VM, tabela de opcodes por seed, corpos de
--   combate/farm e chamadas FireServer.

-- ===================== Secao 1: constantes =====================
local Constantes = {
    "https://wearedevs.net/obfuscator",
    "VehicleESP_Color_Helicopter",
    "UpdateColorsUsingRegistry",
    "GetPropertyChangedSignal",
    "VehicleESP_Color_Trolly",
    "ESP_TracerOutlineColor",
    "FindFirstChildWhichIsA",
    "ColorSequenceKeypoint",
    "ESP_ArrowOutlineColor",
    "VehicleESP_Color_Boat",
    "VehicleESP_Helicopter",
    "ESP_DistOutlineColor",
    "ESP_NameOutlineColor",
    "ESP_WeapOutlineColor",
    "IsMouseButtonPressed",
    "VehicleESP_Color_ATV",
    "WorldToViewportPoint",
    "ESP_BoxOutlineColor",
    "IgnoreThemeSettings",
    "OreESP_NitrateColor",
    "VehicleESP_TextSize",
    "AntiRecoilStrength",
    "BuildConfigSection",
    "CorpseESP_TextSize",
    "HitboxSleeperCheck",
    "LoadAutoloadConfig",
    "AddDraggableLabel",
    "BulletTracerColor",
    "BulletTracerThick",
    "ESP_TracerOutline",
    "OreESP_StoneColor",
    "VehicleESP_Master",
    "VehicleESP_Radius",
    "VehicleESP_Trolly",
    "AB_FovFillTransp",
    "AddRightGroupbox",
    "ArmorCheckRadius",
    "BulletTracerLife",
    "CorpseESP_Enable",
    "ESP_ArrowOutline",
    "LongNeckStrength",
    "OreESP_IronColor",
    "SetIgnoreIndexes",
    "Tamper Detected!",
    "WeaponChamsColor",
    "AB_FovFillColor",
    "AddLeftGroupbox",
    "CorpseESP_Color",
    "ESP_DistOutline",
    "ESP_NameOutline",
    "ESP_WeapOutline",
    "HitboxTeamCheck",
    "OreESP_TextSize",
    "VehicleESP_Boat",
    "0FMLDTJWnCt9no",
    "0h2QVwv8BX53Bv",
    "26eWf4MftOCfu0",
    "2ZjjgaOZkXrYfW",
    "3OZXTHZZIpUOUR",
    "3ympPdlnH1RmpL",
    "3znOgKBLPyRyC9",
    "4Cv8pLwXSbIYe0",
    "4cX072LvMSRsrC",
    "4lm3Jicn9Q1Q4u",
    "6jnFh2yNsZf5A7",
    "6wTC35SPevP6W3",
    "7KBgDwGwRFj0kM",
    "7uVEL8agDfWC24",
    "8X4b8ibBisSzJQ",
    "9Fhm7Qcj5AtJBk",
    "9YjspxSsVz2CD4",
    "A2k3K8ZgFTgJyF",
    "A7WtSjVaCjHoKm",
    "AJuKatjCdGmneY",
    "AddColorPicker",
    "AddRightTabbox",
    "B1NBtBpCOJl3b3",
    "BQmEXF7mPhzl2S",
    "BrWq8e8u5taGVB",
    "CorpseESP_Dist",
    "Dib2zZa5zfboxm",
    "DkAtUa89M5hB8k",
    "EIYG6G0B5ntNsb",
    "EO33LL6SBRrlLr",
    "ESP_BoxOutline",
    "ESP_RenderDist",
    "ESP_SleepCheck",
    "ESP_UpdateRate",
    "FindFirstChild",
    "GetDescendants",
    "H0eawOQnWjEDm1",
    "HI6OXo9WJFXqzj",
    "HIVMmNLEMJJpmd",
    "ICEpyAOTzT0qep",
    "IJ4GQXnYo6AWyv",
    "IsDescendantOf",
    "JP0Sjcl4ZTk0Ak",
    "JSTDy8jvHIHwMW",
    "Jbfx3Ww9yd7O4y",
    "LDYa3AKD4eRS9Z",
    "LootC_Crafting",
    "LootESP_Master",
    "LootT_Crafting",
    "MDbgWs1MXAimfm",
    "McBgsrVA5oSfO1",
    "MiK0QCm0lhYrkM",
    "MovmrBk0qSW96K",
    "MwPIr3FzUSwsON",
    "NgOYj48vxrMthy",
    "NqlsTjEpRcn0R3",
    "O5FQdMufbPkaHX",
    "OdztO7tTd4Kasa",
    "OreESP_MaxDist",
    "OreESP_Nitrate",
    "PxNPOOp8rAe1dF",
    "QIqnmBAKP7dPCz",
    "QJdv62FbUySdCa",
    "R8peEPVnYmaaSs",
    "ROWvzmCvXDp8Tx",
    "RevGVrmgZ3ftOM",
    "Ryiz6WIp6aVb8y",
    "S5UFWoz5uVsxdV",
    "SDA0oZ5LsqyslX",
    "SG3fEvjXtxh0sc",
    "Sj1PIPkTa3RfOk",
    "SqmCWNBaCXd7gw",
    "Ufs0i45FLjYPnJ",
    "Ul6IAPMxdJHlv1",
    "VKYJ9A5au7aX0r",
    "VehicleESP_ATV",
    "Vf3sqEuv6rc4hZ",
    "VlIWVcPEfGtQwE",
    "W5CftNFF4tt5YG",
    "Wc3TJVZQxWL3Vp",
    "WeaponChamsMat",
    "WhQQgADGxfTG6l",
    "XHlGLChJYhzTiw",
    "XPGJzCalYzDTxo",
    "XzjyfrzSwJVV48",
    "YHSTl6swjPJw4R",
    "YZroeo5aw0ixaN",
    "YoRFrJYUkAqZ0A",
    "Z6DmDjT8pkPsIw",
    "ZJ24wEtNV7PnMN",
    "aWJETbUdgJ5uKy",
    "bljxTpQRs8UaWF",
    "cLglm4u9vO6Co5",
    "cOGam4FH6zhR2l",
    "d43Zw0sTrF2MnQ",
    "dW4VmLIfS6Y3jq",
    "f9SYyuMH6A8NCN",
    "fdB4vxYMjR2egK",
    "ffYZBqtdGVLzvO",
    "fzNsC4LBeFZWhi",
    "gla62DOCEjyUZl",
    "hRjwHPOOrkFbXw",
    "hkVHV9dPucbT9k",
    "hnsTHi6f3EAtTE",
    "hvzcc0XQIp13BG",
    "hwvSqMc6LFxAzW",
    "iAl6AY1S6UhDtw",
    "j10LLeqmFAsCEQ",
    "j8reZuveVwslIh",
    "kzjDbPl4Ef8w6M",
    "nKRL2tWERhF8zP",
    "nRiuqnMSdEZAxe",
    "nSQB1mipY4GNtS",
    "nbpYSAOI81leKr",
    "oj6kLWPYQX76DV",
    "p3gQFlX3l6gmnW",
    "pffTDKpzrQOIMU",
    "puYPQ8lzXE3qp4",
    "qBBsTMxOQQboQv",
    "raobBew22bcrzH",
    "sTt6cDXSF0rMew",
    "sak6NgcnTHKcjh",
    "snGEO0DipoiZ3C",
    "t1DocNee0gfmY7",
    "tlqXWYCqM092Vw",
    "uPFpZTyUUxctyd",
    "ucWlV4trDLezyh",
    "uik2Eb1tReuFxt",
    "vJaShIGVyLPptI",
    "w30XBls6THHozs",
    "w7IXTOJEQrd4JB",
    "wDJDnQbdFLVfOB",
    "xkMuMVJIYqEpAm",
    "xnMhxyTPDMkLEh",
    "xxCdu6YvUPh1Dq",
    "xyakOj8Efztly3",
    "yvR40kXiNUTjtE",
    "zOZZPyZUb6IWgR",
    "zpLsXh5sarus8h",
    "0Zox0wYgE1Xdg",
    "0jA0zX04khJmM",
    "1bmKjbgRKEFb2",
    "2kzfUZ3aIjRBp",
    "3cB5HWN3MqwxP",
    "3kWYfPjDy15Lh",
    "3wsO3W9LUiy7j",
    "4NUaAYTVGU3Yn",
    "4mqicwMbCfC4O",
    "5bpOO1dTxpSZS",
    "7D4IZjuDztVi4",
    "7gtmiOwIyouxq",
    "858LVjuxYNofn",
    "86tEqS9c8rQpL",
    "93K0Ic6nOFPwu",
    "9hFzqQrW61xsl",
    "9nmU6YGWxVOUD",
    "9nvnyVmESimcq",
    "AA77j3boomaL9",
    "AAU3uAUHQdQPn",
    "AddLeftTabbox",
    "AntiRecoilKey",
    "ArmChamsColor",
    "B4iMpMnewDaCn",
    "Bp1GRr8NbamoK",
    "BulletTracers",
    "CONTAINER ESP",
    "ColorSequence",
    "E95pRaE9kTjE9",
    "ESP_ArrowDist",
    "ESP_ArrowSize",
    "ESP_TeamCheck",
    "FHMr5gZ0vuPvv",
    "FPFnYtfOm9Ivn",
    "FsbuEWUYaXKXW",
    "FwwerI3IPhsvl",
    "Fy6Pu67jhgUxL",
    "H0cWRBl3nZHhp",
    "HIiQc4Bgb8vsX",
    "HP1GWuRqlsWWz",
    "HitboxAICheck",
    "HitboxCollide",
    "HxgTWVlZVtyDv",
    "IDNsgqrYZ6g5C",
    "ISG5IUO5eFYgn",
    "IU4PaC2HkpUCw",
    "Ixq8dYiTotmDn",
    "K45i3WRk20PU7",
    "Ko4HSu0HntImQ",
    "KpefFN2pKbOsQ",
    "KrKuDxZcQRQCF",
    "L9Bm0DpoHfk0d",
    "LLS27nWFt22cF",
    "LProfz0k60C4b",
    "LUoViEt87tOzy",
    "LkldGIgUhDHch",
    "M0179jLZkTX3g",
    "MGbRljIvseqVu",
    "MWX51rR08casZ",
    "NwyPor9VJnjX1",
    "O1hH5uyOjWTxn",
    "O4sNajgEUDtrz",
    "ODG2fHOqWW8Db",
    "ONNFQymA1Jj0b",
    "OQZmlyehbKpSu",
    "OreESP_Master",
    "OtNZiAxeZ7hlV",
    "PmSuwVMWsfrTD",
    "QlmejC0xdoeu2",
    "RuNmkMH2UJXqr",
    "SafeZoneColor",
    "SetNotifySide",
    "UJmDiWyVaeQOy",
    "UJywgCTHMKOYT",
    "VfPAvxoeFwmYd",
    "WENRRQGhNUKXz",
    "WFCjmWB6EjyeJ",
    "WYgqmMhOm2vql",
    "XcvAJklzD4FtM",
    "XlGDkWfvX1r9j",
    "YtO8kEVTUchXW",
    "Yxq0fYkdexG5d",
    "Z4LsPUvH7W3hw",
    "ar1GTY5zwSrcz",
    "bHbdM2AMqclWv",
    "bSlm0wl9AfkWP",
    "bbEovFvJPZuqJ",
    "bq2UwJg3tAEaB",
    "cLCzApVKhBuym",
    "cqyTAEKHKGyx4",
    "d1qOojlto85yY",
    "dBHilwG3kTYl2",
    "dlz5zfaTucgQf",
    "dxYEQKOED51Lz",
    "e4qIPE6cI4XJa",
    "en8vb2nxmBdmL",
    "ewVEtPsgnzOGR",
    "fM1dbtfsaB6BN",
    "fP1tGziX7WNex",
    "fVldmgYoiraZP",
    "gLw2o0tu4ygBr",
    "ggaLC3qjudNdN",
    "hIOI6Cg4ffmJI",
    "hcnjyA6IPMJrq",
    "hffIX73d1MVRE",
    "hwGUhir2susHV",
    "iRXXfVSInNspt",
    "jOEY3JrRl57fz",
    "jOHod23zO6lgU",
    "jtQrLfsPK0ZOF",
    "k1QgtZn7e1fM0",
    "kKjlvlV0PCknb",
    "lKlYRL9Db5EYT",
    "lS1oQSLOq682v",
    "loYjhQxQyifht",
    "mRsEUaJXPdJUn",
    "o43sfbo3yEGod",
    "oS7C9DxKZxbHC",
    "olQSb44pQdy8B",
    "pqObgsAcUB0d5",
    "q2RfJJwExQKrW",
    "qQnvaqYoY1iEk",
    "qRMfUx1P1CS85",
    "sKQoiZTqzlTl9",
    "sKYGrdoGEdHzv",
    "spCIpY8KHBPEW",
    "t6pAmh9xzuCTl",
    "tVrc8EusBgGs4",
    "uueOwIDJR8Ejg",
    "vPZiEW6YtG7xV",
    "weFI3X0afz7vm",
    "wrPuuI4lVSCXX",
    "x9RGeaxcPI7Na",
    "yXlgWrYTMS6b6",
    "yeyUb3y4TT1lr",
    "zYAK1K3W0pUeT",
    "zt59xE3elJSPV",
    "0zlhJqMXpero",
    "10L9G9M5tFPF",
    "284sxJn8EPFL",
    "2CJou9e1RxMt",
    "2FSH2hQ1yovQ",
    "2cDqzJScUB96",
    "3JYb89UQx6QB",
    "3s1tDRv8d4y9",
    "4IUWNPcovsKW",
    "56kbEErdej4O",
    "5LSJwcEuQyEX",
    "5MuktTNckr4i",
    "5hengk7WIXUv",
    "5y30BAtlDKgQ",
    "6aDiLGTlIYRy",
    "77ZG9XrDxhnB",
    "8Im305vHmef2",
    "AUy8DGz0ggFf",
    "AZDqt4xjgoWY",
    "AddKeyPicker",
    "BSdQCxu0Dysw",
    "BUql7pBGsJF7",
    "BdrB9awhUjam",
    "BfogBAJJmgjC",
    "CG3nMvQQfFGV",
    "CqS7HhcdqaVw",
    "CreateWindow",
    "CzkiJpYqOzf9",
    "D0cCBZQTB4jE",
    "DMR2fkIoGh1j",
    "DaASDuRqQvK6",
    "DkFuQAWE3MIA",
    "DlWtuvUvWOrz",
    "E07dLRvge3Kn",
    "E0St52kdHqIR",
    "EOkr4zVMPtDR",
    "ESP SETTINGS",
    "ESP_TextSize",
    "EjBoAMhocRyZ",
    "EnableTracer",
    "EnableWeapon",
    "FJiegCDh2iCS",
    "FakeGammaKey",
    "FreecamSpeed",
    "G9lnYHzeiOUf",
    "GO6Kw5ja3aXx",
    "GlmODFZuZtca",
    "GnHag6Gy93Bs",
    "HitboxEnable",
    "HitboxTransp",
    "I4L1NOkuUlWD",
    "IVR0gIdjByME",
    "IaSFi8bK6znv",
    "IrB2VplhAt3z",
    "IuQaiZ2ZybIt",
    "J79iDS3F6oCm",
    "JRfG0byDyxRV",
    "Jn9juyJnt3jq",
    "K3qad1hNYrrb",
    "KYk1QE3QAfAn",
    "KkoRMpCmEPNf",
    "KwXbnoxx0BoI",
    "L4IeSU6v34YS",
    "LZV1JaISR68w",
    "LootC_Bucket",
    "LootT_Bucket",
    "LootTextSize",
    "MCK984SSQ7wk",
    "MWwu6jEzII4E",
    "MiBuwCEcNkQt"
}

-- ===================== Secao 2: menu =====================
local Menu = {
    "[] Window | AV?X | flag= | default=nil",
    "[] Tab | COMBAT | flag= | default=nil",
    "[COMBAT] Tab | ESP | flag= | default=nil",
    "[COMBAT > ESP] Tab | VISUALS | flag= | default=nil",
    "[COMBAT > ESP > VISUALS] Tab | UI SETTINGS | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS] LeftGroupbox | HITBOX | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Toggle | HitboxEnable | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] ColorPicker | HitboxColor | flag= | default=trace_16",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Slider | HitboxSizeX | flag= | default=5",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Slider | HitboxSizeY | flag= | default=5",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Slider | HitboxSizeZ | flag= | default=5",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Slider | HitboxTransp | flag= | default=0.5",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Toggle | HitboxCollide | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Toggle | HitboxAICheck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Toggle | HitboxSleeperCheck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] Toggle | HitboxTeamCheck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX] LeftGroupbox | MACRO | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO] Toggle | AntiRecoil | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO] KeyPicker | AntiRecoilKey | flag= | default=None",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO] Slider | AntiRecoilStrength | flag= | default=1",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO] RightGroupbox | AIMBOT | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Toggle | AB_Enable | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Toggle | AB_Pred | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Toggle | AB_Sleep | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Toggle | AB_AI | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Toggle | AB_Team | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Toggle | AB_Fov | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] ColorPicker | AB_FovColor | flag= | default=trace_4234",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Toggle | AB_FovFill | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] ColorPicker | AB_FovFillColor | flag= | default=trace_4235",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Slider | AB_FovFillTransp | flag= | default=0.3",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Slider | AB_FovSize | flag= | default=150",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Slider | AB_Smooth | flag= | default=2",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] Slider | AB_Radius | flag= | default=1000",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT] RightGroupbox | OTHER | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] Toggle | JumpShoot | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] KeyPicker | JsKey | flag= | default=None",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] Toggle | LongNeck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] KeyPicker | LongNeckKey | flag= | default=None",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] Slider | LongNeckStrength | flag= | default=5",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] Toggle | ArmorCheck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] Slider | ArmorCheckRadius | flag= | default=1000",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] LeftTabbox |  | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER] Tab | PLAYERS ESP | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP] Tab | ESP SETTINGS | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableEsp | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_SleepCheck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_AICheck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_TeamCheck | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableBox | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | BoxColor | flag= | default=trace_4296",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Dropdown | BoxType | flag= | default=1",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | BoxFill | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | FillColor1 | flag= | default=trace_4297",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | FillColor2 | flag= | default=trace_4298",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Slider | FillTransp | flag= | default=0.75",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableName | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | NameColor | flag= | default=trace_4299",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableDist | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | DistColor | flag= | default=trace_4300",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableChams | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ChamsColor | flag= | default=trace_4301",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableWeapon | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | WeapColor | flag= | default=trace_4302",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableTracer | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | TracerColor | flag= | default=trace_4303",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | EnableArrow | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ArrowColor | flag= | default=trace_4304",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Slider | ESP_TextSize | flag= | default=13",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Slider | ESP_UpdateRate | flag= | default=60",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_BoxOutline | flag= | default=true",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ESP_BoxOutlineColor | flag= | default=trace_4305",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_NameOutline | flag= | default=true",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ESP_NameOutlineColor | flag= | default=trace_4306",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_DistOutline | flag= | default=true",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ESP_DistOutlineColor | flag= | default=trace_4307",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_WeapOutline | flag= | default=true",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ESP_WeapOutlineColor | flag= | default=trace_4308",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Slider | ESP_RenderDist | flag= | default=1000",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_TracerOutline | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ESP_TracerOutlineColor | flag= | default=trace_4309",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Dropdown | TracerOrigin | flag= | default=1",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Toggle | ESP_ArrowOutline | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] ColorPicker | ESP_ArrowOutlineColor | flag= | default=trace_4310",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Slider | ESP_ArrowDist | flag= | default=80",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Slider | ESP_ArrowSize | flag= | default=16",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] RightTabbox |  | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS] Tab | CONTAINER ESP | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP] Tab | ORE ESP | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootESP_Master | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Slider | LootMaxDist | flag= | default=750",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Slider | LootTextSize | flag= | default=10",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Divider |  | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootT_Bucket | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | LootC_Bucket | flag= | default=trace_4311",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootT_Box | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | LootC_Box | flag= | default=trace_4312",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootT_Chest | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | LootC_Chest | flag= | default=trace_4313",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootT_Crafting | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | LootC_Crafting | flag= | default=trace_4314",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootT_Crate | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | LootC_Crate | flag= | default=trace_4315",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootT_Vault | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | LootC_Vault | flag= | default=trace_4316",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | LootT_Gas | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | LootC_Gas | flag= | default=trace_4317",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | OreESP_Master | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Slider | OreESP_MaxDist | flag= | default=750",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Slider | OreESP_TextSize | flag= | default=10",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Divider |  | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | OreESP_Stone | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | OreESP_StoneColor | flag= | default=trace_4347",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | OreESP_Iron | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | OreESP_IronColor | flag= | default=trace_4348",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Toggle | OreESP_Nitrate | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] ColorPicker | OreESP_NitrateColor | flag= | default=trace_4349",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] RightTabbox |  | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP] Tab | VEHICLE ESP | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP] Tab | CORPSE ESP | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Toggle | VehicleESP_Master | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Slider | VehicleESP_Radius | flag= | default=750",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Slider | VehicleESP_TextSize | flag= | default=14",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Divider |  | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Toggle | VehicleESP_ATV | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] ColorPicker | VehicleESP_Color_ATV | flag= | default=trace_4364",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Toggle | VehicleESP_Boat | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] ColorPicker | VehicleESP_Color_Boat | flag= | default=trace_4365",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Toggle | VehicleESP_Helicopter | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] ColorPicker | VehicleESP_Color_Helicopter | flag= | default=trace_4366",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Toggle | VehicleESP_Trolly | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] ColorPicker | VehicleESP_Color_Trolly | flag= | default=trace_4367",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Toggle | CorpseESP_Enable | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] ColorPicker | CorpseESP_Color | flag= | default=trace_4394",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Slider | CorpseESP_Dist | flag= | default=750",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] Slider | CorpseESP_TextSize | flag= | default=10",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP] LeftGroupbox | WORLD | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD] LeftGroupbox | ZONE CHARMS | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS] RightGroupbox | CHAMS | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS] RightGroupbox | OTHER | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | FakeGamma | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] KeyPicker | FakeGammaKey | flag= | default=None",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Slider | GammaVal | flag= | default=0.5",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | Xray | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] KeyPicker | XrayKey | flag= | default=None",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Slider | XrayTransp | flag= | default=0.5",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | Freecam | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] KeyPicker | FreecamKey | flag= | default=None",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Slider | FreecamSpeed | flag= | default=150",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Label | Move  ? ? ? ? | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | SafeZone | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] ColorPicker | SafeZoneColor | flag= | default=trace_4410",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | NoBuildZone | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] ColorPicker | NoBuildColor | flag= | default=trace_4411",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | WeaponChams | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] ColorPicker | WeaponChamsColor | flag= | default=trace_4419",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Dropdown | WeaponChamsMat | flag= | default=ForceField",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Divider |  | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | ArmChams | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] ColorPicker | ArmChamsColor | flag= | default=trace_4420",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Dropdown | ArmChamsMat | flag= | default=ForceField",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Toggle | BulletTracers | flag= | default=nil",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] ColorPicker | BulletTracerColor | flag= | default=trace_4424",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Slider | BulletTracerThick | flag= | default=0.1",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] Slider | BulletTracerLife | flag= | default=2",
    "[COMBAT > ESP > VISUALS > UI SETTINGS > HITBOX > MACRO > AIMBOT > OTHER > PLAYERS ESP > ESP SETTINGS > CONTAINER ESP > ORE ESP > VEHICLE ESP > CORPSE ESP > WORLD > ZONE CHARMS > CHAMS > OTHER] LeftGroupbox | UI Settings | flag= | default=nil"
}

-- ===================== Secao 3: trace reconstruido =====================
-- operacoes observadas, na ordem real de execucao
game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua")
game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua")
game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
game:GetService("Debris")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Color3.fromRGB(0, 0, 255)
workspace.ChildAdded:Connect(function(...)
    local callback1_arg1, callback1_arg2, callback1_arg3, callback1_arg4 = ...
end)
workspace.ChildRemoved:Connect(function(...)
    local callback2_arg1, callback2_arg2, callback2_arg3, callback2_arg4 = ...
end)
Players.LocalPlayer.CharacterAdded:Connect(function(...)
    local callback3_arg1, callback3_arg2, callback3_arg3, callback3_arg4 = ...
    task.delay(0.10000000000000001, function(...)
        local callback4_arg1, callback4_arg2, callback4_arg3, callback4_arg4 = ...
    end)
end)
Color3.fromRGB(0, 0, 255)
RunService.RenderStepped:Connect(function(...)
    local callback5_arg1, callback5_arg2, callback5_arg3, callback5_arg4 = ...
end)
local result = Color3.fromRGB(0, 0, 255)
local result2 = Color3.fromRGB(0, 0, 255)
local new2 = Drawing.new("Circle")
local new3 = Drawing.new("Circle")
new2.Thickness = 1
new2.NumSides = 64
new2.Radius = 150
new2.Filled = false
new2.Visible = false
new2.Transparency = 1
new2.Color = result
new2.ZIndex = 999
new3.Thickness = 0
new3.NumSides = 64
new3.Radius = 150
new3.Filled = true
new3.Visible = false
new3.Transparency = 0.29999999999999999
new3.Color = result2
new3.ZIndex = 998
local vector2 = Vector2.new((workspace.CurrentCamera.ViewportSize.X/2), (workspace.CurrentCamera.ViewportSize.Y/2))
new2.Position = vector2
new3.Position = vector2
local getPropertyChangedSignal = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize")
getPropertyChangedSignal:Connect(function(...)
    local callback6_arg1, callback6_arg2, callback6_arg3, callback6_arg4 = ...
    local vector22 = Vector2.new((workspace.CurrentCamera.ViewportSize.X/2), (workspace.CurrentCamera.ViewportSize.Y/2))
    new2.Position = vector22
    new3.Position = vector22
end)
task.spawn(function(...)
    local callback7_arg1, callback7_arg2, callback7_arg3, callback7_arg4 = ...
    task.wait(0.20000000000000001)
    local Const = workspace:FindFirstChild("Const")
    local Ignore = Const:FindFirstChild("Ignore")
    local FPSArms = Ignore:FindFirstChild("FPSArms")
    local HandModel = FPSArms:FindFirstChild("HandModel")
    HandModel:FindFirstChild("DefaultSight", true)
    HandModel:FindFirstChild("Barrel", true)
    HandModel:FindFirstChild("Body", true)
    HandModel:FindFirstChild("ChargingHandle", true)
    HandModel:FindFirstChild("Decals", true)
    HandModel:FindFirstChild("Mag", true)
    HandModel:FindFirstChild("Rails", true)
    HandModel:FindFirstChild("ShoulderPad", true)
    HandModel:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const2 = workspace:FindFirstChild("Const")
    local Ignore2 = Const2:FindFirstChild("Ignore")
    local FPSArms2 = Ignore2:FindFirstChild("FPSArms")
    local HandModel2 = FPSArms2:FindFirstChild("HandModel")
    HandModel2:FindFirstChild("DefaultSight", true)
    HandModel2:FindFirstChild("Barrel", true)
    HandModel2:FindFirstChild("Body", true)
    HandModel2:FindFirstChild("ChargingHandle", true)
    HandModel2:FindFirstChild("Decals", true)
    HandModel2:FindFirstChild("Mag", true)
    HandModel2:FindFirstChild("Rails", true)
    HandModel2:FindFirstChild("ShoulderPad", true)
    HandModel2:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const3 = workspace:FindFirstChild("Const")
    local Ignore3 = Const3:FindFirstChild("Ignore")
    local FPSArms3 = Ignore3:FindFirstChild("FPSArms")
    local HandModel3 = FPSArms3:FindFirstChild("HandModel")
    HandModel3:FindFirstChild("DefaultSight", true)
    HandModel3:FindFirstChild("Barrel", true)
    HandModel3:FindFirstChild("Body", true)
    HandModel3:FindFirstChild("ChargingHandle", true)
    HandModel3:FindFirstChild("Decals", true)
    HandModel3:FindFirstChild("Mag", true)
    HandModel3:FindFirstChild("Rails", true)
    HandModel3:FindFirstChild("ShoulderPad", true)
    HandModel3:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const4 = workspace:FindFirstChild("Const")
    local Ignore4 = Const4:FindFirstChild("Ignore")
    local FPSArms4 = Ignore4:FindFirstChild("FPSArms")
    local HandModel4 = FPSArms4:FindFirstChild("HandModel")
    HandModel4:FindFirstChild("DefaultSight", true)
    HandModel4:FindFirstChild("Barrel", true)
    HandModel4:FindFirstChild("Body", true)
    HandModel4:FindFirstChild("ChargingHandle", true)
    HandModel4:FindFirstChild("Decals", true)
    HandModel4:FindFirstChild("Mag", true)
    HandModel4:FindFirstChild("Rails", true)
    HandModel4:FindFirstChild("ShoulderPad", true)
    HandModel4:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const5 = workspace:FindFirstChild("Const")
    local Ignore5 = Const5:FindFirstChild("Ignore")
    local FPSArms5 = Ignore5:FindFirstChild("FPSArms")
    local HandModel5 = FPSArms5:FindFirstChild("HandModel")
    HandModel5:FindFirstChild("DefaultSight", true)
    HandModel5:FindFirstChild("Barrel", true)
    HandModel5:FindFirstChild("Body", true)
    HandModel5:FindFirstChild("ChargingHandle", true)
    HandModel5:FindFirstChild("Decals", true)
    HandModel5:FindFirstChild("Mag", true)
    HandModel5:FindFirstChild("Rails", true)
    HandModel5:FindFirstChild("ShoulderPad", true)
    HandModel5:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const6 = workspace:FindFirstChild("Const")
    local Ignore6 = Const6:FindFirstChild("Ignore")
    local FPSArms6 = Ignore6:FindFirstChild("FPSArms")
    local HandModel6 = FPSArms6:FindFirstChild("HandModel")
    HandModel6:FindFirstChild("DefaultSight", true)
    HandModel6:FindFirstChild("Barrel", true)
    HandModel6:FindFirstChild("Body", true)
    HandModel6:FindFirstChild("ChargingHandle", true)
    HandModel6:FindFirstChild("Decals", true)
    HandModel6:FindFirstChild("Mag", true)
    HandModel6:FindFirstChild("Rails", true)
    HandModel6:FindFirstChild("ShoulderPad", true)
    HandModel6:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const7 = workspace:FindFirstChild("Const")
    local Ignore7 = Const7:FindFirstChild("Ignore")
    local FPSArms7 = Ignore7:FindFirstChild("FPSArms")
    local HandModel7 = FPSArms7:FindFirstChild("HandModel")
    HandModel7:FindFirstChild("DefaultSight", true)
    HandModel7:FindFirstChild("Barrel", true)
    HandModel7:FindFirstChild("Body", true)
    HandModel7:FindFirstChild("ChargingHandle", true)
    HandModel7:FindFirstChild("Decals", true)
    HandModel7:FindFirstChild("Mag", true)
    HandModel7:FindFirstChild("Rails", true)
    HandModel7:FindFirstChild("ShoulderPad", true)
    HandModel7:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const8 = workspace:FindFirstChild("Const")
    local Ignore8 = Const8:FindFirstChild("Ignore")
    local FPSArms8 = Ignore8:FindFirstChild("FPSArms")
    local HandModel8 = FPSArms8:FindFirstChild("HandModel")
    HandModel8:FindFirstChild("DefaultSight", true)
    HandModel8:FindFirstChild("Barrel", true)
    HandModel8:FindFirstChild("Body", true)
    HandModel8:FindFirstChild("ChargingHandle", true)
    HandModel8:FindFirstChild("Decals", true)
    HandModel8:FindFirstChild("Mag", true)
    HandModel8:FindFirstChild("Rails", true)
    HandModel8:FindFirstChild("ShoulderPad", true)
    HandModel8:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const9 = workspace:FindFirstChild("Const")
    local Ignore9 = Const9:FindFirstChild("Ignore")
    local FPSArms9 = Ignore9:FindFirstChild("FPSArms")
    local HandModel9 = FPSArms9:FindFirstChild("HandModel")
    HandModel9:FindFirstChild("DefaultSight", true)
    HandModel9:FindFirstChild("Barrel", true)
    HandModel9:FindFirstChild("Body", true)
    HandModel9:FindFirstChild("ChargingHandle", true)
    HandModel9:FindFirstChild("Decals", true)
    HandModel9:FindFirstChild("Mag", true)
    HandModel9:FindFirstChild("Rails", true)
    HandModel9:FindFirstChild("ShoulderPad", true)
    HandModel9:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const10 = workspace:FindFirstChild("Const")
    local Ignore10 = Const10:FindFirstChild("Ignore")
    local FPSArms10 = Ignore10:FindFirstChild("FPSArms")
    local HandModel10 = FPSArms10:FindFirstChild("HandModel")
    HandModel10:FindFirstChild("DefaultSight", true)
    HandModel10:FindFirstChild("Barrel", true)
    HandModel10:FindFirstChild("Body", true)
    HandModel10:FindFirstChild("ChargingHandle", true)
    HandModel10:FindFirstChild("Decals", true)
    HandModel10:FindFirstChild("Mag", true)
    HandModel10:FindFirstChild("Rails", true)
    HandModel10:FindFirstChild("ShoulderPad", true)
    HandModel10:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
end)
workspace:GetChildren()
workspace.ChildAdded:Connect(function(...)
    local callback8_arg1, callback8_arg2, callback8_arg3, callback8_arg4 = ...
    callback8_arg1:IsA("Model")
    callback8_arg1:FindFirstChild("HumanoidRootPart")
end)
workspace.ChildRemoved:Connect(function(...)
    local callback9_arg1, callback9_arg2, callback9_arg3, callback9_arg4 = ...
end)
RunService.RenderStepped:Connect(function(...)
    local callback10_arg1, callback10_arg2, callback10_arg3, callback10_arg4 = ...
    new2.Visible = false
    new3.Visible = false
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Vector2.new(20, ((workspace.CurrentCamera.ViewportSize.Y/2)-60))
UserInputService.InputBegan:Connect(function(...)
    local callback11_arg1, callback11_arg2, callback11_arg3, callback11_arg4 = ...
end)
UserInputService.InputEnded:Connect(function(...)
    local callback12_arg1, callback12_arg2, callback12_arg3, callback12_arg4 = ...
end)
UserInputService.InputChanged:Connect(function(...)
    local callback13_arg1, callback13_arg2, callback13_arg3, callback13_arg4 = ...
end)
workspace:GetChildren()
trace_180_v1:IsA("Model")
trace_180_v1:FindFirstChild("HumanoidRootPart")
workspace.ChildAdded:Connect(function(...)
    local callback14_arg1, callback14_arg2, callback14_arg3, callback14_arg4 = ...
    task.wait(0.10000000000000001)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback15_arg1, callback15_arg2, callback15_arg3, callback15_arg4 = ...
end)
RunService.RenderStepped:Connect(function(...)
    local callback16_arg1, callback16_arg2, callback16_arg3, callback16_arg4 = ...
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
local result3 = Color3.fromRGB(0, 0, 255)
local result4 = Color3.fromRGB(0, 0, 80)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPHolder"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Parent = PlayerGui
Players.LocalPlayer.CharacterAdded:Connect(function(...)
    local callback17_arg1, callback17_arg2, callback17_arg3, callback17_arg4 = ...
    task.wait(0.5)
end)
Vector2.new(0, 0)
Vector2.new(0, 0)
Vector2.new(1, 0)
Vector2.new(1, 0)
Vector2.new(0, 1)
Vector2.new(0, 1)
Vector2.new(1, 1)
Vector2.new(1, 1)
workspace:GetChildren()
trace_214_v1:IsA("Model")
trace_214_v1:FindFirstChild("HumanoidRootPart")
task.spawn(function(...)
    local callback18_arg1, callback18_arg2, callback18_arg3, callback18_arg4 = ...
    task.wait(0.10000000000000001)
end)
workspace.DescendantAdded:Connect(function(...)
    local callback19_arg1, callback19_arg2, callback19_arg3, callback19_arg4 = ...
    callback19_arg1:IsA("Model")
    callback19_arg1:IsA("Model")
    callback19_arg1:FindFirstChild("HumanoidRootPart")
    task.wait(0.10000000000000001)
end)
workspace.DescendantRemoving:Connect(function(...)
    local callback20_arg1, callback20_arg2, callback20_arg3, callback20_arg4 = ...
    callback20_arg1:IsA("Model")
end)
task.spawn(function(...)
    local callback21_arg1, callback21_arg2, callback21_arg3, callback21_arg4 = ...
    task.wait(15)
end)
Vector3.new(0, 2.7999999999999998, 0)
Vector3.new(0, 3, 0)
local new4 = ColorSequenceKeypoint.new(0, result3)
local new5 = ColorSequenceKeypoint.new(1, result4)
ColorSequence.new({[1] = new4, [2] = new5})
RunService.Heartbeat:Connect(function(...)
    local callback22_arg1, callback22_arg2, callback22_arg3, callback22_arg4 = ...
    tick()
end)
RunService.Heartbeat:Connect(function(...)
    local callback23_arg1, callback23_arg2, callback23_arg3, callback23_arg4 = ...
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 100)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(255, 165, 0)
local result5 = Color3.fromRGB(230, 182, 0)
Color3.fromRGB(150, 150, 150)
Color3.fromRGB(255, 0, 207)
Color3.fromRGB(44, 97, 0)
Color3.fromRGB(100, 100, 100)
Color3.fromRGB(200, 0, 0)
workspace:GetChildren()
task.spawn(function(...)
    local callback24_arg1, callback24_arg2, callback24_arg3, callback24_arg4 = ...
    callback24_arg1:IsA("Model")
    callback24_arg1:FindFirstChild("default")
    callback24_arg1:GetChildren()
    trace_262_v1:IsA("BasePart")
    local box = callback24_arg1:FindFirstChild("box")
    local trash = callback24_arg1:FindFirstChild("trash")
    box:IsA("MeshPart")
    trash:IsA("MeshPart")
    callback24_arg1:FindFirstChildWhichIsA("BasePart")
    local new6 = Drawing.new("Text")
    new6.Text = "DefaultBox"
    new6.Size = 10
    new6.Center = true
    new6.Font = 2
    new6.Outline = true
    local color3 = Color3.new(0, 0, 0)
    new6.OutlineColor = color3
    new6.Color = result5
    new6.Visible = false
    callback24_arg1.AncestryChanged:Connect(function(...)
        local callback25_arg1, callback25_arg2, callback25_arg3, callback25_arg4 = ...
    end)
end, trace_258_v1)
workspace.ChildAdded:Connect(function(...)
    local callback26_arg1, callback26_arg2, callback26_arg3, callback26_arg4 = ...
    task.spawn(function(...)
        local callback27_arg1, callback27_arg2, callback27_arg3, callback27_arg4 = ...
        callback27_arg1:IsA("Model")
        callback27_arg1:FindFirstChild("default")
        callback27_arg1:GetChildren()
        trace_276_v1:IsA("BasePart")
        local box2 = callback27_arg1:FindFirstChild("box")
        local trash2 = callback27_arg1:FindFirstChild("trash")
        box2:IsA("MeshPart")
        trash2:IsA("MeshPart")
        callback27_arg1:FindFirstChildWhichIsA("BasePart")
        local new7 = Drawing.new("Text")
        new7.Text = "DefaultBox"
        new7.Size = 10
        new7.Center = true
        new7.Font = 2
        new7.Outline = true
        local color32 = Color3.new(0, 0, 0)
        new7.OutlineColor = color32
        new7.Color = result5
        new7.Visible = false
        callback27_arg1.AncestryChanged:Connect(function(...)
            local callback28_arg1, callback28_arg2, callback28_arg3, callback28_arg4 = ...
        end)
    end, callback26_arg1)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback29_arg1, callback29_arg2, callback29_arg3, callback29_arg4 = ...
end)
Color3.fromRGB(120, 120, 120)
Color3.fromRGB(255, 215, 0)
Color3.fromRGB(200, 255, 200)
Color3.fromRGB(72, 72, 72)
Color3.fromRGB(199, 172, 120)
Color3.fromRGB(248, 248, 248)
task.spawn(function(...)
    local callback30_arg1, callback30_arg2, callback30_arg3, callback30_arg4 = ...
    workspace:GetChildren()
    trace_294_v1:IsA("Model")
    trace_294_v1:GetChildren()
    trace_296_v1:IsA("MeshPart")
end)
workspace.ChildAdded:Connect(function(...)
    local callback31_arg1, callback31_arg2, callback31_arg3, callback31_arg4 = ...
    callback31_arg1:IsA("Model")
    task.wait()
end)
workspace.ChildRemoved:Connect(function(...)
    local callback32_arg1, callback32_arg2, callback32_arg3, callback32_arg4 = ...
end)
task.spawn(function(...)
    local callback33_arg1, callback33_arg2, callback33_arg3, callback33_arg4 = ...
    task.wait(3)
end)
Color3.fromRGB(255, 100, 0)
Color3.fromRGB(0, 150, 255)
local result6 = Color3.fromRGB(0, 255, 0)
Color3.fromRGB(200, 200, 0)
task.spawn(function(...)
    local callback34_arg1, callback34_arg2, callback34_arg3, callback34_arg4 = ...
    workspace:GetChildren()
    trace_309_v1:IsA("Model")
    ReplicatedStorage.Shared.entities.vehicles.Helicopter.Model:GetChildren()
    trace_309_v1:FindFirstChild(trace_311_v1.Name)
    local new8 = Drawing.new("Text")
    new8.Text = "Helicopter"
    new8.Size = 14
    new8.Center = true
    new8.Font = 2
    new8.Outline = true
    local color33 = Color3.new(0, 0, 0)
    new8.OutlineColor = color33
    new8.Color = result6
    new8.Visible = false
    trace_309_v1.AncestryChanged:Connect(function(...)
        local callback35_arg1, callback35_arg2, callback35_arg3, callback35_arg4 = ...
    end)
end)
workspace.ChildAdded:Connect(function(...)
    local callback36_arg1, callback36_arg2, callback36_arg3, callback36_arg4 = ...
    callback36_arg1:IsA("Model")
    task.wait(0.10000000000000001)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback37_arg1, callback37_arg2, callback37_arg3, callback37_arg4 = ...
end)
task.spawn(function(...)
    local callback38_arg1, callback38_arg2, callback38_arg3, callback38_arg4 = ...
    task.wait(3)
end)
Color3.fromRGB(255, 0, 0)
task.spawn(function(...)
    local callback39_arg1, callback39_arg2, callback39_arg3, callback39_arg4 = ...
    workspace:GetChildren()
    trace_324_v1:IsA("Model")
    trace_324_v1:GetChildren()
    trace_326_v1:IsA("BasePart")
end)
workspace.ChildAdded:Connect(function(...)
    local callback40_arg1, callback40_arg2, callback40_arg3, callback40_arg4 = ...
    callback40_arg1:IsA("Model")
    task.wait(0.10000000000000001)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback41_arg1, callback41_arg2, callback41_arg3, callback41_arg4 = ...
end)
task.spawn(function(...)
    local callback42_arg1, callback42_arg2, callback42_arg3, callback42_arg4 = ...
    task.wait(5)
end)
Color3.fromRGB(255, 0, 0)
RunService.Heartbeat:Connect(function(...)
    local callback43_arg1, callback43_arg2, callback43_arg3, callback43_arg4 = ...
    tick()
end)
workspace:GetDescendants()
trace_337_v1:IsA("BasePart")
workspace.DescendantAdded:Connect(function(...)
    local callback44_arg1, callback44_arg2, callback44_arg3, callback44_arg4 = ...
    callback44_arg1:IsA("BasePart")
end)
workspace.DescendantRemoving:Connect(function(...)
    local callback45_arg1, callback45_arg2, callback45_arg3, callback45_arg4 = ...
end)
RunService.RenderStepped:Connect(function(...)
    local callback46_arg1, callback46_arg2, callback46_arg3, callback46_arg4 = ...
end)
local World = workspace:FindFirstChild("World")
local Zones = World:FindFirstChild("Zones")
Zones:FindFirstChild("SafeZones")
Zones.SafeZones:FindFirstChild("SAFEZONE_Town")
Color3.fromRGB(0, 255, 0)
Zones:FindFirstChild("NoBuildZones")
Color3.fromRGB(255, 0, 0)
Color3.fromRGB(0, 255, 0)
Color3.fromRGB(255, 0, 0)
Color3.new(0, 0, 1)
Color3.new(0, 0, 1)
a = {}
w = {}
ao = {}
wo = {}
local Const11 = workspace:FindFirstChild("Const")
local Ignore11 = Const11:FindFirstChild("Ignore")
local FPSArms11 = Ignore11:FindFirstChild("FPSArms")
FPSArms11.ChildAdded:Connect(function(...)
    local callback47_arg1, callback47_arg2, callback47_arg3, callback47_arg4 = ...
    task.wait(0.10000000000000001)
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
workspace.DescendantAdded:Connect(function(...)
    local callback48_arg1, callback48_arg2, callback48_arg3, callback48_arg4 = ...
    callback48_arg1:IsDescendantOf(ReplicatedStorage)
end)
Color3.fromRGB(0, 0, 255)
RunService.Heartbeat:Connect(function(...)
    local callback49_arg1, callback49_arg2, callback49_arg3, callback49_arg4 = ...
end)
task.spawn(function(...)
    local callback50_arg1, callback50_arg2, callback50_arg3, callback50_arg4 = ...
    task.wait(0.5)
end)
