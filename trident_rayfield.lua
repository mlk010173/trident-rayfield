--[[=====================================================================
    TRIDENT SURVIVAL  •  RAYFIELD GEN2 BUILD
    ---------------------------------------------------------------
    Reescrita completa, focada 100% em Trident (nada de Project Delta).
    Base: free_trident.lua do swimhub + ideias do script do Babyhamsta
    (silent aim por override de camera, ore esp, grab all, no recoil).

    O que mudou em relacao ao original:
      * UI trocada da Linoria forkada para Rayfield Gen2 (funciona no celular,
        nao depende de getcustomasset / imagem / Drawing obrigatorio).
      * Todas as chamadas de jogo passam por "resolve" com pcall e fallback,
        entao se o path mudou o script avisa em vez de estourar erro.
      * Bugs de sintaxe/logica do original corrigidos (loops `for i,v in t do`,
        comparacao `if not dir == Vector3.zero`, offsets de hitbox, etc).
      * Silent aim + aimbot com predicao, FOV, checagem de visao e de dormindo.
      * ESP com dois backends: Drawing (PC/executor completo) e Highlight +
        BillboardGui (Arceus X / mobile, sem Drawing).

    Build 2.0 (upgrade mobile + mundo):
      * Mira fixa no centro: no celular o FOV e a escolha de alvo nao
        seguem mais o dedo (GetMouseLocation devolve o ultimo toque).
      * Chams arco-iris fluido: um Highlight por parte do modelo, com
        matiz deslocada no tempo (as cores andam dentro do corpo).
      * Aura estetica no player local (particulas + brilho arco-iris).
      * Aba Objetos: containers (por ProximityPrompt/ClickDetector, sem
        depender do nome), totens, camas/spawn do player, armas no chao,
        auto loot e nomes extras configuraveis.
      * ESP de NPC separado do de player e nome da arma na mao do alvo.
      * Distancia corrigida: myPosition() tenta Game.middle, partes do
        personagem e por fim a camera (antes ficava 0 quando faltava o
        HumanoidRootPart).
      * Gamma falso / filtro do mundo: ColorCorrection + Bloom + SunRays
        + Atmosfera com presets (natural, neon, cinema, noite, vapor) e
        pulso suave.

    Carregar:
      loadstring(game:HttpGet("https://raw.githubusercontent.com/mlk010173/trident-rayfield/main/trident_rayfield.lua"))()
=====================================================================]]

--=====================================================================
-- 1. SERVICOS
--=====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Camera = Workspace.CurrentCamera
-- math.clamp e Luau; garante que existe no executor
math.clamp = math.clamp or function(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

--=====================================================================
-- 2. UTILITARIOS
--=====================================================================
local function safecall(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function getEnv()
    if type(getrenv) == "function" then
        local ok, env = pcall(getrenv)
        if ok and type(env) == "table" then return env end
    end
    return nil
end

local ENV = getEnv()

local function gameGlobal(key)
    if ENV then
        local g = ENV._G
        if type(g) == "table" and g[key] ~= nil then return g[key] end
        if ENV[key] ~= nil then return ENV[key] end
    end
    return nil
end

local function keyShown(key)
    if key == nil then return "None" end
    if typeof(key) == "EnumItem" then return key.Name end
    return tostring(key)
end

-- logger (alimenta o console da aba Config)
local Log = {
    lines = {},
    console = nil,
    seen = {},
}

function Log:add(msg)
    local line = "[" .. tostring(IS_MOBILE and "mobile" or "pc") .. "] " .. tostring(msg)
    table.insert(self.lines, line)
    if #self.lines > 120 then table.remove(self.lines, 1) end
    if self.console then
        pcall(function() self.console:Append(line) end)
    end
end

function Log:once(tag, msg)
    if self.seen[tag] then return end
    self.seen[tag] = true
    self:add(msg)
end

--=====================================================================
-- 3. RAYFIELD GEN2
--=====================================================================
local Rayfield
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
    end)
    if not ok or type(res) ~= "table" then
        local ok2, res2 = pcall(function()
            return loadstring(game:HttpGet("https://sirius.menu/gen2-preview"))()
        end)
        if ok2 then res = res2 else res = nil end
    end
    Rayfield = res
    if type(Rayfield) ~= "table" then
        error("[trident] nao foi possivel carregar o Rayfield Gen2 (verifique a internet do executor)")
    end
end

-- cria a janela; se o executor nao tiver sistema de arquivos (alguns builds
-- mobile), recria sem o sistema de configuracao em vez de morrer com erro
local windowOk, WindowRes = pcall(function()
    return Rayfield:CreateWindow({
        name = "trident",
        subtitle = "rayfield gen2 build",
        theme = "cobalt",
        sidebarLayout = true,
        profile = IS_MOBILE and "mobile" or "desktop",
        configuration = {
            autoSave = true,
            autoLoad = true,
            fileName = "trident_gen2",
            customFolder = "trident",
        },
    })
end)

local Window = WindowRes
local hasConfig = windowOk

if not windowOk or type(Window) ~= "table" then
    Window = Rayfield:CreateWindow({
        name = "trident",
        subtitle = "rayfield gen2 build",
        theme = "cobalt",
        sidebarLayout = true,
        profile = IS_MOBILE and "mobile" or "desktop",
    })
    hasConfig = false
end

-- abas
local TCombat = Window:CreateTab({ name = "Combat", icon = 93364949241311 })
local TVisual = Window:CreateTab({ name = "Visuals", icon = 88090973560965 })
local TWorld = Window:CreateTab({ name = "World", icon = 89258981739287 })
local TMove = Window:CreateTab({ name = "Movement", icon = 87435173103629 })
local TObj = Window:CreateTab({ name = "Objetos" })
local TConfig = Window:CreateTab({ name = "Config", icon = 125823673784681 })

local Console = TConfig:CreateConsole({
    name = "Console / compatibilidade",
    height = 150,
    follow = true,
    maxLines = 200,
})
Log.console = Console

Window:CreateTag({ text = IS_MOBILE and "mobile" or "desktop", color = Color3.fromRGB(96, 205, 255) })

Window:Notify({
    title = "trident • rayfield",
    content = IS_MOBILE and "Build para celular carregada." or "Build carregada.",
    duration = 4,
})

pcall(function()
    Window:Popup({
        title = "trident • rayfield gen2",
        subtitle = "build 2.0",
        boxes = {
            { title = "Silent aim", description = "Hook no modulo de camera do jogo ou em Camera.CFrame, com predicao, FOV e checagem de visao." },
            { title = "ESP completo", description = "Usa Drawing quando o executor tem; senao cai para Highlight + Billboard." },
            { title = "Celular / Arceus X", description = "Aimbot de camera, hitbox, ESP e speed pelo analogico funcionam sem teclado." },
            { title = "Tudo configuravel", description = "Ids dos remotes (chat e agachar) ficam na aba World, caso o jogo mude." },
        },
        options = { { text = "Comecar", style = "primary" } },
    })
end)

--=====================================================================
-- 4. CAMADA DO JOGO (tudo com fallback)
--=====================================================================
local Game = {
    middle = nil,     -- parte central do personagem local
    top = nil,
    bottom = nil,
    root = nil,       -- modelo/folder do personagem local
    character = nil,  -- Humanoid/AnimationController do personagem local
    tcp = nil,        -- RemoteEvent TCP
    network = nil,    -- _G.Network (API antiga)
    camModule = nil,  -- _G.Camera (modulo de camera antigo)
    charModule = nil, -- _G.Character
    playerModule = nil, -- _G.Player
    tcpChatId = 23,
    tcpCrouchId = 2,
}

function Game.refresh()
    -- a camera pode ser recriada ao trocar de mapa / respawnar
    local cam = Workspace.CurrentCamera
    if cam and cam ~= Camera then Camera = cam end

    -- personagem local: caminho novo (workspace.Const.Ignore.LocalCharacter)
    local const = Workspace:FindFirstChild("Const")
    local ignore = const and const:FindFirstChild("Ignore")
    local localChar = ignore and ignore:FindFirstChild("LocalCharacter")

    if localChar then
        Game.root = localChar
        Game.middle = localChar:FindFirstChild("Middle")
        Game.top = localChar:FindFirstChild("Top")
        Game.bottom = localChar:FindFirstChild("Bottom")
    end

    -- fallback: modulos globais antigos
    if not Game.middle then
        local mod = Game.charModule or gameGlobal("Character")
        if type(mod) == "table" then
            Game.charModule = mod
            local ch = mod.character
            local parts = type(ch) == "table" and (ch.parts or ch) or nil
            if type(parts) == "table" then
                Game.middle = Game.middle or parts.Middle
                Game.top = Game.top or parts.Top
                Game.bottom = Game.bottom or parts.Bottom
                Game.root = Game.root or (ch.character or ch.model)
            end
        end
    end

    -- humanoid (para MoveDirection no celular)
    local plrChar = LocalPlayer.Character
    if plrChar then
        local hum = plrChar:FindFirstChildOfClass("Humanoid")
            or plrChar:FindFirstChild("Humanoid")
        if hum then Game.character = hum end
    end

    -- remote TCP
    if not Game.tcp then
        Game.tcp = LocalPlayer:FindFirstChild("TCP")
    end
    if not Game.tcp then
        -- busca rasa por RemoteEvent "TCP" dentro do LocalPlayer
        for _, d in pairs(LocalPlayer:GetDescendants()) do
            if d:IsA("RemoteEvent") and d.Name == "TCP" then
                Game.tcp = d
                break
            end
        end
    end
    if not Game.tcp then
        for _, d in pairs(ReplicatedStorage:GetDescendants()) do
            if d:IsA("RemoteEvent") and d.Name == "TCP" then
                Game.tcp = d
                break
            end
        end
    end

    -- modulos globais
    Game.network = Game.network or gameGlobal("Network")
    Game.camModule = Game.camModule or gameGlobal("Camera")
    Game.charModule = Game.charModule or gameGlobal("Character")
    Game.playerModule = Game.playerModule or gameGlobal("Player")
end

function Game.hasCharacter()
    Game.refresh()
    return Game.middle ~= nil
end

-- dispara no remote: canal numerico (TCP) ou comando por nome (Network)
-- (args e capturado em tabela porque Luau nao aceita "..." dentro de closure)
function Game.send(cmd, ...)
    local args = { ... }
    if type(cmd) == "string" and type(Game.network) == "table" and type(Game.network.Send) == "function" then
        local ok = safecall(function()
            return Game.network.Send(cmd, unpack(args))
        end)
        return ok ~= nil
    end
    if Game.tcp then
        local ok = safecall(function() Game.tcp:FireServer(unpack(args)) end)
        return ok ~= nil
    end
    return false
end

function Game.sendTcp(...)
    local args = { ... }
    if Game.tcp then
        safecall(function() Game.tcp:FireServer(unpack(args)) end)
        return true
    end
    return false
end

--=====================================================================
-- 5. LOOP CENTRAL
--=====================================================================
local updaters = {}
local slowUpdates = {}
local running = true

local function addUpdater(fn) table.insert(updaters, fn) end
local function addSlow(fn) table.insert(slowUpdates, fn) end

local broken = {}
local function safeUpdater(fn, dt)
    local ok, err = pcall(fn, dt)
    if not ok and not broken[fn] then
        broken[fn] = true
        Log:once(tostring(fn) .. "err", "loop com erro (desativado): " .. tostring(err))
    end
    return ok
end

local frameConn = RunService.RenderStepped:Connect(function(dt)
    if not running then return end
    for i = #updaters, 1, -1 do
        local fn = updaters[i]
        if fn then
            if not safeUpdater(fn, dt) then
                updaters[i] = nil
            end
        end
    end
end)

task.spawn(function()
    while running do
        task.wait(1)
        if not running then break end
        for i = #slowUpdates, 1, -1 do
            local fn = slowUpdates[i]
            if fn then
                if not pcall(fn) then slowUpdates[i] = nil end
            end
        end
    end
end)

--=====================================================================
-- 6. ENTIDADES / ALVOS
--=====================================================================
local entityCache = { list = {}, stamp = 0 }

local function isSleeping(model)
    local head = model:FindFirstChild("Head")
    if not head then return false end
    -- metodo antigo do jogo (se existir)
    local ok, rot = pcall(function() return head.Rotation end)
    if ok and typeof(rot) == "Vector3" then
        if rot.Z == -75 or rot.Z == 45 then return true end
    end
    -- metodo generico: cabeca deitada = up vector longe do eixo Y
    local ok2, up = pcall(function() return head.CFrame.UpVector end)
    if ok2 and typeof(up) == "Vector3" then
        if math.abs(up.Y) < 0.45 then return true end
    end
    return false
end

local function collectEntities()
    local out = {}
    local myChar = LocalPlayer.Character
    for _, v in pairs(Workspace:GetChildren()) do
        if v ~= Game.root and v ~= myChar and v:IsA("Model") then
            local head = v:FindFirstChild("Head")
            local torso = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso") or v:FindFirstChild("LowerTorso")
            local hum = v:FindFirstChildOfClass("Humanoid") or v:FindFirstChild("Humanoid")
            if head and hum then
                local hp, maxHp = 100, 100
                pcall(function() hp = hum.Health; maxHp = hum.MaxHealth end)
                if not hp or hp > 0 then
                    -- GetPlayerFromCharacter e a unica forma confiavel de
                    -- separar player de NPC (nome do modelo engana)
                    local plr = nil
                    pcall(function() plr = Players:GetPlayerFromCharacter(v) end)
                    local weapon = nil
                    pcall(function()
                        local tool = v:FindFirstChildOfClass("Tool")
                        if tool then weapon = tool.Name end
                    end)
                    local isPlayer = plr ~= nil or Players:FindFirstChild(v.Name) ~= nil or v.Name == "Player"
                    table.insert(out, {
                        model = v,
                        head = head,
                        torso = torso,
                        humanoid = hum,
                        hp = hp,
                        maxHp = maxHp,
                        weapon = weapon,
                        isPlayer = isPlayer,
                    })
                end
            end
        end
    end
    return out
end

local function getEntities(force)
    local now = tick()
    -- recria o cache quando vence OU quando esta vazio (evita lista velha vazia)
    if force or next(entityCache.list) == nil or now - entityCache.stamp > 0.35 then
        entityCache.list = collectEntities()
        entityCache.stamp = now
    end
    return entityCache.list
end

local function partPos(part)
    local ok, pos = pcall(function() return part.Position end)
    if ok and typeof(pos) == "Vector3" then return pos end
    return nil
end

local function partVelocity(part)
    local ok, vel = pcall(function() return part.AssemblyLinearVelocity end)
    if ok and typeof(vel) == "Vector3" then return vel end
    local ok2, vel2 = pcall(function() return part.Velocity end)
    if ok2 and typeof(vel2) == "Vector3" then return vel2 end
    return Vector3.new(0, 0, 0)
end

local function isVisible(part)
    local ok, blockers = pcall(function()
        local ig = {}
        local ign = Workspace:FindFirstChild("Ignore")
        if ign then ig = ign:GetDescendants() end
        return Camera:GetPartsObscuringTarget({ part.Position }, ig)
    end)
    if ok and type(blockers) == "table" then return #blockers == 0 end
    return true
end

-- posicao do jogador local com varios fallbacks (o Trident nao usa
-- HumanoidRootPart; Game.middle e o caminho principal, camera e o ultimo)
local function myPosition()
    local middle = partPos(Game.middle)
    if middle then return middle end
    local char = LocalPlayer.Character
    if char then
        local names = { "HumanoidRootPart", "UpperTorso", "Torso", "Middle", "Head" }
        for i = 1, #names do
            local part = char:FindFirstChild(names[i])
            if part then
                local pos = partPos(part)
                if pos then return pos end
            end
        end
    end
    local ok, camPos = pcall(function() return Camera.CFrame.Position end)
    if ok and typeof(camPos) == "Vector3" then return camPos end
    return nil
end

--=====================================================================
-- 7. AIMBOT + SILENT AIM
--=====================================================================
local Aim = {
    enabled = false,
    silent = false,
    activation = "sempre",
    bindHeld = true,
    partName = "Head",
    fov = 220,
    distance = 400,
    smooth = 4,
    prediction = 0.09,
    visibleOnly = false,
    ignoreSleepers = true,
    targetNpc = true,
    -- no celular a mira fica no centro da tela; sem isso o FOV e o alvo
    -- seguem o dedo e o aimbot mira na direcao errada
    centerLock = IS_MOBILE,
}

local Silent = {
    installed = nil,
    moduleOriginal = nil,
    activePos = nil,
}

local function viewportCenter()
    local ok, size = pcall(function() return Camera.ViewportSize end)
    if ok and typeof(size) == "Vector2" then
        return Vector2.new(size.X / 2, size.Y / 2)
    end
    return Vector2.new(640, 360)
end

-- Origem da mira: centro da tela (celular) ou posicao do mouse/toque.
-- GetMouseLocation no celular devolve o ultimo toque, e era isso que
-- arrastava o circulo do FOV junto com o dedo.
local function cursorPoint()
    if Aim.centerLock then return viewportCenter() end
    local ok, loc = pcall(function() return UIS:GetMouseLocation() end)
    if ok and typeof(loc) == "Vector2" then return loc end
    return viewportCenter()
end

local function projectPoint(worldPos)
    local ok, pos, onScreen = pcall(function()
        return Camera:WorldToViewportPoint(worldPos)
    end)
    if ok and typeof(pos) == "Vector3" then
        return Vector2.new(pos.X, pos.Y), onScreen
    end
    return nil, false
end

local function bestTarget()
    if not Aim.enabled and not Aim.silent then return nil end
    if Aim.activation == "bind" and not Aim.bindHeld then return nil end

    local cursor = cursorPoint()
    local myPos = partPos(Game.middle) or (LocalPlayer.Character and partPos(LocalPlayer.Character:FindFirstChild("HumanoidRootPart")))
    local best, bestScore = nil, math.huge

    for _, ent in pairs(getEntities()) do
        if ent.isPlayer or Aim.targetNpc then
            local part = ent.model:FindFirstChild(Aim.partName) or ent.head or ent.torso
            local pos = part and partPos(part)
            if pos and myPos then
                local dist = (pos - myPos).Magnitude
                local skip = false

                if dist > Aim.distance then skip = true end
                if not skip and Aim.ignoreSleepers and isSleeping(ent.model) then skip = true end
                if not skip and Aim.visibleOnly and not isVisible(part) then skip = true end

                if not skip then
                    local screen = projectPoint(pos)
                    if screen then
                        local score = (screen - cursor).Magnitude
                        if score <= Aim.fov and score < bestScore then
                            bestScore = score
                            best = { model = ent.model, part = part, dist = dist }
                        end
                    end
                end
            end
        end
    end
    return best
end

local function predictedPosition(part)
    local pos = partPos(part)
    if not pos then return nil end
    if Aim.prediction > 0 then
        local vel = partVelocity(part)
        pos = pos + vel * Aim.prediction
    end
    return pos
end

--[ silent aim ]-------------------------------------------------------
-- 1) tenta o modulo de camera do jogo (metodo que funcionava no Trident)
-- 2) tenta hook de metatable na instancia Camera
-- 3) se nada existir, o silent cai para aimbot de camera (visual)
local function installSilent()
    if Silent.installed then return true end

    Game.refresh()
    local camMod = Game.camModule
    if type(camMod) == "table" and type(camMod.GetCFrame) == "function" then
        local original = camMod.GetCFrame
        local ok = pcall(function()
            camMod.GetCFrame = function(...)
                local base = original(...)
                local target = Silent.activePos
                if target and typeof(base) == "CFrame" then
                    return CFrame.new(base.Position, target)
                end
                return base
            end
        end)
        if ok then
            Silent.moduleOriginal = original
            Silent.installed = "modulo de camera"
            Log:add("silent aim: hook no modulo de camera do jogo.")
            return true
        end
    end

    if type(getrawmetatable) == "function" and type(setreadonly) == "function" then
        local ok = pcall(function()
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            local wrapper = function(self, key)
                local target = Silent.activePos
                if target and key == "CFrame" and rawequal(self, Camera) then
                    if type(checkcaller) == "function" and not checkcaller() then
                        return CFrame.new(Camera.Position, target)
                    elseif type(checkcaller) ~= "function" then
                        return CFrame.new(Camera.Position, target)
                    end
                end
                return oldIndex(self, key)
            end
            if type(newcclosure) == "function" then
                wrapper = newcclosure(wrapper)
            end
            setreadonly(mt, false)
            mt.__index = wrapper
            setreadonly(mt, true)
        end)
        if ok then
            Silent.installed = "metatable Camera"
            Log:add("silent aim: hook em Camera.CFrame (__index).")
            return true
        end
    end

    Silent.installed = nil
    return false
end

-- loop do alvo
addUpdater(function()
    if not (Aim.enabled or Aim.silent) then
        Silent.activePos = nil
        return
    end

    local target = bestTarget()
    if not target then
        Silent.activePos = nil
        return
    end

    local pos = predictedPosition(target.part)
    if not pos then
        Silent.activePos = nil
        return
    end

    if Aim.silent then
        Silent.activePos = pos
    else
        Silent.activePos = nil
    end

    if Aim.enabled then
        -- aimbot de camera (funciona no celular, sem mouse)
        local camPos = Camera.CFrame.Position
        local goal = CFrame.lookAt(camPos, pos)
        local alpha = math.clamp(1 / math.max(Aim.smooth, 1), 0.02, 1)
        Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
    end
end)

--=====================================================================
-- 8. HITBOX EXPANDER
--=====================================================================
local Hitbox = {
    enabled = false,
    sizeX = 6,
    sizeY = 6,
    transparency = 0.6,
    canCollide = false,
}

local hitboxOriginals = {}

local function hitboxApply()
    for _, ent in pairs(getEntities(true)) do
        local head = ent.head
        if head then
            if not hitboxOriginals[head] then
                hitboxOriginals[head] = {
                    size = head.Size,
                    transparency = head.Transparency,
                    cancollide = head.CanCollide,
                }
            end
            pcall(function()
                head.Size = Vector3.new(Hitbox.sizeX, Hitbox.sizeY, Hitbox.sizeX)
                head.Transparency = Hitbox.transparency
                head.CanCollide = Hitbox.canCollide
            end)
        end
    end
end

local function hitboxRestore()
    for head, orig in pairs(hitboxOriginals) do
        if head and head.Parent then
            pcall(function()
                head.Size = orig.size
                head.Transparency = orig.transparency
                head.CanCollide = orig.cancollide
            end)
        end
    end
    hitboxOriginals = {}
end

addUpdater(function()
    if Hitbox.enabled then hitboxApply() end
end)

--=====================================================================
-- 9. ESP
--=====================================================================
local hasDrawing = false
do
    local ok = pcall(function()
        local obj = Drawing.new("Square")
        obj:Remove()
    end)
    hasDrawing = ok
end

local Esp = {
    enabled = false,
    players = true,
    npc = true,
    weapon = true,
    box = true,
    name = true,
    distance = true,
    health = true,
    tracer = false,
    skeleton = false,
    chams = false,
    maxDistance = 600,
    color = Color3.fromRGB(96, 205, 255),
    npcColor = Color3.fromRGB(255, 120, 120),
    visibleOnly = false,
    ignoreSleepers = false,
}

local espObjects = {}

local function newDrawing(kind, props)
    local obj = Drawing.new(kind)
    if props then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

local function espBox(model)
    local ok, cf, size = pcall(function()
        return model:GetBoundingBox()
    end)
    if not ok or not cf or not size then return nil end

    local corners = {}
    local half = size / 2
    for _, sx in pairs({ -1, 1 }) do
        for _, sy in pairs({ -1, 1 }) do
            for _, sz in pairs({ -1, 1 }) do
                local offset = half * Vector3.new(sx, sy, sz)
                local world = cf * CFrame.new(offset)
                local screen = projectPoint(world.Position)
                if screen then table.insert(corners, screen) end
            end
        end
    end
    if #corners < 2 then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, c in pairs(corners) do
        minX = math.min(minX, c.X)
        minY = math.min(minY, c.Y)
        maxX = math.max(maxX, c.X)
        maxY = math.max(maxY, c.Y)
    end
    if (maxX - minX) < 1 or (maxY - minY) < 1 then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

-- backend desenho ----------------------------------------------------
local function createDrawingEsp(model)
    return {
        box = newDrawing("Square", { Thickness = 1, Filled = false, Color = Esp.color, Transparency = 1 }),
        fill = newDrawing("Square", { Thickness = 1, Filled = true, Color = Esp.color, Transparency = 0.25 }),
        name = newDrawing("Text", { Size = 13, Center = true, Outline = true, Color = Esp.color }),
        dist = newDrawing("Text", { Size = 12, Center = true, Outline = true, Color = Color3.new(1, 1, 1) }),
        health = newDrawing("Square", { Thickness = 1, Filled = true, Color = Color3.fromRGB(80, 220, 120), Transparency = 0.85 }),
        tracer = newDrawing("Line", { Thickness = 1, Color = Esp.color, Transparency = 1 }),
    }
end

local function destroyDrawingEsp(t)
    for _, obj in pairs(t) do
        pcall(function() obj:Remove() end)
    end
end

-- backend gui (mobile) -----------------------------------------------
local function createGuiEsp(model)
    local hl = Instance.new("Highlight")
    hl.Name = "trident_hl"
    hl.FillColor = Esp.color
    hl.FillTransparency = 0.65
    hl.OutlineColor = Esp.color
    hl.OutlineTransparency = 0
    hl.Adornee = model
    hl.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "trident_bb"
    billboard.Size = UDim2.fromScale(0, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = model:FindFirstChild("Head") or model.PrimaryPart

    local label = Instance.new("TextLabel")
    label.Name = "info"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 220, 0, 34)
    label.Position = UDim2.new(0.5, -110, 0, -40)
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextColor3 = Esp.color
    label.TextStrokeTransparency = 0
    label.Text = ""
    label.Parent = billboard
    billboard.Parent = game:GetService("CoreGui")

    return { gui = billboard, label = label, highlight = hl }
end

local function destroyGuiEsp(t)
    pcall(function() if t.gui then t.gui:Destroy() end end)
    pcall(function() if t.highlight then t.highlight:Destroy() end end)
end

-- update -------------------------------------------------------------
local function updateEsp()
    local alive = {}
    local myPos = myPosition()

    for _, ent in pairs(getEntities()) do
        local pos = partPos(ent.head) or (ent.torso and partPos(ent.torso))
        local dist = nil
        if pos and myPos then dist = (pos - myPos).Magnitude end
        local skip = false

        if not pos then skip = true end
        if not skip and dist and dist > Esp.maxDistance then skip = true end
        if not skip and ent.isPlayer and not Esp.players then skip = true end
        if not skip and (not ent.isPlayer) and not Esp.npc then skip = true end
        if not skip and Esp.ignoreSleepers and isSleeping(ent.model) then skip = true end
        if not skip and Esp.visibleOnly and not isVisible(ent.head) then skip = true end

        local entColor = ent.isPlayer and Esp.color or Esp.npcColor
        local distTxt = dist and string.format("%dm", math.floor(dist)) or "?"
        local nameTxt = ent.model.Name
        if Esp.weapon and ent.weapon and ent.weapon ~= "" then
            nameTxt = nameTxt .. "  [" .. tostring(ent.weapon) .. "]"
        end

        if not skip then
            local key = ent.model
            alive[key] = true
            local obj = espObjects[key]

            if hasDrawing then
                if not obj then
                    obj = createDrawingEsp(ent.model)
                    espObjects[key] = obj
                end

                local tl, size = espBox(ent.model)
                if tl and size then
                    obj.box.Visible = Esp.box
                    obj.fill.Visible = Esp.box and Esp.chams
                    obj.box.Position = tl
                    obj.box.Size = size
                    obj.fill.Position = tl
                    obj.fill.Size = size
                    obj.box.Color = entColor
                    obj.fill.Color = entColor

                    local bottom = tl + Vector2.new(0, size.Y)

                    obj.name.Visible = Esp.name
                    obj.name.Text = nameTxt
                    obj.name.Position = Vector2.new(tl.X + size.X / 2, tl.Y - 16)
                    obj.name.Color = entColor

                    obj.dist.Visible = Esp.distance
                    obj.dist.Text = distTxt
                    obj.dist.Position = Vector2.new(tl.X + size.X / 2, bottom.Y + 2)

                    obj.health.Visible = Esp.health
                    local hp = 100
                    pcall(function() hp = (ent.humanoid.Health / math.max(ent.humanoid.MaxHealth, 1)) * 100 end)
                    obj.health.Position = Vector2.new(tl.X - 6, bottom.Y - (size.Y * hp / 100))
                    obj.health.Size = Vector2.new(3, size.Y * hp / 100)

                    obj.tracer.Visible = Esp.tracer
                    obj.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    obj.tracer.To = Vector2.new(tl.X + size.X / 2, bottom.Y)
                    obj.tracer.Color = entColor
                else
                    for _, o in pairs(obj) do pcall(function() o.Visible = false end) end
                end
            else
                if not obj then
                    obj = createGuiEsp(ent.model)
                    espObjects[key] = obj
                end
                pcall(function()
                    obj.highlight.FillColor = entColor
                    obj.highlight.OutlineColor = entColor
                    obj.highlight.Enabled = Esp.chams or Esp.box
                    local txt = {}
                    if Esp.name then table.insert(txt, nameTxt) end
                    if Esp.distance then table.insert(txt, distTxt) end
                    if Esp.health then
                        local hp = 100
                        pcall(function() hp = math.floor((ent.humanoid.Health / math.max(ent.humanoid.MaxHealth, 1)) * 100) end)
                        table.insert(txt, hp .. "%")
                    end
                    obj.label.Text = table.concat(txt, "  ")
                    obj.label.TextColor3 = entColor
                end)
            end
        end
    end

    -- limpa quem saiu
    for model, obj in pairs(espObjects) do
        if not alive[model] or not model.Parent then
            if hasDrawing then destroyDrawingEsp(obj) else destroyGuiEsp(obj) end
            espObjects[model] = nil
        end
    end
end

local function clearEsp()
    for model, obj in pairs(espObjects) do
        if hasDrawing then destroyDrawingEsp(obj) else destroyGuiEsp(obj) end
        espObjects[model] = nil
    end
end

addUpdater(function()
    if Esp.enabled then
        updateEsp()
    elseif next(espObjects) ~= nil then
        clearEsp()
    end
end)

-- ore esp -------------------------------------------------------------
local OreEsp = {
    enabled = false,
    maxDistance = 400,
}

local oreObjects = {}

local function oreLabelFor(model)
    local kind, color = "Ore", Color3.fromRGB(205, 205, 205)
    local count = 0
    for _, child in pairs(model:GetChildren()) do
        count = count + 1
        if child:IsA("MeshPart") then
            local ok, bc = pcall(function() return child.BrickColor.Number end)
            if ok then
                if bc == 352 then
                    kind, color = "Iron", Color3.fromRGB(199, 172, 120)
                elseif bc == 1001 then
                    kind, color = "Nitrate", Color3.fromRGB(248, 248, 248)
                end
            end
        end
    end
    if count == 1 then kind = "Stone" end
    return kind, color
end

-- procura o minerio: aceita filho "rock", "Meshes/rock" ou "Meshes" > "rock"
local function findRock(model)
    local direct = model:FindFirstChild("Meshes/rock") or model:FindFirstChild("rock")
    if direct then return direct end
    local meshes = model:FindFirstChild("Meshes")
    if meshes then return meshes:FindFirstChild("rock") end
    return nil
end

local function updateOreEsp()
    local alive = {}
    local myPos = partPos(Game.middle)

    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == "Model" then
            local rock = findRock(v)
            if rock then
                local pos = partPos(rock)
                local dist = (pos and myPos) and (pos - myPos).Magnitude or 0
                if pos and dist <= OreEsp.maxDistance then
                    alive[v] = true
                    local kind, color = oreLabelFor(v)
                    local obj = oreObjects[v]
                    if hasDrawing then
                        if not obj then
                            obj = {
                                text = newDrawing("Text", { Size = 13, Center = true, Outline = true }),
                            }
                            oreObjects[v] = obj
                        end
                        local screen = projectPoint(pos)
                        obj.text.Visible = screen ~= nil
                        if screen then
                            obj.text.Position = screen
                            obj.text.Text = string.format("%s (%dm)", kind, math.floor(dist))
                            obj.text.Color = color
                        end
                    else
                        if not obj then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "trident_ore"
                            bb.Size = UDim2.fromScale(0, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = rock
                            local lbl = Instance.new("TextLabel")
                            lbl.BackgroundTransparency = 1
                            lbl.Size = UDim2.new(0, 160, 0, 20)
                            lbl.Position = UDim2.new(0.5, -80, 0, -26)
                            lbl.Font = Enum.Font.Code
                            lbl.TextSize = 12
                            lbl.TextStrokeTransparency = 0
                            lbl.Parent = bb
                            bb.Parent = game:GetService("CoreGui")
                            obj = { gui = bb, label = lbl }
                            oreObjects[v] = obj
                        end
                        pcall(function()
                            obj.label.Text = string.format("%s (%dm)", kind, math.floor(dist))
                            obj.label.TextColor3 = color
                        end)
                    end
                end
            end
        end
    end

    for model, obj in pairs(oreObjects) do
        if not alive[model] or not model.Parent then
            if hasDrawing then
                pcall(function() obj.text:Remove() end)
            else
                pcall(function() obj.gui:Destroy() end)
            end
            oreObjects[model] = nil
        end
    end
end

addUpdater(function()
    if OreEsp.enabled then
        updateOreEsp()
    elseif next(oreObjects) ~= nil then
        for model, obj in pairs(oreObjects) do
            if hasDrawing then
                pcall(function() obj.text:Remove() end)
            else
                pcall(function() obj.gui:Destroy() end)
            end
            oreObjects[model] = nil
        end
    end
end)

--=====================================================================
-- 9.5 OBJETOS DO MUNDO — containers, totens, camas, armas caidas
--=====================================================================
-- A deteccao nao depende de saber o nome exato de cada caixa do jogo:
-- qualquer Model com ProximityPrompt / ClickDetector dentro vira alvo,
-- e os nomes conhecidos (militar, cofre, metal, papelao, totem, cama)
-- entram como padrao extra. Assim o ESP continua funcionando depois de
-- update do Trident, sem eu precisar adivinhar o novo nome da caixa.

local Objects = {
    containers = false,
    totems = false,
    beds = false,
    weapons = false,
    autoLoot = false,
    lootRadius = 22,
    lootDelay = 0.45,
    maxDistance = 350,
    maxLabels = 55,
    showAction = true,
    extraNames = "",
}

local PAT_CONTAINER = {
    "crate", "caixa", "cofre", "safe", "vault", "chest", "bau", "baú",
    "box", "container", "loot", "militar", "military", "papel", "cardboard",
    "metal", "supply", "stash", "toolbox", "cargo",
}
local PAT_TOTEM = { "totem" }
local PAT_BED = { "bedroll", "bed", "cama", "sleep", "bag", "spawn", "tent", "barraca", "campfire", "fogueira", "respawn" }
local PAT_WEAPON = { "weapon", "arma", "gun", "rifle", "pistol", "shotgun", "knife", "faca", "bow", "arco", "ammo", "bala", "mag" }

local KIND_COLOR = {
    container = Color3.fromRGB(255, 205, 80),
    totem = Color3.fromRGB(190, 130, 255),
    bed = Color3.fromRGB(110, 235, 150),
    weapon = Color3.fromRGB(255, 140, 90),
    extra = Color3.fromRGB(120, 230, 255),
}

local function lowerStr(s)
    return string.lower(tostring(s or ""))
end

local function matchesAny(name, patterns)
    local low = lowerStr(name)
    if low == "" then return false end
    for i = 1, #patterns do
        if string.find(low, patterns[i], 1, true) then return true end
    end
    return false
end

local function extraPatterns()
    local out = {}
    local raw = tostring(Objects.extraNames or "")
    for piece in string.gmatch(raw, "[^,;]+") do
        local t = lowerStr(piece):gsub("^%s+", ""):gsub("%s+$", "")
        if #t >= 2 then table.insert(out, t) end
    end
    return out
end

-- posicao e parte de referencia (a parte serve de Adornee do BillboardGui)
local function modelRef(model)
    local ok, prim = pcall(function() return model.PrimaryPart end)
    if ok and prim then
        local p = partPos(prim)
        if p then return p, prim end
    end
    local ok2, kids = pcall(function() return model:GetChildren() end)
    if ok2 and kids then
        for _, d in ipairs(kids) do
            if d:IsA("BasePart") then
                local p = partPos(d)
                if p then return p, d end
            end
        end
        local ok3, desc = pcall(function() return model:GetDescendants() end)
        if ok3 and desc then
            for _, d in ipairs(desc) do
                if d:IsA("BasePart") then
                    local p = partPos(d)
                    if p then return p, d end
                end
            end
        end
    end
    if model:IsA("BasePart") then
        local p = partPos(model)
        if p then return p, model end
    end
    return nil, nil
end

local function findPrompt(item)
    local ok, p = pcall(function()
        return item:FindFirstChildOfClass("ProximityPrompt") or item:FindFirstChildOfClass("ClickDetector")
    end)
    if ok and p then return p end
    local ok2, desc = pcall(function() return item:GetDescendants() end)
    if ok2 and desc then
        for _, d in ipairs(desc) do
            local okA, hit = pcall(function()
                return d:IsA("ProximityPrompt") or d:IsA("ClickDetector")
            end)
            if okA and hit then return d end
        end
    end
    return nil
end

local function inspectWorldItem(item, acc)
    if not item or not item.Parent then return end

    if Objects.weapons and item:IsA("Tool") then
        local pos, ref = modelRef(item)
        if pos then
            acc[item] = { kind = "weapon", text = item.Name, pos = pos, part = ref }
        end
        return
    end

    local isModel = item:IsA("Model")
    local isFolder = item:IsA("Folder")
    if not (isModel or isFolder) then return end

    if Objects.containers then
        local prompt = findPrompt(item)
        if prompt then
            local action = ""
            pcall(function()
                action = tostring(prompt.ActionText or "")
                local objectText = tostring(prompt.ObjectText or "")
                if objectText ~= "" then
                    action = (action ~= "" and (action .. " ") or "") .. objectText
                end
            end)
            local pos, ref = modelRef(item)
            if pos then
                acc[item] = { kind = "container", text = item.Name, action = action, prompt = prompt, pos = pos, part = ref }
            end
            return
        end
    end

    if Objects.totems and matchesAny(item.Name, PAT_TOTEM) then
        local pos, ref = modelRef(item)
        if pos then acc[item] = { kind = "totem", text = item.Name, pos = pos, part = ref } end
        return
    end

    if Objects.beds and matchesAny(item.Name, PAT_BED) then
        local pos, ref = modelRef(item)
        if pos then acc[item] = { kind = "bed", text = item.Name, pos = pos, part = ref } end
        return
    end

    if Objects.containers and matchesAny(item.Name, PAT_CONTAINER) then
        local pos, ref = modelRef(item)
        if pos then acc[item] = { kind = "container", text = item.Name, pos = pos, part = ref } end
        return
    end

    local extra = extraPatterns()
    if #extra > 0 and matchesAny(item.Name, extra) then
        local pos, ref = modelRef(item)
        if pos then acc[item] = { kind = "extra", text = item.Name, pos = pos, part = ref } end
    end
end

local worldFound = {}
local worldPass = nil
local worldLabels = {}
local worldLabelTimer = 0

local function anyObjectEspEnabled()
    return Objects.containers or Objects.totems or Objects.beds or Objects.weapons
end

-- varredura com orcamento de tempo por frame: nunca engasga o celular
local function worldScanTick()
    if not anyObjectEspEnabled() then
        if next(worldFound) ~= nil then worldFound = {} end
        worldPass = nil
        return
    end
    if not worldPass then worldPass = { index = 1, acc = {} } end
    local children = Workspace:GetChildren()
    local deadline = os.clock() + 0.0025
    while worldPass.index <= #children and os.clock() < deadline do
        local item = children[worldPass.index]
        worldPass.index = worldPass.index + 1
        pcall(inspectWorldItem, item, worldPass.acc)
    end
    if worldPass.index > #children then
        worldFound = worldPass.acc
        worldPass = { index = 1, acc = {} }
    end
end

local function worldLabel(key, refPart, text, color)
    local obj = worldLabels[key]
    if not obj and hasDrawing and refPart then
        local ok = pcall(function()
            obj = { text = newDrawing("Text", { Size = 13, Center = true, Outline = true }), ref = refPart }
        end)
        if ok and obj then worldLabels[key] = obj end
    end
    if not obj and refPart then
        local ok = pcall(function()
            local bb = Instance.new("BillboardGui")
            bb.Name = "trident_obj"
            bb.Size = UDim2.fromOffset(190, 22)
            bb.StudsOffset = Vector3.new(0, 1.8, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = refPart
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.fromScale(1, 1)
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 12
            lbl.TextStrokeTransparency = 0
            lbl.Text = text
            lbl.TextColor3 = color
            lbl.Parent = bb
            bb.Parent = game:GetService("CoreGui")
            obj = { gui = bb, label = lbl, ref = refPart }
        end)
        if ok and obj then worldLabels[key] = obj end
    end
    if not obj then return end
    pcall(function()
        if obj.text then
            local screen = projectPoint(partPos(refPart) or Vector3.new(0, 0, 0))
            obj.text.Visible = screen ~= nil
            if screen then
                obj.text.Position = screen
                obj.text.Text = text
                obj.text.Color = color
            end
        else
            if obj.ref ~= refPart then
                obj.ref = refPart
                obj.gui.Adornee = refPart
            end
            obj.label.Text = text
            obj.label.TextColor3 = color
        end
    end)
end

local function updateWorldLabels(dt)
    worldLabelTimer = worldLabelTimer + (dt or 0)
    if worldLabelTimer < 0.2 then return end
    worldLabelTimer = 0

    local alive = {}
    local myPos = myPosition()
    local queue = {}

    for key, info in pairs(worldFound) do
        if key.Parent and info.pos then
            local dist = myPos and (info.pos - myPos).Magnitude or 0
            if dist <= Objects.maxDistance then
                queue[#queue + 1] = { key = key, info = info, dist = dist }
            end
        end
    end

    table.sort(queue, function(a, b) return a.dist < b.dist end)

    for i = 1, #queue do
        if i > Objects.maxLabels then break end
        local entry = queue[i]
        local info = entry.info
        local color = KIND_COLOR[info.kind] or KIND_COLOR.extra
        local text = string.format("%s  %dm", tostring(info.text), math.floor(entry.dist))
        if Objects.showAction and info.action and info.action ~= "" then
            text = text .. " [" .. info.action .. "]"
        end
        worldLabel(entry.key, info.part or entry.key, text, color)
        alive[entry.key] = true
    end

    for key, obj in pairs(worldLabels) do
        if not alive[key] then
            if obj.gui then pcall(function() obj.gui:Destroy() end) end
            if obj.text then pcall(function() obj.text:Remove() end) end
            worldLabels[key] = nil
        end
    end
end

local function clearWorldLabels()
    for key, obj in pairs(worldLabels) do
        if obj.gui then pcall(function() obj.gui:Destroy() end) end
        if obj.text then pcall(function() obj.text:Remove() end) end
        worldLabels[key] = nil
    end
end

-- auto loot: dispara o prompt do container mais proximo (fireproximityprompt
-- quando o executor tem; senao tenta InputHoldBegin/End)
local lootTimer = 0

local function firePrompt(prompt)
    if type(fireproximityprompt) == "function" then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then return true end
    end
    local ok2 = pcall(function()
        prompt:InputHoldBegin()
        prompt:InputHoldEnd()
    end)
    return ok2
end

addUpdater(function(dt)
    worldScanTick()
    updateWorldLabels(dt)

    if not Objects.autoLoot then return end
    lootTimer = lootTimer + (dt or 0)
    if lootTimer < Objects.lootDelay then return end
    lootTimer = 0

    local myPos = myPosition()
    if not myPos then return end
    local bestPrompt, bestDist = nil, Objects.lootRadius
    for key, info in pairs(worldFound) do
        if info.kind == "container" and info.prompt and key.Parent and info.pos then
            local dist = (info.pos - myPos).Magnitude
            if dist <= bestDist then
                bestPrompt, bestDist = info.prompt, dist
            end
        end
    end
    if bestPrompt then firePrompt(bestPrompt) end
end)

--=====================================================================
-- 9.6 CHAMS — arco-iris fluido por parte + aura no player local
--=====================================================================
-- Cada parte do modelo ganha um Highlight com matiz propria e deslocada
-- no tempo: as cores andam dentro do corpo em vez de o boneco inteiro
-- piscar de uma cor para outra.

local Chams = {
    players = false,
    npc = false,
    localPlayer = false,
    flow = true,
    speed = 0.4,
    transparency = 0.45,
    outline = true,
    quality = 8,
    depth = true,
    color = Color3.fromRGB(96, 205, 255),
    aura = false,
    auraRate = 14,
}

local chamsModels = {}
local chamsParts = 0
local CHAMS_PART_LIMIT = 280
local chamsHue = 0
local chamsTimer = 0
local auraStore = nil

local function hsvColor(h, s, v)
    return Color3.fromHSV(h % 1, s, v)
end

local function clearModelChams(model)
    local group = chamsModels[model]
    if not group then return end
    for hl in pairs(group.parts) do
        pcall(function() hl:Destroy() end)
        chamsParts = chamsParts - 1
    end
    chamsModels[model] = nil
end

local function clearAllChams()
    for model in pairs(chamsModels) do
        clearModelChams(model)
    end
    chamsModels = {}
    chamsParts = 0
end

local function buildModelChams(model)
    if chamsModels[model] or chamsParts >= CHAMS_PART_LIMIT then return end
    local parts = {}
    pcall(function()
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                parts[#parts + 1] = d
                if #parts >= Chams.quality then break end
            end
        end
    end)
    if #parts == 0 then return end

    local group = { parts = {}, count = #parts }
    for i = 1, #parts do
        if chamsParts >= CHAMS_PART_LIMIT then break end
        local part = parts[i]
        local hl
        local ok = pcall(function()
            hl = Instance.new("Highlight")
            hl.Name = "trident_cham"
            hl.Adornee = part
            hl.Parent = part
        end)
        if ok and hl then
            group.parts[hl] = i / #parts
            chamsParts = chamsParts + 1
        end
    end
    if next(group.parts) ~= nil then
        chamsModels[model] = group
    end
end

local function clearAura()
    if not auraStore then return end
    pcall(function() if auraStore.emitter then auraStore.emitter:Destroy() end end)
    pcall(function() if auraStore.hl then auraStore.hl:Destroy() end end)
    auraStore = nil
end

local function buildAura()
    clearAura()
    local char = LocalPlayer.Character
    if not char then return end
    local root = Game.middle or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not root then return end
    local store = {}
    pcall(function()
        local emitter = Instance.new("ParticleEmitter")
        emitter.Name = "trident_aura"
        emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emitter.Rate = Chams.auraRate
        emitter.Lifetime = NumberRange.new(0.6, 1.3)
        emitter.Speed = NumberRange.new(0.4, 1.6)
        emitter.SpreadAngle = Vector2.new(180, 180)
        emitter.Size = NumberSequence.new(0.55)
        emitter.LightEmission = 1
        emitter.LightInfluence = 0
        emitter.Acceleration = Vector3.new(0, 2.2, 0)
        emitter.Transparency = NumberSequence.new(0.35)
        emitter.Color = ColorSequence.new(hsvColor(chamsHue, 1, 1))
        emitter.Parent = root
        store.emitter = emitter
    end)
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "trident_aura"
        hl.Adornee = char
        hl.FillTransparency = 0.7
        hl.OutlineTransparency = 0
        hl.Parent = char
        store.hl = hl
    end)
    auraStore = store
end

local function updateChams(dt)
    chamsHue = chamsHue + (dt or 0) * Chams.speed

    local anyEntityChams = Chams.players or Chams.npc
    if not anyEntityChams and not Chams.localPlayer then
        if next(chamsModels) ~= nil then clearAllChams() end
        return
    end

    local wanted = {}
    if anyEntityChams then
        for _, ent in pairs(getEntities()) do
            if (ent.isPlayer and Chams.players) or ((not ent.isPlayer) and Chams.npc) then
                wanted[ent.model] = true
            end
        end
    end
    if Chams.localPlayer then
        local char = LocalPlayer.Character
        if char then wanted[char] = true end
    end

    for model in pairs(chamsModels) do
        if not wanted[model] or not model.Parent then clearModelChams(model) end
    end
    for model in pairs(wanted) do
        buildModelChams(model)
    end

    chamsTimer = chamsTimer + (dt or 0)
    if chamsTimer < 0.05 then return end
    chamsTimer = 0

    local depthMode = Chams.depth and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    for _, group in pairs(chamsModels) do
        for hl, offset in pairs(group.parts) do
            local color = Chams.flow and hsvColor(chamsHue + offset, 1, 1) or Chams.color
            pcall(function()
                hl.FillColor = color
                hl.OutlineColor = color
                hl.FillTransparency = Chams.transparency
                hl.OutlineTransparency = Chams.outline and 0 or 1
                hl.DepthMode = depthMode
            end)
        end
    end
end

addUpdater(function(dt)
    updateChams(dt)

    if not Chams.aura then
        if auraStore then clearAura() end
        return
    end

    if not auraStore then buildAura() end
    if not auraStore then return end

    local color = hsvColor(chamsHue, 1, 1)
    pcall(function()
        if auraStore.emitter then
            auraStore.emitter.Color = ColorSequence.new(color)
            auraStore.emitter.Rate = Chams.auraRate
        end
        if auraStore.hl then
            auraStore.hl.FillColor = color
            auraStore.hl.OutlineColor = color
        end
    end)
end)

--=====================================================================
-- 9.7 WORLD FX — gamma falso, saturacao, bloom e atmosfera
--=====================================================================
-- ColorCorrection + Bloom + SunRays + Atmosphere controlados por slider.
-- "Gamma falso" = brilho/contraste/saturacao/tinta combinados, sem mexer
-- no Lighting.Brightness do jogo (que volta sozinho em alguns maps).

local WorldFx = {
    enabled = false,
    preset = "natural",
    brightness = 0.05,
    contrast = 0.12,
    saturation = 0.28,
    tint = Color3.fromRGB(255, 255, 255),
    bloom = false,
    bloomIntensity = 0.7,
    bloomSize = 24,
    bloomThreshold = 0.95,
    sunrays = false,
    atmosphere = false,
    haze = 1.2,
    density = 0.3,
    pulse = false,
}

local FX_PRESETS = {
    natural = { brightness = 0.05, contrast = 0.12, saturation = 0.28, tint = Color3.fromRGB(255, 255, 255), bloom = false, atmosphere = false },
    neon = { brightness = 0.12, contrast = 0.26, saturation = 0.55, tint = Color3.fromRGB(210, 235, 255), bloom = true, atmosphere = false },
    cinema = { brightness = -0.02, contrast = 0.32, saturation = 0.05, tint = Color3.fromRGB(255, 240, 220), bloom = true, atmosphere = true },
    noite = { brightness = 0.35, contrast = 0.22, saturation = 0.18, tint = Color3.fromRGB(170, 200, 255), bloom = false, atmosphere = false },
    vapor = { brightness = 0.08, contrast = 0.2, saturation = 0.62, tint = Color3.fromRGB(255, 170, 240), bloom = true, atmosphere = true },
}

local fxObjects = {}
local fxTimer = 0
local fxPhase = 0

local function destroyFx()
    for key, obj in pairs(fxObjects) do
        pcall(function() obj:Destroy() end)
        fxObjects[key] = nil
    end
end

local function ensureFx()
    if fxObjects.cc then return end
    pcall(function()
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "trident_cc"
        cc.Parent = Lighting
        fxObjects.cc = cc
    end)
    pcall(function()
        local bloom = Instance.new("BloomEffect")
        bloom.Name = "trident_bloom"
        bloom.Enabled = false
        bloom.Parent = Lighting
        fxObjects.bloom = bloom
    end)
    pcall(function()
        local rays = Instance.new("SunRaysEffect")
        rays.Name = "trident_rays"
        rays.Enabled = false
        rays.Parent = Lighting
        fxObjects.rays = rays
    end)
    pcall(function()
        local atm = Instance.new("Atmosphere")
        atm.Name = "trident_atm"
        atm.Enabled = false
        atm.Parent = Lighting
        fxObjects.atm = atm
    end)
end

local function applyPreset(name)
    local preset = FX_PRESETS[name]
    if not preset then return end
    WorldFx.preset = name
    for key, value in pairs(preset) do
        WorldFx[key] = value
    end
end

local function updateWorldFx(dt)
    if not WorldFx.enabled then
        if next(fxObjects) ~= nil then destroyFx() end
        return
    end
    ensureFx()

    fxPhase = fxPhase + (dt or 0)
    fxTimer = fxTimer + (dt or 0)
    if fxTimer < 0.1 then return end
    fxTimer = 0

    local pulse = 0
    if WorldFx.pulse then pulse = math.sin(fxPhase * 2.4) * 0.06 end

    pcall(function()
        local cc = fxObjects.cc
        if cc then
            cc.Brightness = math.clamp(WorldFx.brightness + pulse, -1, 1)
            cc.Contrast = math.clamp(WorldFx.contrast + pulse * 0.5, -1, 1)
            cc.Saturation = math.clamp(WorldFx.saturation + pulse, -1, 1)
            cc.TintColor = WorldFx.tint
        end
        local bloom = fxObjects.bloom
        if bloom then
            bloom.Enabled = WorldFx.bloom
            bloom.Intensity = WorldFx.bloomIntensity
            bloom.Size = WorldFx.bloomSize
            bloom.Threshold = WorldFx.bloomThreshold
        end
        local rays = fxObjects.rays
        if rays then rays.Enabled = WorldFx.sunrays end
        local atm = fxObjects.atm
        if atm then
            atm.Enabled = WorldFx.atmosphere
            atm.Haze = WorldFx.haze
            atm.Density = WorldFx.density
            atm.Color = WorldFx.tint
        end
    end)
end

addUpdater(function(dt)
    updateWorldFx(dt)
end)

--=====================================================================
-- 10. FEATURES DE MOVIMENTO / EXPLOITS
--=====================================================================
local Move = {
    speedEnabled = false,
    speed = 55,
    forceSprint = false,
    freecam = false,
    freecamSpeed = 45,
    freecamOffset = Vector3.new(0, 0, 0),
    noclip = false,
    carFly = false,
    carFlySpeed = 150,
    carFlyUp = 15,
    carFlyAccel = 100,
    carFlyBuild = 0,
    longNeck = false,
    fakeCrouch = false,
}

local moveDirection = Vector3.new(0, 0, 0)

local function readMoveDirection()
    -- 1) humanoid (funciona com analogico no celular)
    if Game.character then
        local ok, dir = pcall(function() return Game.character.MoveDirection end)
        if ok and typeof(dir) == "Vector3" then return dir end
    end
    -- 2) teclado (PC)
    local look = Camera.CFrame.LookVector
    look = Vector3.new(look.X, 0, look.Z)
    local dir = Vector3.new(0, 0, 0)
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + look end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - look end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(-look.Z, 0, look.X) end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(look.Z, 0, -look.X) end
    if dir.Magnitude > 0 then dir = dir.Unit end
    return dir
end

addUpdater(function(dt)
    Game.refresh()
    local middle = Game.middle
    if not middle then return end

    moveDirection = readMoveDirection()

    -- speedhack / forcesprint
    if Move.speedEnabled or Move.forceSprint then
        local dir = moveDirection
        if dir.Magnitude > 0 then
            local speed = Move.speedEnabled and Move.speed or 18
            pcall(function()
                middle.AssemblyLinearVelocity = Vector3.new(dir.X * speed, middle.AssemblyLinearVelocity.Y, dir.Z * speed)
            end)
        end
    end

    -- freecam
    if Move.freecam then
        local camLook = Camera.CFrame.LookVector
        local dir = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camLook end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camLook end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(-camLook.Z, 0, camLook.X) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(camLook.Z, 0, -camLook.X) end
        if dir.Magnitude > 0 then dir = dir.Unit end

        Move.freecamOffset = Move.freecamOffset + dir * (dt * Move.freecamSpeed)
        local base = partPos(middle) or Vector3.new(0, 0, 0)
        pcall(function()
            middle.CFrame = CFrame.new(base + Move.freecamOffset)
            middle.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end)
    elseif Move.freecamOffset.Magnitude > 0 then
        Move.freecamOffset = Vector3.new(0, 0, 0)
    end

    -- noclip
    if Move.noclip then
        local model = Game.root or LocalPlayer.Character
        if model then
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end)

-- car fly (ATV / veiculo proximo)
local function findVehicle()
    local myPos = partPos(Game.middle)
    if not myPos then return nil end
    local best, bestDist = nil, math.huge
    for _, v in pairs(Workspace:GetChildren()) do
        if v:FindFirstChild("Seat") and v:FindFirstChild("Frame") then
            local f = v.Frame
            local pos = partPos(f)
            if pos then
                local dist = (pos - myPos).Magnitude
                if dist < bestDist then
                    best, bestDist = v, dist
                end
            end
        end
    end
    return best
end

addUpdater(function(dt)
    if not Move.carFly then return end
    local car = findVehicle()
    if not car then return end
    local frame = car:FindFirstChild("Frame")
    if not frame then return end

    local ok, dist = pcall(function() return (frame.Position - Camera.CFrame.Position).Magnitude end)
    if not ok or not dist or dist > 60 then return end

    local camLook = Camera.CFrame.LookVector
    local dir = Vector3.new(0, 0, 0)
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camLook end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camLook end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(-camLook.Z, 0, camLook.X) end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(camLook.Z, 0, -camLook.X) end
    if dir.Magnitude > 0 then dir = dir.Unit end

    if dir.Magnitude > 0 then
        Move.carFlyBuild = math.clamp(Move.carFlyBuild + dt * Move.carFlyAccel, 0, Move.carFlySpeed)
    else
        Move.carFlyBuild = math.clamp(Move.carFlyBuild - dt * 150, 0, Move.carFlySpeed)
    end

    for _, part in pairs(car:GetChildren()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.AssemblyLinearVelocity = Vector3.new(
                    dir.X * Move.carFlyBuild,
                    Move.carFlyUp,
                    dir.Z * Move.carFlyBuild
                )
            end)
        end
    end
end)

-- long neck
local longNeckOriginal = nil
local function applyLongNeck(on)
    local top = Game.top
    if not top then return end
    local prism = top:FindFirstChild("Prism1")
    if not prism then return end
    if longNeckOriginal == nil then
        local ok, cf = pcall(function() return prism.CFrame end)
        if ok then longNeckOriginal = cf end
    end
    if longNeckOriginal then
        pcall(function()
            prism.CFrame = on and (longNeckOriginal - Vector3.yAxis * 5) or longNeckOriginal
        end)
    end
end

-- fake crouch (remote) — repete a cada 0.15s, como no script original
local crouchTimer = 0
addUpdater(function(dt)
    if not Move.fakeCrouch then return end
    crouchTimer = crouchTimer + dt
    if crouchTimer >= 0.15 then
        crouchTimer = 0
        Game.sendTcp(Game.tcpCrouchId, true)
    end
end)

--=====================================================================
-- 11. WORLD
--=====================================================================
local World = {
    timeEnabled = false,
    clockTime = 12,
    fullbright = false,
    noFog = false,
}

local LightingCache = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

addSlow(function()
    if World.timeEnabled then
        pcall(function() Lighting.ClockTime = World.clockTime end)
    end
    if World.fullbright then
        pcall(function()
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        end)
    end
    if World.noFog then
        pcall(function() Lighting.FogEnd = 100000 end)
    end
end)

--=====================================================================
-- 12. CHAT
--=====================================================================
local Chat = {
    spam = false,
    text = "trident | rayfield build",
    interval = 2,
    useTcp = true,
}

task.spawn(function()
    while running do
        task.wait(math.max(Chat.interval, 1))
        if Chat.spam and running then
            local sent = false
            if Chat.useTcp then
                sent = Game.sendTcp(Game.tcpChatId, Chat.text, "Global")
            end
            if not sent then
                pcall(function()
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Chat.text, "All")
                end)
            end
        end
    end
end)

--=====================================================================
-- 12.5 OVERLAY (FOV / crosshair) — so quando o executor tem Drawing
--=====================================================================
local Overlay = {
    fov = false,
    crosshair = false,
    color = Color3.fromRGB(255, 255, 255),
    objects = nil,
}

local function ensureOverlay()
    if not hasDrawing then return nil end
    if Overlay.objects then return Overlay.objects end
    local ok, objs = pcall(function()
        return {
            circle = newDrawing("Circle", { Thickness = 1, Filled = false, Transparency = 1 }),
            box = newDrawing("Square", { Thickness = 1, Filled = false, Transparency = 1 }),
            dot = newDrawing("Square", { Thickness = 1, Filled = true, Transparency = 1 }),
        }
    end)
    if not ok or not objs then return nil end
    Overlay.objects = objs
    return objs
end

addUpdater(function()
    local o = Overlay.objects
    if not (Overlay.fov or Overlay.crosshair) then
        if o then
            for _, obj in pairs(o) do pcall(function() obj.Visible = false end) end
        end
        return
    end

    o = ensureOverlay()
    if not o then return end

    local cursor = cursorPoint()

    if Overlay.fov then
        pcall(function()
            o.circle.Visible = true
            o.circle.Position = cursor
            o.circle.Radius = Aim.fov
            o.circle.Color = Overlay.color
            o.circle.Transparency = 1
        end)
    else
        pcall(function() o.circle.Visible = false end)
    end

    if Overlay.crosshair then
        pcall(function()
            o.box.Visible = true
            o.box.Position = cursor - Vector2.new(4, 4)
            o.box.Size = Vector2.new(8, 8)
            o.box.Color = Overlay.color
            o.dot.Visible = true
            o.dot.Position = cursor - Vector2.new(1, 1)
            o.dot.Size = Vector2.new(2, 2)
            o.dot.Color = Overlay.color
        end)
    else
        pcall(function()
            o.box.Visible = false
            o.dot.Visible = false
        end)
    end
end)

--=====================================================================
-- 13. UI — COMBAT
--=====================================================================
TCombat:CreateSection({ name = "Aimbot / Silent aim" })

local toggleAimbot = TCombat:CreateToggle({
    name = "Aimbot (camera)",
    description = "Mira sozinho no alvo mais proximo do centro/FOV. Funciona no celular.",
    flag = "aim_enabled",
    value = false,
    callback = function(v)
        Aim.enabled = v
        if v and Aim.silent then
            Aim.silent = false
            Window:Set("aim_silent", false)
        end
    end,
})

local toggleSilent = TCombat:CreateToggle({
    name = "Silent aim",
    description = "Direciona o tiro sem mover a camera. Precisa de hook no executor.",
    flag = "aim_silent",
    value = false,
    callback = function(v)
        if v then
            local ok = installSilent()
            if not ok then
                Aim.silent = false
                Silent.activePos = nil
                if toggleSilent then toggleSilent:Set(false, true) end
                Window:Notify({
                    title = "Silent aim indisponivel",
                    content = "Seu executor nao expoe getrawmetatable/setreadonly. Use o Aimbot de camera.",
                    duration = 6,
                })
                return
            end
            Aim.silent = true
            Aim.enabled = false
            Window:Set("aim_enabled", false)
        else
            Aim.silent = false
            Silent.activePos = nil
        end
    end,
})

TCombat:CreateDropdown({
    name = "Ativacao",
    description = "No celular use 'sempre'.",
    flag = "aim_activation",
    options = { "sempre", "bind (segurar)" },
    value = "sempre",
    callback = function(opt)
        Aim.activation = opt
    end,
})

local bindAim = TCombat:CreateKeybind({
    name = "Tecla do aim / silent",
    description = "Segure para mirar (PC). No celular use ativacao 'sempre'.",
    flag = "aim_bind",
    hold = true,
    value = Enum.KeyCode.Q,
    callback = function(state)
        if type(state) == "boolean" then
            Aim.bindHeld = state
        else
            Aim.bindHeld = true
        end
    end,
})

TCombat:CreateDropdown({
    name = "Parte do alvo",
    flag = "aim_part",
    options = { "Head", "Torso", "UpperTorso" },
    value = "Head",
    callback = function(opt)
        Aim.partName = opt
    end,
})

TCombat:CreateSlider({
    name = "FOV (pixels)",
    flag = "aim_fov",
    range = { 20, 800 },
    increment = 10,
    value = 220,
    callback = function(v) Aim.fov = v end,
})

TCombat:CreateSlider({
    name = "Distancia maxima",
    flag = "aim_dist",
    range = { 20, 1500 },
    increment = 10,
    value = 400,
    suffix = "m",
    callback = function(v) Aim.distance = v end,
})

TCombat:CreateSlider({
    name = "Suavizacao",
    flag = "aim_smooth",
    range = { 1, 30 },
    increment = 1,
    value = 4,
    description = "1 = trava na hora, 30 = bem devagar.",
    callback = function(v) Aim.smooth = v end,
})

TCombat:CreateSlider({
    name = "Predicao",
    flag = "aim_pred",
    range = { 0, 0.4 },
    increment = 0.01,
    value = 0.09,
    suffix = "s",
    description = "Compensa o movimento do alvo.",
    callback = function(v) Aim.prediction = v end,
})

TCombat:CreateToggle({
    name = "So se estiver visivel",
    flag = "aim_visible",
    value = false,
    callback = function(v) Aim.visibleOnly = v end,
})

TCombat:CreateToggle({
    name = "Ignorar quem esta dormindo",
    flag = "aim_sleepers",
    value = true,
    callback = function(v) Aim.ignoreSleepers = v end,
})

TCombat:CreateToggle({
    name = "Mirar em NPC",
    flag = "aim_npc",
    value = true,
    callback = function(v) Aim.targetNpc = v end,
})

TCombat:CreateSection({ name = "Mira no celular" })

TCombat:CreateToggle({
    name = "Mira fixa no centro",
    description = "FOV, selecao de alvo e crosshair usam o centro da tela. No celular isso impede a mira de seguir o dedo.",
    flag = "aim_center",
    value = IS_MOBILE,
    callback = function(v)
        Aim.centerLock = v
        Window:Notify({
            title = v and "Mira no centro" or "Mira no dedo",
            content = v and "FOV e alvo travados no centro da tela." or "FOV e alvo seguem o toque.",
            duration = 3,
        })
    end,
})

TCombat:CreateSection({ name = "Hitbox" })

TCombat:CreateToggle({
    name = "Hitbox expander",
    description = "Aumenta a cabeca dos alvos (facilita acertar).",
    flag = "hb_enabled",
    value = false,
    callback = function(v)
        Hitbox.enabled = v
        if not v then hitboxRestore() end
    end,
})

TCombat:CreateSlider({
    name = "Hitbox tamanho",
    flag = "hb_size",
    range = { 1, 15 },
    increment = 1,
    value = 6,
    callback = function(v)
        Hitbox.sizeX = v
        Hitbox.sizeY = v
    end,
})

TCombat:CreateSlider({
    name = "Hitbox transparencia",
    flag = "hb_transp",
    range = { 0, 1 },
    increment = 0.1,
    value = 0.6,
    callback = function(v) Hitbox.transparency = v end,
})

TCombat:CreateToggle({
    name = "Hitbox com colisao",
    flag = "hb_collide",
    value = false,
    callback = function(v) Hitbox.canCollide = v end,
})

--=====================================================================
-- 14. UI — VISUALS
--=====================================================================
TVisual:CreateSection({ name = "ESP de players" })

TVisual:CreateToggle({
    name = "Players",
    flag = "esp_players",
    value = true,
    callback = function(v) Esp.players = v end,
})

TVisual:CreateToggle({
    name = "NPC",
    description = "Inimigos do mapa, separados dos players.",
    flag = "esp_npc",
    value = true,
    callback = function(v) Esp.npc = v end,
})

TVisual:CreateToggle({
    name = "Arma na mao",
    description = "Mostra o nome da arma que o alvo esta segurando.",
    flag = "esp_weapon",
    value = true,
    callback = function(v) Esp.weapon = v end,
})

TVisual:CreateToggle({
    name = "ESP ativo",
    description = hasDrawing and "Backend: Drawing." or "Backend: Highlight + Billboard (mobile).",
    flag = "esp_enabled",
    value = false,
    callback = function(v)
        Esp.enabled = v
        if not v then clearEsp() end
    end,
})

TVisual:CreateToggle({
    name = "Caixa",
    flag = "esp_box",
    value = true,
    callback = function(v) Esp.box = v end,
})

TVisual:CreateToggle({
    name = "Chams / preenchimento",
    flag = "esp_chams",
    value = false,
    callback = function(v) Esp.chams = v end,
})

TVisual:CreateToggle({
    name = "Nome",
    flag = "esp_name",
    value = true,
    callback = function(v) Esp.name = v end,
})

TVisual:CreateToggle({
    name = "Distancia",
    flag = "esp_dist",
    value = true,
    callback = function(v) Esp.distance = v end,
})

TVisual:CreateToggle({
    name = "Vida",
    flag = "esp_health",
    value = true,
    callback = function(v) Esp.health = v end,
})

TVisual:CreateToggle({
    name = "Tracer",
    flag = "esp_tracer",
    value = false,
    callback = function(v) Esp.tracer = v end,
})

TVisual:CreateToggle({
    name = "So visiveis",
    flag = "esp_visible",
    value = false,
    callback = function(v) Esp.visibleOnly = v end,
})

TVisual:CreateSlider({
    name = "Distancia maxima do ESP",
    flag = "esp_maxdist",
    range = { 50, 1500 },
    increment = 50,
    value = 600,
    suffix = "m",
    callback = function(v) Esp.maxDistance = v end,
})

TVisual:CreateColorPicker({
    name = "Cor do ESP",
    flag = "esp_color",
    color = Color3.fromRGB(96, 205, 255),
    callback = function(color) Esp.color = color end,
})

TVisual:CreateSection({ name = "Chams arco-iris" })

TVisual:CreateToggle({
    name = "Chams em players",
    description = "Cada parte do corpo com matiz diferente: as cores andam dentro do modelo.",
    flag = "cham_players",
    value = false,
    callback = function(v) Chams.players = v end,
})

TVisual:CreateToggle({
    name = "Chams em NPC",
    flag = "cham_npc",
    value = false,
    callback = function(v) Chams.npc = v end,
})

TVisual:CreateToggle({
    name = "Chams no player local",
    description = "Visual estetico no seu personagem.",
    flag = "cham_local",
    value = false,
    callback = function(v) Chams.localPlayer = v end,
})

TVisual:CreateToggle({
    name = "Cores em movimento",
    description = "Desligado usa a cor fixa do seletor.",
    flag = "cham_flow",
    value = true,
    callback = function(v) Chams.flow = v end,
})

TVisual:CreateSlider({
    name = "Velocidade das cores",
    flag = "cham_speed",
    range = { 0.05, 2 },
    increment = 0.05,
    value = 0.4,
    callback = function(v) Chams.speed = v end,
})

TVisual:CreateSlider({
    name = "Transparencia do chams",
    flag = "cham_transp",
    range = { 0, 0.9 },
    increment = 0.05,
    value = 0.45,
    callback = function(v) Chams.transparency = v end,
})

TVisual:CreateSlider({
    name = "Partes por modelo",
    description = "Mais partes = mais arco-iris, mais custo no celular.",
    flag = "cham_quality",
    range = { 2, 16 },
    increment = 1,
    value = 8,
    callback = function(v)
        Chams.quality = v
        if next(chamsModels) ~= nil then clearAllChams() end
    end,
})

TVisual:CreateToggle({
    name = "Contorno",
    flag = "cham_outline",
    value = true,
    callback = function(v) Chams.outline = v end,
})

TVisual:CreateToggle({
    name = "Sempre na frente",
    description = "Mostra o chams mesmo atraves da parede.",
    flag = "cham_depth",
    value = true,
    callback = function(v) Chams.depth = v end,
})

TVisual:CreateColorPicker({
    name = "Cor fixa do chams",
    flag = "cham_color",
    color = Color3.fromRGB(96, 205, 255),
    callback = function(color) Chams.color = color end,
})

TVisual:CreateSection({ name = "Aura (player local)" })

TVisual:CreateToggle({
    name = "Aura estetica",
    description = "Particulas e brilho arco-iris no seu personagem.",
    flag = "aura_on",
    value = false,
    callback = function(v) Chams.aura = v end,
})

TVisual:CreateSlider({
    name = "Particulas por segundo",
    flag = "aura_rate",
    range = { 1, 60 },
    increment = 1,
    value = 14,
    callback = function(v) Chams.auraRate = v end,
})

TVisual:CreateSection({ name = "Overlay na tela" })

TVisual:CreateToggle({
    name = "Circulo do FOV",
    description = hasDrawing and "Desenha o raio de mira na tela." or "Precisa de executor com Drawing.",
    flag = "ov_fov",
    value = false,
    callback = function(v)
        Overlay.fov = v
        if v and not hasDrawing then
            Window:Notify({ title = "Sem Drawing", content = "Este executor nao desenha na tela. O FOV continua valendo.", duration = 5 })
        end
    end,
})

TVisual:CreateToggle({
    name = "Crosshair",
    description = hasDrawing and "Mira fixa no centro." or "Precisa de executor com Drawing.",
    flag = "ov_cross",
    value = false,
    callback = function(v) Overlay.crosshair = v end,
})

TVisual:CreateColorPicker({
    name = "Cor do overlay",
    flag = "ov_color",
    color = Color3.fromRGB(255, 255, 255),
    callback = function(color) Overlay.color = color end,
})

TVisual:CreateSection({ name = "Ore ESP" })

TVisual:CreateToggle({
    name = "Ore ESP ativo",
    description = "Ferro, nitrato e pedra pelo mapa.",
    flag = "ore_enabled",
    value = false,
    callback = function(v) OreEsp.enabled = v end,
})

TVisual:CreateSlider({
    name = "Distancia do Ore ESP",
    flag = "ore_dist",
    range = { 50, 1200 },
    increment = 50,
    value = 400,
    suffix = "m",
    callback = function(v) OreEsp.maxDistance = v end,
})

TVisual:CreateButton({
    name = "ESP nativo do jogo (Player.SetEsp)",
    description = "Usa a funcao de ESP que ja existe no Trident. Pode ser detectavel.",
    callback = function()
        Game.refresh()
        local mod = Game.playerModule
        if type(mod) == "table" and type(mod.SetEsp) == "function" then
            local ok = pcall(function() mod.SetEsp(true) end)
            Window:Notify({
                title = ok and "ESP nativo ligado" or "Falhou",
                content = ok and "Player.SetEsp(true)" or "a funcao existe mas deu erro.",
                duration = 4,
            })
        else
            Window:Notify({
                title = "Nao disponivel",
                content = "Player.SetEsp nao foi encontrado nesta versao do jogo.",
                duration = 5,
            })
        end
    end,
})

--=====================================================================
-- 15. UI — WORLD
--=====================================================================
TWorld:CreateSection({ name = "Ambiente" })

TWorld:CreateToggle({
    name = "Time changer",
    flag = "world_time_on",
    value = false,
    callback = function(v) World.timeEnabled = v end,
})

TWorld:CreateSlider({
    name = "Hora do dia",
    flag = "world_time",
    range = { 0, 24 },
    increment = 0.5,
    value = 12,
    callback = function(v) World.clockTime = v end,
})

TWorld:CreateToggle({
    name = "Fullbright",
    flag = "world_bright",
    value = false,
    callback = function(v)
        World.fullbright = v
        if not v then
            pcall(function()
                Lighting.Brightness = LightingCache.Brightness
                Lighting.Ambient = LightingCache.Ambient
                Lighting.OutdoorAmbient = LightingCache.OutdoorAmbient
            end)
        end
    end,
})

TWorld:CreateToggle({
    name = "Sem fog",
    flag = "world_fog",
    value = false,
    callback = function(v)
        World.noFog = v
        if not v then
            pcall(function() Lighting.FogEnd = LightingCache.FogEnd end)
        end
    end,
})

TWorld:CreateSection({ name = "Chat" })

TWorld:CreateToggle({
    name = "Chat spam",
    flag = "chat_spam",
    value = false,
    callback = function(v) Chat.spam = v end,
})

TWorld:CreateSlider({
    name = "Intervalo do spam",
    flag = "chat_interval",
    range = { 1, 10 },
    increment = 1,
    value = 2,
    suffix = "s",
    callback = function(v) Chat.interval = v end,
})

TWorld:CreateInput({
    name = "Mensagem do spam",
    flag = "chat_text",
    value = "trident | rayfield build",
    placeholder = "texto enviado no chat",
    callback = function(text) Chat.text = text end,
})

TWorld:CreateInput({
    name = "ID do remote de chat",
    flag = "chat_remote_id",
    numeric = true,
    value = "23",
    description = "23 no build atual. Se o chat parar, teste outros numeros.",
    callback = function(text)
        local n = tonumber(text)
        if n then Game.tcpChatId = n end
    end,
})

TWorld:CreateSection({ name = "Remotes (se algo parar de funcionar)" })

TWorld:CreateInput({
    name = "ID do remote de agachar",
    flag = "crouch_remote_id",
    numeric = true,
    value = "2",
    callback = function(text)
        local n = tonumber(text)
        if n then Game.tcpCrouchId = n end
    end,
})

TWorld:CreateButton({
    name = "Pegar tudo (quick move)",
    description = "Tenta mover todos os itens do bau/inventario.",
    callback = function()
        Game.refresh()
        local ok = false
        if type(Game.network) == "table" and type(Game.network.Send) == "function" then
            for i = 1, 24 do
                pcall(function() Game.network.Send("QuickMove", i, true) end)
                ok = true
            end
        end
        Window:Notify({
            title = ok and "Grab all enviado" or "Nao disponivel",
            content = ok and "24 slots via Network.Send" or "Network.Send nao encontrado.",
            duration = 4,
        })
    end,
})

TWorld:CreateSection({ name = "Gamma falso / filtro do mundo" })

TWorld:CreateToggle({
    name = "Ativar filtro",
    description = "Color correction + bloom + atmosfera. Deixa o mapa mais claro e bonito.",
    flag = "fx_on",
    value = false,
    callback = function(v) WorldFx.enabled = v end,
})

TWorld:CreateDropdown({
    name = "Preset",
    flag = "fx_preset",
    options = { "natural", "neon", "cinema", "noite", "vapor" },
    currentOption = { "natural" },
    multipleOptions = false,
    callback = function(option)
        local picked = type(option) == "table" and option[1] or option
        applyPreset(tostring(picked))
        Window:Notify({ title = "Preset", content = tostring(picked), duration = 3 })
    end,
})

TWorld:CreateSlider({
    name = "Brilho (gamma)",
    flag = "fx_brightness",
    range = { -0.5, 0.6 },
    increment = 0.01,
    value = 0.05,
    callback = function(v) WorldFx.brightness = v end,
})

TWorld:CreateSlider({
    name = "Contraste",
    flag = "fx_contrast",
    range = { -0.5, 0.6 },
    increment = 0.01,
    value = 0.12,
    callback = function(v) WorldFx.contrast = v end,
})

TWorld:CreateSlider({
    name = "Saturacao",
    flag = "fx_saturation",
    range = { -1, 1 },
    increment = 0.01,
    value = 0.28,
    callback = function(v) WorldFx.saturation = v end,
})

TWorld:CreateColorPicker({
    name = "Tinta do mundo",
    flag = "fx_tint",
    color = Color3.fromRGB(255, 255, 255),
    callback = function(color) WorldFx.tint = color end,
})

TWorld:CreateToggle({
    name = "Bloom",
    flag = "fx_bloom",
    value = false,
    callback = function(v) WorldFx.bloom = v end,
})

TWorld:CreateSlider({
    name = "Intensidade do bloom",
    flag = "fx_bloom_int",
    range = { 0, 3 },
    increment = 0.05,
    value = 0.7,
    callback = function(v) WorldFx.bloomIntensity = v end,
})

TWorld:CreateToggle({
    name = "Raios de sol",
    flag = "fx_rays",
    value = false,
    callback = function(v) WorldFx.sunrays = v end,
})

TWorld:CreateToggle({
    name = "Atmosfera / neblina",
    flag = "fx_atm",
    value = false,
    callback = function(v) WorldFx.atmosphere = v end,
})

TWorld:CreateSlider({
    name = "Densidade da neblina",
    flag = "fx_density",
    range = { 0, 1 },
    increment = 0.01,
    value = 0.3,
    callback = function(v) WorldFx.density = v end,
})

TWorld:CreateToggle({
    name = "Pulsar devagar",
    description = "Brilho e saturacao respirando de leve.",
    flag = "fx_pulse",
    value = false,
    callback = function(v) WorldFx.pulse = v end,
})

--=====================================================================
-- 16. UI — MOVEMENT
--=====================================================================
TMove:CreateSection({ name = "Velocidade" })

TMove:CreateToggle({
    name = "Speedhack",
    description = "Funciona com o analogico no celular.",
    flag = "move_speed_on",
    value = false,
    callback = function(v) Move.speedEnabled = v end,
})

TMove:CreateSlider({
    name = "Velocidade",
    flag = "move_speed",
    range = { 18, 70 },
    increment = 1,
    value = 55,
    callback = function(v) Move.speed = v end,
})

TMove:CreateToggle({
    name = "Forcar sprint",
    flag = "move_sprint",
    value = false,
    callback = function(v) Move.forceSprint = v end,
})

TMove:CreateSection({ name = "Camera e personagem" })

TMove:CreateToggle({
    name = "Freecam",
    description = "Descola a camera do corpo. Use com cuidado.",
    flag = "move_freecam",
    value = false,
    callback = function(v)
        Move.freecam = v
        local parts = { Game.middle, Game.top, Game.bottom }
        for _, p in pairs(parts) do
            if p then pcall(function() p.CanCollide = not v end) end
        end
        if not v then Move.freecamOffset = Vector3.new(0, 0, 0) end
    end,
})

TMove:CreateSlider({
    name = "Velocidade do freecam",
    flag = "move_freecam_speed",
    range = { 5, 200 },
    increment = 5,
    value = 45,
    callback = function(v) Move.freecamSpeed = v end,
})

TMove:CreateToggle({
    name = "Long neck",
    flag = "move_longneck",
    value = false,
    callback = function(v)
        Move.longNeck = v
        applyLongNeck(v)
    end,
})

TMove:CreateToggle({
    name = "Fake crouch (remote)",
    description = "Manda o remote de agachar sem agachar.",
    flag = "move_fakecrouch",
    value = false,
    callback = function(v) Move.fakeCrouch = v end,
})

TMove:CreateToggle({
    name = "Noclip",
    description = "Atravessa paredes. Pode ser detectavel.",
    flag = "move_noclip",
    value = false,
    callback = function(v)
        Move.noclip = v
        local mod = Game.charModule
        if type(mod) == "table" and type(mod.SetNoclipping) == "function" then
            pcall(function() mod.SetNoclipping(v) end)
        end
    end,
})

TMove:CreateSection({ name = "Veiculo" })

TMove:CreateToggle({
    name = "Car fly",
    description = "Voa com o ATV/veiculo mais proximo.",
    flag = "move_carfly",
    value = false,
    callback = function(v)
        Move.carFly = v
        Move.carFlyBuild = 0
    end,
})

TMove:CreateSlider({
    name = "Car fly velocidade",
    flag = "move_carfly_speed",
    range = { 50, 300 },
    increment = 10,
    value = 150,
    callback = function(v) Move.carFlySpeed = v end,
})

TMove:CreateSlider({
    name = "Car fly subida",
    flag = "move_carfly_up",
    range = { 5, 100 },
    increment = 5,
    value = 15,
    callback = function(v) Move.carFlyUp = v end,
})

--=====================================================================
-- 16.5 UI — OBJETOS DO MUNDO
--=====================================================================
TObj:CreateSection({ name = "Containers e itens" })

TObj:CreateToggle({
    name = "Containers",
    description = "Pega qualquer caixa/cofre com prompt de interacao, sem depender do nome.",
    flag = "obj_containers",
    value = false,
    callback = function(v) Objects.containers = v end,
})

TObj:CreateToggle({
    name = "Totens",
    description = "Totens de respawn / claim.",
    flag = "obj_totems",
    value = false,
    callback = function(v) Objects.totems = v end,
})

TObj:CreateToggle({
    name = "Camas e caixa de spawn",
    description = "Saco de dormir, cama, barraca, fogueira e ponto de respawn do player.",
    flag = "obj_beds",
    value = false,
    callback = function(v) Objects.beds = v end,
})

TObj:CreateToggle({
    name = "Armas no chao",
    description = "Tools e armas dropadas.",
    flag = "obj_weapons",
    value = false,
    callback = function(v) Objects.weapons = v end,
})

TObj:CreateSlider({
    name = "Distancia dos objetos",
    flag = "obj_dist",
    range = { 50, 1200 },
    increment = 10,
    suffix = "m",
    value = 350,
    callback = function(v) Objects.maxDistance = v end,
})

TObj:CreateSlider({
    name = "Maximo de etiquetas",
    description = "Limite para nao derrubar o FPS no celular.",
    flag = "obj_labels",
    range = { 5, 150 },
    increment = 5,
    value = 55,
    callback = function(v) Objects.maxLabels = v end,
})

TObj:CreateToggle({
    name = "Mostrar acao do prompt",
    description = "Exibe o texto do prompt (Loot, Abrir, etc) junto do nome.",
    flag = "obj_action",
    value = true,
    callback = function(v) Objects.showAction = v end,
})

TObj:CreateInput({
    name = "Nomes extras",
    description = "Nomes que voce viu no jogo, separados por virgula.",
    placeholder = "cofre_militar, caixa_papelao",
    flag = "obj_extra",
    currentValue = "",
    callback = function(text) Objects.extraNames = tostring(text) end,
})

TObj:CreateButton({
    name = "Escanear agora",
    callback = function()
        worldPass = { index = 1, acc = {} }
        Window:Notify({ title = "Escanear", content = "Varredura do mapa reiniciada.", duration = 3 })
    end,
})

TObj:CreateSection({ name = "Auto loot" })

TObj:CreateToggle({
    name = "Auto loot",
    description = "Dispara o prompt do container mais proximo.",
    flag = "obj_autoloot",
    value = false,
    callback = function(v) Objects.autoLoot = v end,
})

TObj:CreateSlider({
    name = "Raio do auto loot",
    flag = "obj_lootradius",
    range = { 5, 80 },
    increment = 1,
    suffix = "m",
    value = 22,
    callback = function(v) Objects.lootRadius = v end,
})

TObj:CreateSlider({
    name = "Intervalo entre coletas",
    flag = "obj_lootdelay",
    range = { 0.2, 3 },
    increment = 0.05,
    suffix = "s",
    value = 0.45,
    callback = function(v) Objects.lootDelay = v end,
})

--=====================================================================
-- 17. UI — CONFIG
--=====================================================================
TConfig:CreateSection({ name = "Aparencia" })

TConfig:CreateDropdown({
    name = "Tema",
    flag = "ui_theme",
    options = { "default", "cobalt", "ember", "amethyst", "frost", "rose" },
    value = "cobalt",
    callback = function(opt)
        pcall(function() Window:ChangeTheme(opt) end)
    end,
})

TConfig:CreateSection({ name = "Configuracoes salvas" })

TConfig:CreateInput({
    name = "Nome da config",
    flag = "cfg_name",
    value = "default",
    placeholder = "ex: pvp",
})

TConfig:CreateButton({
    name = "Salvar config",
    callback = function()
        local name = Window:Get("cfg_name") or "default"
        local ok = pcall(function() return Window:Save(name) end)
        Window:Notify({ title = ok and "Salvo" or "Falhou", content = tostring(name), duration = 3 })
        pcall(function()
            Window:Toast({ title = ok and "Config salva" or "Falhou ao salvar", subtitle = tostring(name) })
        end)
    end,
})

TConfig:CreateButton({
    name = "Carregar config",
    callback = function()
        local name = Window:Get("cfg_name") or "default"
        local ok = pcall(function() return Window:Load(name) end)
        Window:Notify({ title = ok and "Carregado" or "Falhou", content = tostring(name), duration = 3 })
    end,
})

TConfig:CreateButton({
    name = "Listar configs no console",
    callback = function()
        local ok, list = pcall(function() return Window:ListConfigs() end)
        if ok and type(list) == "table" then
            Log:add("configs: " .. (#list > 0 and table.concat(list, ", ") or "nenhuma"))
        else
            Log:add("configs: nao foi possivel listar")
        end
    end,
})

TConfig:CreateSection({ name = "Sessao" })

local statTargets = TConfig:CreateStat({
    name = "Alvos no mapa",
    description = "Modelos com cabeca e humanoid por perto.",
    value = 0,
})

local statPlayers = TConfig:CreateStat({
    name = "Jogadores no servidor",
    value = #Players:GetPlayers(),
})

TConfig:CreateDivider({ text = "informacoes" })

TConfig:CreateText({
    name = "Como usar no celular",
    text = "Aimbot: ligue 'Aimbot (camera)' e deixe 'Ativacao' em 'sempre'. Silent aim precisa de um executor com getrawmetatable (Arceus X tem em algumas versoes); se aparecer aviso, use o aimbot de camera. Se o chat ou o fake crouch pararem, troque os IDs dos remotes na aba World.",
})

TConfig:CreateDivider()

TConfig:CreateButton({
    name = "Diagnostico",
    description = "Mostra o que o script encontrou no jogo.",
    callback = function()
        Game.refresh()
        Log:add("----- diagnostico -----")
        Log:add("personagem: " .. (Game.middle and "ok" or "NAO ENCONTRADO"))
        Log:add("remote TCP: " .. (Game.tcp and Game.tcp:GetFullName() or "NAO ENCONTRADO"))
        Log:add("Network: " .. (type(Game.network) == "table" and "ok" or "nao"))
        Log:add("modulo Camera: " .. (type(Game.camModule) == "table" and "ok" or "nao"))
        Log:add("modulo Character: " .. (type(Game.charModule) == "table" and "ok" or "nao"))
        Log:add("modulo Player: " .. (type(Game.playerModule) == "table" and "ok" or "nao"))
        Log:add("Drawing: " .. (hasDrawing and "disponivel" or "indisponivel (usando Highlight)"))
        Log:add("silent hook: " .. tostring(Silent.installed or "nao instalado"))
        Log:add("humanoid (analogico): " .. (Game.character and "ok" or "nao (usando teclado)"))
        Log:add("camera: " .. (Camera and Camera:GetFullName() or "sem camera"))
        Log:add("plataforma: " .. (IS_MOBILE and "celular" or "pc"))
        Log:add("mira: " .. (Aim.centerLock and "fixa no centro" or "segue o dedo/mouse"))
        Log:add("objetos no mapa: " .. tostring(#Workspace:GetChildren()))
        Log:add("Highlight: " .. tostring(select(1, pcall(function() local h = Instance.new("Highlight"); h:Destroy() end)) and "ok" or "indisponivel"))
        Log:add("alvos vistos: " .. tostring(#getEntities(true)))
        Window:Notify({ title = "Diagnostico", content = "Veja a aba Config > Console.", duration = 4 })
    end,
})

TConfig:CreateButton({
    name = "Rejoin",
    callback = function()
        local ok = pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
        if not ok then
            pcall(function() LocalPlayer:Kick("rejoin") end)
        end
    end,
})

--=====================================================================
-- 18. UNLOAD
--=====================================================================
local function liftoff()
    running = false
    pcall(function() frameConn:Disconnect() end)

    Silent.activePos = nil
    if Silent.installed == "modulo de camera" and Game.camModule and Silent.moduleOriginal then
        pcall(function() Game.camModule.GetCFrame = Silent.moduleOriginal end)
    end

    Hitbox.enabled = false
    hitboxRestore()

    Esp.enabled = false
    clearEsp()
    clearAllChams()
    clearAura()
    clearWorldLabels()
    destroyFx()

    if Overlay.objects then
        for _, obj in pairs(Overlay.objects) do
            pcall(function() obj:Remove() end)
        end
        Overlay.objects = nil
    end

    pcall(function()
        Lighting.Brightness = LightingCache.Brightness
        Lighting.Ambient = LightingCache.Ambient
        Lighting.OutdoorAmbient = LightingCache.OutdoorAmbient
        Lighting.FogEnd = LightingCache.FogEnd
    end)

    pcall(function() Window:Unload() end)
    print("[trident] unloaded")
end

TConfig:CreateButton({
    name = "Unload",
    description = "Remove a interface e desliga tudo.",
    callback = function() liftoff() end,
})

getgenv = getgenv or function() return _G end
local genv = getgenv()
if type(genv) == "table" then
    genv.trident_unload = liftoff
    genv.trident = { Game = Game, Aim = Aim, Esp = Esp, Move = Move, Hitbox = Hitbox, Silent = Silent, Objects = Objects, Chams = Chams, WorldFx = WorldFx, Window = Window }
end

--=====================================================================
-- 19. START
--=====================================================================
Game.refresh()
Log:add("trident rayfield carregado (" .. (IS_MOBILE and "mobile" or "desktop") .. ")")
Log:add("salvar config: " .. (hasConfig and "ativo" or "indisponivel neste executor"))
Log:add("personagem: " .. (Game.middle and "ok" or "aguardando spawn"))
Log:add("remote TCP: " .. (Game.tcp and "ok" or "nao encontrado"))
Log:add("Drawing: " .. (hasDrawing and "sim" or "nao (fallback Highlight)"))

addSlow(function()
    Game.refresh()
end)

addSlow(function()
    if statTargets then statTargets:Set(#getEntities()) end
    if statPlayers then statPlayers:Set(#Players:GetPlayers()) end
end)
