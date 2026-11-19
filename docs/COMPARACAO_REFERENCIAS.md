# Comparacao com os repositorios de referencia

Leitura feita sobre as copias locais (mesmo conteudo dos links) e confronto com o
nosso `trident_rayfield.lua` (build 3.2). So entrou o que serve ao nosso contexto.

## 1. swimhub/free_trident.lua (1.908 linhas, texto puro)

**Entidades e partes**
- Bootstrap em loop: `workspace.Const.Ignore.LocalCharacter.Middle`,
  `ReplicatedStorage.Shared.entities.Player.Model` e `LocalPlayer.TCP`, repetindo
  `task.wait(0.5)` ate os tres existirem. Nossa build 3.1 ja cobre os caminhos e o
  rig `Middle/Top/Bottom`, mas nao tem espera ativa: em servidor lento a primeira
  varredura pode sair vazia. Anotado como melhoria, nao aplicado ainda.
- Long neck real: `Top.Prism1.CFrame` deslocado no eixo Y. Ja temos igual.
- Identificacao de minerio por aparencia, nao por nome: monta assinatura
  `Color + Material + CollisionGroup` a partir do `PrimaryPart` de cada template em
  `Shared.entities`, e ainda trata o caso especial `MeshId 12939036056` (1 filho =
  Stone; cor 248,248,248 = Nitrate; 199,172,120 = Iron).
  **Adotado na build 3.3** (`Catalog.identify`), porque no mapa os modelos costumam
  vir sem nome util e o nosso ore ESP exigia `Name == "Model"` + filho `rock`.

**Aimbot/remotes**
- `cheat.utility.new_hook` embrulha `hookfunction` com `clonefunction` para restaurar
  hooks no unload. Nossa implementacao ja guarda o original, mas nao clona.
- `FireServer(23, word, "Global")` e `FireServer(2, true)` confirmam o que ja usamos.

## 2. Babyhamsta/Trident Survival Main.lua (589 linhas)

- Aimbot por `mousemoverel((pos.X - Mouse.X)/smooth, (pos.Y - Mouse.Y)/smooth)` apos
  `Camera:WorldToScreenPoint(Head.Position)`. Alternativa ao nosso override de camera.
- Usa `Target:FindFirstChild("Head")`, ou seja, e de uma epoca em que o rig tinha Head.
  Com o rig atual (`Middle`) esse codigo fica cego: **nao vale portar como esta**.
- `mousemoverel` como fallback e util em executor que ignora escrita em `Camera.CFrame`,
  mas em celular o cursor nao existe, entao deixei fora para nao arriscar a estabilidade
  mobile que voce pediu.

## 3. 6segs/kira (bloxsense 13.944 linhas + ESP.lua 647 linhas)

- ESP com `Highlight` (chams) e `BoxHandleAdornment` para caixas, em vez de Drawing.
  E o mesmo caminho que o nosso script ja usa como fallback quando `Drawing` falta.
- Nada de entidade/Trident: o bloxsense e multi-jogo generico, com `FireServer`
  especifico de C4/ragdoll de outros jogos. Sem aproveitamento direto.
- Ideia barata que vale no futuro: `DepthMode = AlwaysOnTop` no Highlight quando o
  chams precisa atravessar parede. Ja expomos isso na UI ("Sempre na frente").

## 4. WaffleManTheGreat/DirtyFork

- Container LOL-VM (`--[[ Update 9.0 ... ]]` + `v0..vN`), mesmo formato do Trident V4.
  Sem codigo legivel sem o lifter; nada a extrair alem do que ja mapeamos.

## 5. O que foi aplicado agora (build 3.3)

- `Catalog.signatures` montado no `loadCatalog` a partir de `Shared.entities`.
- `Catalog.identify(model)` com a regra do MeshId 12939036056 e o casamento por
  aparencia, exposto como campo de tabela (zero `local` novo no chunk, limite de 200
  locais preservado).
- Ore ESP deixa de exigir nome: se `findRock` falha, tenta `Catalog.identify`.

## 6. O que ficou de fora, de proposito

- `mousemoverel` no aimbot (risco em mobile, sem ganho claro sobre o override atual).
- Bootstrap em `repeat ... until` dos tres caminhos: melhora robustez em servidor
  lento, mas mexe no fluxo de inicializacao que ja esta estavel; candidato para 3.4.
- Clonagem de hooks no unload: so relevante se instalarmos mais de um hook.

## 8. Pipeline unico (`deob/wad_lift.py`)

O roteiro de deofuscacao em JavaScript nao se aplica (o alvo e Lua), entao a versao
Lua do mesmo pipeline ficou num script so:

1. deteccao de protecao (WeAreDevs, LOL-VM, MoonSec, Luraph, bytecode);
2. extracao e unescape da tabela de strings;
3. analise estrutural (entropia, razao imprimivel, periodicidade para estimar largura
   de instrucao);
4. relatorio JSON (`deob/wad_lift_report.json`).

Rodado no AV0X: 1.119.824 bytes, WeAreDevs v1.0.0 confirmado, 4.313 entradas na tabela,
48.952 bytes decodificados, entropia 5,845 e razao imprimivel 1,0. Isso mostra que a
tabela guarda texto base64, nao bytecode: a instrucao real so aparece depois do decode
com alfabeto permutado, que ja roda em `deob/deob_wearedevs.py`.

### Incremento: dobra de constantes

A VM WeAreDevs disfarca cada numero como soma ou subtracao (`840618+-840617` = 1) e
esconde o despacho numa arvore de comparacoes. O `wad_lift.py` agora dobra essas
expressoes em passes sucessivos:

- 37.370 expressoes dobradas;
- 1.119.824 -> 710.970 bytes (reducao de 36,5%);
- a arvore de despacho passa a mostrar numero puro (`if -578020 == a[z] then`).

Artefato: `deob/avox_folded.lua`. Aviso: a dobra e para leitura, nao garante sintaxe
valida — quando havia parenteses aninhados sobra parentese orfao (`a[z]-(1`), entao o
arquivo nao roda como esta.

### Correcao da dobra (dobra conservadora)

A primeira versao da dobra consumia parenteses e corrompia a sintaxe (`a[z]-(1`).
A versao final e conservadora: so dobra numero-op-numero, sem tocar em parenteses, e
quando o resultado e negativo escreve `(0-5)` em vez de `-5`, porque `a--5` viraria
comentario e comeria a linha inteira (o payload tem 2 linhas).

- 27.971 expressoes dobradas; 1.119.824 -> 835.219 bytes (25,4%);
- sem numero malformado e sem `--` acidental;
- o arquivo segue nao compilavel no Lua 5.1 por "control structure too long", que e
  limitacao do proprio alvo (funcao unica gigante), nao da dobra.
