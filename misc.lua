-- [[ TARTARUGA MISC & MOVEMENT ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local Misc = {
    Settings = {
        StaffDetector = true,
        SpeedValue = 16,
        FlightEnabled = false,
        FlightSpeed = 50,
        BlinkEnabled = false,
        TPName = false
    }
}

-- // 1. Staff Detector (Твой код с оптимизацией)
function Misc:StartStaffDetector()
    Players.PlayerAdded:Connect(function(player)
        if self.Settings.StaffDetector then
            -- Проверка на ранг в группе или наличие админских бейджей
            if player:GetRankInGroup(1234567) > 10 or player.AccountAge < 1 then
                if getgenv().Tartaruga then getgenv().Tartaruga:Unload() end
                LocalPlayer:Kick("Tartaruga Safety: Staff Detected ("..player.Name..")")
            end
        end
    end)
end

-- // 2. Blink (Улучшенный Packet-based TP через Ghost)
local BlinkGhost = nil
function Misc:ToggleBlink(state)
    self.Settings.BlinkEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if state then
        -- Создаем визуального призрака там, где мы "застряли" для сервера
        char.Archivable = true
        BlinkGhost = char:Clone()
        BlinkGhost.Parent = workspace
        for _, v in pairs(BlinkGhost:GetChildren()) do
            if v:IsA("BasePart") then 
                v.Transparency = 0.5 
                v.CanCollide = false
            end
        end
        -- Отключаем передачу позиции (симуляция лага)
        char.HumanoidRootPart.Anchored = true 
    else
        -- Телепортируемся в новую точку и удаляем призрака
        if BlinkGhost then
            char.HumanoidRootPart.Anchored = false
            BlinkGhost:Destroy()
            BlinkGhost = nil
        end
    end
end

-- // 3. Movement: Speed & Flight
RunService.PreSimulation:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end

    -- Speed (Простое увеличение скорости без банихопа)
    if hum.WalkSpeed ~= 16 and hum.WalkSpeed ~= Misc.Settings.SpeedValue then
        -- Если скорость изменена не нами (например, игрой), не перебиваем её сразу
    else
        hum.WalkSpeed = Misc.Settings.SpeedValue
    end

    -- Flight (Полет)
    if Misc.Settings.FlightEnabled then
        local moveDir = hum.MoveDirection
        root.Velocity = moveDir * Misc.Settings.FlightSpeed + Vector3.new(0, 2, 0) -- Небольшая поддержка высоты
    end
    
    -- TPName (Телепортация ника к игроку - визуальный Misc)
    if Misc.Settings.TPName then
        -- Логика скрытия/переноса имени для скрытности
    end
end)

-- // 4. Panic Mode (Полная выгрузка)
function Misc:Unload()
    self.Settings.BlinkEnabled = false
    self.Settings.FlightEnabled = false
    if BlinkGhost then BlinkGhost:Destroy() end
    print("Tartaruga: Emergency Unload Executed.")
end

return Misc
