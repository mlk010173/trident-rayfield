# Trident Survival - mapa de proteções e o que dá para recuperar

Medições feitas no sandbox sobre os arquivos reais do corpus (86 repositórios minerados
+ o raw do scriptblox). Tudo por análise estática e por execução controlada da VM, sem
depender de serviço externo.

## 1. Tipo de ofuscação por amostra

| Amostra | Bytes | Proteção | Evidência estática |
|---|---|---|---|
| AV0X `PyhTeT/avox.lol/main/TridentSurvival` | 1.119.824 | VM WeAreDevs v1.0.0 | cabeçalho `--[[ v1.0.0 https://wearedevs.net/obfuscator ]]`, 46.879 escapes decimais, 2 `getfenv`, zero `string.dump` |
| Trident V4 FAZMA/BETA | 187.234 | VM "LOL!" (mesma família do V4 de 87 KB) | tag `LOL!`, renomeação `v0..v151`, 144 escapes |
| `cocacolahim/...Protected 1` | 168.906 | MoonSec | marcador MoonSec, 144 escapes, 3 `getfenv` |
| `LemonProgramfile/...Protected` | 142.403 | MoonSec | 116 escapes, 3 `getfenv` |
| `rxn-xyz/TridentSurvival` | 268.075 | Luraph (loader base64) | blob base64 > 80 chars, zero escapes, 1 `getfenv` |
| `bez1236/TridentScript` | 221.464 | Luraph + MoonSec em camadas | ambos os marcadores, apenas 12 escapes |
| `Lennox2010/Trident-Survival` | 682.928 | WeAreDevs | mesmo cabeçalho do AV0X |
| `Rostik22803/Ocel-hub` | 729.813 | container próprio (sem VM) | sem assinatura, código legível com nomes curtos |

Nenhuma das amostras é bytecode Luau puro (`\x1bLua`, `RBMX`, `RBM`, LuaU). Ou seja:
não há Unluau/unluac a aplicar de saída, o que existe são VMs em Lua que carregam
bytecode no runtime.

## 2. Assinaturas que uso para classificar

- **WeAreDevs**: `--[[ v1.0.0 https://wearedevs.net/obfuscator ]]` + `return(function(...)local W={"\051\065...` .
  Strings em escapes decimais dentro de tabela; despacho por índice; a entry function
  espera 26 parâmetros do executor. Constante `"Tamper Detected!"` no corpo.
- **Luraph**: loader com blob base64 e `getfenv`, sem escapes decimais; V15 usa payload
  em chunks base64 com alfabeto trocado e checagem de integridade por `debug.info`.
- **MoonSec**: renomeação `v0..vN`, tabela numérica com `string.char`, 3 `getfenv`,
  `\27Lua`/`\x1b` só quando empacota bytecode.
- **IronBrew 2**: `getfenv` + `string.dump` + concatenação de `\27` e hash de ambiente;
  não apareceu neste corpus.
- **Prometheus**: VM com `prometheus`/`newproxy` e tabela de opcodes nomeados; usado só
  como ferramenta de saída aqui, não como proteção das amostras.
- **LOL!/VortexDQ/RBMX**: renomeação total `v0..v1xx` + strings em `sub/gsub` +
  base64 de alfabeto trocado; RBMX/RBM trazem cabeçalho binário próprio.

## 3. Camadas de codificação encontradas

1. **Escapes decimais** (`\051\065\085`) - AV0X, MoonSec. Reversível trivial: `chr()`.
2. **Base64 com alfabeto permutado** - Luraph, LOL. Grupos de 4 chars viram 3 bytes,
   `=` fecha o bloco. Foi assim que saíram 4.312 constantes do AV0X (516 legíveis).
3. **VM de despacho** - bytecode próprio, opcodes como índices de tabela. Precisa da VM
   inteira para resolver os literais de jogo.
4. **Renomeação/flattening** - `v0..v151`, blocos `if` invertidos, `repeat until true`.
5. **Checagem anti-tamper** - `Kick("Game not support!")` com `game.PlaceId`, e
   `Tamper Detected!` quando `debug.getupvalues` é chamado.

## 4. Strings e constantes recuperáveis

- AV0X: 4.312 constantes recuperadas, 516 legíveis (`FPSArms`, `DefaultSight`, `Barrel`,
  `ChargingHandle`, `ShoulderPad`, `SafeZones`, `NoBuildZones`, `Helicopter`, `DefaultBox`).
- V4 LOL: 236 constants, container cobre só a cola (freecam, crosshair, box ESP, hitbox,
  fullbright). O miolo vem em texto puro por HTTP.
- MoonSec (BETA/Protected): strings sobrevivem porque `string.char` monta em runtime; dá
  para extrair com stub de `string.char`/`table.concat` sem rodar a VM inteira.

## 5. Estruturas de função

- No AV0X a VM expõe 522 linhas de Lua reconstruído em execução real (Luau compilado no
  sandbox, `game.PlaceId` forjado em 13253735473).
- No V4 LOL o decode rendeu 34.755 bytes com 236 constantes, e o menu foi reconstruído
  pela gravação das chamadas da library (166 elementos, abas COMBAT/ESP/VISUALS/UI
  SETTINGS, flags `AB_FovSize=150`, `AB_Smooth=2`, `AB_Radius=1000`, `HitboxSizeX/Y/Z=5`).
- Bytecode interno: sem `string.dump` nas amostras, então não há proto para desmontar por
  `luau-compile`; a estrutura só aparece executando a VM.

## 6. Recuperável x irrecuperável

**Recuperável:** tabela de strings, constantes numéricas, hierarquia de menu, nomes de
remotes e serviços quando aparecem como literal, caminhos de `workspace` e
`ReplicatedStorage`, chaves de keybind, defaults de slider.

**Parcial:** corpos de função que dependem de objeto do jogo (character, tool, remote).
O trace reconstrói a chamada mas não o resultado, porque o dummy devolve outro dummy.

**Irrecuperável na prática:** ordem exata de dispatch da VM, tabelas de opcode
embaralhadas por seed e qualquer literal calculado em runtime a partir de
`HttpService`/`os.time`. Também os `FireServer` do AV0X: quando os callbacks do menu são
executados no trace, a VM entra em loop de render e estoura o orçamento antes da primeira
chamada de rede.

## 7. Ferramentas

- **Luau oficial** (compilado no sandbox: `luau`, `luau-compile`, `luau-analyze`): usado
  para rodar a VM e validar sintaxe do Lua reconstruído.
- **Prometheus** (desofuscador): usado no trace para reconstruir o Lua executado.
- **ByteVeil**: serve para inspeção estática e detecção de VM sem executar; bate com o
  que fiz no passo 1, mas não abre VM WeAreDevs.
- **Deobfuscate.su / LeakD**: detectores e conversores por serviço externo; úteis para
  MoonSec/Luraph, dispensáveis aqui porque o payload já sai do trace.
- **unluac/Unluau**: só valem para bytecode Lua 5.1/Luau de verdade, e nenhuma amostra
  deste corpus vem nesse formato.
