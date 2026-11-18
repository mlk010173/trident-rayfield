-- jumpshoot.lua - funcao JumpShoot do AV0X reconstruida pelo trace
-- Fonte: trace da VM WeAreDevs (passD), callback "JumpShoot" do menu.
-- Natureza: RECONSTRUIDO a partir das operacoes observadas; nomes de variaveis
-- eram v0..vN no payload e foram renomeados por papel. Sem invencao de partes
-- ausentes: o corpo abaixo corresponde 1:1 ao que a VM executou.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local plataforma = Instance.new("Part", Workspace)
plataforma.Name = "!.!"
plataforma.Size = Vector3.new(4, 0.2, 4)
plataforma.Anchored = true
plataforma.CanCollide = true
plataforma.Color = Color3.fromRGB(0, 0, 255)
plataforma.Transparency = 1
plataforma.Material = Enum.Material.Neon

local malha = Instance.new("SpecialMesh")
malha.MeshType = Enum.MeshType.FileMesh
malha.MeshId = "rbxassetid://20329976"
malha.Parent = plataforma

task.spawn(function()
    while true do
        local personagem = workspace.Const.Ignore.LocalCharacter
        local deslocamento = Vector3.new(0, 3.5, 0)
        plataforma.Position = personagem.Middle.Position - deslocamento
        RunService.Heartbeat:Wait()
    end
end)

-- Nao recuperado deste callback: condicao de saida do loop (o trace estourou o
-- orcamento antes), tecla de ativacao e limpeza da part ao desligar.
