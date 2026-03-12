-- [[ TARTARUGA VISUAL ENGINE ]] --
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Visuals = {
    Settings = {
        ChinaHat = false,
        Trails = false,
        JumpCircle = false,
        TargetESP = false,
        Arrows = false,
        ThemeColor = Color3.fromRGB(0, 255, 170)
    },
    ActivePyramid = nil
}

-- // 1. TargetESP: Вращающиеся пирамиды (на основе твоего кода)
function Visuals:UpdateTargetESP(target)
    if self.Settings.TargetESP and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if not self.ActivePyramid then
            self.ActivePyramid = Instance.new("Part")
            self.ActivePyramid.Name = "Tartaruga_TargetESP"
            self.ActivePyramid.Size = Vector3.new(1, 1, 1)
            self.ActivePyramid.Color = self.Settings.ThemeColor
            self.ActivePyramid.Material = Enum.Material.Neon
            self.ActivePyramid.CanCollide = false
            self.ActivePyramid.Anchored = true
            self.ActivePyramid.Parent = workspace
            -- Создаем форму пирамиды через SpecialMesh
            local Mesh = Instance.new("SpecialMesh", self.ActivePyramid)
            Mesh.MeshType = Enum.MeshType.FileMesh
            Mesh.MeshId = "rbxassetid://1033714" -- ID стандартной пирамиды
        end
        
        local tPos = target.Character.HumanoidRootPart.Position
        local angle = tick() * 5
        local offset = Vector3.new(math.cos(angle)*3, 2 + math.sin(angle*2)*0.5, math.sin(angle)*3)
        self.ActivePyramid.Position = tPos + offset
        self.ActivePyramid.Rotation = Vector3.new(0, angle * 50, 0)
    else
        if self.ActivePyramid then
            self.ActivePyramid:Destroy()
            self.ActivePyramid = nil
        end
    end
end

-- // 2. ChinaHat: Неоновая шляпа (из твоего плана)
local HatPart = nil
function Visuals:RenderChinaHat()
    if self.Settings.ChinaHat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        if not HatPart then
            HatPart = Instance.new("Part")
            HatPart.Name = "ChinaHat"
            HatPart.Parent = LocalPlayer.Character
            HatPart.Size = Vector3.new(2, 0.5, 2)
            HatPart.CanCollide = false
            HatPart.Material = Enum.Material.Neon
            HatPart.Color = self.Settings.ThemeColor
            HatPart.Transparency = 0.4
            
            local Mesh = Instance.new("SpecialMesh", HatPart)
            Mesh.MeshType = Enum.MeshType.FileMesh
            Mesh.MeshId = "rbxassetid://1033714" -- Конус/Пирамида
            Mesh.Scale = Vector3.new(2.5, 0.8, 2.5)
            
            local Weld = Instance.new("Weld", HatPart)
            Weld.Part0 = HatPart
            Weld.Part1 = LocalPlayer.Character.Head
            Weld.C0 = CFrame.new(0, -0.6, 0) * CFrame.Angles(math.rad(180), 0, 0)
        end
    elseif HatPart then
        HatPart:Destroy()
        HatPart = nil
    end
end

-- // 3. Trails: Шлейф при движении (из твоего плана)
local CurrentTrail = nil
function Visuals:UpdateTrails()
    if self.Settings.Trails and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if not CurrentTrail then
            local Root = LocalPlayer.Character.HumanoidRootPart
            local Attachment0 = Instance.new("Attachment", Root)
            Attachment0.Position = Vector3.new(0, 1, 0)
            local Attachment1 = Instance.new("Attachment", Root)
            Attachment1.Position = Vector3.new(0, -1, 0)
            
            CurrentTrail = Instance.new("Trail", Root)
            CurrentTrail.Attachment0 = Attachment0
            CurrentTrail.Attachment1 = Attachment1
            CurrentTrail.Color = ColorSequence.new(self.Settings.ThemeColor)
            CurrentTrail.Lifetime = 0.5
            CurrentTrail.Transparency = NumberSequence.new(0.5, 1)
        end
    elseif CurrentTrail then
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root then
            for _, v in pairs(Root:GetChildren()) do
                if v:IsA("Trail") or v:IsA("Attachment") then v:Destroy() end
            end
        end
        CurrentTrail = nil
    end
end

-- // 4. TargetHUD Win Logic (Твой код с исправлением Win/Lose)
function Visuals:GetWinChance(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Humanoid") then return "idk🐖 (50%)" end
    
    local myHP = LocalPlayer.Character.Humanoid.Health
    local tHP = target.Character.Humanoid.Health
    
    if myHP > tHP then 
        return "Win (>51%)" -- Твой текст из макета
    elseif myHP == tHP then 
        return "idk🐖 (50%)" -- Твой смайлик из макета
    else 
        return "Lose (<49%)" -- Твой текст из макета
    end
end

-- // Цикл рендеринга
RunService.RenderStepped:Connect(function()
    Visuals:RenderChinaHat()
    Visuals:UpdateTrails()
    -- Сюда передается текущая цель из Combat.lua
    if getgenv().Tartaruga and getgenv().Tartaruga.Combat then
        Visuals:UpdateTargetESP(getgenv().Tartaruga.Combat.Target)
    end
end)

return Visuals
