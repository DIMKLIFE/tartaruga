-- [[ TARTARUGA ELITE CLIENT: CORE ]] --
local Tartaruga = {
    Version = "1.0.0",
    Theme = {
        Accent = Color3.fromRGB(0, 255, 150), -- Default Neon Green
        Secondary = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Modules = {},
    Settings = {
        Mode = "Minecraft", -- "Minecraft" or "CS"
        Language = "English"
    }
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Holiday System
local function GetHolidayTheme()
    local date = os.date("*t")
    local month, day = date.month, date.day
    
    if month == 10 and day == 31 then
        return Color3.fromRGB(255, 120, 0), "Halloween" -- Orange
    elseif month == 12 and (day >= 24) then
        return Color3.fromRGB(255, 50, 50), "Christmas" -- Red
    elseif month == 3 and day == 8 then
        return Color3.fromRGB(255, 100, 200), "March 8" -- Pink
    elseif month == 1 and day == 1 then
        return Color3.fromRGB(0, 200, 255), "New Year" -- Cyan
    end
    return Tartaruga.Theme.Accent, "Default"
end

Tartaruga.Theme.Accent, Tartaruga.ActiveHoliday = GetHolidayTheme()
