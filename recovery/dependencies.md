# Dependencias identificadas (AV0X)

## Payloads remotos

- `https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua`
- `https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua`
- `https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua`
- `https://wearedevs.net/obfuscator`

O primeiro e o proprio script protegido; os demais sao carregados em texto puro
pela VM via `game:HttpGet` e nao tem ofuscacao alguma.

## Bibliotecas de UI

- `Obsidian` (fork da Linoria) `Library.lua` - janela, abas, groupbox, sliders,
  colorpicker, keypicker, dropdown.
- `addons/ThemeManager.lua` e `addons/SaveManager.lua` - temas e configuracao
  (autoload/autosave em arquivo do executor).

## Servicos Roblox

- `Debris`
- `Lighting`
- `Players`
- `ReplicatedStorage`
- `RunService`
- `Stats`
- `UserInputService`

## Caminhos de jogo usados

- `workspace.ChildAdded`
- `workspace.ChildRemoved`
- `workspace.CurrentCamera`
- `workspace.CurrentCamera.ViewportSize.X`
- `workspace.CurrentCamera.ViewportSize.Y`
- `workspace.DescendantAdded`
- `workspace.DescendantRemoving`
- `ReplicatedStorage.Shared.entities.vehicles` (veiculos, Helicopter)
- `workspace.World.Zones.SafeZones` / `NoBuildZones`

## Remotes

- `Players.LocalPlayer.TCP` - canal unico do jogo; acoes como `FireServer(10,"Swing")`,
  `FireServer(10,"Hit",id,pos,parte,Vector3)` e chat `FireServer(23,msg,"Global")`.
- Nomes de remote adicionais **nao recuperados**: o trace estoura o orcamento em loop
  de render antes da primeira chamada de rede.

## Recursos do executor exigidos

`loadstring`, `game:HttpGet`, `getgenv`, `getgc`, `hookfunction`, `debug.getconstants`,
`debug.getupvalues` (este ultimo dispara "Tamper Detected!"), `Drawing`.
