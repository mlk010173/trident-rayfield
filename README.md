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

## Abas e funções

**Combat**
- Aimbot de câmera (funciona no toque, sem mouse): FOV em pixels, suavização, distância máxima, predição de movimento, checagem de visão (`GetPartsObscuringTarget`) e filtro de quem está dormindo.
- Silent aim em 3 camadas: override no módulo de câmera do jogo (`_G.Camera.GetCFrame`), hook de `Camera.CFrame` via `getrawmetatable`, e aviso honesto quando o executor não permite nenhum dos dois.
- Hitbox expander com tamanho, transparência e colisão, restaurando o original ao desligar.

**Visuals**
- ESP de players com backend duplo (Drawing ou Highlight + Billboard), caixa, chams, nome, distância, vida e tracer.
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
- Execução em ambiente Roblox simulado (mock com `Const.Ignore.LocalCharacter`, `LocalPlayer.TCP`, NPC, minério e veículo), ligando e desligando os 81 controles: 0 erros.
- Silent aim validado: com alvo, o `GetCFrame` do jogo passa a apontar para o NPC e volta ao normal ao desligar.

O que só o jogo confirma é qual hook o Trident aceita hoje. O console diz qual entrou em uso.

## Aviso

Uso em servidor público viola os Termos de Serviço do Roblox e pode resultar em ban da conta. O código está publicado para estudo de UI (Rayfield Gen2), de hooks e de engenharia reversa em ambiente próprio. Use por sua conta e risco.

## Créditos

- `free_trident.lua` e bibliotecas: [SWIMHUBISWIMMING/swimhub](https://github.com/SWIMHUBISWIMMING/swimhub)
- Silent aim por override de câmera, ore ESP, grab all: [Babyhamsta/RBLX_Scripts](https://github.com/Babyhamsta/RBLX_Scripts)
- Interface: [Rayfield Gen2](https://sirius.menu/gen2)
