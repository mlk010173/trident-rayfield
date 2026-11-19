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
