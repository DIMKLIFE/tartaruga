-- [[ UI HANDLER ]] --
function Tartaruga:CreateIntro()
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Viewport = Instance.new("ViewportFrame", ScreenGui)
    Viewport.Size = UDim2.new(1, 0, 1, 0)
    Viewport.BackgroundTransparency = 1
    
    -- 3D Turtle Model (Placeholder Mesh)
    local Turtle = Instance.new("Part")
    Turtle.Shape = Enum.PartType.Ball -- In production, use a Turtle Mesh
    Turtle.Parent = Viewport
    
    local Camera = Instance.new("Camera", Viewport)
    Viewport.CurrentCamera = Camera
    Camera.CFrame = CFrame.new(Vector3.new(0, 0, 5), Turtle.Position)

    -- Rotate Logic
    RunService.RenderStepped:Connect(function()
        Turtle.CFrame = Turtle.CFrame * CFrame.Angles(0, math.rad(2), 0)
    end)
    
    task.delay(3, function()
        TweenService:Create(Viewport, TweenInfo.new(1), {ImageTransparency = 1}):Play()
        -- Load Mode Selection Here
    end)
end

-- Watermark 5s Cycle
function Tartaruga:StartWatermark()
    local Labels = {"🐢 Tartaruga", "User: "..LocalPlayer.Name, "FPS: 60"}
    local Index = 1
    task.spawn(function()
        while task.wait(5) do
            Index = (Index % #Labels) + 1
            -- Update UI Label with Tween
            print("Watermark Cycle: " .. Labels[Index])
        end
    end)
end
