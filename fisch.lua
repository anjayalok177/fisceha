-- ======================
-- Intro animation
-- ======================
local function createIntroAnimation()
    local TweenService = game:GetService("TweenService")
    local SoundService = game:GetService("SoundService")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "IntroScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Create sounds
    local laserSound = Instance.new("Sound")
    laserSound.SoundId = "rbxassetid://9057675920"
    laserSound.Volume = 0.5
    laserSound.Parent = SoundService
    
    local explosionSound = Instance.new("Sound")
    explosionSound.SoundId = "rbxassetid://112797079504478"
    explosionSound.Volume = 0.6
    explosionSound.Parent = SoundService
    
    -- Animated Background with gradient
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    background.BorderSizePixel = 0
    background.Parent = screenGui
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 10, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 30, 70))
    }
    gradient.Rotation = 45
    gradient.Parent = background
    
    -- Animated particles in background
    for i = 1, 20 do
        local bgParticle = Instance.new("Frame")
        bgParticle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
        bgParticle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        bgParticle.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        bgParticle.BackgroundTransparency = math.random(50, 80) / 100
        bgParticle.BorderSizePixel = 0
        bgParticle.Parent = background
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = bgParticle
        
        -- Float animation
        task.spawn(function()
            while bgParticle.Parent do
                local floatAnim = TweenService:Create(
                    bgParticle,
                    TweenInfo.new(math.random(20, 40) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {
                        Position = UDim2.new(
                            bgParticle.Position.X.Scale + math.random(-10, 10) / 100,
                            0,
                            bgParticle.Position.Y.Scale + math.random(-10, 10) / 100,
                            0
                        )
                    }
                )
                floatAnim:Play()
                task.wait(math.random(20, 40) / 10)
            end
        end)
    end
    
    -- Main Image Frame (Square) - Centered
    local imageFrame = Instance.new("ImageLabel")
    imageFrame.Size = UDim2.new(0, 220, 0, 220)
    imageFrame.Position = UDim2.new(0.5, 0, 1.2, 0)
    imageFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    imageFrame.BackgroundTransparency = 1
    imageFrame.Image = "rbxassetid://110843044052526"
    imageFrame.ScaleType = Enum.ScaleType.Fit
    imageFrame.Parent = background
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 25)
    corner.Parent = imageFrame
    
    -- Glow effect around image
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.3, 0, 1.3, 0)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = Color3.fromRGB(138, 43, 226)
    glow.ImageTransparency = 0.5
    glow.Parent = imageFrame
    
    -- Title text - MOVED MUCH LOWER
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 500, 0, 70)
    title.Position = UDim2.new(0.5, 0, 0.78, 0)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "YI DA MU SAKE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 48
    title.Font = Enum.Font.GothamBold
    title.TextTransparency = 1
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.fromRGB(138, 43, 226)
    title.Parent = background
    
    -- ANIMATION 1: Slide up from bottom with smooth BOUNCE effect (2.5 SECONDS)
    local slideUp = TweenService:Create(
        imageFrame,
        TweenInfo.new(2.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, 0, 0.4, 0)}
    )
    
    -- ANIMATION 2: Fade in text
    local fadeInTitle = TweenService:Create(
        title,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0}
    )
    
    -- Start animations + LASER SOUND
    laserSound:Play()
    slideUp:Play()
    task.wait(1.2)
    fadeInTitle:Play()
    
    -- Wait for bounce to settle completely
    task.wait(2.0)
    
    -- Calculate distance from center for OUTSIDE-IN shatter
    local function getDistanceFromCenter(row, col, gridSize)
        local centerRow = (gridSize - 1) / 2
        local centerCol = (gridSize - 1) / 2
        local distRow = row - centerRow
        local distCol = col - centerCol
        return math.sqrt(distRow * distRow + distCol * distCol)
    end
    
    -- SHATTER FROM OUTSIDE TO INSIDE
    local function createShatteredPieces()
        local pieces = {}
        local gridSize = 6  -- 6x6 grid = 36 pieces
        local imageSize = 220
        local pieceSize = imageSize / gridSize
        local originalImageSize = 420
        
        -- Store pieces with their distance from center
        local piecesWithDistance = {}
        
        for row = 0, gridSize - 1 do
            for col = 0, gridSize - 1 do
                local piece = Instance.new("ImageLabel")
                
                piece.Size = UDim2.new(0, pieceSize, 0, pieceSize)
                piece.Position = UDim2.new(
                    0.5, (col * pieceSize) - (imageSize / 2),
                    0.4, (row * pieceSize) - (imageSize / 2)
                )
                piece.AnchorPoint = Vector2.new(0, 0)
                
                piece.BackgroundTransparency = 1
                piece.Image = "rbxassetid://110843044052526"
                piece.ScaleType = Enum.ScaleType.Crop
                piece.ZIndex = 5
                
                -- Crop to specific part
                local rectWidth = originalImageSize / gridSize
                local rectHeight = originalImageSize / gridSize
                
                piece.ImageRectSize = Vector2.new(rectWidth, rectHeight)
                piece.ImageRectOffset = Vector2.new(col * rectWidth, row * rectHeight)
                
                piece.Parent = background
                
                local pCorner = Instance.new("UICorner")
                pCorner.CornerRadius = UDim.new(0, math.random(2, 6))
                pCorner.Parent = piece
                
                -- Calculate distance from center
                local distance = getDistanceFromCenter(row, col, gridSize)
                
                table.insert(piecesWithDistance, {
                    piece = piece,
                    distance = distance
                })
            end
        end
        
        -- Sort by distance (furthest first = outside first)
        table.sort(piecesWithDistance, function(a, b)
            return a.distance > b.distance
        end)
        
        return piecesWithDistance
    end
    
    -- TOTEM PARTICLES (spawn with image pieces!)
    local function createTotemParticles()
        local particles = {}
        
        for i = 1, 45 do
            local particle = Instance.new("Frame")
            local size = math.random(10, 22)
            particle.Size = UDim2.new(0, size, 0, size)
            particle.Position = UDim2.new(0.5, 0, 0.4, 0)
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            
            -- Totem colors: white, yellow, gold
            local colorChoice = math.random(1, 4)
            if colorChoice == 1 then
                particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
            elseif colorChoice == 2 then
                particle.BackgroundColor3 = Color3.fromRGB(255, 255, 120) -- Yellow
            elseif colorChoice == 3 then
                particle.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Gold
            else
                particle.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple accent
            end
            
            particle.BorderSizePixel = 0
            particle.ZIndex = 6
            particle.Parent = background
            
            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(0.35, 0)
            pCorner.Parent = particle
            
            table.insert(particles, particle)
        end
        
        return particles
    end
    
    -- White flash
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flash.BorderSizePixel = 0
    flash.BackgroundTransparency = 1
    flash.ZIndex = 10
    flash.Parent = background
    
    -- INSTANT FLASH (like totem pop)
    local flashIn = TweenService:Create(
        flash,
        TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.1}
    )
    
    local flashOut = TweenService:Create(
        flash,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    
    -- Hide original
    imageFrame.Visible = false
    glow.Visible = false
    
    -- EXPLOSION SOUND!
    explosionSound:Play()
    
    -- FLASH!
    flashIn:Play()
    flashIn.Completed:Connect(function()
        flashOut:Play()
    end)
    
    -- Create particles
    local shatteredPieces = createShatteredPieces()
    local totemParts = createTotemParticles()
    
    -- SCATTER FROM OUTSIDE TO INSIDE (shockwave effect!)
    -- Image pieces and totem particles fly out TOGETHER
    
    for i, pieceData in ipairs(shatteredPieces) do
        local piece = pieceData.piece
        
        local angle = math.random(0, 360)
        local rad = math.rad(angle)
        local distance = math.random(400, 800)
        
        local targetX = math.cos(rad) * distance
        local targetY = math.sin(rad) * distance + math.random(100, 300)
        
        local scatter = TweenService:Create(
            piece,
            TweenInfo.new(
                2.0, -- PARTICLE DURATION: 2 SECONDS
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Position = UDim2.new(piece.Position.X.Scale, piece.Position.X.Offset + targetX, 
                                   piece.Position.Y.Scale, piece.Position.Y.Offset + targetY),
                ImageTransparency = 1,
                Rotation = math.random(-450, 450),
                Size = UDim2.new(0, piece.Size.X.Offset * 0.3, 0, piece.Size.Y.Offset * 0.3)
            }
        )
        
        scatter:Play()
        
        -- Spawn totem particle alongside some image pieces
        if i <= #totemParts then
            local totemParticle = totemParts[i]
            
            local tAngle = math.random(0, 360)
            local tRad = math.rad(tAngle)
            local tDistance = math.random(350, 750)
            
            local tTargetX = math.cos(tRad) * tDistance
            local tTargetY = math.sin(tRad) * tDistance + math.random(120, 280)
            
            local totemScatter = TweenService:Create(
                totemParticle,
                TweenInfo.new(
                    2.0, -- PARTICLE DURATION: 2 SECONDS
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    Position = UDim2.new(0.5, tTargetX, 0.4, tTargetY),
                    BackgroundTransparency = 1,
                    Rotation = math.random(-280, 280),
                    Size = UDim2.new(0, totemParticle.Size.X.Offset * 0.25, 0, totemParticle.Size.Y.Offset * 0.25)
                }
            )
            
            totemScatter:Play()
        end
        
        -- DELAY based on distance (outside pieces go first!)
        -- Smaller delay = faster shockwave effect
        task.wait(0.004)
    end
    
    -- Fade out (wait longer for particles to finish)
    task.wait(1.5)
    
    local fadeOutTitle = TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 1})
    local fadeOutBg = TweenService:Create(background, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    
    fadeOutTitle:Play()
    fadeOutBg:Play()
    
    task.wait(0.6)
    
    -- Clean up sounds
    laserSound:Destroy()
    explosionSound:Destroy()
    
    screenGui:Destroy()
end

createIntroAnimation()

-- ========================================
-- SCRIPT KAMU MULAI DI BAWAH INI
-- ========================================

-- ================= SERVICES =================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= CONFIG =================
local Config = {
    -- Auto Cast
    AutoCast = false,
    AutoCastDelay = 3,
    AutoCastHoldTime = 1, -- waktu hold mouse dalam detik

    -- Auto Shake
    AutoShake = false,
    AutoShakeDelay = 0,
    AutoShakeMethod = "VirtualInput",
    CenterShake = false,

    -- Auto Reel
    AutoReel = false,
    AutoReelDelay = 1,

    -- Auto Legit Reel
    AutoLegitReel = false,

    -- Instant Reel
    InstantReel = false,
    InstantReelDelay = 250,
    PerfectReel = false,

    -- Auto Drop Bobber
    AutoDropBobber = false
}

-- ================= STATE =================
local FishingState = {
    IsCasting = false,
    IsShaking = false,
    IsReeling = false,
    CanCast = true,
    LastCastTime = 0,
    BobberDeployed = false
}

local CurrentTool = nil
local Connections = {}
local ShakeConnections = {}

-- ================= UTILS =================
local Utils = {}

function Utils.GetCurrentTool()
    if LocalPlayer.Character then
        for _, item in pairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("values") then
                return item
            end
        end
    end
    return nil
end

function Utils.ResetTool()
    local tool = Utils.GetCurrentTool()
    if tool then
        tool.Parent = nil
        task.wait(0.1)
        if LocalPlayer.Character then
            tool.Parent = LocalPlayer.Character
        end
    end
    FishingState.BobberDeployed = false
    FishingState.CanCast = true
end

function Utils.HandleShakeButton(Button)
    if not Button or not Button:IsA("ImageButton") then return end

    FishingState.IsShaking = true
    task.wait(Config.AutoShakeDelay)

    if Config.AutoShakeMethod == "ReplicateSignal" and replicatesignal then
        pcall(function()
            replicatesignal(Button.MouseButton1Click)
        end)
    else
        Button.Selectable = true
        GuiService.SelectedObject = Button
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end

    task.wait(0.05)
    if Button and Button.Parent then
        Button:Destroy()
    end

    FishingState.IsShaking = false
end

function Utils.MountShakeUI(ShakeUI)
    local SafeZone = ShakeUI:WaitForChild("safezone", 5)
    if not SafeZone then return end

    if Config.CenterShake then
        local Connect = SafeZone:FindFirstChild("connect")
        if Connect then
            Connect.Enabled = false
        end
        SafeZone.Size = UDim2.fromOffset(0, 0)
        SafeZone.Position = UDim2.fromScale(0.5, 0.5)
        SafeZone.AnchorPoint = Vector2.new(0.5, 0.5)
    end

    if Config.AutoShake then
        local shakeConnection = SafeZone.ChildAdded:Connect(function(Child)
            if Child:IsA("ImageButton") then
                task.spawn(function()
                    Utils.HandleShakeButton(Child)
                end)
            end
        end)
        table.insert(ShakeConnections, shakeConnection)

        for _, child in pairs(SafeZone:GetChildren()) do
            if child:IsA("ImageButton") then
                task.spawn(function()
                    Utils.HandleShakeButton(child)
                end)
            end
        end
    end
end

-- ================= AUTO CAST SYSTEM (STABLE HUMAN-LIKE) =================
local function GetRod()
    if not LocalPlayer.Character then return nil end
    for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("values") then
            return v
        end
    end
    return nil
end

local function CanCast(values)
    if not values then return false end
    if values:FindFirstChild("casted") and values.casted.Value == true then
        return false
    end
    if values:FindFirstChild("bite") and values.bite.Value == true then
        return false
    end
    return true
end

local function HumanClick()
    local vp = Camera.ViewportSize
    local x, y = vp.X / 2, vp.Y / 2

    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(Config.AutoCastHoldTime)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function AutoCastLoop()
    task.spawn(function()
        local lastCast = 0
        
        while true do
            task.wait(0.15)

            if not Config.AutoCast then
                continue
            end

            local rod = GetRod()
            if not rod then
                continue
            end

            local values = rod:FindFirstChild("values")
            if not CanCast(values) then
                continue
            end

            if tick() - lastCast < Config.AutoCastDelay then
                continue
            end

            lastCast = tick()

            pcall(function()
                HumanClick()
            end)
        end
    end)
end

-- ================= OTHER SYSTEMS =================

-- Monitor Reel UI
local function MonitorReelUI()
    local connection
    connection = LocalPlayer.PlayerGui.ChildAdded:Connect(function(Child)
        if Child.Name == "reel" and Child:IsA("ScreenGui") then
            FishingState.IsReeling = true
            FishingState.CanCast = false

            local reelEndConnection
            reelEndConnection = Child.AncestryChanged:Connect(function()
                if not Child:IsDescendantOf(game) then
                    FishingState.IsReeling = false
                    FishingState.BobberDeployed = false
                    task.wait(0.5)
                    FishingState.CanCast = true
                    if reelEndConnection then
                        reelEndConnection:Disconnect()
                    end
                end
            end)
        end
    end)

    table.insert(Connections, connection)
end

-- Auto Shake Loop
local function AutoShakeLoop()
    local connection = LocalPlayer.PlayerGui.ChildAdded:Connect(function(Child)
        if Child.Name == "shakeui" and Child:IsA("ScreenGui") and Config.AutoShake then
            task.spawn(function()
                Utils.MountShakeUI(Child)
            end)
        end
    end)

    table.insert(Connections, connection)
end

-- Auto Drop Bobber
local function AutoDropBobberLoop()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not Config.AutoDropBobber then return end

        pcall(function()
            local tool = Utils.GetCurrentTool()
            if not tool then return end

            local Values = tool:FindFirstChild("values")
            if not Values then return end

            if Values:FindFirstChild("bite") and Values.bite.Value == true then
                local Events = tool:FindFirstChild("events")
                if Events and Events:FindFirstChild("release") then
                    Events.release:FireServer()
                end
            end
        end)
    end)

    table.insert(Connections, connection)
end

-- Instant Reel
local function AutoReelInstantLoop()
    local connection
    local hasReeled = {}

    connection = RunService.Heartbeat:Connect(function()
        if not Config.InstantReel then
            hasReeled = {}
            return
        end

        pcall(function()
            local ReelUI = LocalPlayer.PlayerGui:FindFirstChild("reel")
            if not ReelUI then
                hasReeled = {}
                return
            end

            local reelId = tostring(ReelUI)
            if hasReeled[reelId] then return end
            hasReeled[reelId] = true

            task.spawn(function()
                task.wait(Config.InstantReelDelay / 1000)

                local Events = ReplicatedStorage:FindFirstChild("events")
                if Events and Events:FindFirstChild("reelfinished")
                    and ReelUI:IsDescendantOf(game) then

                    Events.reelfinished:FireServer(100, Config.PerfectReel)
                end
            end)
        end)
    end)

    table.insert(Connections, connection)
end

-- Auto Reel (Snap)
local function AutoReelLoop()
    local connection
    local lastReelUpdate = 0

    connection = RunService.RenderStepped:Connect(function()
        if not Config.AutoReel then return end

        if (tick() - lastReelUpdate) < (Config.AutoReelDelay * 0.1) then
            return
        end

        pcall(function()
            local ReelUI = LocalPlayer.PlayerGui:FindFirstChild("reel")
            if not ReelUI then return end

            local Bar = ReelUI:FindFirstChild("bar")
            if not Bar then return end

            local PlayerBar = Bar:FindFirstChild("playerbar")
            local TargetBar = Bar:FindFirstChild("fish")

            if PlayerBar and TargetBar then
                PlayerBar.Position = TargetBar.Position
                lastReelUpdate = tick()
            end
        end)
    end)

    table.insert(Connections, connection)
end

-- Auto Legit Reel
local function AutoLegitReelLoop()
    local connection
    local activeReelUI = nil
    local reelConnection = nil

    connection = RunService.Heartbeat:Connect(function()
        if not Config.AutoLegitReel then
            if reelConnection then
                reelConnection:Disconnect()
                reelConnection = nil
            end
            activeReelUI = nil
            return
        end

        pcall(function()
            local ReelUI = LocalPlayer.PlayerGui:FindFirstChild("reel")
            if not ReelUI then
                if reelConnection then
                    reelConnection:Disconnect()
                    reelConnection = nil
                end
                activeReelUI = nil
                return
            end

            if activeReelUI ~= ReelUI then
                if reelConnection then
                    reelConnection:Disconnect()
                end

                activeReelUI = ReelUI

                reelConnection = RunService.RenderStepped:Connect(function()
                    if not Config.AutoLegitReel
                        or not ReelUI:IsDescendantOf(game) then

                        if reelConnection then
                            reelConnection:Disconnect()
                            reelConnection = nil
                        end
                        return
                    end

                    local Bar = ReelUI:FindFirstChild("bar")
                    if not Bar then return end

                    local PlayerBar = Bar:FindFirstChild("playerbar")
                    local TargetBar = Bar:FindFirstChild("fish")

                    if PlayerBar and TargetBar then
                        local currentPos = PlayerBar.Position
                        local targetPos = TargetBar.Position

                        local lerped = currentPos:Lerp(targetPos, 0.7)
                        PlayerBar.Position = UDim2.fromScale(
                            math.clamp(lerped.X.Scale, 0.15, 0.85),
                            lerped.Y.Scale
                        )

                        -- mouse movement biar progress ke-detect
                        local diff = targetPos.X.Scale - currentPos.X.Scale
                        if math.abs(diff) > 0.01 then
                            local dir = diff > 0 and 1 or -1
                            local vp = Camera.ViewportSize
                            VirtualInputManager:SendMouseMoveEvent(
                                vp.X / 2 + (dir * 5),
                                vp.Y / 2,
                                game
                            )
                        end
                    end
                end)
            end
        end)
    end)

    table.insert(Connections, connection)
end

-- ================= INIT SYSTEM =================
local function InitializeSystems()
    MonitorReelUI()
    AutoCastLoop()
    AutoShakeLoop()
    AutoDropBobberLoop()
    AutoReelInstantLoop()
    AutoReelLoop()
    AutoLegitReelLoop()
end

-- ================= CLEANUP SHAKE =================
local function CleanupShakeConnections()
    for _, connection in pairs(ShakeConnections) do
        connection:Disconnect()
    end
    ShakeConnections = {}
end

-- ================= LOAD WINDUI =================
local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok and result then
        WindUI = result
    else
        WindUI = loadstring(
            game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua")
        )()
    end
end

-- ================= CREATE WINDOW =================
local Window = WindUI:CreateWindow({
    Title = "Fisch Script | WindUI",
    Author = "by .Birban",
    Folder = "FischScript",
    Icon = "fish",
    IconSize = 44,

    OpenButton = {
        Title = "Yi Da Mu Sake",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,

        Color = ColorSequence.new(
            Color3.fromHex("#3045ff"),
            Color3.fromHex("#6d2fff")
        )
    },
})

-- ================= MAIN TAB =================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "fish",
})

-- ===== AUTO CAST =====
local AutoCastSection = MainTab:Section({ Title = "Auto Cast" })

AutoCastSection:Toggle({
    Title = "Auto Cast",
    Desc = "Automatically cast fishing rod",
    Default = false,
    Callback = function(v)
        Config.AutoCast = v
    end
})

AutoCastSection:Slider({
    Title = "Cast Hold Time (sec)",
    Desc = "How long to hold mouse button (0.1-3 seconds)",
    Step = 0.1,
    Value = { Min = 0.1, Max = 3, Default = 1 },
    Callback = function(v)
        Config.AutoCastHoldTime = v
    end
})

AutoCastSection:Slider({
    Title = "Cast Delay (sec)",
    Desc = "Delay between each cast (1-300 seconds)",
    Step = 1,
    Value = { Min = 1, Max = 300, Default = 3 },
    Callback = function(v)
        Config.AutoCastDelay = v
        local minutes = math.floor(v / 60)
        local seconds = v % 60
        if minutes > 0 then
            print("Auto Cast Delay:", minutes, "min", seconds, "sec")
        else
            print("Auto Cast Delay:", seconds, "sec")
        end
    end
})

-- ===== AUTO SHAKE =====
local ShakeSection = MainTab:Section({ Title = "Auto Shake" })

ShakeSection:Toggle({
    Title = "Auto Shake",
    Default = false,
    Callback = function(v)
        Config.AutoShake = v
        if not v then CleanupShakeConnections() end
    end
})

ShakeSection:Dropdown({
    Title = "Shake Method",
    Values = {"VirtualInput","ReplicateSignal"},
    Value = "VirtualInput",
    Callback = function(v)
        Config.AutoShakeMethod = v
    end
})

ShakeSection:Slider({
    Title = "Shake Delay",
    Step = 0.1,
    Value = { Min = 0, Max = 10, Default = 0 },
    Callback = function(v)
        Config.AutoShakeDelay = v
    end
})

ShakeSection:Toggle({
    Title = "Center Shake UI",
    Default = false,
    Callback = function(v)
        Config.CenterShake = v
    end
})

-- ===== AUTO DROP =====
MainTab:Section({ Title = "Auto Drop Bobber" }):Toggle({
    Title = "Auto Drop Bobber",
    Default = false,
    Callback = function(v)
        Config.AutoDropBobber = v
    end
})

-- ===== AUTO REEL =====
local ReelSection = MainTab:Section({ Title = "Auto Reel" })

ReelSection:Toggle({
    Title = "Auto Reel (Snap)",
    Default = false,
    Callback = function(v)
        Config.AutoReel = v
        if v then
            Config.InstantReel = false
            Config.AutoLegitReel = false
        end
    end
})

ReelSection:Slider({
    Title = "Auto Reel Delay",
    Step = 1,
    Value = { Min = 1, Max = 20, Default = 1 },
    Callback = function(v)
        Config.AutoReelDelay = v
    end
})

-- ===== INSTANT REEL =====
local InstantSection = MainTab:Section({ Title = "Instant Reel" })

InstantSection:Toggle({
    Title = "Instant Reel",
    Default = false,
    Callback = function(v)
        Config.InstantReel = v
        if v then
            Config.AutoReel = false
            Config.AutoLegitReel = false
        end
    end
})

InstantSection:Slider({
    Title = "Instant Reel Delay (ms)",
    Step = 50,
    Value = { Min = 100, Max = 10000, Default = 3000 },
    Callback = function(v)
        Config.InstantReelDelay = v
    end
})

InstantSection:Toggle({
    Title = "Perfect Reel",
    Default = false,
    Callback = function(v)
        Config.PerfectReel = v
    end
})

-- ===== LEGIT REEL =====
MainTab:Section({ Title = "Auto Legit Reel" }):Toggle({
    Title = "Auto Legit Reel",
    Desc = "Smooth human-like reel with lerp",
    Default = false,
    Callback = function(v)
        Config.AutoLegitReel = v
        if v then
            Config.AutoReel = false
            Config.InstantReel = false
        end
    end
})

-- ================= SETTINGS TAB =================
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

SettingsTab:Button({
    Title = "Reload Script",
    Color = Color3.fromHex("#30a0ff"),
    Justify = "Center",
    Icon = "refresh-cw",
    Callback = function()
        for _, c in pairs(Connections) do
            c:Disconnect()
        end
        CleanupShakeConnections()
        Connections = {}
        InitializeSystems()
        WindUI:Notify({
            Title = "Success",
            Content = "Script reloaded successfully!"
        })
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Destroy UI",
    Color = Color3.fromHex("#ff4830"),
    Justify = "Center",
    Icon = "trash",
    Callback = function()
        for _, c in pairs(Connections) do
            c:Disconnect()
        end
        CleanupShakeConnections()
        Window:Destroy()
    end
})

-- ================= START =================
InitializeSystems()

print("MAN ANJENGF")
WindUI:Notify({
    Title = "Loaded",
    Content = "Fisch Script Ready!"
})
