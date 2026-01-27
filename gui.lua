-- ============================================
-- GUI.LUA - PURE GUI ONLY
-- No logic, just visual components
-- ============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GUI = {}
GUI.Config = {}
GUI.SkibidiGui = nil
GUI.MainFrame = nil
GUI.BackgroundImage = nil
GUI.MusicSounds = {}
GUI.CurrentTrack = 1
GUI.LoadingScreen = nil
GUI.Connections = {}
GUI.Tasks = {}
GUI.RunningTweens = {}
GUI.Playlist = {}

-- Ultra-Modern Theme - Cyberpunk Neon
GUI.AccentColor = Color3.fromRGB(0, 255, 255) -- Cyan Neon
GUI.SecondaryColor = Color3.fromRGB(255, 0, 255) -- Magenta Neon
GUI.TertiaryColor = Color3.fromRGB(255, 255, 0) -- Yellow Neon
GUI.BackgroundColor = Color3.fromRGB(8, 8, 15)
GUI.SurfaceColor = Color3.fromRGB(18, 18, 30)
GUI.GlassColor = Color3.fromRGB(25, 25, 45)
GUI.TextPrimary = Color3.fromRGB(255, 255, 255)
GUI.TextSecondary = Color3.fromRGB(180, 180, 220)
GUI.NeonGlow = Color3.fromRGB(0, 255, 255)

-- Configuration
local WORKSPACE_FOLDER = "cuackerdoing"
local MAX_TRACKS = 10
local BG_FILENAME = "backlua.png"
local CHANGE_FILENAME = "change.png"
local MUSIC_TIME_FILENAME = "musictime_%d.txt"
local MUSIC_PATH = WORKSPACE_FOLDER .. "/sound%d.mp3"
local BG_PATH = WORKSPACE_FOLDER .. "/" .. BG_FILENAME
local CHANGE_PATH = WORKSPACE_FOLDER .. "/" .. CHANGE_FILENAME
local ASSETS_REPO = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"

GUI.Config = {
    AutoFarmEnabled = true,
    InstaTeleportEnabled = true,
    AntiRagdollEnabled = true,
    FruitAttackEnabled = true,
    MusicEnabled = true,
    MusicVolume = 0.5
}

-- Helper functions for cleanup
function GUI.AddConnection(connection)
    if connection then
        table.insert(GUI.Connections, connection)
    end
    return connection
end

function GUI.AddTask(taskThread)
    if taskThread then
        table.insert(GUI.Tasks, taskThread)
    end
    return taskThread
end

-- Ultra-smooth animations with bloom effect
local function SmoothTween(object, properties, duration, style, direction)
    if not object or not object.Parent then 
        return nil
    end
    
    local success, tween = pcall(function()
        return TweenService:Create(
            object,
            TweenInfo.new(
                duration or 0.5, 
                style or Enum.EasingStyle.Quint, 
                direction or Enum.EasingDirection.Out
            ),
            properties
        )
    end)
    
    if not success or not tween then
        return nil
    end
    
    table.insert(GUI.RunningTweens, tween)
    
    tween.Completed:Connect(function()
        local index = table.find(GUI.RunningTweens, tween)
        if index then
            table.remove(GUI.RunningTweens, index)
        end
    end)
    
    pcall(function()
        tween:Play()
    end)
    
    return tween
end

-- Neon glow effect
local function CreateNeonGlow(parent, color, intensity)
    if not parent or not parent.Parent then return end
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "NeonGlow"
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0.5, -20, 0.5, -20)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = color or GUI.NeonGlow
    glow.ImageTransparency = 0.5
    glow.ZIndex = 0
    glow.Parent = parent
    
    -- Pulse animation
    GUI.AddTask(task.spawn(function()
        while glow and glow.Parent do
            SmoothTween(glow, {ImageTransparency = 0.3}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
            SmoothTween(glow, {ImageTransparency = 0.7}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
        end
    end))
    
    return glow
end

-- Advanced particle system with trails
local function CreateFloatingParticle(parent, color, speed)
    if not parent or not parent.Parent then return nil end
    
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(2, 8), 0, math.random(2, 8))
    particle.BackgroundColor3 = color or GUI.AccentColor
    particle.BorderSizePixel = 0
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundTransparency = math.random(20, 60) / 100
    particle.Parent = parent
    particle.ZIndex = 5
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    -- Glow effect on particle
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0.5, -5, 0.5, -5)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundColor3 = color or GUI.AccentColor
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.ZIndex = 4
    glow.Parent = particle
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    
    local animTask = task.spawn(function()
        while particle and particle.Parent and parent and parent.Parent do
            local success = pcall(function()
                local randomX = math.random()
                local randomY = math.random()
                local randomDuration = (speed or 60) / 10
                local randomTransparency = math.random(20, 80) / 100
                
                SmoothTween(particle, {
                    Position = UDim2.new(randomX, 0, randomY, 0),
                    BackgroundTransparency = randomTransparency
                }, randomDuration, Enum.EasingStyle.Sine)
            end)
            
            if not success then break end
            task.wait(randomDuration or 6)
        end
        
        if particle and particle.Parent then
            particle:Destroy()
        end
    end)
    
    GUI.AddTask(animTask)
    return particle
end

-- Music playlist management
function GUI.SaveMusicState()
    if not GUI.MusicSounds[GUI.CurrentTrack] then return end
    
    pcall(function()
        local currentSound = GUI.MusicSounds[GUI.CurrentTrack]
        if currentSound and currentSound.IsPlaying and writefile then
            local timePos = currentSound.TimePosition
            if timePos and type(timePos) == "number" and timePos > 0 then
                local timePath = string.format(WORKSPACE_FOLDER .. "/" .. MUSIC_TIME_FILENAME, GUI.CurrentTrack)
                writefile(timePath, tostring(timePos))
                print("[SKIBIDI] Track " .. GUI.CurrentTrack .. " state saved: " .. timePos)
            end
        end
    end)
end

function GUI.PlayNextTrack()
    -- Stop current track
    if GUI.MusicSounds[GUI.CurrentTrack] then
        GUI.MusicSounds[GUI.CurrentTrack]:Stop()
    end
    
    -- Move to next track
    GUI.CurrentTrack = GUI.CurrentTrack + 1
    if GUI.CurrentTrack > #GUI.Playlist then
        GUI.CurrentTrack = 1
    end
    
    -- Play next track
    if GUI.MusicSounds[GUI.CurrentTrack] then
        local sound = GUI.MusicSounds[GUI.CurrentTrack]
        sound:Play()
        print("[SKIBIDI] Now playing track " .. GUI.CurrentTrack)
    end
end

-- Server change fullscreen
function GUI.ShowServerChangeScreen()
    print("[SKIBIDI] Showing server change screen...")
    
    local ChangeScreen = Instance.new("Frame")
    ChangeScreen.Name = "ServerChangeScreen"
    ChangeScreen.Size = UDim2.new(1, 0, 1, 0)
    ChangeScreen.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    ChangeScreen.BorderSizePixel = 0
    ChangeScreen.ZIndex = 10000
    ChangeScreen.BackgroundTransparency = 1
    
    -- Parent to main GUI or create new ScreenGui
    local targetParent = GUI.SkibidiGui
    if not targetParent or not targetParent.Parent then
        targetParent = Instance.new("ScreenGui")
        targetParent.Name = "ServerChangeGui"
        targetParent.ResetOnSpawn = false
        targetParent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function()
            targetParent.Parent = CoreGui
        end)
        if not targetParent.Parent then
            targetParent.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    
    ChangeScreen.Parent = targetParent
    
    -- Fade in background
    SmoothTween(ChangeScreen, {BackgroundTransparency = 0}, 0.5)
    
    -- Background image
    local ChangeImage = Instance.new("ImageLabel")
    ChangeImage.Size = UDim2.new(1, 0, 1, 0)
    ChangeImage.BackgroundTransparency = 1
    ChangeImage.ScaleType = Enum.ScaleType.Crop
    ChangeImage.ImageTransparency = 0.3
    ChangeImage.ZIndex = 10001
    ChangeImage.Parent = ChangeScreen
    
    -- Load change image
    task.spawn(function()
        pcall(function()
            local asset = getcustomasset or getsynasset
            if asset and isfile and isfile(CHANGE_PATH) then
                ChangeImage.Image = asset(CHANGE_PATH)
            end
        end)
    end)
    
    -- Neon particles during change
    for i = 1, 50 do
        CreateFloatingParticle(ChangeScreen, 
            i % 3 == 0 and GUI.AccentColor or (i % 3 == 1 and GUI.SecondaryColor or GUI.TertiaryColor),
            math.random(30, 60)
        )
    end
    
    -- Text container on left side
    local TextContainer = Instance.new("Frame")
    TextContainer.Size = UDim2.new(0, 600, 0, 300)
    TextContainer.Position = UDim2.new(0, 80, 0.5, -150)
    TextContainer.BackgroundTransparency = 1
    TextContainer.ZIndex = 10002
    TextContainer.Parent = ChangeScreen
    
    -- Main text
    local MainText = Instance.new("TextLabel")
    MainText.Text = "CHANGING SERVERS"
    MainText.Size = UDim2.new(1, 0, 0, 100)
    MainText.BackgroundTransparency = 1
    MainText.Font = Enum.Font.GothamBlack
    MainText.TextColor3 = GUI.TextPrimary
    MainText.TextSize = 64
    MainText.TextXAlignment = Enum.TextXAlignment.Left
    MainText.TextTransparency = 1
    MainText.ZIndex = 10003
    MainText.Parent = TextContainer
    
    -- Neon gradient on text
    local TextGradient = Instance.new("UIGradient")
    TextGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.TertiaryColor)
    }
    TextGradient.Rotation = 45
    TextGradient.Parent = MainText
    
    -- Subtitle
    local SubText = Instance.new("TextLabel")
    SubText.Text = "Please wait..."
    SubText.Size = UDim2.new(1, 0, 0, 40)
    SubText.Position = UDim2.new(0, 0, 0, 110)
    SubText.BackgroundTransparency = 1
    SubText.Font = Enum.Font.GothamMedium
    SubText.TextColor3 = GUI.TextSecondary
    SubText.TextSize = 28
    SubText.TextXAlignment = Enum.TextXAlignment.Left
    SubText.TextTransparency = 1
    SubText.ZIndex = 10003
    SubText.Parent = TextContainer
    
    -- Loading bar
    local BarContainer = Instance.new("Frame")
    BarContainer.Size = UDim2.new(1, 0, 0, 6)
    BarContainer.Position = UDim2.new(0, 0, 0, 180)
    BarContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    BarContainer.BorderSizePixel = 0
    BarContainer.BackgroundTransparency = 1
    BarContainer.ZIndex = 10003
    BarContainer.Parent = TextContainer
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarContainer
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = GUI.AccentColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.ZIndex = 10004
    ProgressBar.Parent = BarContainer
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar
    
    -- Neon glow on bar
    CreateNeonGlow(ProgressBar, GUI.AccentColor)
    
    -- Animate in
    task.wait(0.3)
    SmoothTween(MainText, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    SmoothTween(SubText, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    SmoothTween(BarContainer, {BackgroundTransparency = 0.5}, 0.8)
    
    -- Animate progress bar
    SmoothTween(ProgressBar, {Size = UDim2.new(1, 0, 1, 0)}, 3, Enum.EasingStyle.Linear)
    
    -- Rotate text gradient
    GUI.AddTask(task.spawn(function()
        while TextGradient and TextGradient.Parent do
            SmoothTween(TextGradient, {Rotation = TextGradient.Rotation + 360}, 3, Enum.EasingStyle.Linear)
            task.wait(3)
        end
    end))
    
    return ChangeScreen
end

-- KEY SYSTEM GUI (CALLED FROM FUNC.LUA)
function GUI.CreateKeySystemGUI(onSubmitCallback)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.BackgroundColor3 = GUI.BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = MainFrame
    
    -- Triple neon border
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 3
    Stroke.Transparency = 0
    Stroke.Parent = MainFrame
    
    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.33, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(0.66, GUI.TertiaryColor),
        ColorSequenceKeypoint.new(1, GUI.AccentColor)
    }
    StrokeGradient.Rotation = 0
    StrokeGradient.Parent = Stroke
    
    -- Rotate border gradient
    GUI.AddTask(task.spawn(function()
        while Stroke and Stroke.Parent and StrokeGradient and StrokeGradient.Parent do
            SmoothTween(StrokeGradient, {Rotation = StrokeGradient.Rotation + 360}, 4, Enum.EasingStyle.Linear)
            task.wait(4)
        end
    end))
    
    -- Neon glow
    CreateNeonGlow(MainFrame, GUI.NeonGlow)
    
    -- Particles
    for i = 1, 15 do
        local color = i % 3 == 0 and GUI.AccentColor or (i % 3 == 1 and GUI.SecondaryColor or GUI.TertiaryColor)
        CreateFloatingParticle(MainFrame, color, math.random(50, 90))
    end
    
    -- Header
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "🔐 SKIBIDI FARM"
    HeaderTitle.Size = UDim2.new(1, -60, 0, 60)
    HeaderTitle.Position = UDim2.new(0, 30, 0, 20)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextColor3 = GUI.TextPrimary
    HeaderTitle.TextSize = 32
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 2
    HeaderTitle.Parent = MainFrame
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.TertiaryColor)
    }
    HeaderGradient.Rotation = 0
    HeaderGradient.Parent = HeaderTitle
    
    -- Rotate header gradient
    GUI.AddTask(task.spawn(function()
        while HeaderGradient and HeaderGradient.Parent do
            SmoothTween(HeaderGradient, {Rotation = HeaderGradient.Rotation + 360}, 5, Enum.EasingStyle.Linear)
            task.wait(5)
        end
    end))
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Enter Key to Continue"
    Subtitle.Size = UDim2.new(1, -60, 0, 20)
    Subtitle.Position = UDim2.new(0, 30, 0, 75)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextColor3 = GUI.TextSecondary
    Subtitle.TextSize = 14
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 2
    Subtitle.Parent = MainFrame
    
    -- Key Input
    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(1, -60, 0, 50)
    KeyBox.Position = UDim2.new(0, 30, 0, 115)
    KeyBox.BackgroundColor3 = GUI.SurfaceColor
    KeyBox.BorderSizePixel = 0
    KeyBox.Text = ""
    KeyBox.PlaceholderText = "Enter your key here..."
    KeyBox.TextColor3 = GUI.TextPrimary
    KeyBox.PlaceholderColor3 = GUI.TextSecondary
    KeyBox.TextSize = 16
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.ClearTextOnFocus = false
    KeyBox.ZIndex = 2
    KeyBox.Parent = MainFrame
    
    local KeyBoxCorner = Instance.new("UICorner")
    KeyBoxCorner.CornerRadius = UDim.new(0, 12)
    KeyBoxCorner.Parent = KeyBox
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(1, -60, 0, 45)
    SubmitButton.Position = UDim2.new(0, 30, 0, 180)
    SubmitButton.BackgroundColor3 = GUI.AccentColor
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "SUBMIT KEY"
    SubmitButton.TextColor3 = GUI.TextPrimary
    SubmitButton.TextSize = 18
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.ZIndex = 2
    SubmitButton.Parent = MainFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 12)
    SubmitCorner.Parent = SubmitButton
    
    CreateNeonGlow(SubmitButton, GUI.AccentColor)
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -60, 0, 25)
    StatusLabel.Position = UDim2.new(0, 30, 0, 240)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.ZIndex = 2
    StatusLabel.Parent = MainFrame
    
    -- Get Key Button
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Size = UDim2.new(1, -60, 0, 25)
    GetKeyButton.Position = UDim2.new(0, 30, 1, -35)
    GetKeyButton.BackgroundTransparency = 1
    GetKeyButton.Text = "🔗 Get Key"
    GetKeyButton.TextColor3 = GUI.SecondaryColor
    GetKeyButton.TextSize = 14
    GetKeyButton.Font = Enum.Font.Gotham
    GetKeyButton.ZIndex = 2
    GetKeyButton.Parent = MainFrame
    
    GetKeyButton.MouseButton1Click:Connect(function()
        setclipboard("https://key.raservices.shop")
        StatusLabel.Text = "✅ Link copied to clipboard!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(3)
        StatusLabel.Text = ""
    end)
    
    -- Submit logic
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        StatusLabel.Text = "⏳ Validating..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        SubmitButton.Text = "PLEASE WAIT..."
        
        -- Call the validation callback from func.lua
        if onSubmitCallback then
            onSubmitCallback(key, StatusLabel, SubmitButton, ScreenGui)
        end
    end)
    
    -- Animate entrance
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    SmoothTween(MainFrame, {Size = UDim2.new(0, 450, 0, 300)}, 0.8, Enum.EasingStyle.Back)
    
    return ScreenGui
end

-- Ultra-modern loading screen
function GUI.CreateFullScreenLoader()
    local LoaderScreen = Instance.new("Frame")
    LoaderScreen.Name = "FullScreenLoader"
    LoaderScreen.Size = UDim2.new(1, 0, 1, 0)
    LoaderScreen.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    LoaderScreen.BorderSizePixel = 0
    LoaderScreen.ZIndex = 9000
    LoaderScreen.Parent = GUI.SkibidiGui
    
    -- Animated gradient background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 20)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(15, 0, 30)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 15, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    }
    Gradient.Rotation = 0
    Gradient.Parent = LoaderScreen
    
    -- Rotate gradient
    GUI.AddTask(task.spawn(function()
        while LoaderScreen and LoaderScreen.Parent and Gradient and Gradient.Parent do
            SmoothTween(Gradient, {Rotation = Gradient.Rotation + 360}, 8, Enum.EasingStyle.Linear)
            task.wait(8)
        end
    end))
    
    -- Neon particles
    for i = 1, 60 do
        local color = i % 3 == 0 and GUI.AccentColor or (i % 3 == 1 and GUI.SecondaryColor or GUI.TertiaryColor)
        CreateFloatingParticle(LoaderScreen, color, math.random(40, 80))
    end
    
    -- Center container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 700, 0, 400)
    Container.Position = UDim2.new(0.5, -350, 0.5, -200)
    Container.BackgroundTransparency = 1
    Container.Parent = LoaderScreen
    
    -- Neon logo
    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "◢ SKIBIDI ◣"
    LogoText.Size = UDim2.new(1, 0, 0, 120)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.TextColor3 = GUI.TextPrimary
    LogoText.TextSize = 82
    LogoText.TextTransparency = 1
    LogoText.Parent = Container
    
    -- Triple gradient on logo
    local LogoGradient = Instance.new("UIGradient")
    LogoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.33, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(0.66, GUI.TertiaryColor),
        ColorSequenceKeypoint.new(1, GUI.AccentColor)
    }
    LogoGradient.Rotation = 0
    LogoGradient.Parent = LogoText
    
    -- Rotate logo gradient
    GUI.AddTask(task.spawn(function()
        while LogoGradient and LogoGradient.Parent do
            SmoothTween(LogoGradient, {Rotation = LogoGradient.Rotation + 360}, 4, Enum.EasingStyle.Linear)
            task.wait(4)
        end
    end))
    
    -- Glow effect on logo
    CreateNeonGlow(LogoText, GUI.AccentColor)
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "◆ ULTRA AUTO FARM SYSTEM ◆"
    Subtitle.Size = UDim2.new(1, 0, 0, 40)
    Subtitle.Position = UDim2.new(0, 0, 0, 125)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamBold
    Subtitle.TextColor3 = GUI.TextSecondary
    Subtitle.TextSize = 22
    Subtitle.TextTransparency = 1
    Subtitle.Parent = Container
    
    -- Loading bar container with glassmorphism
    local BarContainer = Instance.new("Frame")
    BarContainer.Size = UDim2.new(0.9, 0, 0, 10)
    BarContainer.Position = UDim2.new(0.05, 0, 0, 210)
    BarContainer.BackgroundColor3 = GUI.GlassColor
    BarContainer.BackgroundTransparency = 0.3
    BarContainer.BorderSizePixel = 0
    BarContainer.Parent = Container
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarContainer
    
    local BarStroke = Instance.new("UIStroke")
    BarStroke.Color = GUI.AccentColor
    BarStroke.Thickness = 2
    BarStroke.Transparency = 0.5
    BarStroke.Parent = BarContainer
    
    -- Progress bar with neon effect
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = GUI.AccentColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = BarContainer
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar
    
    -- Gradient on progress bar
    local BarGradient = Instance.new("UIGradient")
    BarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.TertiaryColor)
    }
    BarGradient.Rotation = 0
    BarGradient.Parent = ProgressBar
    
    -- Animate bar gradient
    GUI.AddTask(task.spawn(function()
        while BarGradient and BarGradient.Parent do
            SmoothTween(BarGradient, {Rotation = BarGradient.Rotation + 360}, 3, Enum.EasingStyle.Linear)
            task.wait(3)
        end
    end))
    
    -- Neon glow
    CreateNeonGlow(ProgressBar, GUI.NeonGlow)
    
    -- Status text
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "◈ Initializing systems..."
    StatusText.Size = UDim2.new(1, 0, 0, 30)
    StatusText.Position = UDim2.new(0, 0, 0, 245)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextColor3 = GUI.TextSecondary
    StatusText.TextSize = 18
    StatusText.TextTransparency = 1
    StatusText.Parent = Container
    
    -- Percentage
    local PercentText = Instance.new("TextLabel")
    PercentText.Text = "0%"
    PercentText.Size = UDim2.new(1, 0, 0, 50)
    PercentText.Position = UDim2.new(0, 0, 0, 290)
    PercentText.BackgroundTransparency = 1
    PercentText.Font = Enum.Font.GothamBlack
    PercentText.TextColor3 = GUI.AccentColor
    PercentText.TextSize = 42
    PercentText.TextTransparency = 1
    PercentText.Parent = Container
    
    -- Fade in
    SmoothTween(LogoText, {TextTransparency = 0}, 1)
    task.wait(0.3)
    SmoothTween(Subtitle, {TextTransparency = 0}, 1)
    task.wait(0.3)
    SmoothTween(StatusText, {TextTransparency = 0}, 1)
    SmoothTween(PercentText, {TextTransparency = 0}, 1)
    
    GUI.LoadingScreen = LoaderScreen
    
    return {
        Screen = LoaderScreen,
        Bar = ProgressBar,
        Status = StatusText,
        Percent = PercentText,
        Update = function(progress, statusText)
            if StatusText and StatusText.Parent then
                StatusText.Text = "◈ " .. (statusText or "Loading...")
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = math.floor(progress * 100) .. "%"
            end
            if ProgressBar and ProgressBar.Parent then
                SmoothTween(ProgressBar, {
                    Size = UDim2.new(progress, 0, 1, 0)
                }, 0.4, Enum.EasingStyle.Quad)
            end
        end,
        Complete = function()
            if not LoaderScreen or not LoaderScreen.Parent then return end
            
            if StatusText and StatusText.Parent then
                StatusText.Text = "◈ Launch complete!"
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = "100%"
            end
            
            task.wait(0.8)
            
            SmoothTween(LoaderScreen, {BackgroundTransparency = 1}, 0.6)
            
            for _, child in pairs(LoaderScreen:GetDescendants()) do
                pcall(function()
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        SmoothTween(child, {TextTransparency = 1, BackgroundTransparency = 1}, 0.6)
                    elseif child:IsA("Frame") then
                        SmoothTween(child, {BackgroundTransparency = 1}, 0.6)
                    end
                end)
            end
            
            task.wait(0.7)
            
            if LoaderScreen and LoaderScreen.Parent then
                LoaderScreen:Destroy()
            end
            
            GUI.LoadingScreen = nil
        end
    }
end

function GUI.InitAssets(progressCallback)
    print("[SKIBIDI] Initializing ultra assets...")
    
    local loader = GUI.CreateFullScreenLoader()
    if not loader then
        warn("[SKIBIDI] Failed to create loader")
        return
    end
    
    loader.Update(0.05, "Creating workspace directory...")
    
    pcall(function()
        if makefolder and not isfolder(WORKSPACE_FOLDER) then 
            makefolder(WORKSPACE_FOLDER)
            print("[SKIBIDI] Workspace created")
        end
    end)
    
    task.wait(0.3)
    loader.Update(0.1, "Downloading music...")
    
    -- Initialize playlist
    GUI.Playlist = {}
    
    -- Download and load ONE random sound.mp3
    GUI.AddTask(task.spawn(function()
        local success = pcall(function()
            local musicPath = WORKSPACE_FOLDER .. "/sound.mp3"
            
            -- Download if needed
            if isfile and not isfile(musicPath) then
                if writefile then
                    local httpSuccess, musicData = pcall(function()
                        return game:HttpGet(ASSETS_REPO .. "sound.mp3", true)
                    end)
                    
                    if httpSuccess and musicData and #musicData > 1000 then
                        writefile(musicPath, musicData)
                        print("[SKIBIDI] Music downloaded")
                    end
                end
            end
            
            -- Create sound instance
            if isfile and isfile(musicPath) then
                local asset = getcustomasset or getsynasset
                if asset then
                    local sound = Instance.new("Sound")
                    sound.Name = "SkibidiMusic"
                    sound.Looped = true
                    sound.Volume = GUI.Config.MusicVolume
                    sound.SoundId = asset(musicPath)
                    sound.Parent = SoundService
                    
                    table.insert(GUI.Playlist, 1)
                    GUI.MusicSounds[1] = sound
                    GUI.CurrentTrack = 1
                    sound:Play()
                    print("[SKIBIDI] Music loaded and playing")
                end
            end
        end)
        
        if not success then
            print("[SKIBIDI] Music failed to load")
        end
    end))
    
    task.wait(0.5)
    loader.Update(0.55, "Loading background image...")
    
    -- Wait for BackgroundImage
    local maxWait = 100
    local waited = 0
    while not GUI.BackgroundImage and waited < maxWait do
        task.wait(0.1)
        waited = waited + 1
    end
    
    if GUI.BackgroundImage then
        GUI.AddTask(task.spawn(function()
            pcall(function()
                local asset = getcustomasset or getsynasset
                if not asset then return end
                
                -- Download background
                if isfile and not isfile(BG_PATH) then
                    if writefile then
                        loader.Update(0.7, "Downloading background...")
                        local bgData = game:HttpGet(ASSETS_REPO .. BG_FILENAME, true)
                        if bgData then
                            writefile(BG_PATH, bgData)
                            print("[SKIBIDI] Background downloaded")
                        end
                    end
                end
                
                -- Load background
                if isfile and isfile(BG_PATH) and GUI.BackgroundImage.Parent then
                    GUI.BackgroundImage.Image = asset(BG_PATH)
                    print("[SKIBIDI] Background loaded")
                end
                
                loader.Update(0.75, "Background ready")
            end)
        end))
    end
    
    loader.Update(0.8, "Loading server change image...")
    
    -- Download change.png
    GUI.AddTask(task.spawn(function()
        pcall(function()
            if isfile and not isfile(CHANGE_PATH) then
                if writefile then
                    local changeData = game:HttpGet(ASSETS_REPO .. CHANGE_FILENAME, true)
                    if changeData then
                        writefile(CHANGE_PATH, changeData)
                        print("[SKIBIDI] Change image downloaded")
                    end
                end
            end
        end)
    end))
    
    task.wait(0.5)
    loader.Update(0.9, "Finalizing systems...")
    task.wait(0.4)
    loader.Update(1, "All systems operational")
    task.wait(0.6)
    loader.Complete()
    
    -- Save music on teleport
    GUI.AddConnection(Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end))
    
    print("[SKIBIDI] Ultra assets initialized")
end

function GUI.Init(vars)
    -- Cleanup existing
    if GUI.SkibidiGui then 
        GUI.Cleanup()
    end
    
    if not vars or type(vars) ~= "table" then
        vars = {}
    end
    
    local lp = Players.LocalPlayer
    if not lp then return nil end
    
    -- Create ScreenGui
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "SkibidiGui"
    GUI.SkibidiGui.ResetOnSpawn = false
    GUI.SkibidiGui.IgnoreGuiInset = true
    GUI.SkibidiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() 
        GUI.SkibidiGui.Parent = CoreGui 
    end)
    
    if not GUI.SkibidiGui.Parent then 
        GUI.SkibidiGui.Parent = lp:WaitForChild("PlayerGui", 5)
    end

    -- Main Frame with glassmorphism
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.BackgroundColor
    GUI.MainFrame.BackgroundTransparency = 0.02
    GUI.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -350)
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = GUI.MainFrame
    
    -- Triple neon border
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 3
    Stroke.Transparency = 0
    Stroke.Parent = GUI.MainFrame
    
    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.33, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(0.66, GUI.TertiaryColor),
        ColorSequenceKeypoint.new(1, GUI.AccentColor)
    }
    StrokeGradient.Rotation = 0
    StrokeGradient.Parent = Stroke
    
    -- Rotate border gradient
    GUI.AddTask(task.spawn(function()
        while Stroke and Stroke.Parent and StrokeGradient and StrokeGradient.Parent do
            SmoothTween(StrokeGradient, {Rotation = StrokeGradient.Rotation + 360}, 4, Enum.EasingStyle.Linear)
            task.wait(4)
        end
    end))
    
    -- Outer glow
    CreateNeonGlow(GUI.MainFrame, GUI.NeonGlow)
    
    -- Glass overlay
    local GlassOverlay = Instance.new("Frame")
    GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
    GlassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassOverlay.BackgroundTransparency = 0.95
    GlassOverlay.BorderSizePixel = 0
    GlassOverlay.Parent = GUI.MainFrame
    
    local GlassCorner = Instance.new("UICorner")
    GlassCorner.CornerRadius = UDim.new(0, 20)
    GlassCorner.Parent = GlassOverlay

    -- Background Image
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.4
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = GUI.MainFrame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 20)
    BgCorner.Parent = GUI.BackgroundImage
    
    -- Dark overlay
    local DarkOverlay = Instance.new("Frame")
    DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
    DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DarkOverlay.BackgroundTransparency = 0.3
    DarkOverlay.BorderSizePixel = 0
    DarkOverlay.ZIndex = 1
    DarkOverlay.Parent = GUI.MainFrame
    
    local DarkCorner = Instance.new("UICorner")
    DarkCorner.CornerRadius = UDim.new(0, 20)
    DarkCorner.Parent = DarkOverlay
    
    -- More neon particles
    for i = 1, 25 do
        local color = i % 3 == 0 and GUI.AccentColor or (i % 3 == 1 and GUI.SecondaryColor or GUI.TertiaryColor)
        CreateFloatingParticle(GUI.MainFrame, color, math.random(50, 90))
    end
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    GUI.AddConnection(GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            SmoothTween(GUI.MainFrame, {
                Size = GUI.MainFrame.Size - UDim2.new(0, 10, 0, 10)
            }, 0.1)
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false
                    SmoothTween(GUI.MainFrame, {
                        Size = UDim2.new(0, 500, 0, 700)
                    }, 0.1)
                    if endConnection then
                        endConnection:Disconnect()
                    end
                end
            end)
        end
    end))
    
    GUI.AddConnection(GUI.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input 
        end
    end))
    
    GUI.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and GUI.MainFrame and GUI.MainFrame.Parent then
            local delta = input.Position - dragStart
            GUI.MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end))

    -- Ultra Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 90)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 2
    Header.Parent = GUI.MainFrame
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "◢ SKIBIDI FARM ◣"
    HeaderTitle.Size = UDim2.new(1, -70, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 35, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextColor3 = GUI.TextPrimary
    HeaderTitle.TextSize = 38
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 3
    HeaderTitle.Parent = Header
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.TertiaryColor)
    }
    HeaderGradient.Rotation = 0
    HeaderGradient.Parent = HeaderTitle
    
    -- Rotate header gradient
    GUI.AddTask(task.spawn(function()
        while HeaderGradient and HeaderGradient.Parent do
            SmoothTween(HeaderGradient, {Rotation = HeaderGradient.Rotation + 360}, 5, Enum.EasingStyle.Linear)
            task.wait(5)
        end
    end))
    
    -- Neon glow on header
    CreateNeonGlow(HeaderTitle, GUI.AccentColor)
    
    -- Version badge
    local VersionBadge = Instance.new("TextLabel")
    VersionBadge.Text = "◆ v5.0"
    VersionBadge.Size = UDim2.new(0, 75, 0, 35)
    VersionBadge.Position = UDim2.new(1, -95, 0.5, -17)
    VersionBadge.BackgroundColor3 = GUI.SurfaceColor
    VersionBadge.BackgroundTransparency = 0.3
    VersionBadge.Font = Enum.Font.GothamBlack
    VersionBadge.TextColor3 = GUI.AccentColor
    VersionBadge.TextSize = 16
    VersionBadge.ZIndex = 3
    VersionBadge.Parent = Header
    
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 17)
    BadgeCorner.Parent = VersionBadge
    
    local BadgeStroke = Instance.new("UIStroke")
    BadgeStroke.Color = GUI.AccentColor
    BadgeStroke.Thickness = 2
    BadgeStroke.Transparency = 0.3
    BadgeStroke.Parent = VersionBadge
    
    CreateNeonGlow(VersionBadge, GUI.AccentColor)

    -- Stats Container
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Position = UDim2.new(0, 25, 0, 110)
    StatsContainer.Size = UDim2.new(1, -50, 0, 560)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.ZIndex = 2
    StatsContainer.Parent = GUI.MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 16)
    Layout.Parent = StatsContainer

    -- Modern icon with glow
    local function CreateIconFrame(iconText, color)
        iconText = tostring(iconText or "◆")
        color = color or GUI.AccentColor
        
        local IconFrame = Instance.new("Frame")
        IconFrame.Size = UDim2.new(0, 58, 0, 58)
        IconFrame.BackgroundColor3 = color
        IconFrame.BackgroundTransparency = 0.75
        IconFrame.BorderSizePixel = 0
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 15)
        IconCorner.Parent = IconFrame
        
        local IconStroke = Instance.new("UIStroke")
        IconStroke.Color = color
        IconStroke.Thickness = 2
        IconStroke.Transparency = 0.4
        IconStroke.Parent = IconFrame
        
        CreateNeonGlow(IconFrame, color)
        
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundTransparency = 1
        Icon.Font = Enum.Font.GothamBlack
        Icon.Text = iconText
        Icon.TextColor3 = color
        Icon.TextSize = 28
        Icon.Parent = IconFrame
        
        return IconFrame
    end
    
    local function CreateStatCard(label, value, iconText, iconColor, order)
        label = tostring(label or "LABEL")
        value = tostring(value or "0")
        iconText = tostring(iconText or "◆")
        iconColor = iconColor or GUI.AccentColor
        order = order or 1
        
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 95)
        Card.BackgroundColor3 = GUI.SurfaceColor
        Card.BackgroundTransparency = 0.15
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.ZIndex = 2
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 18)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = iconColor
        CardStroke.Thickness = 1.5
        CardStroke.Transparency = 0.6
        CardStroke.Parent = Card
        
        CreateNeonGlow(Card, iconColor)
        
        -- Hover effects
        GUI.AddConnection(Card.MouseEnter:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.05}, 0.3)
            SmoothTween(CardStroke, {Transparency = 0.2, Thickness = 2.5}, 0.3)
        end))
        
        GUI.AddConnection(Card.MouseLeave:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.15}, 0.3)
            SmoothTween(CardStroke, {Transparency = 0.6, Thickness = 1.5}, 0.3)
        end))
        
        -- Icon
        local Icon = CreateIconFrame(iconText, iconColor)
        Icon.Position = UDim2.new(0, 18, 0.5, -29)
        Icon.Parent = Card
        
        -- Label
        local Label = Instance.new("TextLabel")
        Label.Text = label
        Label.Size = UDim2.new(1, -100, 0, 24)
        Label.Position = UDim2.new(0, 88, 0, 16)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 15
        Label.TextColor3 = GUI.TextSecondary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 3
        Label.Parent = Card
        
        -- Value
        local Value = Instance.new("TextLabel")
        Value.Text = value
        Value.Size = UDim2.new(1, -100, 0, 38)
        Value.Position = UDim2.new(0, 88, 0, 43)
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBlack
        Value.TextSize = 26
        Value.TextColor3 = GUI.TextPrimary
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.ZIndex = 3
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.Parent = Card
        
        return Value
    end

    -- Create ultra stat cards
    vars.TargetLabel = CreateStatCard("◉ CURRENT TARGET", "Searching...", "◉", GUI.AccentColor, 1)
    vars.StateLabel = CreateStatCard("◆ STATUS", "Initializing", "◆", GUI.SecondaryColor, 2)
    vars.BountyLabel = CreateStatCard("◈ BOUNTY GAINED", "+0", "◈", Color3.fromRGB(255, 215, 0), 3)
    vars.TimeLabel = CreateStatCard("◷ SESSION TIME", "00:00:00", "◷", Color3.fromRGB(100, 200, 255), 4)
    vars.KillsLabel = CreateStatCard("✦ TOTAL KILLS", "0", "✦", Color3.fromRGB(255, 100, 100), 5)

    -- Session time updater
    local sessionStartTime = tick()
    GUI.AddTask(task.spawn(function()
        while vars.TimeLabel and vars.TimeLabel.Parent do
            task.wait(1)
            
            local elapsed = tick() - sessionStartTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = math.floor(elapsed % 60)
            
            vars.TimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
    end))

    -- Dramatic entrance
    SmoothTween(GUI.MainFrame, {
        Size = UDim2.new(0, 500, 0, 700)
    }, 0.8, Enum.EasingStyle.Back)

    -- Stagger card animations
    GUI.AddTask(task.spawn(function()
        for i, card in ipairs(StatsContainer:GetChildren()) do
            if card:IsA("Frame") and card ~= Layout then
                card.BackgroundTransparency = 1
                task.wait(0.08)
                SmoothTween(card, {BackgroundTransparency = 0.15}, 0.6)
            end
        end
    end))

    print("[SKIBIDI] Ultra GUI initialized")
    
    -- Auto-load assets
    task.spawn(function()
        GUI.InitAssets()
    end)

    -- Logger
    local Logger = {}
    
    function Logger:Log(m) 
        if vars.StateLabel and vars.StateLabel.Parent then
            vars.StateLabel.Text = tostring(m)
        end
    end
    
    function Logger:Info(m) self:Log(m) end
    function Logger:Success(m) self:Log(m) end
    function Logger:Warning(m) self:Log(m) end
    function Logger:Error(m) self:Log(m) end
    
    function Logger:Target(m) 
        if vars.TargetLabel and vars.TargetLabel.Parent then
            vars.TargetLabel.Text = tostring(m)
        end
    end
    
    return Logger
end

-- Enhanced cleanup
function GUI.Cleanup()
    print("[SKIBIDI] Ultra cleanup...")
    
    GUI.SaveMusicState()
    
    -- Stop all music
    for _, sound in pairs(GUI.MusicSounds) do
        pcall(function()
            if sound then
                sound:Stop()
                sound:Destroy()
            end
        end)
    end
    GUI.MusicSounds = {}
    GUI.Playlist = {}
    
    -- Cancel tweens
    for _, tween in ipairs(GUI.RunningTweens) do
        pcall(function()
            if tween then tween:Cancel() end
        end)
    end
    GUI.RunningTweens = {}
    
    -- Cancel tasks
    for _, taskThread in ipairs(GUI.Tasks) do
        pcall(function()
            if taskThread then task.cancel(taskThread) end
        end)
    end
    GUI.Tasks = {}
    
    -- Disconnect
    for _, connection in ipairs(GUI.Connections) do
        pcall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
    end
    GUI.Connections = {}
    
    -- Destroy GUI
    if GUI.SkibidiGui then
        pcall(function()
            GUI.SkibidiGui:Destroy()
        end)
    end
    
    GUI.SkibidiGui = nil
    GUI.MainFrame = nil
    GUI.BackgroundImage = nil
    GUI.LoadingScreen = nil
    
    print("[SKIBIDI] Ultra cleanup complete")
end

return GUI
