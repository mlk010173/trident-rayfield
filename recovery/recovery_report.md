# Relatorio de recuperacao - Trident Survival AV0X

## 1. Alvo e integridade

- Loader: `loadstring(game:HttpGet("https://scriptblox.com/raw/Trident-Survival-AV0X-223117"))()`
- Payload efetivo: `https://raw.githubusercontent.com/PyhTeT/avox.lol/main/TridentSurvival`
- Bytes: 1119824 | SHA-256: `3ab49245490098c75b26f92751be713eda4c3d0616633e32a63a8a69983fe283`
- Loader de 143 bytes preservado em `recovery/loader.lua`.

## 2. Protecao real (nao presumida)

Camada unica confirmada: **WeAreDevs Obfuscator v1.0.0**, assinatura no cabecalho.
Dentro dela: VM de despacho, 48972 escapes
decimais na tabela de strings, renomeacao total e flattening. Duas travas de ambiente:
`game.PlaceId` com `Kick("Game not support!")` e "Tamper Detected!" ao usar
`debug.getupvalues`. Nenhuma assinatura de Luraph, MoonSec, IronBrew ou Prometheus no
payload; MoonSec aparece apenas no V4, que e outro produto.

## 3. Codificacoes

- Escapes decimais: 48972 (reversivel por `chr`).
- Base64 com alfabeto permutado: presente na tabela de strings, recuperado pelo decoder.
- Hexadecimal e XOR: nao usados como camada primaria.
- Bytecode Luau: **ausente**. Nao ha `\x1bLua`, `RBMX`/`RBM` nem `string.dump`, portanto
  Unluau, Luau Decompiler Rust e VortexDQ nao tem arquivo de entrada. A "VM" e Lua puro.

## 4. Metodo

1. Preservacao do loader e do payload (hash acima).
2. Extracao estatica de strings com o extrator de terceiros
   (`hutaoshusband/WeAreDevs-Deobfuscator`): 4313 strings,
   independente do meu decoder.
3. Execucao controlada da VM em Luau compilado na sandbox, com `game.PlaceId`
   forjado e `HttpGet` stubado, sob o desofuscador Prometheus em modo trace.
4. Segunda passada com a library de UI substituida por uma gravadora de chamadas,
   para mapear o menu sem o ruido de 200 mil linhas da biblioteca real.
5. Validacao de sintaxe do Lua reconstruido no compilador oficial do Luau.

## 5. O que e cada arquivo

| Arquivo | Natureza |
|---|---|
| `recovery/recovered.lua` | constantes + arvore de menu + trace das operacoes (reconstruido, nao original) |
| `recovery/strings.txt` | strings recuperadas e verificadas |
| `recovery/analysis.json` | diagnostico completo das protecoes |
| `recovery/functions.md` | inventario por papel observado |
| `recovery/dependencies.md` | remotes, servicos, caminhos e libs |
| `recovery/loader.lua` | carregador original preservado |

## 6. Recuperado x reconstruido x nao recuperavel

**Recuperado (fato):** 4313 constantes da tabela,
655 strings legiveis, 166 elementos de menu com
abas COMBAT/ESP/VISUALS/UI SETTINGS, servicos, cores literais, caminhos de workspace e
URLs de bibliotecas.

**Reconstruido (inferido do trace):** ordem de conexoes (`RenderStepped`,
`CharacterAdded`, `ChildAdded/Removed`), criacao de primitivas `Drawing`, fluxo de
checagem de PlaceId.

**Nao recuperavel com prova:** corpos das funcoes de combate e farm, nomes de remotes
alem de `LocalPlayer.TCP`, tabela de opcodes da VM embaralhada por seed, e qualquer
literal calculado em runtime. Os callbacks do menu, quando executados, entram em loop de
render e o trace estoura antes de chegar a rede: limite medido, nao suposto.

## 7. Limitacoes declaradas

- Nao houve execucao em Roblox: o ambiente foi simulado.
- A porcentagem de codigo recuperado nao e 100%. O que esta em `recovered.lua` e a
  representacao legivel mais completa obtida com prova de origem por linha.
