# Inventario de funcoes e estruturas (AV0X)

Fonte: trace da VM (522 linhas reconstruidas) + instrumentacao das
chamadas de menu. Nomes originais de funcoes locais nao existem no payload: a VM os
renomeia para `v0..vN`, entao o inventario e por papel observado.

## Conexoes de evento observadas (37)

- `.AncestryChanged`
- `.ChildAdded`
- `Players.LocalPlayer.CharacterAdded`
- `RunService.Heartbeat`
- `RunService.RenderStepped`
- `UserInputService.InputBegan`
- `UserInputService.InputChanged`
- `UserInputService.InputEnded`
- `getPropertyChangedSignal`
- `workspace.ChildAdded`
- `workspace.ChildRemoved`
- `workspace.DescendantAdded`
- `workspace.DescendantRemoving`

## Servicos instanciados (7)

- `Debris`
- `Lighting`
- `Players`
- `ReplicatedStorage`
- `RunService`
- `Stats`
- `UserInputService`

## Desenho em tela (5 primitivas)

- `Drawing.new("Circle")`
- `Drawing.new("Text")`

## Cores literais recuperadas (22)

- `Color3.fromRGB(0, 0, 100)`
- `Color3.fromRGB(0, 0, 255)`
- `Color3.fromRGB(0, 0, 80)`
- `Color3.fromRGB(0, 150, 255)`
- `Color3.fromRGB(0, 255, 0)`
- `Color3.fromRGB(100, 100, 100)`
- `Color3.fromRGB(120, 120, 120)`
- `Color3.fromRGB(150, 150, 150)`
- `Color3.fromRGB(199, 172, 120)`
- `Color3.fromRGB(20, 20, 20)`
- `Color3.fromRGB(200, 0, 0)`
- `Color3.fromRGB(200, 200, 0)`
- `Color3.fromRGB(200, 255, 200)`
- `Color3.fromRGB(230, 182, 0)`
- `Color3.fromRGB(248, 248, 248)`
- `Color3.fromRGB(255, 0, 0)`
- `Color3.fromRGB(255, 0, 207)`
- `Color3.fromRGB(255, 100, 0)`
- `Color3.fromRGB(255, 165, 0)`
- `Color3.fromRGB(255, 215, 0)`
- `Color3.fromRGB(44, 97, 0)`
- `Color3.fromRGB(72, 72, 72)`

## Elementos de menu por tipo (166 no total)

- : 7
- OTHER: 2
- AV∅X: 1
- COMBAT: 1
- ESP: 1
- VISUALS: 1
- UI SETTINGS: 1
- HITBOX: 1
- HitboxEnable: 1
- HitboxColor: 1
- HitboxSizeX: 1
- HitboxSizeY: 1
- HitboxSizeZ: 1
- HitboxTransp: 1
- HitboxCollide: 1
- HitboxAICheck: 1
- HitboxSleeperCheck: 1
- HitboxTeamCheck: 1
- MACRO: 1
- AntiRecoil: 1
- AntiRecoilKey: 1
- AntiRecoilStrength: 1
- AIMBOT: 1
- AB_Enable: 1
- AB_Pred: 1
- AB_Sleep: 1
- AB_AI: 1
- AB_Team: 1
- AB_Fov: 1
- AB_FovColor: 1
- AB_FovFill: 1
- AB_FovFillColor: 1
- AB_FovFillTransp: 1
- AB_FovSize: 1
- AB_Smooth: 1
- AB_Radius: 1
- JumpShoot: 1
- JsKey: 1
- LongNeck: 1
- LongNeckKey: 1
- LongNeckStrength: 1
- ArmorCheck: 1
- ArmorCheckRadius: 1
- PLAYERS ESP: 1
- ESP SETTINGS: 1
- EnableEsp: 1
- ESP_SleepCheck: 1
- ESP_AICheck: 1
- ESP_TeamCheck: 1
- EnableBox: 1
- BoxColor: 1
- BoxType: 1
- BoxFill: 1
- FillColor1: 1
- FillColor2: 1
- FillTransp: 1
- EnableName: 1
- NameColor: 1
- EnableDist: 1
- DistColor: 1
- EnableChams: 1
- ChamsColor: 1
- EnableWeapon: 1
- WeapColor: 1
- EnableTracer: 1
- TracerColor: 1
- EnableArrow: 1
- ArrowColor: 1
- ESP_TextSize: 1
- ESP_UpdateRate: 1
- ESP_BoxOutline: 1
- ESP_BoxOutlineColor: 1
- ESP_NameOutline: 1
- ESP_NameOutlineColor: 1
- ESP_DistOutline: 1
- ESP_DistOutlineColor: 1
- ESP_WeapOutline: 1
- ESP_WeapOutlineColor: 1
- ESP_RenderDist: 1
- ESP_TracerOutline: 1
- ESP_TracerOutlineColor: 1
- TracerOrigin: 1
- ESP_ArrowOutline: 1
- ESP_ArrowOutlineColor: 1
- ESP_ArrowDist: 1
- ESP_ArrowSize: 1
- CONTAINER ESP: 1
- ORE ESP: 1
- LootESP_Master: 1
- LootMaxDist: 1
- LootTextSize: 1
- LootT_Bucket: 1
- LootC_Bucket: 1
- LootT_Box: 1
- LootC_Box: 1
- LootT_Chest: 1
- LootC_Chest: 1
- LootT_Crafting: 1
- LootC_Crafting: 1
- LootT_Crate: 1
- LootC_Crate: 1
- LootT_Vault: 1
- LootC_Vault: 1
- LootT_Gas: 1
- LootC_Gas: 1
- OreESP_Master: 1
- OreESP_MaxDist: 1
- OreESP_TextSize: 1
- OreESP_Stone: 1
- OreESP_StoneColor: 1
- OreESP_Iron: 1
- OreESP_IronColor: 1
- OreESP_Nitrate: 1
- OreESP_NitrateColor: 1
- VEHICLE ESP: 1
- CORPSE ESP: 1
- VehicleESP_Master: 1
- VehicleESP_Radius: 1
- VehicleESP_TextSize: 1
- VehicleESP_ATV: 1
- VehicleESP_Color_ATV: 1
- VehicleESP_Boat: 1
- VehicleESP_Color_Boat: 1
- VehicleESP_Helicopter: 1
- VehicleESP_Color_Helicopter: 1
- VehicleESP_Trolly: 1
- VehicleESP_Color_Trolly: 1
- CorpseESP_Enable: 1
- CorpseESP_Color: 1
- CorpseESP_Dist: 1
- CorpseESP_TextSize: 1
- WORLD: 1
- ZONE CHARMS: 1
- CHAMS: 1
- FakeGamma: 1
- FakeGammaKey: 1
- GammaVal: 1
- Xray: 1
- XrayKey: 1
- XrayTransp: 1
- Freecam: 1
- FreecamKey: 1
- FreecamSpeed: 1
- Move  ↑ ← ↓ →: 1
- SafeZone: 1
- SafeZoneColor: 1
- NoBuildZone: 1
- NoBuildColor: 1
- WeaponChams: 1
- WeaponChamsColor: 1
- WeaponChamsMat: 1
- ArmChams: 1
- ArmChamsColor: 1
- ArmChamsMat: 1
- BulletTracers: 1
- BulletTracerColor: 1
- BulletTracerThick: 1
- BulletTracerLife: 1
- UI Settings: 1

## Grupos de menu

- ESP SETTINGS: 43 elementos
- OTHER: 35 elementos
- ORE ESP: 30 elementos
- CORPSE ESP: 17 elementos
- AIMBOT: 14 elementos
- HITBOX: 11 elementos
- MACRO: 4 elementos
- COMBAT: 1 elementos
- ESP: 1 elementos
- VISUALS: 1 elementos
- UI SETTINGS: 1 elementos
- PLAYERS ESP: 1 elementos
- CONTAINER ESP: 1 elementos
- VEHICLE ESP: 1 elementos
- WORLD: 1 elementos
- ZONE CHARMS: 1 elementos
- CHAMS: 1 elementos

## Funcoes do proprio cheat

- Callbacks ligados a `RenderStepped` (ESP, FOV, hitbox) e a `CharacterAdded`
  (re-hook pos respawn): recuperados como estrutura, corpo parcial.
- `workspace.ChildAdded` / `ChildRemoved`: rastreio de containers e zonas.
- Funcoes de combate (aimbot, silent, anti-recoil), automacao de fabricacao e
  teleporte: **nao recuperadas**. Dependem de `EntityMap`, `RangedWeaponClient`
  e de remotes que o trace nao alcanca.
