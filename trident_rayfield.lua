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

    Build 2.6 (somente Linoria, layout do AV0X):
      * Rayfield removido: a UI e so Linoria. Se a Linoria nao carregar o
        script para com mensagem clara em vez de trocar de biblioteca.
      * Abas na ordem do AV0X: Combat, ESP, Visuals, Movement, Objetos,
        UI Settings.
      * Secoes em DUAS colunas (groupbox esquerdo/direito alternando),
        igual aos prints.
      * Secao Configuration/Theme do addon SaveManager oficial da
        Linoria (criar, listar, carregar e sobrescrever config).
      * Watermark com FPS e Ping no canto superior.
      * Modo seguro agora vem DESLIGADO (sem restricao): o silent aim de
        projetil e o EntityMap por debug.getupvalues sobem por padrao.

    Build 2.5 (UI Linoria):
      * A interface passou para Linoria (a mesma do AV0X), que e a que
        se comporta melhor no celular: touch/drag nativos e sem
        depender de MouseButton como o Rayfield.
      * Linoria vem em texto puro (Library.lua) e recebeu um adaptador
        com a MESMA API que o script ja usava (CreateTab, CreateSection,
        CreateToggle, CreateSlider, CreateButton, CreateDropdown,
        CreateKeybind, CreateConsole, Notify, Popup), entao nenhum dos
        157 controles foi reescrito.
      * Se a Linoria nao carregar (executor sem HttpGet/loadstring),
        cai automaticamente no Rayfield Gen2.

    Build 2.4 (modo seguro + engenharia do AV0X):
      * SafeMode ligado por padrao: nao usa debug.getupvalues nem
        debug.getconstants (o jogo loga "Executed a script" e tem
        TamperingDetected). EntityMap so por getgc(true); silent aim
        de projetil recusa instalar e cai no silent aim normal.
      * AV0X (scriptblox 223117) mapeado: loader -> PyhTeT/avox.lol
        -> main de 1,12 MB em VM WeAreDevs + Library.lua e addons em
        texto puro. Decodificador em deob/deob_wearedevs.py.

    Build 2.3 (desofuscacao do Trident V4 + FPS booster):
      * Perf: preset de performance com sombras off, render no
        minimo, particulas off, efeitos de camera off, agua do
        Terrain off e materiais 2022 off, com restauracao total.
        Tecnica lida do Trident V4 (Fazma) desofuscado (ele carrega
        o FPSBooster.lua do CasperFlyModz).

    Build 2.2 (mineracao de 86 repositorios publicos):
      * Silent aim de projetil: hook no createProjectile do
        RangedWeaponClient (getgc + debug.getconstants "ProjectileSpeed"),
        com predicao por ProjectileSpeed/ProjectileDrop e velocidade do
        alvo. Fallback automatico para o silent aim antigo.
      * Dash slide por TCP: FireServer(3,true,Vector3.xAxis) +
        FireServer(2,true) com empurrao na direcao da camera e release
        depois de X segundos (fonte: KumaoRoblox/TridentSurvival).
      * Arma equipada lida do modulo GetEquippedItem via getgc
        (fonte: Panda22MyGod/TridentSurvival), com fallback no Tool.
      * Containers: nomes reais Metal, Cardboard, Crate e deteccao por
        filho Crates/Cables/Lid (fonte: Ocel-hub).
      * EntityMap via getgc para farm/kill aura.

    Build 2.1 (correcao do erro em jogo + fontes novas):
      * FIX do erro "attempt to modify a readonly table": era o
        math.clamp = ... no topo. math e readonly no Luau, entao o clamp
        virou funcao local (era a linha 53 do stack do Developer Console).
      * Personagem local: agora tenta workspace.Ignore.LocalCharacter
        (caminho do Trident atual) e Const.Ignore.LocalCharacter.
      * Catalogo lido de ReplicatedStorage.Shared.entities: tipos reais
        do jogo (Tree, Cactus, Iron, Nitrate, Stone, Totem, cofres,
        NPCs), sem adivinhar nome de caixa.
      * Auto farm e kill aura por TCP (Swing + Hit) com EntityMap,
        com aviso de tampering.

    Fontes publicas usadas:
      github.com/ipso1337/tridenopenscr  -> protocolo TCP Swing/Hit
      github.com/7PXS/ScriptArchive      -> Shared.entities (swimhub pago)
      github.com/6segs/kira              -> ESP (caixas, skeleton, chams)

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
-- math e readonly no Luau: atribuir em math.clamp estoura
-- "attempt to modify a readonly table". Entao o clamp e local.
local function clamp(v, lo, hi)
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
-- 3. UI — LINORIA (unica, sem reserva)
--=====================================================================
-- Layout igual ao do AV0X: abas a esquerda, secoes em duas colunas
-- (groupbox esquerdo/direito), busca por nome, tarja com FPS/Ping e a
-- secao Configuration vinda do addon SaveManager da propria Linoria.
local LINORIA_BASE = "https://raw.githubusercontent.com/PyhTeT/avox.lol/main/"

local function fetchLua(name)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(LINORIA_BASE .. name))()
    end)
    if ok and type(res) == "table" then return res end
    return nil
end

local Library = fetchLua("Library.lua")
if type(Library) ~= "table" or type(Library.CreateWindow) ~= "function" then
    error("[trident] nao consegui carregar a Linoria (HttpGet/loadstring do executor).")
end
if type(Library.LoadConfiguration) == "function" then
    error("[trident] a URL da Linoria devolveu outra biblioteca (Rayfield). Ajuste LINORIA_BASE.")
end

local SaveManager = fetchLua("addons/SaveManager.lua")
local ThemeManager = fetchLua("addons/ThemeManager.lua")

local function enumName(v)
    if type(typeof) == "function" and typeof(v) == "EnumItem" then return v.Name end
    if type(v) == "table" and rawget(v, "Name") then return rawget(v, "Name") end
    local s = tostring(v)
    return (string.match(s, "([%w_]+)$")) or s
end

local UIFlags = {}

local function rememberFlag(o, obj)
    if o and o.flag and obj then UIFlags[o.flag] = obj end
    return obj
end

local function liftGroupbox(g, uid)
    local box, n = {}, 0
    local function key(o)
        n = n + 1
        return tostring(o.flag or o.name or "opt") .. "_" .. tostring(uid) .. "_" .. tostring(n)
    end
    function box:CreateToggle(o)
        local self_ = {}
        pcall(function()
            self_ = g:AddToggle(key(o), {
                Text = o.name,
                Default = o.value and true or false,
                Tooltip = o.description,
                Callback = o.callback,
            })
        end)
        return rememberFlag(o, self_)
    end
    function box:CreateSlider(o)
        local self_ = {}
        local span = (o.max or 1) - (o.min or 0)
        local rounding = o.decimals or (span <= 5 and 1 or 0)
        pcall(function()
            self_ = g:AddSlider(key(o), {
                Text = o.name,
                Default = o.value,
                Min = o.min,
                Max = o.max,
                Rounding = rounding,
                Tooltip = o.description,
                Callback = o.callback,
            })
        end)
        return rememberFlag(o, self_)
    end
    function box:CreateButton(o)
        pcall(function()
            g:AddButton({ Text = o.name, Func = o.callback, Tooltip = o.description })
        end)
        return {}
    end
    function box:CreateDropdown(o)
        local self_ = {}
        pcall(function()
            self_ = g:AddDropdown(key(o), {
                Text = o.name,
                Values = o.options or o.values or {},
                Default = o.value,
                Multi = o.multi or false,
                Tooltip = o.description,
                Callback = o.callback,
            })
        end)
        return rememberFlag(o, self_)
    end
    function box:CreateKeybind(o)
        local self_ = {}
        pcall(function()
            self_ = g:AddKeyPicker(key(o), {
                Text = o.name,
                Default = enumName(o.value or ""),
                Mode = { "Always", "Toggle", "Hold" },
                Tooltip = o.description,
                Callback = o.callback,
            })
        end)
        return self_
    end
    function box:CreateColorPicker(o)
        local self_ = {}
        pcall(function()
            self_ = g:AddColorPicker(key(o), {
                Text = o.name,
                Default = o.value or Color3.fromRGB(255, 255, 255),
                Tooltip = o.description,
                Callback = o.callback,
            })
        end)
        return self_
    end
    function box:CreateInput(o)
        local self_ = {}
        pcall(function()
            self_ = g:AddInput(key(o), {
                Text = o.name,
                Default = o.value,
                Placeholder = o.placeholder,
                Numeric = o.numeric or false,
                Finished = o.callback,
                Tooltip = o.description,
            })
        end)
        return self_
    end
    function box:CreateStat(o)
        local label
        pcall(function() label = g:AddLabel(tostring(o.name) .. ": " .. tostring(o.value or "")) end)
        return {
            Set = function(_, v)
                if label then pcall(function() label:SetText(tostring(o.name) .. ": " .. tostring(v)) end) end
            end,
        }
    end
    function box:CreateText(o)
        pcall(function() g:AddLabel(type(o) == "string" and o or (o and o.text) or "") end)
        return {}
    end
    function box:CreateLabel(o)
        pcall(function() g:AddLabel(type(o) == "string" and o or o.name) end)
        return {}
    end
    function box:CreateDivider()
        pcall(function() g:AddDivider() end)
        return {}
    end
    function box:CreateConsole(o)
        local label, lines = nil, {}
        pcall(function() label = g:AddLabel("console") end)
        return {
            lines = lines,
            Append = function(_, line)
                table.insert(lines, tostring(line))
                if #lines > 6 then table.remove(lines, 1) end
                if label then pcall(function() label:SetText(table.concat(lines, "\n")) end) end
            end,
        }
    end
    return box
end

local function liftTab(t, uid)
    local tab, boxes, turn = {}, {}, 0
    tab.raw = t

    -- duas colunas como no AV0X: secao 1 na esquerda, 2 na direita, 3 na
    -- esquerda... cada coluna tem o proprio groupbox (com scroll).
    local function column(side)
        if not boxes[side] then
            local g
            if side == "left" then
                pcall(function() g = t:AddLeftGroupbox("geral") end)
            else
                pcall(function() g = t:AddRightGroupbox("geral") end)
            end
            boxes[side] = { group = g, box = liftGroupbox(g, tostring(uid) .. "_" .. side) }
        end
        return boxes[side]
    end

    local function nextColumn()
        turn = turn + 1
        return column(turn % 2 == 1 and "left" or "right")
    end

    function tab:CreateSection(o)
        local col = column("left")
        -- titulo da secao como label + divisor na coluna que estiver livre
        if boxes.right == nil or (turn % 2 == 1) then
            col = column("left")
        else
            col = column("right")
        end
        turn = turn + 1
        pcall(function()
            if col.group.AddDivider then col.group:AddDivider() end
            if col.group.AddLabel then col.group:AddLabel(o.name) end
        end)
        return col.box
    end

    local methods = { "CreateToggle", "CreateSlider", "CreateButton", "CreateDropdown", "CreateKeybind", "CreateLabel", "CreateDivider", "CreateColorPicker", "CreateInput", "CreateStat", "CreateText" }
    for _, m in ipairs(methods) do
        tab[m] = function(_, o)
            local col = nextColumn()
            return col.box[m](col.box, o)
        end
    end

    function tab:CreateConsole(o)
        return column("left").box:CreateConsole(o or {})
    end

    return tab
end

-- A janela desta Linoria nasce com Visible = false e so abre quando
-- Config.AutoShow esta ligado ou quando alguem aperta RightShift/RightControl.
-- Sem AutoShow o menu fica invisivel no celular (nao existe tecla), que era
-- exatamente o sintoma do build 2.6/2.7.
local RawWindow
do
    local config = {
        Title = "trident",
        SubTitle = IS_MOBILE and "build 3.2 - mobile" or "build 3.2",
        TabWidth = 170,
        BaseKey = Enum.KeyCode.RightShift,
        Font = nil,
        Center = true,
        AutoShow = true,
    }
    local ok, res = pcall(function() return Library:CreateWindow(config) end)
    if not (ok and type(res) == "table") then
        local ok2, res2 = pcall(function() return Library:CreateWindow({ Title = "trident", AutoShow = true }) end)
        if ok2 and type(res2) == "table" then res = res2 end
    end
    RawWindow = type(res) == "table" and res or nil
end

-- garante a janela aberta mesmo se o AutoShow falhar (task.spawn do
-- executor com timers bloqueados, por exemplo)
pcall(function()
    if not RawWindow then return end
    local holder = RawWindow.Holder or rawget(RawWindow, "Holder")
    if holder and holder.Visible ~= true then
        if type(Library.Toggle) == "function" then
            local ok = pcall(function() task.spawn(Library.Toggle) end)
            if not ok then pcall(function() Library:Toggle() end) end
        end
        holder.Visible = true
    end
end)

-- botao flutuante "MENU" para toque: no celular nao existe RightShift e a
-- janela pode ser fechada sem querer, entao o botao reabre a qualquer hora.
local MenuButton = nil
pcall(function()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "tridentMenuButton"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = playerGui
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(92, 32)
    button.Position = UDim2.new(0, 10, 0, 46)
    button.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = "\226\137\161 MENU"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.ZIndex = 10
    button.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(230, 182, 0)
    stroke.Transparency = 0.35
    stroke.Parent = button
    button.MouseButton1Click:Connect(function()
        pcall(function()
            if type(Library.Toggle) == "function" then
                task.spawn(Library.Toggle)
            end
        end)
    end)
    local dragging, dragStart, startPos = false, nil, nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    button.InputChanged:Connect(function(input)
        if not dragging or not dragStart then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    MenuButton = { gui = gui, button = button }
end)

local Win, tabCount = { lib = Library, raw = RawWindow }, 0
function Win:CreateTab(o)
    tabCount = tabCount + 1
    local t
    pcall(function() t = RawWindow:AddTab(o.name) end)
    return liftTab(t, tabCount)
end
function Win:CreateTag() return {} end
function Win:Set(flag, value)
    local el = UIFlags[flag]
    if not el then return end
    if type(el.Set) == "function" then
        pcall(function() el:Set(value) end)
    elseif type(el.SetValue) == "function" then
        pcall(function() el:SetValue(value) end)
    elseif type(el.SetValue) == "function" then
        pcall(function() el:SetValue(value) end)
    end
end
function Win:Get(flag)
    local el = UIFlags[flag]
    if not el then return nil end
    if type(el.GetValue) == "function" then
        local ok, v = pcall(function() return el:GetValue() end)
        if ok then return v end
    end
    return el.Value
end
function Win:Notify(o)
    local text = tostring(o.title or "trident")
    if o.content then text = text .. " | " .. tostring(o.content) end
    pcall(function() Library:Notify(text, o.duration or 4) end)
end
function Win:Popup(o)
    pcall(function() Library:Notify(tostring(o.title or "") .. " | " .. tostring(o.subtitle or ""), 5) end)
end

local Window = Win
local hasConfig = false
local UI_BACKEND = "linoria"

-- abas na ordem do AV0X
local TCombat = Window:CreateTab({ name = "Combat" })
local TVisual = Window:CreateTab({ name = "ESP" })
local TWorld = Window:CreateTab({ name = "Visuals" })
local TMove = Window:CreateTab({ name = "Movement" })
local TObj = Window:CreateTab({ name = "Objetos" })
local TConfig = Window:CreateTab({ name = "UI Settings" })

local Console = TConfig:CreateConsole({
    name = "Console / compatibilidade",
    height = 150,
    follow = true,
    maxLines = 200,
})
Log.console = Console

-- Configuration / themes: addons oficiais da Linoria (mesma UI do AV0X)
if SaveManager and type(SaveManager.BuildConfigSection) == "function" and TConfig.raw then
    pcall(function()
        SaveManager:SetLibrary(Library)
        SaveManager:SetIgnoreIndexes({})
        SaveManager:SetFolder("trident")
        SaveManager:BuildConfigSection(TConfig.raw)
        SaveManager:LoadAutoloadConfig()
    end)
    hasConfig = true
end
if ThemeManager and type(ThemeManager.BuildThemeManagerSection) == "function" and TConfig.raw then
    pcall(function()
        ThemeManager:SetLibrary(Library)
        ThemeManager:BuildThemeManagerSection(TConfig.raw)
    end)
end

--=====================================================================
-- 3.1 WATERMARK (FPS + ping, como a tarja do AV0X)
--=====================================================================
local Watermark = { label = nil, gui = nil }
pcall(function()
    local parent = nil
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok then parent = hui end
    end
    if not parent then
        parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    if not parent then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "trident_watermark"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    local label = Instance.new("TextLabel")
    label.Name = "wm"
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(200, 210, 230)
    label.TextStrokeTransparency = 0.5
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(0, 320, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.Text = "trident"
    label.Parent = gui
    gui.Parent = parent
    Watermark.gui, Watermark.label = gui, label
end)

local wmClock = 0
RunService.Heartbeat:Connect(function(dt)
    wmClock = wmClock + (dt or 0)
    if wmClock < 0.5 then return end
    wmClock = 0
    if not Watermark.label then return end
    local fps = 0
    pcall(function() fps = math.floor(1 / math.max(Workspace:GetRealPhysicsFPS() > 0 and dt or 0.016, 0.001)) end)
    if fps <= 0 or fps > 240 then fps = 60 end
    local ping = 0
    pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) end)
    if ping < 0 then ping = 0 end
    pcall(function()
        Watermark.label.Text = string.format("trident | FPS: %d | Ping: %dms", fps, ping)
    end)
end)

Window:Notify({
    title = "trident",
    content = "Linoria carregada (build 2.9).",
    duration = 4,
})

Log:once("ui", "ui: linoria")

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

    -- personagem local. O Trident usa workspace.Ignore.LocalCharacter; em
    -- algumas builds o Ignore fica dentro de Const, entao tenta os dois.
    local function findLocalChar()
        local candidates = {}
        local const = Workspace:FindFirstChild("Const")
        if const then
            local ig = const:FindFirstChild("Ignore")
            if ig then candidates[#candidates + 1] = ig end
        end
        local ig2 = Workspace:FindFirstChild("Ignore")
        if ig2 then candidates[#candidates + 1] = ig2 end
        for i = 1, #candidates do
            local lc = candidates[i]:FindFirstChild("LocalCharacter")
            if lc then return lc end
        end
        return nil
    end

    local localChar = findLocalChar()

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

local function sameTeam(model)
    local ok, result = pcall(function()
        local player = Players:GetPlayerFromCharacter(model)
        if not player then return false end
        local me = LocalPlayer
        if not me or not me.Team then return false end
        return player.Team ~= nil and me.Team ~= nil and player.Team == me.Team
    end)
    return ok and result == true
end

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

-- O Trident nao usa rig R6/R15: o personagem fica em workspace.Ignore com as
-- partes Middle/Top/Bottom (o "Head" nao existe). Sem isso o ESP e o aim ficam
-- cegos no jogo real, mesmo funcionando no mock.
local function tridentRig(model)
    local ok, middle = pcall(function() return model:FindFirstChild("Middle") end)
    if ok and middle then
        local top = model:FindFirstChild("Top")
        local bottom = model:FindFirstChild("Bottom")
        return middle, top, bottom
    end
    return nil
end

local function entityFromModel(v, myChar)
    if v == myChar or not v:IsA("Model") then return nil end
    local head = v:FindFirstChild("Head")
    local middle, top, bottom = tridentRig(v)
    local torso = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso") or v:FindFirstChild("LowerTorso")
    local hum = v:FindFirstChildOfClass("Humanoid") or v:FindFirstChild("Humanoid")
    local rig = nil
    if head then
        rig = "r6"
    elseif middle then
        rig = "trident"
        head = middle
        torso = torso or middle
    else
        return nil
    end
    local hp, maxHp = 100, 100
    if hum then
        pcall(function() hp = hum.Health; maxHp = hum.MaxHealth end)
    end
    if hp and hp <= 0 then return nil end
    local plr = nil
    pcall(function() plr = Players:GetPlayerFromCharacter(v) end)
    local weapon = nil
    pcall(function()
        local tool = v:FindFirstChildOfClass("Tool")
        if tool then weapon = tool.Name end
    end)
    if not weapon and v == myChar then weapon = equippedItemName() end
    local isPlayer = plr ~= nil or Players:FindFirstChild(v.Name) ~= nil or v.Name == "Player"
    return {
        model = v,
        head = head,
        middle = middle,
        top = top,
        bottom = bottom,
        torso = torso,
        humanoid = hum,
        hp = hp,
        maxHp = maxHp,
        weapon = weapon,
        isPlayer = isPlayer,
        rig = rig,
    }
end

local function collectEntities()
    local out = {}
    local myChar = LocalPlayer.Character
    local sources = { Workspace }
    local ignore = Workspace:FindFirstChild("Ignore")
    if ignore then
        sources[#sources + 1] = ignore
        local localChar = ignore:FindFirstChild("LocalCharacter")
        if localChar then myChar = myChar or localChar end
    end
    local seen = {}
    for _, source in ipairs(sources) do
        local okList, children = pcall(function() return source:GetChildren() end)
        if okList and type(children) == "table" then
            for _, v in ipairs(children) do
                if not seen[v] and v ~= Game.root then
                    local okEnt, ent = pcall(entityFromModel, v, myChar)
                    if okEnt and ent then
                        seen[v] = true
                        out[#out + 1] = ent
                    end
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
    ignoreTeam = true,
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
                if not skip and Aim.ignoreTeam and ent.isPlayer and sameTeam(ent.model) then skip = true end
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
        local alpha = clamp(1 / math.max(Aim.smooth, 1), 0.02, 1)
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
    sizeZ = 6,
    transparency = 0.6,
    canCollide = false,
    color = nil,
    ignoreTeam = false,
    ignoreSleepers = false,
    ignoreTeam = false,
    ignoreNpc = false,
}

local hitboxOriginals = {}

local function hitboxApply()
    for _, ent in pairs(getEntities(true)) do
        local head = ent.head
        local skip = false
        -- filtros do AV0X (HitboxTeamCheck / HitboxSleeperCheck / HitboxAICheck)
        if head and Hitbox.ignoreTeam and ent.isPlayer and sameTeam(ent.model) then skip = true end
        if not skip and head and Hitbox.ignoreSleepers and isSleeping(ent.model) then skip = true end
        if not skip and head and Hitbox.ignoreNpc and not ent.isPlayer then skip = true end
        if head and not skip then
            if not hitboxOriginals[head] then
                hitboxOriginals[head] = {
                    size = head.Size,
                    transparency = head.Transparency,
                    cancollide = head.CanCollide,
                    color = head.Color,
                    material = head.Material,
                }
            end
            pcall(function()
                head.Size = Vector3.new(Hitbox.sizeX, Hitbox.sizeY, Hitbox.sizeZ)
                head.Transparency = Hitbox.transparency
                head.CanCollide = Hitbox.canCollide
                if Hitbox.color then
                    head.Color = Hitbox.color
                    head.Material = Enum.Material.Neon
                end
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
                if orig.color then head.Color = orig.color end
                if orig.material then head.Material = orig.material end
            end)
        end
    end
    hitboxOriginals = {}
end

addUpdater(function()
    if Hitbox.enabled then hitboxApply() end
end)

--=====================================================================
-- 8.5 JUMP SHOOT (reconstruido do trace do AV0X)
--   Part 4 x 0.2 x 4, Anchored, CanCollide, Material Neon, SpecialMesh
--   rbxassetid://20329976, seguindo LocalCharacter.Middle - Vector3(0,3.5,0).
--   Tudo em uma tabela unica: o chunk ja esta no limite de 200 locais do Lua 5.1.
--=====================================================================
local JumpShoot = {
    enabled = false,
    offset = 3.5,
    transparency = 1,
    part = nil,
    conn = nil,
}

function JumpShoot.position()
    local ok, pos = pcall(function()
        local const = Workspace:FindFirstChild("Const")
        local ignore = const and const:FindFirstChild("Ignore")
        local char = ignore and ignore:FindFirstChild("LocalCharacter")
        local middle = char and char:FindFirstChild("Middle")
        if middle then return middle.Position end
        local myChar = LocalPlayer.Character
        local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.Position
    end)
    if ok then return pos end
    return nil
end

function JumpShoot.stop()
    if JumpShoot.conn then
        pcall(function() JumpShoot.conn:Disconnect() end)
        JumpShoot.conn = nil
    end
    if JumpShoot.part then
        pcall(function() JumpShoot.part:Destroy() end)
        JumpShoot.part = nil
    end
end

function JumpShoot.start()
    JumpShoot.stop()
    local part
    local ok = pcall(function()
        part = Instance.new("Part")
        part.Name = "trident_jumpshoot"
        part.Size = Vector3.new(4, 0.2, 4)
        part.Anchored = true
        part.CanCollide = true
        part.Color = Color3.fromRGB(0, 0, 255)
        part.Transparency = JumpShoot.transparency
        part.Material = Enum.Material.Neon
        pcall(function()
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://20329976"
            mesh.Parent = part
        end)
        part.Parent = Workspace
    end)
    if not ok or not part then return false end
    JumpShoot.part = part
    pcall(function()
        JumpShoot.conn = RunService.Heartbeat:Connect(function()
            if not JumpShoot.enabled or not JumpShoot.part then return end
            local pos = JumpShoot.position()
            if pos then
                pcall(function()
                    JumpShoot.part.Position = pos - Vector3.new(0, JumpShoot.offset, 0)
                end)
            end
        end)
    end)
    return true
end

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
        if not skip and Esp.ignoreTeam and ent.isPlayer and sameTeam(ent.model) then skip = true end
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
-- 9.8 CATALOGO DE ENTIDADES DO JOGO + AUTO FARM / KILL AURA
--=====================================================================
-- O Trident guarda os tipos de entidade em Shared.entities
-- (ReplicatedStorage.Shared.entities.Tree, .Iron, .Nitrate, .Stone,
-- .Cactus, .NPC.<tipo>, .Player ...). Lendo isso o script deixa de
-- adivinhar nome de caixa/minerio: usa exatamente o nome que o jogo usa.
-- Referencia: scripts publicos do proprio Trident.

local Catalog = {
    loaded = false,
    kinds = {},
    list = {},
    npcs = {},
    resources = {},
    objects = {},
}

local RESOURCE_NAMES = { "Tree", "Cactus", "Iron", "Nitrate", "Stone", "Rock", "Ore" }

local function isResourceName(name)
    local low = string.lower(tostring(name or ""))
    for i = 1, #RESOURCE_NAMES do
        if string.find(low, string.lower(RESOURCE_NAMES[i]), 1, true) then return true end
    end
    return false
end

local function loadCatalog()
    Catalog.kinds = {}
    Catalog.list = {}
    Catalog.npcs = {}
    Catalog.resources = {}
    Catalog.objects = {}

    local shared = ReplicatedStorage:FindFirstChild("Shared")
    local entities = shared and shared:FindFirstChild("entities")
    if not entities then
        Catalog.loaded = false
        return false
    end

    local function register(name, kind)
        if type(name) ~= "string" or name == "" then return end
        if Catalog.kinds[name] then return end
        Catalog.kinds[name] = kind
        table.insert(Catalog.list, name)
        if kind == "resource" then
            Catalog.resources[name] = true
        elseif kind == "object" then
            Catalog.objects[name] = true
        elseif kind == "npc" then
            Catalog.npcs[name] = true
        end
    end

    local ok = pcall(function()
        for _, child in ipairs(entities:GetChildren()) do
            local name = child.Name
            local low = string.lower(name)
            if low == "npc" or low == "npcs" then
                -- pasta com um filho por tipo de NPC
                for _, npc in ipairs(child:GetChildren()) do
                    register(npc.Name, "npc")
                end
            elseif low == "player" then
                register(name, "player")
            elseif isResourceName(name) then
                register(name, "resource")
            else
                -- sem pasta de NPC: o que tem Humanoid no Model e NPC
                local kind = "object"
                local model = child:FindFirstChild("Model")
                if model then
                    local okHum, hum = pcall(function() return model:FindFirstChildOfClass("Humanoid") end)
                    if okHum and hum then kind = "npc" end
                end
                register(name, kind)
            end
        end
    end)

    Catalog.loaded = ok and #Catalog.list > 0
    if Catalog.loaded then
        Log:add("catalogo do jogo: " .. #Catalog.list .. " tipos (" .. table.concat(Catalog.list, ", ", 1, math.min(#Catalog.list, 8)) .. ")")
    end
    return Catalog.loaded
end

local function catalogKindOf(name)
    if not Catalog.loaded then return nil end
    return Catalog.kinds[name]
end

-- farm / kill aura -----------------------------------------------------
-- Precisa do EntityMap do cliente (id de cada entidade). Ele so existe
-- via debug.getupvalues/getgc, entao a feature se desliga sozinha quando
-- o executor nao permite. Referencia: tridenopenscr (PlayerBody.lua).
local Farm = {
    enabled = false,
    killAura = false,
    distance = 28,
    delay = 0.95,
    fastDelay = 0.05,
    hitPart = "Head",
    types = {},
    map = nil,
    mapTried = false,
    warned = false,
    lastFire = 0,
    hits = 0,
}

do
    for _, name in ipairs({ "Tree", "Cactus", "Iron", "Nitrate", "Stone" }) do
        Farm.types[name] = true
    end
end

local function resolveEntityMap()
    if Farm.map then return Farm.map end
    if Farm.mapTried then return nil end
    Farm.mapTried = true
    if type(getgc) ~= "function" then return nil end
    local debugAllowed = (not SafeMode.enabled) and type(debug) == "table"
        and type(debug.getupvalues) == "function"
    if not debugAllowed and not SafeMode.enabled then return nil end

    local ok, map = pcall(function()
        for _, value in pairs(getgc(true)) do
            if type(value) == "table" then
                local candidate = rawget(value, "EntityMap")
                if type(candidate) == "table" and next(candidate) ~= nil then
                    return candidate
                end
            elseif debugAllowed and type(value) == "function" then
                local ups = debug.getupvalues(value)
                if type(ups) == "table" then
                    for _, up in pairs(ups) do
                        if type(up) == "table" then
                            local candidate = rawget(up, "EntityMap")
                            if type(candidate) == "table" and next(candidate) ~= nil then
                                return candidate
                            end
                        end
                    end
                end
            end
        end
        return nil
    end)

    if ok and type(map) == "table" then
        Farm.map = map
        Log:add("EntityMap encontrado (" .. tostring(next(map) ~= nil and "ok" or "vazio") .. ")")
        return map
    end
    return nil
end

local function fireHit(id, position, hitType, part)
    local tcp = Game.tcp
    if not tcp then return false end
    pcall(function() tcp:FireServer(10, "Swing") end)
    local ok = pcall(function()
        tcp:FireServer(10, "Hit", id, position, part or Farm.hitPart, hitType or "Part", Vector3.new(0, 0, 0))
    end)
    if ok then Farm.hits = Farm.hits + 1 end
    return ok
end

local farmTimer = 0

local function updateFarm(dt)
    if not (Farm.enabled or Farm.killAura) then
        farmTimer = 0
        return
    end
    farmTimer = farmTimer + (dt or 0)
    local delay = Farm.enabled and Farm.delay or 0.5
    if farmTimer < delay then return end

    local myPos = myPosition()
    if not myPos then return end

    local map = resolveEntityMap()
    if not map then
        if not Farm.warned then
            Farm.warned = true
            Farm.enabled, Farm.killAura = false, true
            Farm.killAura = false
            Log:add("farm desligado: este executor nao expoe getgc/debug.getupvalues")
            Window:Notify({
                title = "Auto farm indisponivel",
                content = "O executor nao expoe getgc/debug.getupvalues, que o Trident exige para o Hit funcionar.",
                duration = 7,
            })
        end
        return
    end

    local bestId, bestPos, bestType, bestDist
    for id, ent in pairs(map) do
        if type(ent) == "table" then
            local etype = ent.type
            local epos = ent.pos
            if type(etype) == "string" and typeof(epos) == "Vector3" then
                local isResourceType = Farm.types[etype] or isResourceName(etype)
                local want = (Farm.killAura and (etype == "Player" or Catalog.npcs[etype])) or (Farm.enabled and isResourceType)
                if want then
                    local okD, dist = pcall(function() return (epos - myPos).Magnitude end)
                    if okD and dist and dist <= Farm.distance and (bestDist == nil or dist < bestDist) then
                        bestId, bestPos, bestType, bestDist = id, epos, etype, dist
                    end
                end
            end
        end
    end

    if bestId then
        farmTimer = 0
        local hitType = (bestType == "Tree") and "default" or "Part"
        fireHit(bestId, bestPos, hitType)
    end
end

addUpdater(updateFarm)

-- carrega o catalogo assim que o script sobe
loadCatalog()

--=====================================================================
-- 9.9 SILENT AIM DE PROJETIL + DASH TCP + ARMA EQUIPADA
--=====================================================================
-- Fonte (mineracao de 86 repos publicos):
--   Mick-gordon/Trident-Survival-Silent-aim -> hook no createProjectile
--     do RangedWeaponClient usando getgc + debug.getconstants
--     ("ProjectileSpeed"), com predicao por ProjectileSpeed/Drop.
--   KumaoRoblox/TridentSurvival -> TCP 2/3 (slide) e TCP 23 (chat).
--   Panda22MyGod/TridentSurvival -> GetEquippedItem via getgc.
--   Rostik22803/Ocel-hub-trident-survival -> containers por nome de
--     filho ("Crates", "Cables") e materiais (Metal, Metal2...).

-- Modo seguro: evita debug.getupvalues/getconstants (o jogo loga
-- "Executed a script" e tem TamperingDetected). Ligado por padrao.
local SafeMode = { enabled = false }

local ProjectileAim = {
    enabled = false,
    partName = "Head",
    fov = 520,
    hooked = false,
    status = "nao instalado",
    players = nil,
    shots = 0,
    history = {},
}

local equippedModule = nil
local equippedChecked = false

local function findEquippedModule()
    if equippedModule or equippedChecked then return equippedModule end
    equippedChecked = true
    if type(getgc) ~= "function" then return nil end
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "GetEquippedItem") ~= nil then
                equippedModule = v
                return
            end
        end
    end)
    return equippedModule
end

-- nome da arma na mao (modulo do jogo, com fallback no Tool)
local function equippedItemName()
    local mod = findEquippedModule()
    if mod then
        local ok, item = pcall(function() return mod.GetEquippedItem() end)
        if ok and item ~= nil then
            if type(item) == "table" then
                local name = item.type or item.name or item.id
                if type(name) == "string" then return name end
            elseif type(item) == "string" then
                return item
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then return tool.Name end
    end
    return nil
end

-- ---------------------------------------------------------------------
-- hook no createProjectile
-- ---------------------------------------------------------------------
local function findProjectileHook()
    if type(getgc) ~= "function" then return nil, nil end
    if type(debug) ~= "table" then return nil, nil end

    local createProjectile, playersTable
    pcall(function()
        for _, v in pairs(getgc()) do
            if type(v) == "function" then
                local okSrc, src = pcall(function() return debug.info(v, "s") end)
                if okSrc and type(src) == "string" then
                    if string.find(src, "RangedWeaponClient", 1, true) then
                        local okConst, consts = pcall(function() return debug.getconstants(v) end)
                        if okConst and type(consts) == "table" and consts[1] == "ProjectileSpeed" then
                            createProjectile = v
                        end
                    elseif string.find(src, "PlayerClient", 1, true) then
                        local okName, nm = pcall(function() return debug.info(v, "n") end)
                        if okName and nm == "updatePlayers" then
                            local okUp, up = pcall(function() return debug.getupvalue(v, 1) end)
                            if okUp and type(up) == "table" then playersTable = up end
                        end
                    end
                end
            end
        end
    end)
    return createProjectile, playersTable
end

local function rememberPosition(model, position)
    if not model or not position then return nil end
    local now = os.clock()
    local h = ProjectileAim.history[model]
    if not h then
        ProjectileAim.history[model] = { pos = position, time = now }
        return nil
    end
    local dt = now - h.time
    local velocity = nil
    if dt > 0.001 and dt < 1 then
        velocity = (position - h.pos) / dt
    end
    h.pos, h.time = position, now
    return velocity
end

local function projectileTarget()
    local center = viewportCenter()
    local best, bestDist, bestPart, bestVel = nil, ProjectileAim.fov, nil, nil
    for _, ent in pairs(getEntities()) do
        local part = ent.model:FindFirstChild(ProjectileAim.partName) or ent.head
        local pos = partPos(part)
        if pos then
            local screen = projectPoint(pos)
            if screen then
                local dx = screen.X - center.X
                local dy = screen.Y - center.Y
                local dist = math.sqrt(dx * dx + dy * dy)
                local allowed = ent.isPlayer or Aim.targetNpc
                if allowed and dist <= bestDist then
                    best, bestDist, bestPart = ent, dist, part
                    bestVel = rememberPosition(ent.model, pos)
                end
            end
        end
    end
    if not best or not bestPart then return nil end
    return partPos(bestPart), bestVel, bestPart
end

local function installProjectileAim()
    if ProjectileAim.hooked then return true end
    if SafeMode.enabled then
        ProjectileAim.status = "modo seguro ativo (debug bloqueado)"
        return false
    end
    if type(hookfunction) ~= "function" then
        ProjectileAim.status = "executor sem hookfunction"
        return false
    end

    local createProjectile, playersTable = findProjectileHook()
    if not createProjectile then
        ProjectileAim.status = "createProjectile nao encontrado"
        return false
    end

    ProjectileAim.players = playersTable
    local original
    local ok = pcall(function()
        original = hookfunction(createProjectile, function(cFrame, weaponInfo, isLocal, p63, p64)
            if ProjectileAim.enabled and isLocal and cFrame then
                local targetPos, velocity = projectileTarget()
                if targetPos then
                    local speed, drop = 800, 1
                    pcall(function()
                        speed = tonumber(weaponInfo.ProjectileSpeed) or 800
                        drop = tonumber(weaponInfo.ProjectileDrop) or 1
                    end)
                    if speed > 0 then
                        local okCalc = pcall(function()
                            local travel = (targetPos - cFrame.Position).Magnitude / speed
                            local pos = targetPos
                            if velocity then pos = targetPos + velocity * travel end
                            travel = (pos - cFrame.Position).Magnitude / speed
                            if drop and drop ~= 0 then
                                pos = pos - Vector3.yAxis * (-(drop) ^ (travel * drop) + 1)
                            end
                            cFrame = CFrame.new(cFrame.Position, pos)
                            ProjectileAim.shots = ProjectileAim.shots + 1
                        end)
                    end
                end
            end
            return original(cFrame, weaponInfo, isLocal, p63, p64)
        end)
    end)

    ProjectileAim.hooked = ok
    ProjectileAim.status = ok and "hook ativo" or "hook recusado"
    Log:add("silent aim de projetil: " .. ProjectileAim.status)
    return ok
end

-- ---------------------------------------------------------------------
-- dash / slide via TCP (ids 2 e 3)
-- ---------------------------------------------------------------------
local Dash = {
    enabled = false,
    speed = 62,
    duration = 1.4,
    active = false,
    timer = 0,
    cooldown = 0,
}

local function flatLook()
    local ok, look = pcall(function() return Camera.CFrame.LookVector end)
    if ok and typeof(look) == "Vector3" then
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.001 then return flat.Unit end
    end
    return Vector3.new(0, 0, -1)
end

local function isMoving()
    local part = Game.middle
    if not part then return false end
    local ok, vel = pcall(function() return part.AssemblyLinearVelocity end)
    if ok and typeof(vel) == "Vector3" then return vel.Magnitude > 2 end
    return false
end

local function dashStart()
    local tcp = Game.tcp
    if not tcp then return false end
    local ok = pcall(function()
        tcp:FireServer(3, true, Vector3.xAxis)
        tcp:FireServer(2, true)
    end)
    Dash.active = true
    Dash.timer = 0
    return ok
end

local function dashStop()
    local tcp = Game.tcp
    if tcp then
        pcall(function()
            tcp:FireServer(3, false)
            tcp:FireServer(2, false)
        end)
    end
    Dash.active = false
    Dash.cooldown = 0.6
end

addUpdater(function(dt)
    if ProjectileAim.enabled and not ProjectileAim.hooked then
        if not ProjectileAim.installTried then
            ProjectileAim.installTried = true
            local ok = installProjectileAim()
            if not ok then
                ProjectileAim.enabled = false
                Window:Notify({
                    title = "Silent aim de projetil",
                    content = ProjectileAim.status .. ". Use o silent aim normal.",
                    duration = 6,
                })
            end
        end
    end

    if Dash.cooldown > 0 then Dash.cooldown = math.max(0, Dash.cooldown - (dt or 0)) end

    if not Dash.enabled then
        if Dash.active then dashStop() end
        return
    end

    if Dash.active then
        Dash.timer = Dash.timer + (dt or 0)
        if Dash.timer > Dash.duration then
            dashStop()
            return
        end
        local dir = flatLook()
        for _, name in ipairs({ "middle", "top", "bottom" }) do
            local part = Game[name]
            if part then
                pcall(function() part.AssemblyLinearVelocity = dir * Dash.speed end)
            end
        end
    elseif Dash.cooldown <= 0 and isMoving() then
        dashStart()
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
    resources = false,
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
    "metal", "supply", "stash", "toolbox", "cargo", "crates", "cables",
    "backpack", "duffel",
}
local PAT_TOTEM = { "totem" }
local PAT_BED = { "bedroll", "bed", "cama", "sleep", "bag", "spawn", "tent", "barraca", "campfire", "fogueira", "respawn" }
local PAT_WEAPON = { "weapon", "arma", "gun", "rifle", "pistol", "shotgun", "knife", "faca", "bow", "arco", "ammo", "bala", "mag" }

local KIND_COLOR = {
    container = Color3.fromRGB(255, 205, 80),
    totem = Color3.fromRGB(190, 130, 255),
    bed = Color3.fromRGB(110, 235, 150),
    weapon = Color3.fromRGB(255, 140, 90),
    resource = Color3.fromRGB(150, 235, 210),
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

    -- catalogo do jogo (Shared.entities): nome exato, sem adivinhacao
    local catalogKind = catalogKindOf(item.Name)
    if catalogKind == "resource" and Objects.resources then
        local pos, ref = modelRef(item)
        if pos then acc[item] = { kind = "resource", text = item.Name, pos = pos, part = ref } end
        return
    end

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

    -- caixa sem nome reconhecivel: o modelo tem filho Crates/Cables/Lid
    if Objects.containers then
        local okChild, crates = pcall(function()
            return item:FindFirstChild("Crates") or item:FindFirstChild("Cables")
                or item:FindFirstChild("Lid") or item:FindFirstChild("Loot")
        end)
        if okChild and crates then
            local pos, ref = modelRef(item)
            if pos then acc[item] = { kind = "container", text = item.Name, pos = pos, part = ref } end
            return
        end
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
    return Objects.containers or Objects.totems or Objects.beds or Objects.weapons or Objects.resources
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
            cc.Brightness = clamp(WorldFx.brightness + pulse, -1, 1)
            cc.Contrast = clamp(WorldFx.contrast + pulse * 0.5, -1, 1)
            cc.Saturation = clamp(WorldFx.saturation + pulse, -1, 1)
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
-- 9.6 PACOTE AV0X (extraido do trace da VM: containers default/box/trash,
-- zonas safe/no-build, veiculos e arm chams do FPSArms)
--=====================================================================
local Avox = {
    containers = false,
    zones = false,
    vehicles = false,
    arm_chams = false,
    arm_material = "ForceField",
    arm_color = Color3.fromRGB(0, 0, 255),
    labels = {},
    parts_touched = {},
    t = 0,
}

local AVOX = {
    box = Color3.fromRGB(230, 182, 0),
    safe = Color3.fromRGB(0, 255, 0),
    nobuild = Color3.fromRGB(255, 0, 0),
    vehicle = Color3.fromRGB(0, 255, 0),
}

-- pecas que o AV0X pinta em workspace.Const.Ignore.FPSArms.HandModel
local ARM_PARTS = {
    DefaultSight = true, Barrel = true, Body = true, ChargingHandle = true,
    Decals = true, Mag = true, Rails = true, ShoulderPad = true, Stock = true,
}

local function avoxLabel(key, text, color, size)
    if type(Drawing) ~= "table" then return nil end
    local l = Avox.labels[key]
    if not l then
        local ok, obj = pcall(function()
            return newDrawing("Text", {
                Size = size or 10,
                Center = true,
                Outline = true,
                Font = 2,
                Color = color,
                OutlineColor = Color3.new(0, 0, 0),
                Visible = false,
            })
        end)
        if not ok or not obj then return nil end
        l = obj
        Avox.labels[key] = l
    end
    l.Text = text
    l.Color = color
    return l
end

local function avoxIsVector(v)
    if v == nil then return false end
    if type(typeof) == "function" then
        local ok, t = pcall(typeof, v)
        if ok and t == "Vector3" then return true end
    end
    local okType, plain = pcall(type, v)
    if okType and plain == "table" then
        local okX = pcall(function() return v.X ~= nil and v.Y ~= nil and v.Z ~= nil end)
        if okX then return true end
    end
    return false
end


local function avoxFirstPart(model)
    if model == nil then return nil end
    local okPart, direct = pcall(function() return model:IsA("BasePart") end)
    if okPart and direct then return model end
    local ok, found = pcall(function() return model:FindFirstChildWhichIsA("BasePart", true) end)
    if ok and found then return found end
    local okList, kids = pcall(function() return model:GetDescendants() end)
    if okList and type(kids) == "table" then
        for _, kid in ipairs(kids) do
            local okIs, isPart = pcall(function() return kid:IsA("BasePart") end)
            if okIs and isPart then return kid end
        end
    end
    return nil
end

local function avoxPosition(part)
    local ok, pos = pcall(function()
        local p = part.Position
        return p
    end)
    if ok and avoxIsVector(pos) then return pos end
    local ok2, pivot = pcall(function() return part:GetPivot().Position end)
    if ok2 then return pivot end
    return nil
end

-- container do AV0X: Model com filho "default" e partes box/trash (MeshPart)
local function isAvoxContainer(model)
    local ok, ok2 = pcall(function()
        if not model:IsA("Model") then return false end
        if not model:FindFirstChild("default") then return false end
        return true
    end)
    return ok and ok2 == true
end

local function avoxContainerLabel(model, index)
    local box = model:FindFirstChild("box", true)
    local trash = model:FindFirstChild("trash", true)
    local text = "DefaultBox"
    if box then
        text = "Box"
    elseif trash then
        text = "Trash"
    end
    local pos = avoxPosition(box or trash or avoxFirstPart(model) or model)
    return text, pos
end

local function avoxCleanup(keys)
    for key, label in pairs(Avox.labels) do
        local keep = false
        for _, k in ipairs(keys) do
            if key == k or key:sub(1, #k) == k then keep = true break end
        end
        if not keep then
            pcall(function() label.Visible = false end)
        end
    end
end

local function avoxDraw(key, text, pos, color, size, cam)
    local label = avoxLabel(key, text, color, size)
    if not label or not pos then return end
    local ok, screen, onScreen = pcall(function()
        local v, vis = projectPoint(pos)
        return v, vis
    end)
    if not ok or not screen or not onScreen then
        pcall(function() label.Visible = false end)
        return
    end
    pcall(function()
        label.Position = screen
        label.Visible = true
    end)
end

local function avoxArmChams()
    local parts = {}
    local ok = pcall(function()
        local const = Workspace:FindFirstChild("Const")
        local ignore = const and const:FindFirstChild("Ignore")
        local arms = ignore and ignore:FindFirstChild("FPSArms")
        if not arms then return end
        for _, part in ipairs(arms:GetDescendants()) do
            if part:IsA("BasePart") and ARM_PARTS[part.Name] then
                parts[#parts + 1] = part
            end
        end
    end)
    if not ok then return end
    local mat = Avox.arm_material
    for _, part in ipairs(parts) do
        pcall(function()
            if mat and Enum.Material[mat] then part.Material = Enum.Material[mat] end
            part.Color = Avox.arm_color
        end)
        Avox.parts_touched[part] = true
    end
end

local function avoxRestoreArms()
    for part in pairs(Avox.parts_touched) do
        pcall(function()
            if part and part.Parent then
                part.Material = Enum.Material.Plastic
            end
        end)
    end
    Avox.parts_touched = {}
end

local function updateAvox(dt)
    Avox.t = Avox.t + (dt or 0)
    if Avox.t < 0.35 then return end
    Avox.t = 0
    local n = 0

    if Avox.containers then
        pcall(function()
            for _, model in ipairs(Workspace:GetChildren()) do
                if isAvoxContainer(model) then
                    n = n + 1
                    local text, pos = avoxContainerLabel(model, n)
                    if pos then
                        avoxDraw("ctn_" .. tostring(n), text, pos + Vector3.new(0, 2, 0), AVOX.box, 10)
                    end
                end
            end
        end)
    end

    if Avox.zones then
        pcall(function()
            local world = Workspace:FindFirstChild("World")
            local zones = world and world:FindFirstChild("Zones")
            if not zones then return end
            local safe = zones:FindFirstChild("SafeZones")
            if safe then
                for i, model in ipairs(safe:GetChildren()) do
                    local pos = avoxPosition(avoxFirstPart(model) or model)
                    if pos then
                        avoxDraw("safe_" .. tostring(i), "SAFE", pos + Vector3.new(0, 4, 0), AVOX.safe, 12)
                    end
                end
            end
            local nob = zones:FindFirstChild("NoBuildZones")
            if nob then
                for i, model in ipairs(nob:GetChildren()) do
                    local pos = avoxPosition(avoxFirstPart(model) or model)
                    if pos then
                        avoxDraw("nob_" .. tostring(i), "NO BUILD", pos + Vector3.new(0, 4, 0), AVOX.nobuild, 12)
                    end
                end
            end
        end)
    end

    if Avox.vehicles then
        pcall(function()
            local shared = ReplicatedStorage:FindFirstChild("Shared")
            local entities = shared and shared:FindFirstChild("entities")
            local vehicles = entities and entities:FindFirstChild("vehicles")
            if not vehicles then return end
            local types = {}
            for _, v in ipairs(vehicles:GetChildren()) do
                types[#types + 1] = v.Name
            end
            for _, model in ipairs(Workspace:GetChildren()) do
                local found = nil
                for _, name in ipairs(types) do
                    if model.Name == name then
                        found = name
                        break
                    end
                    local okChild, child = pcall(function() return model:FindFirstChild(name) end)
                    if okChild and child then
                        found = name
                        break
                    end
                end
                if found then
                    local pos = avoxPosition(avoxFirstPart(model) or model)
                    if pos then
                        avoxDraw("veh_" .. tostring(model), found, pos + Vector3.new(0, 4, 0), AVOX.vehicle, 14)
                    end
                end
            end
        end)
    end

    if Avox.arm_chams then
        avoxArmChams()
    end
end

addSlow(function() updateAvox(0.35) end)

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
        Move.carFlyBuild = clamp(Move.carFlyBuild + dt * Move.carFlyAccel, 0, Move.carFlySpeed)
    else
        Move.carFlyBuild = clamp(Move.carFlyBuild - dt * 150, 0, Move.carFlySpeed)
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
    fovFill = false,
    fovFillColor = Color3.fromRGB(255, 255, 255),
    fovFillTransparency = 0.7,
    crosshair = false,
    color = Color3.fromRGB(255, 255, 255),
    objects = nil,
}

local function ensureOverlay()
    if not hasDrawing then return nil end
    if Overlay.objects then return Overlay.objects end
    local ok, objs = pcall(function()
        return {
            fill = newDrawing("Circle", { Thickness = 0, Filled = true, Transparency = 1 }),
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
        if Overlay.fovFill then
            pcall(function()
                o.fill.Visible = true
                o.fill.Position = cursor
                o.fill.Radius = Aim.fov
                o.fill.Color = Overlay.fovFillColor
                o.fill.Transparency = Overlay.fovFillTransparency
            end)
        else
            pcall(function() o.fill.Visible = false end)
        end
    else
        pcall(function()
            o.circle.Visible = false
            o.fill.Visible = false
        end)
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
-- 12.7 PERFORMANCE (FPS booster) — extraido do Trident V4 (Fazma)
--=====================================================================
-- O V4 desofuscado carrega FPSBooster.lua (CasperFlyModz) para isso:
-- GlobalShadows off, FogEnd alto, agua do Terrain zerada,
-- settings().Rendering.QualityLevel = 1, MeshPartDetailLevel = Level04,
-- particulas desligadas e MaterialService.Use2022Materials = false.
-- Aqui esta reimplementado sem loadstring de terceiros.

local Perf = {
    shadows = false,
    water = false,
    render = false,
    particles = false,
    effects = false,
    materials = false,
    saved = {},
    applied = {},
}

local function lighting()
    return Lighting or game:GetService("Lighting")
end

local function terrain()
    local ws = Workspace
    if not ws then return nil end
    local ok, t = pcall(function() return ws.Terrain end)
    if ok then return t end
    return nil
end

local function setSaved(key, value)
    if Perf.saved[key] == nil then Perf.saved[key] = value end
end

function Perf.applyShadows(on)
    local l = lighting()
    if not l then return end
    if on then
        pcall(function()
            setSaved("GlobalShadows", l.GlobalShadows)
            setSaved("FogEnd", l.FogEnd)
            setSaved("Brightness", l.Brightness)
            l.GlobalShadows = false
            l.FogEnd = 9e9
        end)
    elseif Perf.saved.GlobalShadows ~= nil then
        pcall(function()
            l.GlobalShadows = Perf.saved.GlobalShadows
            l.FogEnd = Perf.saved.FogEnd
        end)
    end
end

function Perf.applyWater(on)
    local t = terrain()
    if not t then return end
    local keys = { "WaterWaveSize", "WaterWaveSpeed", "WaterReflectance", "WaterTransparency" }
    if on then
        pcall(function()
            for i = 1, #keys do
                setSaved(keys[i], t[keys[i]])
                t[keys[i]] = (keys[i] == "WaterTransparency") and 1 or 0
            end
        end)
    else
        pcall(function()
            for i = 1, #keys do
                if Perf.saved[keys[i]] ~= nil then t[keys[i]] = Perf.saved[keys[i]] end
            end
        end)
    end
end

function Perf.applyRender(on)
    if type(settings) ~= "function" then return end
    local ok = pcall(function()
        local rendering = settings().Rendering
        if on then
            setSaved("QualityLevel", rendering.QualityLevel)
            rendering.QualityLevel = Enum.QualityLevel.Level01
            if Enum.MeshPartDetailLevel then
                rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
            end
        elseif Perf.saved.QualityLevel ~= nil then
            rendering.QualityLevel = Perf.saved.QualityLevel
        end
    end)
    return ok
end

function Perf.applyParticles(on)
    local ws = Workspace
    if not ws then return end
    local classes = { "ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles" }
    Perf.applied.particles = Perf.applied.particles or {}

    if on then
        pcall(function()
            for _, d in ipairs(ws:GetDescendants()) do
                for i = 1, #classes do
                    if d:IsA(classes[i]) then
                        if d.Enabled then
                            Perf.applied.particles[d] = true
                            d.Enabled = false
                        end
                        break
                    end
                end
            end
        end)
    else
        pcall(function()
            for obj in pairs(Perf.applied.particles) do
                pcall(function() obj.Enabled = true end)
            end
            Perf.applied.particles = {}
        end)
    end
end

local EFFECT_CLASSES = {
    "BloomEffect", "BlurEffect", "SunRaysEffect", "DepthOfFieldEffect",
}

function Perf.applyEffects(on)
    local l = lighting()
    if not l then return end
    Perf.applied.effects = Perf.applied.effects or {}
    if on then
        pcall(function()
            for _, d in ipairs(l:GetChildren()) do
                for i = 1, #EFFECT_CLASSES do
                    if d:IsA(EFFECT_CLASSES[i]) and d.Enabled then
                        Perf.applied.effects[d] = true
                        d.Enabled = false
                    end
                end
            end
        end)
    else
        pcall(function()
            for obj in pairs(Perf.applied.effects) do
                pcall(function() obj.Enabled = true end)
            end
            Perf.applied.effects = {}
        end)
    end
end

function Perf.applyMaterials(on)
    local ok = pcall(function()
        local service = game:GetService("MaterialService")
        if service then
            if on then
                setSaved("Use2022Materials", service.Use2022Materials)
                if service.Use2022Materials ~= nil then service.Use2022Materials = false end
            elseif Perf.saved.Use2022Materials ~= nil then
                service.Use2022Materials = Perf.saved.Use2022Materials
            end
        end
    end)
    return ok
end

function Perf.set(name, value)
    if name == "shadows" then Perf.applyShadows(value)
    elseif name == "water" then Perf.applyWater(value)
    elseif name == "render" then Perf.applyRender(value)
    elseif name == "particles" then Perf.applyParticles(value)
    elseif name == "effects" then Perf.applyEffects(value)
    elseif name == "materials" then Perf.applyMaterials(value) end
    Perf[name] = value
end

function Perf.restoreAll()
    Perf.set("shadows", false)
    Perf.set("water", false)
    Perf.set("render", false)
    Perf.set("particles", false)
    Perf.set("effects", false)
    Perf.set("materials", false)
    Log:add("performance: tudo restaurado")
end

function Perf.applyPreset()
    Perf.set("effects", true)
    Perf.set("render", true)
    Perf.set("shadows", true)
    Perf.set("water", true)
    Perf.set("particles", true)
    Log:add("performance: preset FPS aplicado")
end


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
    name = "Ignorar time",
    flag = "aim_team",
    value = true,
    description = "Nao mira em quem esta no seu time.",
    callback = function(v) Aim.ignoreTeam = v end,
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

TCombat:CreateSection({ name = "Silent aim de projetil (hook)" })

TCombat:CreateToggle({
    name = "Silent aim de projetil",
    description = "Hook no createProjectile do RangedWeaponClient com predicao (ProjectileSpeed/Drop). Precisa de getgc, debug e hookfunction.",
    flag = "proj_silent",
    value = false,
    callback = function(v)
        ProjectileAim.enabled = v
        ProjectileAim.installTried = false
        if v then
            local ok = installProjectileAim()
            if not ok then
                ProjectileAim.enabled = false
                Window:Notify({
                    title = "Nao instalou",
                    content = ProjectileAim.status .. ". Use o silent aim normal.",
                    duration = 7,
                })
            else
                Window:Notify({ title = "Silent aim de projetil", content = "Hook ativo no createProjectile.", duration = 4 })
            end
        end
    end,
})

TCombat:CreateSlider({
    name = "FOV do projetil",
    description = "Raio em pixels a partir do centro da tela.",
    flag = "proj_fov",
    range = { 50, 1200 },
    increment = 10,
    value = 520,
    callback = function(v) ProjectileAim.fov = v end,
})

TCombat:CreateDropdown({
    name = "Parte do projetil",
    flag = "proj_part",
    options = { "Head", "Torso" },
    currentOption = { "Head" },
    multipleOptions = false,
    callback = function(option)
        ProjectileAim.partName = tostring(type(option) == "table" and option[1] or option)
    end,
})

TCombat:CreateSection({ name = "Seguranca / deteccao" })

TCombat:CreateToggle({
    name = "Modo seguro",
    description = "Ligado: nao usa debug.getupvalues nem debug.getconstants (o jogo loga Executed a script e tem TamperingDetected). Desligue so se o silent aim de projetil e o EntityMap forem necessarios.",
    flag = "safe_mode",
    value = false,
    callback = function(v)
        SafeMode.enabled = v
        if v then
            ProjectileAim.enabled = false
        end
        Log:add("modo seguro: " .. (v and "ativo" or "desligado"))
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

TCombat:CreateSlider({
    name = "Hitbox altura (Z)",
    flag = "hb_sizez",
    range = { 1, 15 },
    increment = 1,
    value = 6,
    callback = function(v) Hitbox.sizeZ = v end,
})

TCombat:CreateColorPicker({
    name = "Hitbox cor",
    flag = "hb_color",
    color = Color3.fromRGB(255, 0, 0),
    callback = function(color) Hitbox.color = color end,
})

TCombat:CreateToggle({
    name = "Hitbox: ignorar time",
    flag = "hb_team",
    value = false,
    description = "Nao expande hitbox de quem esta no seu time.",
    callback = function(v) Hitbox.ignoreTeam = v end,
})

TCombat:CreateToggle({
    name = "Hitbox: ignorar dormindo",
    flag = "hb_sleep",
    value = false,
    callback = function(v) Hitbox.ignoreSleepers = v end,
})

TCombat:CreateToggle({
    name = "Hitbox: so players",
    flag = "hb_npc",
    value = false,
    description = "Deixa NPC fora do hitbox expander.",
    callback = function(v) Hitbox.ignoreNpc = v end,
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
    name = "Ignorar time",
    flag = "esp_team",
    value = false,
    callback = function(v) Esp.ignoreTeam = v end,
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
    name = "Preencher FOV",
    flag = "ov_fovfill",
    value = false,
    description = hasDrawing and "Circulo do FOV com preenchimento." or "Precisa de executor com Drawing.",
    callback = function(v) Overlay.fovFill = v end,
})

TVisual:CreateColorPicker({
    name = "Cor do preenchimento",
    flag = "ov_fillcolor",
    color = Color3.fromRGB(0, 150, 255),
    callback = function(color) Overlay.fovFillColor = color end,
})

TVisual:CreateSlider({
    name = "Transparencia do preenchimento",
    flag = "ov_filltransp",
    range = { 0, 1 },
    increment = 0.05,
    value = 0.7,
    callback = function(v) Overlay.fovFillTransparency = v end,
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

TWorld:CreateSection({ name = "Performance (FPS booster)" })

TWorld:CreateButton({
    name = "Preset FPS (tudo)",
    callback = function()
        Perf.applyPreset()
        Window:Notify({ title = "Performance", content = "Preset aplicado: sombras, agua, render, particulas e efeitos.", duration = 5 })
    end,
})

TWorld:CreateToggle({
    name = "Sem sombras",
    description = "GlobalShadows = false e FogEnd alto (ganho grande no celular).",
    flag = "perf_shadows",
    value = false,
    callback = function(v) Perf.set("shadows", v) end,
})

TWorld:CreateToggle({
    name = "Render no minimo",
    description = "QualityLevel Level01 e MeshPartDetailLevel Level04.",
    flag = "perf_render",
    value = false,
    callback = function(v) Perf.set("render", v) end,
})

TWorld:CreateToggle({
    name = "Sem particulas",
    description = "Desliga ParticleEmitter, Trail, Smoke, Fire e Sparkles do mapa.",
    flag = "perf_particles",
    value = false,
    callback = function(v) Perf.set("particles", v) end,
})

TWorld:CreateToggle({
    name = "Sem efeitos de camera",
    description = "Bloom, Blur, SunRays e DepthOfField. Nao mexe no gamma do script.",
    flag = "perf_effects",
    value = false,
    callback = function(v) Perf.set("effects", v) end,
})

TWorld:CreateToggle({
    name = "Agua do Terrain off",
    description = "WaterWaveSize, WaveSpeed, Reflectance e Transparency.",
    flag = "perf_water",
    value = false,
    callback = function(v) Perf.set("water", v) end,
})

TWorld:CreateToggle({
    name = "Materiais 2022 off",
    description = "MaterialService.Use2022Materials = false (menos custo de shader).",
    flag = "perf_materials",
    value = false,
    callback = function(v) Perf.set("materials", v) end,
})

TWorld:CreateButton({
    name = "Restaurar performance",
    callback = function()
        Perf.restoreAll()
        Window:Notify({ title = "Performance", content = "Configuracoes originais restauradas.", duration = 4 })
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

TMove:CreateSection({ name = "Jump shoot (plataforma)" })

TMove:CreateToggle({
    name = "Jump shoot",
    flag = "js_enable",
    value = false,
    description = "Plataforma invisivel embaixo do player para atirar pulando (receita do AV0X).",
    callback = function(v)
        JumpShoot.enabled = v
        if v then
            if not JumpShoot.start() then
                JumpShoot.enabled = false
                Window:Notify({ title = "Jump shoot", content = "Nao consegui criar a plataforma aqui.", duration = 5 })
            end
        else
            JumpShoot.stop()
        end
    end,
})

TMove:CreateSlider({
    name = "Jump shoot altura",
    flag = "js_offset",
    range = { 0, 8 },
    increment = 0.5,
    value = 3.5,
    callback = function(v) JumpShoot.offset = v end,
})

TMove:CreateSlider({
    name = "Jump shoot transparencia",
    flag = "js_transp",
    range = { 0, 1 },
    increment = 0.05,
    value = 1,
    callback = function(v)
        JumpShoot.transparency = v
        if JumpShoot.part then pcall(function() JumpShoot.part.Transparency = v end) end
    end,
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

TMove:CreateSection({ name = "Dash slide (TCP 2/3)" })

TMove:CreateToggle({
    name = "Dash automatico",
    description = "Manda TCP (3,true) + (2,true) e empurra o corpo na direcao da camera. Repete enquanto voce anda.",
    flag = "dash_on",
    value = false,
    callback = function(v)
        Dash.enabled = v
        if not v and Dash.active then dashStop() end
    end,
})

TMove:CreateSlider({
    name = "Velocidade do dash",
    flag = "dash_speed",
    range = { 20, 90 },
    increment = 1,
    suffix = "sps",
    value = 62,
    callback = function(v) Dash.speed = v end,
})

TMove:CreateSlider({
    name = "Duracao do dash",
    flag = "dash_time",
    range = { 0.2, 3 },
    increment = 0.1,
    suffix = "s",
    value = 1.4,
    callback = function(v) Dash.duration = v end,
})

TMove:CreateButton({
    name = "Dash agora",
    callback = function()
        local ok = dashStart()
        Window:Notify({
            title = "Dash",
            content = ok and "Slide enviado no TCP." or "Sem remote TCP disponivel.",
            duration = 3,
        })
    end,
})

TMove:CreateButton({
    name = "Parar dash",
    callback = function()
        dashStop()
        Window:Notify({ title = "Dash", content = "Slide liberado.", duration = 3 })
    end,
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
TObj:CreateSection({ name = "AV0X (containers, zonas, veiculos)" })

TObj:CreateToggle({
    name = "Containers AV0X (default/box/trash)",
    flag = "avox_containers",
    value = false,
    description = "Detecta Model com filho 'default' e partes box/trash, como o AV0X.",
    callback = function(v) Avox.containers = v end,
})

TObj:CreateToggle({
    name = "Zonas (safe zone / no build)",
    flag = "avox_zones",
    value = false,
    description = "Marca workspace.World.Zones.SafeZones e NoBuildZones.",
    callback = function(v) Avox.zones = v end,
})

TObj:CreateToggle({
    name = "Veiculos (helicoptero)",
    flag = "avox_vehicles",
    value = false,
    description = "Le ReplicatedStorage.Shared.entities.vehicles e marca o modelo correspondente.",
    callback = function(v) Avox.vehicles = v end,
})

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

TObj:CreateSection({ name = "Catalogo do jogo (Shared.entities)" })

TObj:CreateToggle({
    name = "Recursos",
    description = "Tree, Cactus, Iron, Nitrate, Stone: nomes lidos do proprio jogo.",
    flag = "obj_resources",
    value = false,
    callback = function(v) Objects.resources = v end,
})

TObj:CreateButton({
    name = "Recarregar catalogo",
    callback = function()
        local ok = loadCatalog()
        Window:Notify({
            title = "Catalogo",
            content = ok and (tostring(#Catalog.list) .. " tipos encontrados: " .. table.concat(Catalog.list, ", ", 1, math.min(#Catalog.list, 10)))
                or "ReplicatedStorage.Shared.entities nao encontrado.",
            duration = 7,
        })
    end,
})

TObj:CreateSection({ name = "Auto farm / kill aura (TCP)" })

TObj:CreateToggle({
    name = "Auto farm (recursos)",
    description = "Dispara Swing + Hit no recurso mais proximo. Precisa de getgc/debug.getupvalues no executor.",
    flag = "farm_on",
    value = false,
    callback = function(v)
        Farm.enabled = v
        if v then
            Farm.warned = false
            Window:Notify({
                title = "Auto farm ligado",
                content = "O Trident tem deteccao de tampering: use em conta secundaria e por sua conta.",
                duration = 6,
            })
        end
    end,
})

TObj:CreateToggle({
    name = "Kill aura (players e NPCs)",
    description = "Manda Hit no player/NPC dentro do raio usando o EntityMap do cliente.",
    flag = "farm_killaura",
    value = false,
    callback = function(v) Farm.killAura = v; if v then Farm.warned = false end end,
})

TObj:CreateSlider({
    name = "Raio do farm",
    flag = "farm_distance",
    range = { 5, 120 },
    increment = 1,
    suffix = "m",
    value = 28,
    callback = function(v) Farm.distance = v end,
})

TObj:CreateSlider({
    name = "Intervalo do swing",
    flag = "farm_delay",
    range = { 0.05, 1.5 },
    increment = 0.05,
    suffix = "s",
    value = 0.95,
    callback = function(v) Farm.delay = v end,
})

TObj:CreateDropdown({
    name = "Parte do Hit (kill aura)",
    flag = "farm_hitpart",
    options = { "Head", "Torso" },
    currentOption = { "Head" },
    multipleOptions = false,
    callback = function(option)
        Farm.hitPart = tostring(type(option) == "table" and option[1] or option)
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
        Log:add("modo seguro: " .. (SafeMode.enabled and "ativo" or "desligado"))
        Log:add("silent aim de projetil: " .. tostring(ProjectileAim.status))
        Log:add("Highlight: " .. tostring(select(1, pcall(function() local h = Instance.new("Highlight"); h:Destroy() end)) and "ok" or "indisponivel"))
        local alvos = getEntities(true)
        local r6, trident = 0, 0
        for _, ent in ipairs(alvos) do
            if ent.rig == "trident" then trident = trident + 1 else r6 = r6 + 1 end
        end
        Log:add("alvos vistos: " .. tostring(#alvos) .. " (r6=" .. r6 .. " trident=" .. trident .. ")")

        -- checks diretos, com resultado legivel (antes saia "true true")
        local fpsArms, fpsCount = false, 0
        pcall(function()
            local c = Workspace:FindFirstChild("Const")
            local ign = c and c:FindFirstChild("Ignore")
            local arms = ign and ign:FindFirstChild("FPSArms")
            if arms then
                fpsArms = true
                fpsCount = #arms:GetChildren()
            end
        end)
        Log:add("Const.Ignore.FPSArms: " .. (fpsArms and ("ok (" .. fpsCount .. " filhos)") or "NAO ENCONTRADO"))

        local sharedEntities, entityCount, entityKinds = false, 0, ""
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local sh = rs:FindFirstChild("Shared")
            local ents = sh and sh:FindFirstChild("entities")
            if ents then
                sharedEntities = true
                local kids = ents:GetChildren()
                entityCount = #kids
                local names = {}
                for i = 1, math.min(#kids, 8) do names[i] = kids[i].Name end
                entityKinds = table.concat(names, ",")
            end
        end)
        Log:add("Shared.entities: " .. (sharedEntities and ("ok (" .. entityCount .. ": " .. entityKinds .. ")") or "NAO ENCONTRADO"))

        local tcpName, tcpOk = "NAO ENCONTRADO", false
        pcall(function()
            if Game.tcp then
                tcpOk = true
                tcpName = Game.tcp:GetFullName()
            else
                local tcp = LocalPlayer:FindFirstChild("TCP")
                if tcp then
                    tcpOk = true
                    tcpName = tcp:GetFullName()
                end
            end
        end)
        Log:add("LocalPlayer.TCP: " .. tcpName)
        Log:add("EntityMap: " .. (type(Game.entityMap) == "table" and "ok" or "nao resolvido (getgc)"))
        Log:add("resumo: alvos=" .. #alvos .. " tcp=" .. (tcpOk and "ok" or "NAO") .. " fpsArms=" .. (fpsArms and "ok" or "NAO") .. " entities=" .. (sharedEntities and "ok" or "NAO"))

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
    JumpShoot.enabled = false
    pcall(function() JumpShoot.stop() end)

    Esp.enabled = false
    Farm.enabled, Farm.killAura = false, false
    pcall(function() Perf.restoreAll() end)
    ProjectileAim.enabled = false
    Dash.enabled = false
    if Dash.active then dashStop() end
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
    genv.trident = { Log = Log, Game = Game, Aim = Aim, Esp = Esp, Move = Move, Hitbox = Hitbox, Silent = Silent, Objects = Objects, Chams = Chams, WorldFx = WorldFx, Catalog = Catalog, Farm = Farm, ProjectileAim = ProjectileAim, Dash = Dash, Perf = Perf, SafeMode = SafeMode, Window = Window }
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
