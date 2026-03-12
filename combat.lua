-- [[ TARTARUGA COMBAT ENGINE ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local Combat = {
    Target = nil,
    Settings = {
        AuraEnabled = false,
        RotationMode = "Silent", -- Silent, Legit, Snap, Extra, Plus
        HitboxSize = 2,          -- Размер расширенного хитбокса
        FOV = 100,               -- Радиус проверки
        Smoothing = 0.2,         -- Для Legit ротации
        MoveHelper = "Off"       -- Off, Targeted
    },
    
    -- Кэшируем анимацию для ShellMode, чтобы не создавать её в цикле (защита от краша)
    ShellAnim = Instance.new("Animation")
}
Combat.ShellAnim.AnimationId = "rbxassetid://0" -- Замени на ID реальной анимации, если есть

-- // Вспомогательные функции
local function GetClosestTarget()
    local nearest = nil
    local lastDist = Combat.Settings.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            -- Проверка на друзей (если есть в системе)
            if Tartaruga and Tartaruga.Friends[p.UserId] then continue end
            
            local root = p.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            local mousePos = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            
            if dist < lastDist then
                nearest = p
                lastDist = dist
            end
        end
    end
    return nearest
end

-- // Ротации
Combat.Rotations = {
    Silent = function(targetPos)
        return CFrame.new(LocalPlayer.Character.PrimaryPart.Position, targetPos)
    end,
    
    Legit = function(targetPos)
        local current = LocalPlayer.Character.PrimaryPart.CFrame
        local goal = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, targetPos)
        return current:Lerp(goal, Combat.Settings.Smoothing)
    end,
    
    Snap = function(targetPos)
        -- Мгновенная ротация (без сглаживания)
        return CFrame.new(LocalPlayer.Character.PrimaryPart.Position, targetPos)
    end,
    
    Extra = function(targetPos, targetVelocity)
        -- Ротация с предсказанием движения (Prediction)
        local predictedPos = targetPos + (targetVelocity * 0.18) 
        return CFrame.new(LocalPlayer.Character.PrimaryPart.Position, predictedPos)
    end,
    
    Plus = function(target)
        -- Ротация по точкам расширенного Hitbox
        local tRoot = target.Character.HumanoidRootPart
        local s = Combat.Settings.HitboxSize
        -- Смещение в пределах хитбокса для обхода проверок
        local offset = Vector3.new(math.random(-s,s)/10, math.random(-s,s)/10, math.random(-s,s)/10)
        return CFrame.new(LocalPlayer.Character.PrimaryPart.Position, tRoot.Position + offset)
    end
}

-- // Главная логика
function Combat:Update()
    if not self.Settings.AuraEnabled then 
        self.Target = nil
        return 
    end

    self.Target = GetClosestTarget()
    
    if self.Target and self.Target.Character then
        local root = LocalPlayer.Character.PrimaryPart
        local tRoot = self.Target.Character.HumanoidRootPart
        
        -- Применяем ротацию (Server-Side Only)
        local newCF = nil
        local mode = self.Settings.RotationMode
        
        if mode == "Extra" then
            newCF = self.Rotations.Extra(tRoot.Position, tRoot.Velocity)
        elseif mode == "Plus" then
            newCF = self.Rotations.Plus(self.Target)
        elseif mode == "Legit" then
            newCF = self.Rotations.Legit(tRoot.Position)
        else
            newCF = self.Rotations.Silent(tRoot.Position)
        end
        
        -- Разворачиваем только персонажа (не камеру!), чтобы другие видели поворот
        root.CFrame = CFrame.new(root.Position, Vector3.new(newCF.LookVector.X, 0, newCF.LookVector.Z) * 100 + root.Position)
        
        -- MoveHelper Logic
        if self.Settings.MoveHelper == "Targeted" then
            LocalPlayer.Character.Humanoid:MoveTo(tRoot.Position - (tRoot.CFrame.LookVector * 2))
        end
    end
end

-- // Shell Mode (Исправлен)
local shellLoop = nil
function Combat:SetShellMode(active)
    if active then
        shellLoop = task.spawn(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local track = hum:LoadAnimation(Combat.ShellAnim)
            while task.wait(0.05) do
                track:Play(0, 1, 10) -- Быстрое зацикливание
                task.wait(0.05)
                track:Stop()
            end
        end)
    else
        if shellLoop then task.cancel(shellLoop) end
    end
end

-- Подключение к циклу игры
RunService.Stepped:Connect(function()
    Combat:Update()
end)

return Combat
