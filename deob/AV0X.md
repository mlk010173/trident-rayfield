# Trident Survival AV0X (scriptblox 223117) — engenharia reversa

## Cadeia de carregamento (mapeada)

```
scriptblox.com/raw/Trident-Survival-AV0X-223117      (143 bytes, só um loader)
  └─ raw.githubusercontent.com/PyhTeT/avox.lol/main/TridentSurvival   (1.119.824 bytes)
       └─ carrega também: Library.lua, Universal, addons/*, Example.lua
```

Repositório `PyhTeT/avox.lol` (público, branch `main`):

| arquivo | tamanho | estado |
|---|---|---|
| `TridentSurvival` | 1.119.824 B | **WeAreDevs VM** (ofuscado) |
| `Universal` | 404.831 B | **WeAreDevs VM** (ofuscado) |
| `Library.lua` | 119.266 B | **texto puro** (UI Linoria-like) |
| `Example.lua` | 15.330 B | texto puro |
| `addons/SaveManager.lua` | 7.442 B | texto puro |
| `addons/ThemeManager.lua` | 8.705 B | texto puro |

Ou seja: a interface e os addons do AV0X **não são ofuscados**, e estão no repo.

## O ofuscador

Cabeçalho: `--[[ v1.0.0 https://wearedevs.net/obfuscator ]] return(function(...)`.
É a **VM da WeAreDevs**: o programa inteiro vira uma tabela `t` de números e um
interpretador em Lua puro. A tabela `A/W` inicial é um dicionário de strings
cifradas em base64 com alfabeto trocado (64 entradas, valores 0..63).

Formato do decode (portado fielmente):
- grupos de 4 caracteres → 3 bytes (`E = E + peso * 64^(3-D)`);
- `=` fecha o último grupo (1 ou 2 bytes);
- `L(V, string.char(...))` acumula.

`deob_wearedevs.py` reproduz isso e recuperou **4.312 constantes únicas** do
`TridentSurvival` (516 legíveis). O que aparece nelas:

- biblioteca de UI: `AddLeftGroupbox`, `AddRightGroupbox`, `AddTabbox`, `AddSlider`,
  `AddKeyPicker`, `AddDraggableLabel`, `BuildConfigSection`, `LoadAutoloadConfig`,
  `UpdateColorsUsingRegistry`, `ApplyToTab`, `IgnoreThemeSettings`, `AddItem`
  → é **Linoria** (a mesma família da versão antiga), não Rayfield;
- API usada: `WorldToViewportPoint`, `FindFirstChildWhichIsA`, `IsMouseButtonPressed`,
  `ColorSequenceKeypoint`, `GetPropertyChangedSignal`, `HttpGet`;
- `Tamper Detected!` → tem **anti-tamper** próprio.

## Por que não sai "Lua legível" do main

Os literais de jogo (nomes de remote, labels de feature, itens) **não estão** na
tabela de strings: eles são materializados pelo bytecode (CONCAT/char) durante a
execução. Recuperar isso exige ou (a) um **lifter** da VM WeAreDevs (decodificar a
tabela `t` + a tabela de opcodes), ou (b) **execução instrumentada** num host Lua 5.1
com API Roblox real.

Tentei (b): montei mock Roblox + shims (`getfenv`, `setfenv`, `newproxy`, `bit32`,
`unpack`) no fengari. A VM **carrega e começa a rodar**, mas morre em
`attempt to index a nil value (local 'M')` porque a entry function recebe 7
argumentos do executor e espera 26 parâmetros — depende do ambiente do executor
(Roblox + getfenv real). Com espionagem de UI (stub universal que loga todo
método + rótulo) ela não chega a chamar a biblioteca, então não vaza label.

Conclusão honesta: **o main do AV0X não é recuperável estaticamente** sem lifter
específico dessa VM, e ele é justamente a parte que interessa. O que dá para usar
dele é o que já está em texto puro no repo (Library, addons) e o mapa de constantes.

## Comparação com o nosso build

| | AV0X | nosso (2.4) |
|---|---|---|
| UI | Linoria ofuscado (main) | Rayfield Gen2, código aberto no repo |
| Ofuscação | WeAreDevs VM | nenhuma |
| Anti-tamper | sim | modo seguro (evita debug.getupvalues) |
| Manutenção | editar bytecode | editar Lua |

Na prática o caminho do AV0X (VM + Linoria) é pior para mobile e para manutenção.
O que valeu copiar foi a ideia do `SaveManager` (autoload de config) e o
`ThemeManager` (registro de cores), que o nosso já cobre via `salvar config` e o
Controle de cores do Rayfield.

## Quebra da VM (build 2.7)

O AV0X nao fica mais como caixa preta: a VM WeAreDevs foi executada de verdade e
o trace reconstruiu 522 linhas de Lua legivel (`deob/AV0X_reconstructed.lua`,
trace cru em `deob/AV0X_trace.txt`).

Como foi feito:
1. Lua 5.1 e Luau compilados na sandbox.
2. Desofuscador Prometheus (WeAreDevs) adaptado para rodar sob Luau: `debug.sethook`,
   `loadfile`/`io` e `arg` emulados, entrada embutida via `INPUT_SRC`.
3. A VM morria em `game.PlaceId`. Ela faz `LocalPlayer:Kick("Game not support!")`
   quando o PlaceId nao e o do jogo. PlaceId correto: **13253735473**.
4. Com o PlaceId forjado e `game.HttpGet` devolvendo uma library universal (stub),
   a VM abriu e o tracer passou a registrar as operacoes reais.

### O que o trace revelou

- UI: o AV0X usa **Obsidian** (`deividcomsono/Obsidian/main/Library.lua` +
  `addons/ThemeManager.lua` + `addons/SaveManager.lua`), nao Linoria.
- Bracos: `workspace.Const.Ignore.FPSArms.HandModel` com as pecas `DefaultSight`,
  `Barrel`, `Body`, `ChargingHandle`, `Decals`, `Mag`, `Rails`, `ShoulderPad`, `Stock`.
- Containers: `Model` com filho `"default"` e partes `box` / `trash` (MeshPart),
  rotulo `DefaultBox` / `Box` / `Trash` em `230,182,0`.
- Zonas: `workspace.World.Zones.SafeZones` (verde) e `NoBuildZones` (vermelho).
- Veiculos: `ReplicatedStorage.Shared.entities.vehicles` (ex. `Helicopter`,
  rotulo verde tamanho 14).
- FOV: dois `Drawing.new("Circle")`, raio 150, azul, ZIndex 999/998.
- Paleta de itens: laranja `255,100,0`, azul `0,150,255`, verde `0,255,0`,
  amarelo `200,200,0`, rosa `255,0,207`.
- ESP usa ScreenGui `ESPHolder` em `PlayerGui` (ResetOnSpawn false) e
  `Drawing.new("Text")` com `Font 2`, `Center`, contorno preto.

O que o trace nao entrega: os remotes (o trace para no carregamento da UI e nos
loops de render; nao ha `FireServer` no caminho executado). O protocolo TCP do
Trident segue o mapeado na build 2.2 (`10 Swing`, `10 Hit`, `23` chat, `2`/`3` slide).
