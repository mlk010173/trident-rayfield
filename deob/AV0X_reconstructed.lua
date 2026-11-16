game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua")
game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua")
game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
game:GetService("Debris")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Color3.fromRGB(0, 0, 255)
workspace.ChildAdded:Connect(function(...)
    local callback1_arg1, callback1_arg2, callback1_arg3, callback1_arg4 = ...
end)
workspace.ChildRemoved:Connect(function(...)
    local callback2_arg1, callback2_arg2, callback2_arg3, callback2_arg4 = ...
end)
Players.LocalPlayer.CharacterAdded:Connect(function(...)
    local callback3_arg1, callback3_arg2, callback3_arg3, callback3_arg4 = ...
    task.delay(0.10000000000000001, function(...)
        local callback4_arg1, callback4_arg2, callback4_arg3, callback4_arg4 = ...
    end)
end)
Color3.fromRGB(0, 0, 255)
RunService.RenderStepped:Connect(function(...)
    local callback5_arg1, callback5_arg2, callback5_arg3, callback5_arg4 = ...
end)
local result = Color3.fromRGB(0, 0, 255)
local result2 = Color3.fromRGB(0, 0, 255)
local new2 = Drawing.new("Circle")
local new3 = Drawing.new("Circle")
new2.Thickness = 1
new2.NumSides = 64
new2.Radius = 150
new2.Filled = false
new2.Visible = false
new2.Transparency = 1
new2.Color = result
new2.ZIndex = 999
new3.Thickness = 0
new3.NumSides = 64
new3.Radius = 150
new3.Filled = true
new3.Visible = false
new3.Transparency = 0.29999999999999999
new3.Color = result2
new3.ZIndex = 998
local vector2 = Vector2.new((workspace.CurrentCamera.ViewportSize.X/2), (workspace.CurrentCamera.ViewportSize.Y/2))
new2.Position = vector2
new3.Position = vector2
local getPropertyChangedSignal = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize")
getPropertyChangedSignal:Connect(function(...)
    local callback6_arg1, callback6_arg2, callback6_arg3, callback6_arg4 = ...
    local vector22 = Vector2.new((workspace.CurrentCamera.ViewportSize.X/2), (workspace.CurrentCamera.ViewportSize.Y/2))
    new2.Position = vector22
    new3.Position = vector22
end)
task.spawn(function(...)
    local callback7_arg1, callback7_arg2, callback7_arg3, callback7_arg4 = ...
    task.wait(0.20000000000000001)
    local Const = workspace:FindFirstChild("Const")
    local Ignore = Const:FindFirstChild("Ignore")
    local FPSArms = Ignore:FindFirstChild("FPSArms")
    local HandModel = FPSArms:FindFirstChild("HandModel")
    HandModel:FindFirstChild("DefaultSight", true)
    HandModel:FindFirstChild("Barrel", true)
    HandModel:FindFirstChild("Body", true)
    HandModel:FindFirstChild("ChargingHandle", true)
    HandModel:FindFirstChild("Decals", true)
    HandModel:FindFirstChild("Mag", true)
    HandModel:FindFirstChild("Rails", true)
    HandModel:FindFirstChild("ShoulderPad", true)
    HandModel:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const2 = workspace:FindFirstChild("Const")
    local Ignore2 = Const2:FindFirstChild("Ignore")
    local FPSArms2 = Ignore2:FindFirstChild("FPSArms")
    local HandModel2 = FPSArms2:FindFirstChild("HandModel")
    HandModel2:FindFirstChild("DefaultSight", true)
    HandModel2:FindFirstChild("Barrel", true)
    HandModel2:FindFirstChild("Body", true)
    HandModel2:FindFirstChild("ChargingHandle", true)
    HandModel2:FindFirstChild("Decals", true)
    HandModel2:FindFirstChild("Mag", true)
    HandModel2:FindFirstChild("Rails", true)
    HandModel2:FindFirstChild("ShoulderPad", true)
    HandModel2:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const3 = workspace:FindFirstChild("Const")
    local Ignore3 = Const3:FindFirstChild("Ignore")
    local FPSArms3 = Ignore3:FindFirstChild("FPSArms")
    local HandModel3 = FPSArms3:FindFirstChild("HandModel")
    HandModel3:FindFirstChild("DefaultSight", true)
    HandModel3:FindFirstChild("Barrel", true)
    HandModel3:FindFirstChild("Body", true)
    HandModel3:FindFirstChild("ChargingHandle", true)
    HandModel3:FindFirstChild("Decals", true)
    HandModel3:FindFirstChild("Mag", true)
    HandModel3:FindFirstChild("Rails", true)
    HandModel3:FindFirstChild("ShoulderPad", true)
    HandModel3:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const4 = workspace:FindFirstChild("Const")
    local Ignore4 = Const4:FindFirstChild("Ignore")
    local FPSArms4 = Ignore4:FindFirstChild("FPSArms")
    local HandModel4 = FPSArms4:FindFirstChild("HandModel")
    HandModel4:FindFirstChild("DefaultSight", true)
    HandModel4:FindFirstChild("Barrel", true)
    HandModel4:FindFirstChild("Body", true)
    HandModel4:FindFirstChild("ChargingHandle", true)
    HandModel4:FindFirstChild("Decals", true)
    HandModel4:FindFirstChild("Mag", true)
    HandModel4:FindFirstChild("Rails", true)
    HandModel4:FindFirstChild("ShoulderPad", true)
    HandModel4:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const5 = workspace:FindFirstChild("Const")
    local Ignore5 = Const5:FindFirstChild("Ignore")
    local FPSArms5 = Ignore5:FindFirstChild("FPSArms")
    local HandModel5 = FPSArms5:FindFirstChild("HandModel")
    HandModel5:FindFirstChild("DefaultSight", true)
    HandModel5:FindFirstChild("Barrel", true)
    HandModel5:FindFirstChild("Body", true)
    HandModel5:FindFirstChild("ChargingHandle", true)
    HandModel5:FindFirstChild("Decals", true)
    HandModel5:FindFirstChild("Mag", true)
    HandModel5:FindFirstChild("Rails", true)
    HandModel5:FindFirstChild("ShoulderPad", true)
    HandModel5:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const6 = workspace:FindFirstChild("Const")
    local Ignore6 = Const6:FindFirstChild("Ignore")
    local FPSArms6 = Ignore6:FindFirstChild("FPSArms")
    local HandModel6 = FPSArms6:FindFirstChild("HandModel")
    HandModel6:FindFirstChild("DefaultSight", true)
    HandModel6:FindFirstChild("Barrel", true)
    HandModel6:FindFirstChild("Body", true)
    HandModel6:FindFirstChild("ChargingHandle", true)
    HandModel6:FindFirstChild("Decals", true)
    HandModel6:FindFirstChild("Mag", true)
    HandModel6:FindFirstChild("Rails", true)
    HandModel6:FindFirstChild("ShoulderPad", true)
    HandModel6:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const7 = workspace:FindFirstChild("Const")
    local Ignore7 = Const7:FindFirstChild("Ignore")
    local FPSArms7 = Ignore7:FindFirstChild("FPSArms")
    local HandModel7 = FPSArms7:FindFirstChild("HandModel")
    HandModel7:FindFirstChild("DefaultSight", true)
    HandModel7:FindFirstChild("Barrel", true)
    HandModel7:FindFirstChild("Body", true)
    HandModel7:FindFirstChild("ChargingHandle", true)
    HandModel7:FindFirstChild("Decals", true)
    HandModel7:FindFirstChild("Mag", true)
    HandModel7:FindFirstChild("Rails", true)
    HandModel7:FindFirstChild("ShoulderPad", true)
    HandModel7:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const8 = workspace:FindFirstChild("Const")
    local Ignore8 = Const8:FindFirstChild("Ignore")
    local FPSArms8 = Ignore8:FindFirstChild("FPSArms")
    local HandModel8 = FPSArms8:FindFirstChild("HandModel")
    HandModel8:FindFirstChild("DefaultSight", true)
    HandModel8:FindFirstChild("Barrel", true)
    HandModel8:FindFirstChild("Body", true)
    HandModel8:FindFirstChild("ChargingHandle", true)
    HandModel8:FindFirstChild("Decals", true)
    HandModel8:FindFirstChild("Mag", true)
    HandModel8:FindFirstChild("Rails", true)
    HandModel8:FindFirstChild("ShoulderPad", true)
    HandModel8:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const9 = workspace:FindFirstChild("Const")
    local Ignore9 = Const9:FindFirstChild("Ignore")
    local FPSArms9 = Ignore9:FindFirstChild("FPSArms")
    local HandModel9 = FPSArms9:FindFirstChild("HandModel")
    HandModel9:FindFirstChild("DefaultSight", true)
    HandModel9:FindFirstChild("Barrel", true)
    HandModel9:FindFirstChild("Body", true)
    HandModel9:FindFirstChild("ChargingHandle", true)
    HandModel9:FindFirstChild("Decals", true)
    HandModel9:FindFirstChild("Mag", true)
    HandModel9:FindFirstChild("Rails", true)
    HandModel9:FindFirstChild("ShoulderPad", true)
    HandModel9:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
    local Const10 = workspace:FindFirstChild("Const")
    local Ignore10 = Const10:FindFirstChild("Ignore")
    local FPSArms10 = Ignore10:FindFirstChild("FPSArms")
    local HandModel10 = FPSArms10:FindFirstChild("HandModel")
    HandModel10:FindFirstChild("DefaultSight", true)
    HandModel10:FindFirstChild("Barrel", true)
    HandModel10:FindFirstChild("Body", true)
    HandModel10:FindFirstChild("ChargingHandle", true)
    HandModel10:FindFirstChild("Decals", true)
    HandModel10:FindFirstChild("Mag", true)
    HandModel10:FindFirstChild("Rails", true)
    HandModel10:FindFirstChild("ShoulderPad", true)
    HandModel10:FindFirstChild("Stock", true)
    task.wait(0.20000000000000001)
end)
workspace:GetChildren()
workspace.ChildAdded:Connect(function(...)
    local callback8_arg1, callback8_arg2, callback8_arg3, callback8_arg4 = ...
    callback8_arg1:IsA("Model")
    callback8_arg1:FindFirstChild("HumanoidRootPart")
end)
workspace.ChildRemoved:Connect(function(...)
    local callback9_arg1, callback9_arg2, callback9_arg3, callback9_arg4 = ...
end)
RunService.RenderStepped:Connect(function(...)
    local callback10_arg1, callback10_arg2, callback10_arg3, callback10_arg4 = ...
    new2.Visible = false
    new3.Visible = false
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Vector2.new(20, ((workspace.CurrentCamera.ViewportSize.Y/2)-60))
UserInputService.InputBegan:Connect(function(...)
    local callback11_arg1, callback11_arg2, callback11_arg3, callback11_arg4 = ...
end)
UserInputService.InputEnded:Connect(function(...)
    local callback12_arg1, callback12_arg2, callback12_arg3, callback12_arg4 = ...
end)
UserInputService.InputChanged:Connect(function(...)
    local callback13_arg1, callback13_arg2, callback13_arg3, callback13_arg4 = ...
end)
workspace:GetChildren()
trace_180_v1:IsA("Model")
trace_180_v1:FindFirstChild("HumanoidRootPart")
workspace.ChildAdded:Connect(function(...)
    local callback14_arg1, callback14_arg2, callback14_arg3, callback14_arg4 = ...
    task.wait(0.10000000000000001)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback15_arg1, callback15_arg2, callback15_arg3, callback15_arg4 = ...
end)
RunService.RenderStepped:Connect(function(...)
    local callback16_arg1, callback16_arg2, callback16_arg3, callback16_arg4 = ...
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
local result3 = Color3.fromRGB(0, 0, 255)
local result4 = Color3.fromRGB(0, 0, 80)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPHolder"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Parent = PlayerGui
Players.LocalPlayer.CharacterAdded:Connect(function(...)
    local callback17_arg1, callback17_arg2, callback17_arg3, callback17_arg4 = ...
    task.wait(0.5)
end)
Vector2.new(0, 0)
Vector2.new(0, 0)
Vector2.new(1, 0)
Vector2.new(1, 0)
Vector2.new(0, 1)
Vector2.new(0, 1)
Vector2.new(1, 1)
Vector2.new(1, 1)
workspace:GetChildren()
trace_214_v1:IsA("Model")
trace_214_v1:FindFirstChild("HumanoidRootPart")
task.spawn(function(...)
    local callback18_arg1, callback18_arg2, callback18_arg3, callback18_arg4 = ...
    task.wait(0.10000000000000001)
end)
workspace.DescendantAdded:Connect(function(...)
    local callback19_arg1, callback19_arg2, callback19_arg3, callback19_arg4 = ...
    callback19_arg1:IsA("Model")
    callback19_arg1:IsA("Model")
    callback19_arg1:FindFirstChild("HumanoidRootPart")
    task.wait(0.10000000000000001)
end)
workspace.DescendantRemoving:Connect(function(...)
    local callback20_arg1, callback20_arg2, callback20_arg3, callback20_arg4 = ...
    callback20_arg1:IsA("Model")
end)
task.spawn(function(...)
    local callback21_arg1, callback21_arg2, callback21_arg3, callback21_arg4 = ...
    task.wait(15)
end)
Vector3.new(0, 2.7999999999999998, 0)
Vector3.new(0, 3, 0)
local new4 = ColorSequenceKeypoint.new(0, result3)
local new5 = ColorSequenceKeypoint.new(1, result4)
ColorSequence.new({[1] = new4, [2] = new5})
RunService.Heartbeat:Connect(function(...)
    local callback22_arg1, callback22_arg2, callback22_arg3, callback22_arg4 = ...
    tick()
end)
RunService.Heartbeat:Connect(function(...)
    local callback23_arg1, callback23_arg2, callback23_arg3, callback23_arg4 = ...
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 100)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(20, 20, 20)
Color3.fromRGB(255, 165, 0)
local result5 = Color3.fromRGB(230, 182, 0)
Color3.fromRGB(150, 150, 150)
Color3.fromRGB(255, 0, 207)
Color3.fromRGB(44, 97, 0)
Color3.fromRGB(100, 100, 100)
Color3.fromRGB(200, 0, 0)
workspace:GetChildren()
task.spawn(function(...)
    local callback24_arg1, callback24_arg2, callback24_arg3, callback24_arg4 = ...
    callback24_arg1:IsA("Model")
    callback24_arg1:FindFirstChild("default")
    callback24_arg1:GetChildren()
    trace_262_v1:IsA("BasePart")
    local box = callback24_arg1:FindFirstChild("box")
    local trash = callback24_arg1:FindFirstChild("trash")
    box:IsA("MeshPart")
    trash:IsA("MeshPart")
    callback24_arg1:FindFirstChildWhichIsA("BasePart")
    local new6 = Drawing.new("Text")
    new6.Text = "DefaultBox"
    new6.Size = 10
    new6.Center = true
    new6.Font = 2
    new6.Outline = true
    local color3 = Color3.new(0, 0, 0)
    new6.OutlineColor = color3
    new6.Color = result5
    new6.Visible = false
    callback24_arg1.AncestryChanged:Connect(function(...)
        local callback25_arg1, callback25_arg2, callback25_arg3, callback25_arg4 = ...
    end)
end, trace_258_v1)
workspace.ChildAdded:Connect(function(...)
    local callback26_arg1, callback26_arg2, callback26_arg3, callback26_arg4 = ...
    task.spawn(function(...)
        local callback27_arg1, callback27_arg2, callback27_arg3, callback27_arg4 = ...
        callback27_arg1:IsA("Model")
        callback27_arg1:FindFirstChild("default")
        callback27_arg1:GetChildren()
        trace_276_v1:IsA("BasePart")
        local box2 = callback27_arg1:FindFirstChild("box")
        local trash2 = callback27_arg1:FindFirstChild("trash")
        box2:IsA("MeshPart")
        trash2:IsA("MeshPart")
        callback27_arg1:FindFirstChildWhichIsA("BasePart")
        local new7 = Drawing.new("Text")
        new7.Text = "DefaultBox"
        new7.Size = 10
        new7.Center = true
        new7.Font = 2
        new7.Outline = true
        local color32 = Color3.new(0, 0, 0)
        new7.OutlineColor = color32
        new7.Color = result5
        new7.Visible = false
        callback27_arg1.AncestryChanged:Connect(function(...)
            local callback28_arg1, callback28_arg2, callback28_arg3, callback28_arg4 = ...
        end)
    end, callback26_arg1)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback29_arg1, callback29_arg2, callback29_arg3, callback29_arg4 = ...
end)
Color3.fromRGB(120, 120, 120)
Color3.fromRGB(255, 215, 0)
Color3.fromRGB(200, 255, 200)
Color3.fromRGB(72, 72, 72)
Color3.fromRGB(199, 172, 120)
Color3.fromRGB(248, 248, 248)
task.spawn(function(...)
    local callback30_arg1, callback30_arg2, callback30_arg3, callback30_arg4 = ...
    workspace:GetChildren()
    trace_294_v1:IsA("Model")
    trace_294_v1:GetChildren()
    trace_296_v1:IsA("MeshPart")
end)
workspace.ChildAdded:Connect(function(...)
    local callback31_arg1, callback31_arg2, callback31_arg3, callback31_arg4 = ...
    callback31_arg1:IsA("Model")
    task.wait()
end)
workspace.ChildRemoved:Connect(function(...)
    local callback32_arg1, callback32_arg2, callback32_arg3, callback32_arg4 = ...
end)
task.spawn(function(...)
    local callback33_arg1, callback33_arg2, callback33_arg3, callback33_arg4 = ...
    task.wait(3)
end)
Color3.fromRGB(255, 100, 0)
Color3.fromRGB(0, 150, 255)
local result6 = Color3.fromRGB(0, 255, 0)
Color3.fromRGB(200, 200, 0)
task.spawn(function(...)
    local callback34_arg1, callback34_arg2, callback34_arg3, callback34_arg4 = ...
    workspace:GetChildren()
    trace_309_v1:IsA("Model")
    ReplicatedStorage.Shared.entities.vehicles.Helicopter.Model:GetChildren()
    trace_309_v1:FindFirstChild(trace_311_v1.Name)
    local new8 = Drawing.new("Text")
    new8.Text = "Helicopter"
    new8.Size = 14
    new8.Center = true
    new8.Font = 2
    new8.Outline = true
    local color33 = Color3.new(0, 0, 0)
    new8.OutlineColor = color33
    new8.Color = result6
    new8.Visible = false
    trace_309_v1.AncestryChanged:Connect(function(...)
        local callback35_arg1, callback35_arg2, callback35_arg3, callback35_arg4 = ...
    end)
end)
workspace.ChildAdded:Connect(function(...)
    local callback36_arg1, callback36_arg2, callback36_arg3, callback36_arg4 = ...
    callback36_arg1:IsA("Model")
    task.wait(0.10000000000000001)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback37_arg1, callback37_arg2, callback37_arg3, callback37_arg4 = ...
end)
task.spawn(function(...)
    local callback38_arg1, callback38_arg2, callback38_arg3, callback38_arg4 = ...
    task.wait(3)
end)
Color3.fromRGB(255, 0, 0)
task.spawn(function(...)
    local callback39_arg1, callback39_arg2, callback39_arg3, callback39_arg4 = ...
    workspace:GetChildren()
    trace_324_v1:IsA("Model")
    trace_324_v1:GetChildren()
    trace_326_v1:IsA("BasePart")
end)
workspace.ChildAdded:Connect(function(...)
    local callback40_arg1, callback40_arg2, callback40_arg3, callback40_arg4 = ...
    callback40_arg1:IsA("Model")
    task.wait(0.10000000000000001)
end)
workspace.ChildRemoved:Connect(function(...)
    local callback41_arg1, callback41_arg2, callback41_arg3, callback41_arg4 = ...
end)
task.spawn(function(...)
    local callback42_arg1, callback42_arg2, callback42_arg3, callback42_arg4 = ...
    task.wait(5)
end)
Color3.fromRGB(255, 0, 0)
RunService.Heartbeat:Connect(function(...)
    local callback43_arg1, callback43_arg2, callback43_arg3, callback43_arg4 = ...
    tick()
end)
workspace:GetDescendants()
trace_337_v1:IsA("BasePart")
workspace.DescendantAdded:Connect(function(...)
    local callback44_arg1, callback44_arg2, callback44_arg3, callback44_arg4 = ...
    callback44_arg1:IsA("BasePart")
end)
workspace.DescendantRemoving:Connect(function(...)
    local callback45_arg1, callback45_arg2, callback45_arg3, callback45_arg4 = ...
end)
RunService.RenderStepped:Connect(function(...)
    local callback46_arg1, callback46_arg2, callback46_arg3, callback46_arg4 = ...
end)
local World = workspace:FindFirstChild("World")
local Zones = World:FindFirstChild("Zones")
Zones:FindFirstChild("SafeZones")
Zones.SafeZones:FindFirstChild("SAFEZONE_Town")
Color3.fromRGB(0, 255, 0)
Zones:FindFirstChild("NoBuildZones")
Color3.fromRGB(255, 0, 0)
Color3.fromRGB(0, 255, 0)
Color3.fromRGB(255, 0, 0)
Color3.new(0, 0, 1)
Color3.new(0, 0, 1)
a = {}
w = {}
ao = {}
wo = {}
local Const11 = workspace:FindFirstChild("Const")
local Ignore11 = Const11:FindFirstChild("Ignore")
local FPSArms11 = Ignore11:FindFirstChild("FPSArms")
FPSArms11.ChildAdded:Connect(function(...)
    local callback47_arg1, callback47_arg2, callback47_arg3, callback47_arg4 = ...
    task.wait(0.10000000000000001)
end)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
Color3.fromRGB(0, 0, 255)
workspace.DescendantAdded:Connect(function(...)
    local callback48_arg1, callback48_arg2, callback48_arg3, callback48_arg4 = ...
    callback48_arg1:IsDescendantOf(ReplicatedStorage)
end)
Color3.fromRGB(0, 0, 255)
RunService.Heartbeat:Connect(function(...)
    local callback49_arg1, callback49_arg2, callback49_arg3, callback49_arg4 = ...
end)
task.spawn(function(...)
    local callback50_arg1, callback50_arg2, callback50_arg3, callback50_arg4 = ...
    task.wait(0.5)
end)
