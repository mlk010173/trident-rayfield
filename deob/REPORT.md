# Desofuscação — Trident V4

## Estado do link pedido

`https://raw.githubusercontent.com/v3lvics/scriptsheaven/refs/heads/main/tridentv4` → **404**.

Verificado pela API: o usuário `v3lvics` existe, mas não tem repositório público `scriptsheaven`
(só `DataStoreADVMGR`, `kurzor-ai`, `TRACE`, `rbx-datastorer` e outros pequenos). O único
`scriptsheaven` público no GitHub é `Metaverseal/scriptsheaven`, com um arquivo diferente
(`scriptsheavenuniversal`). Também tentei `main`/`master`/`ScriptsHeaven`/jsDelivr e o Wayback: nada.

Ou seja: o arquivo saiu do ar, virou privado ou foi renomeado. Sem o arquivo, não há o que desofuscar
**daquele** link.

## O que foi feito no lugar

O Trident V4 é distribuído em vários espelhos com a mesma família de VM. Peguei o
`FAZMA-IKU/Trident-Survival-V4` (mesmo "EZ TRIDENT V4", VM idêntica) e escrevi o decodificador:

- `deob_lol.py` — acha o payload (`v15("LOL!…")`), decodifica hex + run-length (`<n>O` = repetir o
  próximo byte `n` vezes), gera `payload.bin`, `strings.txt` e `remotes.txt`.

Resultado: **61.350 caracteres → 34.755 bytes** de container, **236 constantes de texto** recuperadas.

## Arquitetura do V4 (reconstruída pelos constantes)

O script não é só obfuscação: ele **carrega três coisas de fora, em texto puro**:

| O que | De onde | Conteúdo |
|---|---|---|
| UI (tabs, sections, dropdowns) | `raw.githubusercontent.com/Nextinel/Roblox_UI_Exploit_Template/main/UI` | biblioteca de interface |
| Combate/ESP/freecam/crosshair | `rawscripts.net/raw/Trident-Survival-V3-esp-and-hitbox-…-12304` | 20.887 bytes, **não ofuscado** |
| FPS booster | `raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua` | 16.612 bytes, **não ofuscado** |

O núcleo ofuscado do V4 faz: freecam (ContextActionService + gamepad + springs + deadzone),
crosshair com recenter no `ViewportSize`, box ESP por Drawing, hitbox/"legit head", updater de UI,
histórico de update, fullbright e toggles de FPS.

Isso significa que **a lógica que interessa já é obtível sem ofuscação**: o V3 e o FPSBooster são
baixados e lidos direto. O container VM só guarda a cola (UI, ordem de chamadas, strings).

## Limite honesto

Descompilar até Lua legível no nível de opcode exige a tabela de despacho **daquele build**
(o interpretador depois do payload). Como os opcodes mudam por versão, isso não é genérico: dá
trabalho de engenharia reversa por script. O que é recuperável de forma confiável e genérica é
o mapa de constantes e o comportamento — que é o que `deob_lol.py` entrega.

Além disso a VM usa `math.ldexp` (removido no Lua 5.3+), então rodá-la num sandbox Lua moderno
exige shim — o que também limita tracing dinâmico direto.

## Se você tem o arquivo

Manda o conteúdo (upload ou cole no chat). Rodo:

```
python3 deob/deob_lol.py tridentv4.lua deob/v4_seu
```

e em cima do resultado faço o mapa de remotes/features e a reimplementação limpa.
