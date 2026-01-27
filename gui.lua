-- ============================================
-- GUI.LUA - MINIMAL MACOS STYLE
-- Clean, modern, no excessive colors
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

-- Minimal macOS Theme - Clean and Professional
GUI.AccentColor = Color3.fromRGB(0, 122, 255) -- iOS Blue
GUI.BackgroundColor = Color3.fromRGB(28, 28, 30) -- Dark Background
GUI.SurfaceColor = Color3.fromRGB(44, 44, 46) -- Card Background
GUI.TextPrimary = Color3.fromRGB(255, 255, 255)
GUI.TextSecondary = Color3.fromRGB(152, 152, 157)
GUI.BorderColor = Color3.fromRGB(58, 58, 60)
GUI.SuccessColor = Color3.fromRGB(52, 199, 89)
GUI.WarningColor = Color3.fromRGB(255, 204, 0)
GUI.ErrorColor = Color3.fromRGB(255, 59, 48)

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

-- Smooth macOS-style animations
local function SmoothTween(object, properties, duration, style, direction)
    if not object or not object.Parent then 
        return nil
    end
    
    local success, tween = pcall(function()
        return TweenService:Create(
            object,
            TweenInfo.new(
                duration or 0.3, 
                style or Enum.EasingStyle.Quart, 
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
            end
        end
    end)
end

function GUI.PlayNextTrack()
    if GUI.MusicSounds[GUI.CurrentTrack] then
        GUI.MusicSounds[GUI.CurrentTrack]:Stop()
    end
    
    GUI.CurrentTrack = GUI.CurrentTrack + 1
    if GUI.CurrentTrack > #GUI.Playlist then
        GUI.CurrentTrack = 1
    end
    
    if GUI.MusicSounds[GUI.CurrentTrack] then
        local sound = GUI.MusicSounds[GUI.CurrentTrack]
        sound:Play()
    end
end

-- Minimal server change screen with gradient text
function GUI.ShowServerChangeScreen()
    local ChangeScreen = Instance.new("Frame")
    ChangeScreen.Name = "ServerChangeScreen"
    ChangeScreen.Size = UDim2.new(1, 0, 1, 0)
    ChangeScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ChangeScreen.BorderSizePixel = 0
    ChangeScreen.ZIndex = 10000
    ChangeScreen.BackgroundTransparency = 1
    
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
    
    -- Background image (subtle)
    local ChangeImage = Instance.new("ImageLabel")
    ChangeImage.Size = UDim2.new(1, 0, 1, 0)
    ChangeImage.BackgroundTransparency = 1
    ChangeImage.ScaleType = Enum.ScaleType.Crop
    ChangeImage.ImageTransparency = 0.7
    ChangeImage.ZIndex = 10001
    ChangeImage.Parent = ChangeScreen
    
    task.spawn(function()
        pcall(function()
            local asset = getcustomasset or getsynasset
            if asset and isfile and isfile(CHANGE_PATH) then
                ChangeImage.Image = asset(CHANGE_PATH)
            end
        end)
    end)
    
    -- Center container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 500, 0, 200)
    Container.Position = UDim2.new(0.5, -250, 0.5, -100)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 10002
    Container.Parent = ChangeScreen
    
    -- Main text with gradient
    local MainText = Instance.new("TextLabel")
    MainText.Text = "Changing Servers"
    MainText.Size = UDim2.new(1, 0, 0, 60)
    MainText.BackgroundTransparency = 1
    MainText.Font = Enum.Font.GothamBold
    MainText.TextColor3 = GUI.TextPrimary
    MainText.TextSize = 48
    MainText.TextTransparency = 1
    MainText.ZIndex = 10003
    MainText.Parent = Container
    
    -- Gradient on text
    local TextGradient = Instance.new("UIGradient")
    TextGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
    }
    TextGradient.Rotation = 45
    TextGradient.Parent = MainText
    
    -- Animate gradient rotation
    GUI.AddTask(task.spawn(function()
        while TextGradient and TextGradient.Parent do
            SmoothTween(TextGradient, {Rotation = TextGradient.Rotation + 360}, 3, Enum.EasingStyle.Linear)
            task.wait(3)
        end
    end))
    
    -- Subtitle
    local SubText = Instance.new("TextLabel")
    SubText.Text = "Please wait..."
    SubText.Size = UDim2.new(1, 0, 0, 30)
    SubText.Position = UDim2.new(0, 0, 0, 70)
    SubText.BackgroundTransparency = 1
    SubText.Font = Enum.Font.Gotham
    SubText.TextColor3 = GUI.TextSecondary
    SubText.TextSize = 18
    SubText.TextTransparency = 1
    SubText.ZIndex = 10003
    SubText.Parent = Container
    
    -- Minimal loading bar
    local BarContainer = Instance.new("Frame")
    BarContainer.Size = UDim2.new(1, 0, 0, 4)
    BarContainer.Position = UDim2.new(0, 0, 0, 120)
    BarContainer.BackgroundColor3 = GUI.BorderColor
    BarContainer.BorderSizePixel = 0
    BarContainer.BackgroundTransparency = 0.5
    BarContainer.ZIndex = 10003
    BarContainer.Parent = Container
    
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
    
    -- Animate in
    task.wait(0.2)
    SmoothTween(MainText, {TextTransparency = 0}, 0.5)
    task.wait(0.1)
    SmoothTween(SubText, {TextTransparency = 0}, 0.5)
    task.wait(0.1)
    SmoothTween(BarContainer, {BackgroundTransparency = 0.5}, 0.5)
    
    -- Animate progress bar
    SmoothTween(ProgressBar, {Size = UDim2.new(1, 0, 1, 0)}, 3, Enum.EasingStyle.Linear)
    
    return ChangeScreen
end

-- TEXT-BASED KEY SYSTEM (No images)
function GUI.CreateKeySystemGUI(onSubmitCallback)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Blur background
    local BlurFrame = Instance.new("Frame")
    BlurFrame.Size = UDim2.new(1, 0, 1, 0)
    BlurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlurFrame.BackgroundTransparency = 0.3
    BlurFrame.BorderSizePixel = 0
    BlurFrame.Parent = ScreenGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    MainFrame.BackgroundColor3 = GUI.BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = GUI.BorderColor
    Stroke.Thickness = 1
    Stroke.Transparency = 0
    Stroke.Parent = MainFrame
    
    -- Header
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "Skibidi Farm"
    HeaderTitle.Size = UDim2.new(1, -40, 0, 50)
    HeaderTitle.Position = UDim2.new(0, 20, 0, 20)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextColor3 = GUI.TextPrimary
    HeaderTitle.TextSize = 28
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 2
    HeaderTitle.Parent = MainFrame
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Enter your key to continue"
    Subtitle.Size = UDim2.new(1, -40, 0, 20)
    Subtitle.Position = UDim2.new(0, 20, 0, 65)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextColor3 = GUI.TextSecondary
    Subtitle.TextSize = 14
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 2
    Subtitle.Parent = MainFrame
    
    -- Key Input
    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(1, -40, 0, 44)
    KeyBox.Position = UDim2.new(0, 20, 0, 100)
    KeyBox.BackgroundColor3 = GUI.SurfaceColor
    KeyBox.BorderSizePixel = 0
    KeyBox.Text = ""
    KeyBox.PlaceholderText = "Enter key..."
    KeyBox.TextColor3 = GUI.TextPrimary
    KeyBox.PlaceholderColor3 = GUI.TextSecondary
    KeyBox.TextSize = 15
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.ClearTextOnFocus = false
    KeyBox.ZIndex = 2
    KeyBox.Parent = MainFrame
    
    local KeyBoxCorner = Instance.new("UICorner")
    KeyBoxCorner.CornerRadius = UDim.new(0, 10)
    KeyBoxCorner.Parent = KeyBox
    
    local KeyBoxStroke = Instance.new("UIStroke")
    KeyBoxStroke.Color = GUI.BorderColor
    KeyBoxStroke.Thickness = 1
    KeyBoxStroke.Transparency = 0
    KeyBoxStroke.Parent = KeyBox
    
    -- Focus effects
    KeyBox.Focused:Connect(function()
        SmoothTween(KeyBoxStroke, {Color = GUI.AccentColor}, 0.2)
    end)
    
    KeyBox.FocusLost:Connect(function()
        SmoothTween(KeyBoxStroke, {Color = GUI.BorderColor}, 0.2)
    end)
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(1, -40, 0, 44)
    SubmitButton.Position = UDim2.new(0, 20, 0, 158)
    SubmitButton.BackgroundColor3 = GUI.AccentColor
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "Continue"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 16
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.ZIndex = 2
    SubmitButton.Parent = MainFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 10)
    SubmitCorner.Parent = SubmitButton
    
    -- Hover effect
    SubmitButton.MouseEnter:Connect(function()
        SmoothTween(SubmitButton, {BackgroundColor3 = Color3.fromRGB(10, 132, 255)}, 0.2)
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        SmoothTween(SubmitButton, {BackgroundColor3 = GUI.AccentColor}, 0.2)
    end)
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -40, 0, 20)
    StatusLabel.Position = UDim2.new(0, 20, 0, 215)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = GUI.ErrorColor
    StatusLabel.TextSize = 13
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.ZIndex = 2
    StatusLabel.Parent = MainFrame
    
    -- Get Key Button
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Size = UDim2.new(1, -40, 0, 20)
    GetKeyButton.Position = UDim2.new(0, 20, 0, 245)
    GetKeyButton.BackgroundTransparency = 1
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = GUI.AccentColor
    GetKeyButton.TextSize = 13
    GetKeyButton.Font = Enum.Font.Gotham
    GetKeyButton.ZIndex = 2
    GetKeyButton.Parent = MainFrame
    
    GetKeyButton.MouseButton1Click:Connect(function()
        setclipboard("https://key.raservices.shop")
        StatusLabel.Text = "Link copied to clipboard!"
        StatusLabel.TextColor3 = GUI.SuccessColor
        task.wait(2)
        StatusLabel.Text = ""
    end)
    
    -- Submit logic
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        StatusLabel.Text = "Validating..."
        StatusLabel.TextColor3 = GUI.TextSecondary
        SubmitButton.Text = "Please wait..."
        
        if onSubmitCallback then
            onSubmitCallback(key, StatusLabel, SubmitButton, ScreenGui)
        end
    end)
    
    -- Animate entrance
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    BlurFrame.BackgroundTransparency = 1
    
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    SmoothTween(BlurFrame, {BackgroundTransparency = 0.3}, 0.3)
    SmoothTween(MainFrame, {
        Size = UDim2.new(0, 400, 0, 280),
        Position = UDim2.new(0.5, -200, 0.5, -140)
    }, 0.5, Enum.EasingStyle.Back)
    
    return ScreenGui
end

-- Minimal loading screen
function GUI.CreateFullScreenLoader()
    local LoaderScreen = Instance.new("Frame")
    LoaderScreen.Name = "FullScreenLoader"
    LoaderScreen.Size = UDim2.new(1, 0, 1, 0)
    LoaderScreen.BackgroundColor3 = GUI.BackgroundColor
    LoaderScreen.BorderSizePixel = 0
    LoaderScreen.ZIndex = 9000
    LoaderScreen.Parent = GUI.SkibidiGui
    
    -- Center container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 400, 0, 200)
    Container.Position = UDim2.new(0.5, -200, 0.5, -100)
    Container.BackgroundTransparency = 1
    Container.Parent = LoaderScreen
    
    -- Logo text
    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "Skibidi Farm"
    LogoText.Size = UDim2.new(1, 0, 0, 60)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextColor3 = GUI.TextPrimary
    LogoText.TextSize = 48
    LogoText.TextTransparency = 1
    LogoText.Parent = Container
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Initializing..."
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0, 65)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextColor3 = GUI.TextSecondary
    Subtitle.TextSize = 16
    Subtitle.TextTransparency = 1
    Subtitle.Parent = Container
    
    -- Loading bar
    local BarContainer = Instance.new("Frame")
    BarContainer.Size = UDim2.new(0.9, 0, 0, 4)
    BarContainer.Position = UDim2.new(0.05, 0, 0, 120)
    BarContainer.BackgroundColor3 = GUI.BorderColor
    BarContainer.BackgroundTransparency = 0.5
    BarContainer.BorderSizePixel = 0
    BarContainer.Parent = Container
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarContainer
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = GUI.AccentColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = BarContainer
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar
    
    -- Percentage
    local PercentText = Instance.new("TextLabel")
    PercentText.Text = "0%"
    PercentText.Size = UDim2.new(1, 0, 0, 30)
    PercentText.Position = UDim2.new(0, 0, 0, 140)
    PercentText.BackgroundTransparency = 1
    PercentText.Font = Enum.Font.GothamBold
    PercentText.TextColor3 = GUI.AccentColor
    PercentText.TextSize = 24
    PercentText.TextTransparency = 1
    PercentText.Parent = Container
    
    -- Fade in
    SmoothTween(LogoText, {TextTransparency = 0}, 0.5)
    task.wait(0.2)
    SmoothTween(Subtitle, {TextTransparency = 0}, 0.5)
    SmoothTween(PercentText, {TextTransparency = 0}, 0.5)
    
    GUI.LoadingScreen = LoaderScreen
    
    return {
        Screen = LoaderScreen,
        Bar = ProgressBar,
        Status = Subtitle,
        Percent = PercentText,
        Update = function(progress, statusText)
            if Subtitle and Subtitle.Parent then
                Subtitle.Text = statusText or "Loading..."
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = math.floor(progress * 100) .. "%"
            end
            if ProgressBar and ProgressBar.Parent then
                SmoothTween(ProgressBar, {
                    Size = UDim2.new(progress, 0, 1, 0)
                }, 0.3, Enum.EasingStyle.Quad)
            end
        end,
        Complete = function()
            if not LoaderScreen or not LoaderScreen.Parent then return end
            
            if Subtitle and Subtitle.Parent then
                Subtitle.Text = "Complete!"
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = "100%"
            end
            
            task.wait(0.5)
            
            SmoothTween(LoaderScreen, {BackgroundTransparency = 1}, 0.4)
            
            for _, child in pairs(LoaderScreen:GetDescendants()) do
                pcall(function()
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        SmoothTween(child, {TextTransparency = 1}, 0.4)
                    elseif child:IsA("Frame") then
                        SmoothTween(child, {BackgroundTransparency = 1}, 0.4)
                    end
                end)
            end
            
            task.wait(0.5)
            
            if LoaderScreen and LoaderScreen.Parent then
                LoaderScreen:Destroy()
            end
            
            GUI.LoadingScreen = nil
        end
    }
end

function GUI.InitAssets(progressCallback)
    local loader = GUI.CreateFullScreenLoader()
    if not loader then
        warn("[SKIBIDI] Failed to create loader")
        return
    end
    
    loader.Update(0.05, "Creating workspace...")
    
    pcall(function()
        if makefolder and not isfolder(WORKSPACE_FOLDER) then 
            makefolder(WORKSPACE_FOLDER)
        end
    end)
    
    task.wait(0.3)
    loader.Update(0.1, "Loading music...")
    
    GUI.Playlist = {}
    
    GUI.AddTask(task.spawn(function()
        local success = pcall(function()
            local musicPath = WORKSPACE_FOLDER .. "/sound.mp3"
            
            if isfile and not isfile(musicPath) then
                if writefile then
                    local httpSuccess, musicData = pcall(function()
                        return game:HttpGet(ASSETS_REPO .. "sound.mp3", true)
                    end)
                    
                    if httpSuccess and musicData and #musicData > 1000 then
                        writefile(musicPath, musicData)
                    end
                end
            end
            
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
                end
            end
        end)
    end))
    
    task.wait(0.5)
    loader.Update(0.55, "Loading assets...")
    
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
                
                if isfile and not isfile(BG_PATH) then
                    if writefile then
                        loader.Update(0.7, "Downloading background...")
                        local bgData = game:HttpGet(ASSETS_REPO .. BG_FILENAME, true)
                        if bgData then
                            writefile(BG_PATH, bgData)
                        end
                    end
                end
                
                if isfile and isfile(BG_PATH) and GUI.BackgroundImage.Parent then
                    GUI.BackgroundImage.Image = asset(BG_PATH)
                end
                
                loader.Update(0.75, "Background ready")
            end)
        end))
    end
    
    loader.Update(0.8, "Loading change screen...")
    
    GUI.AddTask(task.spawn(function()
        pcall(function()
            if isfile and not isfile(CHANGE_PATH) then
                if writefile then
                    local changeData = game:HttpGet(ASSETS_REPO .. CHANGE_FILENAME, true)
                    if changeData then
                        writefile(CHANGE_PATH, changeData)
                    end
                end
            end
        end)
    end))
    
    task.wait(0.5)
    loader.Update(0.9, "Finalizing...")
    task.wait(0.4)
    loader.Update(1, "Ready!")
    task.wait(0.3)
    loader.Complete()
    
    GUI.AddConnection(Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end))
end

function GUI.Init(vars)
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

    -- Main Frame - Minimal macOS style
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.BackgroundColor
    GUI.MainFrame.BackgroundTransparency = 0
    GUI.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = GUI.MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = GUI.BorderColor
    Stroke.Thickness = 1
    Stroke.Transparency = 0
    Stroke.Parent = GUI.MainFrame

    -- Background Image (subtle)
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.85
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = GUI.MainFrame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 16)
    BgCorner.Parent = GUI.BackgroundImage
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    GUI.AddConnection(GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false
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

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 2
    Header.Parent = GUI.MainFrame
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "Skibidi Farm"
    HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 20, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextColor3 = GUI.TextPrimary
    HeaderTitle.TextSize = 24
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.TextYAlignment = Enum.TextYAlignment.Center
    HeaderTitle.ZIndex = 3
    HeaderTitle.Parent = Header
    
    -- Version badge
    local VersionBadge = Instance.new("TextLabel")
    VersionBadge.Text = "v5.0"
    VersionBadge.Size = UDim2.new(0, 50, 0, 24)
    VersionBadge.Position = UDim2.new(1, -70, 0.5, -12)
    VersionBadge.BackgroundColor3 = GUI.SurfaceColor
    VersionBadge.Font = Enum.Font.GothamBold
    VersionBadge.TextColor3 = GUI.AccentColor
    VersionBadge.TextSize = 12
    VersionBadge.ZIndex = 3
    VersionBadge.Parent = Header
    
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 12)
    BadgeCorner.Parent = VersionBadge
    
    local BadgeStroke = Instance.new("UIStroke")
    BadgeStroke.Color = GUI.BorderColor
    BadgeStroke.Thickness = 1
    BadgeStroke.Parent = VersionBadge

    -- Stats Container
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Position = UDim2.new(0, 15, 0, 85)
    StatsContainer.Size = UDim2.new(1, -30, 0, 500)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.ZIndex = 2
    StatsContainer.Parent = GUI.MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 12)
    Layout.Parent = StatsContainer

    -- Stat card function (minimal style)
    local function CreateStatCard(label, value, iconText, order)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 70)
        Card.BackgroundColor3 = GUI.SurfaceColor
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.ZIndex = 2
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 12)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = GUI.BorderColor
        CardStroke.Thickness = 1
        CardStroke.Transparency = 0
        CardStroke.Parent = Card
        
        -- Icon
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 40, 0, 40)
        Icon.Position = UDim2.new(0, 15, 0.5, -20)
        Icon.BackgroundTransparency = 1
        Icon.Font = Enum.Font.GothamBold
        Icon.Text = iconText
        Icon.TextColor3 = GUI.AccentColor
        Icon.TextSize = 24
        Icon.ZIndex = 3
        Icon.Parent = Card
        
        -- Label
        local Label = Instance.new("TextLabel")
        Label.Text = label
        Label.Size = UDim2.new(1, -70, 0, 18)
        Label.Position = UDim2.new(0, 60, 0, 15)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextColor3 = GUI.TextSecondary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 3
        Label.Parent = Card
        
        -- Value
        local Value = Instance.new("TextLabel")
        Value.Text = value
        Value.Size = UDim2.new(1, -70, 0, 24)
        Value.Position = UDim2.new(0, 60, 0, 33)
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBold
        Value.TextSize = 18
        Value.TextColor3 = GUI.TextPrimary
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.ZIndex = 3
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.Parent = Card
        
        return Value
    end

    -- Create stat cards with proper icons
    vars.TargetLabel = CreateStatCard("CURRENT TARGET", "Searching...", "🎯", 1)
    vars.StateLabel = CreateStatCard("STATUS", "Initializing", "●", 2)
    vars.BountyLabel = CreateStatCard("BOUNTY GAINED", "+0", "💎", 3)
    vars.TimeLabel = CreateStatCard("SESSION TIME", "00:00:00", "⏱", 4)
    vars.KillsLabel = CreateStatCard("TOTAL KILLS", "0", "⚔", 5)

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

    -- Smooth entrance animation
    SmoothTween(GUI.MainFrame, {
        Size = UDim2.new(0, 400, 0, 600)
    }, 0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

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

-- Cleanup
function GUI.Cleanup()
    GUI.SaveMusicState()
    
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
    
    for _, tween in ipairs(GUI.RunningTweens) do
        pcall(function()
            if tween then tween:Cancel() end
        end)
    end
    GUI.RunningTweens = {}
    
    for _, taskThread in ipairs(GUI.Tasks) do
        pcall(function()
            if taskThread then task.cancel(taskThread) end
        end)
    end
    GUI.Tasks = {}
    
    for _, connection in ipairs(GUI.Connections) do
        pcall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
    end
    GUI.Connections = {}
    
    if GUI.SkibidiGui then
        pcall(function()
            GUI.SkibidiGui:Destroy()
        end)
    end
    
    GUI.SkibidiGui = nil
    GUI.MainFrame = nil
    GUI.BackgroundImage = nil
    GUI.LoadingScreen = nil
end

return GUI
