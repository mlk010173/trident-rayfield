# trident • rayfield gen2

Reconstrução do cheat de **Trident Survival** (Roblox) em cima do **Rayfield Gen2**.
Base: `free_trident.lua` do repositório [swimhub](https://github.com/SWIMHUBISWIMMING/swimhub) + lógicas de referência do [Babyhamsta/RBLX_Scripts](https://github.com/Babyhamsta/RBLX_Scripts), reescritas para funcionar em executor de celular.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/mlk010173/trident-rayfield/main/trident_rayfield.lua"))()
```

## Por que o script original quebrava no celular

O `free_trident.lua` do swimhub não tem erro de sintaxe (o parser só aponta `continue`, que é Luau válido). O que estoura em executores mobile é a lista de dependências: `debug.setconstant`, `getcustomasset`, `hookfunction`, `cloneref`, `writefile`/`isfile` e `Drawing` obrigatório.

Este build depende apenas de:

| Recurso | Obrigatório | Se faltar |
|---|---|---|
| `getrawmetatable` / `setreadonly` | não | cai para o hook no módulo de câmera ou para o aimbot de câmera |
| `Drawing` | não | ESP troca para `Highlight` + `BillboardGui`, overlay do FOV some |
| `getrenv` | não | usa apenas os paths de instância (`workspace.Const.Ignore.LocalCharacter`, `LocalPlayer.TCP`) |
| sistema de arquivos | não | a janela é recriada sem salvamento de config |

Tudo passa por `pcall` com fallback: quando um path do jogo muda, o script avisa no console em vez de estourar.

## Build 2.2 — mineração de 86 repositórios

Varredura com 10 consultas na API do GitHub (`trident survival`, `trident survival script`, `trident roblox cheat`, `swimhub trident`, `trident survival lua`, `aimbot`, `hack`, `gui`, `exploit`, `trident survival roblox`): **86 repositórios mapeados**, 22 com Lua legível, 44 arquivos baixados e analisados.

- **Silent aim de projétil (novo, o mais forte).** Hook no `createProjectile` do `RangedWeaponClient`, achado por `getgc()` + `debug.getconstants(v)[1] == "ProjectileSpeed"`, exatamente como em `Mick-gordon/Trident-Survival-Silent-aim`. O alvo é corrigido antes do projétil nascer, com predição por `weaponInfo.ProjectileSpeed` / `ProjectileDrop` e velocidade do alvo. Se o executor não tiver `hookfunction`, avisa e cai no silent aim antigo.
- **Dash slide por TCP.** `FireServer(3, true, Vector3.xAxis)` + `FireServer(2, true)` para entrar no slide, empurrão de `AssemblyLinearVelocity` na direção da câmera e `(3,false)`/`(2,false)` no fim — sequência extraída do `KumaoRoblox/TridentSurvival` (speedhack silencioso). Tem toggle, velocidade, duração, "Dash agora" e "Parar dash" (para nunca ficar preso no slide).
- **Arma equipada pelo módulo do jogo.** `GetEquippedItem` via `getgc`, como no `Panda22MyGod/TridentSurvival`, com fallback no `Tool`; usada no rótulo do ESP.
- **Containers com nome real.** `Metal`, `Metal2`, `Cardboard`, `Crate` e detecção por filho `Crates`/`Cables`/`Lid` (padrão do `Rostik22803/Ocel-hub-trident-survival`), além do `ProximityPrompt` que já existia.
- **EntityMap** também usado pelo farm/kill aura, com `Classes.Player.EntityMap` como caminho alternativo.

Ranking de densidade de feature entre os 86: `6segs/kira` (115), `mlk010173/trident-rayfield` (95), `Rostik22803/Ocel-hub-trident-survival` (93), `KumaoRoblox/TridentSurvival` (92), `Panda22MyGod/TridentSurvival` (80), `Mick-gordon/Trident-Survival-Silent-aim` (23).

Sobre os ofuscados: `WaffleManTheGreat/DirtyFork`, `Zu0aX/Trident-Survival`, `cocacolahim/trident-survival` e `LemonProgramfile/TridentSurvival-me` estão compilados em VM (Luraph/PSU), sem source recuperável sem o deobfuscator específico. Do `Ocel-hub` foi possível ler a camada de proteção (o truque de `string.gsub` guardado em `return ({ string_replace = string.gsub, ... })`) e aproveitar as listas de material/container.

## Build 2.1 — correção do erro em jogo + fontes

- **`attempt to modify a readonly table` corrigido.** O stack apontava a linha 53 do script: era o `math.clamp = ...`. No Luau a tabela `math` é readonly, então atribuir nela estoura. O `clamp` virou função local.
- **Personagem local com o caminho do jogo.** O Trident usa `workspace.Ignore.LocalCharacter` (e em algumas builds `Const.Ignore.LocalCharacter`). O resolver agora tenta os dois, então `Middle`/`Top`/`Bottom` aparecem mesmo quando o path muda.
- **Catálogo de entidades do jogo.** Lido de `ReplicatedStorage.Shared.entities`: `Player`, `Tree`, `Cactus`, `Iron`, `Nitrate`, `Stone`, `Totem`, cofres/caixas e a pasta de NPCs. O ESP de objetos passa a usar o nome exato do jogo em vez de adivinhar por padrão de texto. Tem toggle **Recursos** e botão **Recarregar catálogo**.
- **Auto farm e kill aura por TCP.** `TCP:FireServer(10, "Swing")` + `(10, "Hit", id, pos, parte, Vector3)` no recurso/player/NPC mais próximo, com raio, intervalo e parte do hit. Depende do `EntityMap` do cliente (`getgc`/`debug.getupvalues`); quando o executor não expõe, a feature se desliga sozinha com aviso — o Trident tem detecção de tampering (`TamperingDetected`), então isso vem desligado por padrão.

### Fontes públicas usadas

| Repositório | O que trouxe |
|---|---|
| [ipso1337/tridenopenscr](https://github.com/ipso1337/tridenopenscr) | protocolo `TCP` real (`Swing`/`Hit`), caminho `workspace.Ignore.LocalCharacter`, tipos de farm (`Cactus`, `Tree`, `Nitrate`, `Stone`, `Iron`), kill aura e entity map |
| [7PXS/ScriptArchive](https://github.com/7PXS/ScriptArchive) | `ReplicatedStorage.Shared.entities` (catálogo pago do swimhub trident), identificação de modelo por material/cor, arma por entidade, `ProjectileSpeed`/`ProjectileDrop`/`Recoil` |
| [6segs/kira](https://github.com/6segs/kira) | módulo de ESP legível: caixas, skeleton, chams, barras e ordenação |

Descartados: `WaffleManTheGreat/DirtyFork` e `Zu0aX/Trident-Survival` estão compilados em VM (não dá para extrair nada sem deobfuscator).

## Build 2.0 — upgrade mobile e de mundo

- **Mira fixa no centro.** No celular o `GetMouseLocation` devolve o último toque, e era isso que arrastava o círculo do FOV junto com o dedo (e fazia o aimbot escolher alvo pela posição errada). Agora FOV, seleção de alvo e crosshair usam o centro da tela por padrão (`Mira fixa no centro`, desligável em Combat).
- **Chams arco-íris fluido.** Um `Highlight` por parte do corpo, com a matiz deslocada no tempo: as cores andam dentro do modelo em vez de o boneco inteiro trocar de cor. Tem velocidade, transparência, quantidade de partes (custo no celular), contorno e "sempre na frente".
- **Aura no player local.** Partículas + brilho arco-íris no seu personagem, com taxa de partículas ajustável.
- **Aba Objetos.** O ESP antigo só via players. Agora:
  - **Containers** por `ProximityPrompt`/`ClickDetector`, ou seja, funciona sem saber o nome que o jogo deu para a caixa (militar, cofre, metal, papelão);
  - **Totens**, **camas/caixa de spawn** do player e **armas no chão** (`Tool`);
  - **Nomes extras** configuráveis por texto, para quando aparecer container novo;
  - **Auto loot** dispara o prompt do container mais próximo, com raio e intervalo;
  - varredura com orçamento de 2,5 ms por frame, então o mapa inteiro é indexado sem engasgar o celular.
- **ESP de NPC separado do de player** (`GetPlayerFromCharacter`), cor própria, e o **nome da arma na mão** do alvo no rótulo.
- **Distância corrigida.** `myPosition()` tenta `Game.middle`, depois as partes do personagem e por fim a câmera. Antes, sem `HumanoidRootPart`, tudo ficava em 0 m.
- **Gamma falso / filtro do mundo.** `ColorCorrectionEffect` + `BloomEffect` + `SunRaysEffect` + `Atmosphere`, com sliders de brilho, contraste, saturação, tinta, neblina e pulso, mais presets `natural`, `neon`, `cinema`, `noite` e `vapor`. Tudo é destruído no unload.

## Abas e funções

**Combat**
- Aimbot de câmera (funciona no toque, sem mouse): FOV em pixels, suavização, distância máxima, predição de movimento, checagem de visão (`GetPartsObscuringTarget`) e filtro de quem está dormindo.
- Silent aim em 3 camadas: override no módulo de câmera do jogo (`_G.Camera.GetCFrame`), hook de `Camera.CFrame` via `getrawmetatable`, e aviso honesto quando o executor não permite nenhum dos dois.
- Hitbox expander com tamanho, transparência e colisão, restaurando o original ao desligar.

**Visuals**
- ESP de players e de NPC com backend duplo (Drawing ou Highlight + Billboard), caixa, chams, nome, distância, vida, tracer e arma na mão.
- Chams arco-íris fluido por parte, aura estética no player local.
- Overlay de FOV e crosshair, presos no centro da tela.
- Ore ESP (ferro, nitrato, pedra).
- Círculo de FOV e crosshair (só onde existe `Drawing`).

**World**
- Time changer, fullbright, sem fog.
- Chat spam com intervalo e mensagem editáveis.
- IDs dos remotes de chat e de agachar editáveis na própria UI, para quando o jogo mudar os canais.

**Movement**
- Speedhack pelo analógico (`Humanoid.MoveDirection`), forcesprint, freecam, long neck, fake crouch, noclip.
- Car fly no ATV/veículo mais próximo, com aceleração e subida ajustáveis.

**Config**
- Temas, salvar/carregar config, console de compatibilidade e botão **Diagnóstico**, que mostra o que o script encontrou no jogo (personagem, remote TCP, `Network`, módulos, backend de ESP, hook do silent aim, alvos vistos).

## Como usar no Arceus X

1. Cole o loadstring no executor com o jogo já carregado.
2. Abra **Combat** e ligue `Aimbot (camera)`, deixando `Ativacao` em `sempre`.
3. Se ligar `Silent aim` e aparecer o aviso de indisponível, o executor não tem `getrawmetatable`: use o aimbot de câmera.
4. Se o chat spam ou o fake crouch pararem de funcionar, abra **World** e troque os IDs dos remotes (padrão: chat `23`, agachar `2`).
5. **Config → Diagnóstico** mostra exatamente o que foi encontrado, útil para reportar o que quebrou depois de um update do jogo.

## Testes feitos

- Parse de sintaxe em Lua 5.1/5.2/5.3 (Luau é superset para o que é usado aqui).
- Execução em ambiente Roblox simulado (mock com `Const.Ignore.LocalCharacter`, `LocalPlayer.TCP`, NPC, minério, veículo, containers com prompt, totem, cama e arma no chão), ligando e desligando os **127 controles**: 0 erros.
- Verificado nas etiquetas geradas pelo teste: `Bandit [WoodArrow]`, `Crate_Military 6m [Loot Caixa militar]`, `Cofre 8m`, `Totem 9m`, `SleepingBag 5m`, `AK47 7m`, com distância real e sem 0 m.
- Gamma validado: preset `neon` aplica brilho 0.12 e saturação 0.55 no `ColorCorrectionEffect`, e o efeito é destruído ao desligar.
- Silent aim validado: com alvo, o `GetCFrame` do jogo passa a apontar para o NPC e volta ao normal ao desligar.

O que só o jogo confirma é qual hook o Trident aceita hoje. O console diz qual entrou em uso.

## Aviso

Uso em servidor público viola os Termos de Serviço do Roblox e pode resultar em ban da conta. O código está publicado para estudo de UI (Rayfield Gen2), de hooks e de engenharia reversa em ambiente próprio. Use por sua conta e risco.

## Créditos

- `free_trident.lua` e bibliotecas: [SWIMHUBISWIMMING/swimhub](https://github.com/SWIMHUBISWIMMING/swimhub)
- Silent aim por override de câmera, ore ESP, grab all: [Babyhamsta/RBLX_Scripts](https://github.com/Babyhamsta/RBLX_Scripts)
- Interface: [Rayfield Gen2](https://sirius.menu/gen2)
