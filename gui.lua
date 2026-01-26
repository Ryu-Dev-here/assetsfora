local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local GUI = {}
GUI.Config = {}
GUI.AccentColor = Color3.fromRGB(138, 43, 226) -- Electric Purple
GUI.SecondColor = Color3.fromRGB(0, 255, 255)  -- Cyan for gradients
GUI.SkibidiGui = nil
GUI.MainFrame = nil
GUI.MusicSound = nil
GUI.BackgroundImage = nil

-- ============================================================================
-- FOLDER & ASSET CONFIGURATION
-- ============================================================================
local WORKSPACE_FOLDER = "cuackerdoing"
local MUSIC_FILENAME = "sound.mp3"
local BG_FILENAME = "backlua.png"
local MUSIC_PATH = WORKSPACE_FOLDER .. "/" .. MUSIC_FILENAME
local BG_PATH = WORKSPACE_FOLDER .. "/" .. BG_FILENAME

local ASSETS_REPO = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"
local MUSIC_URL = ASSETS_REPO .. MUSIC_FILENAME
local BG_URL = ASSETS_REPO .. BG_FILENAME

-- Global config (Hardcoded as requested)
GUI.Config = {
    AutoFarmEnabled = true,
    InstaTeleportEnabled = true,
    AntiRagdollEnabled = true,
    FruitAttackEnabled = true,
    FARM_DURATION = 30,
    FruitAttackRange = 600,
    PREDICTION_TIME = 0.00,
    YOffset = 0,
    SELECTED_FRUIT = "Dragon",
    MusicEnabled = true,
    MusicVolume = 0.5
}

-- ============================================================================
-- ASSET LOADER
-- ============================================================================
function GUI.InitAssets(progressCallback)
    print("[ASSETS] Initializing asset loader...")
    
    -- 1. Ensure Folder Exists
    if makefolder then
        if not isfolder(WORKSPACE_FOLDER) then
            print("[ASSETS] Creating folder: " .. WORKSPACE_FOLDER)
            makefolder(WORKSPACE_FOLDER)
        end
    else
        warn("[ASSETS] 'makefolder' not supported! Assets might fail to save.")
    end

    -- 2. Setup Sound Instance
    GUI.MusicSound = Instance.new("Sound")
    GUI.MusicSound.Name = "SkibidiMusic"
    GUI.MusicSound.Looped = true
    GUI.MusicSound.Volume = GUI.Config.MusicVolume
    GUI.MusicSound.Parent = SoundService

    -- 3. Parallel Download/Load Tasks
    task.spawn(function()
        pcall(function()
            if progressCallback then progressCallback("Checking music...", 0.3) end
            
            local function LoadMusic()
                local asset = getcustomasset or getsynasset
                if asset and isfile(MUSIC_PATH) then
                    print("[MUSIC] Loading from: " .. MUSIC_PATH)
                    GUI.MusicSound.SoundId = asset(MUSIC_PATH)
                    if progressCallback then progressCallback("Music loaded", 0.5) end
                    if GUI.Config.MusicEnabled then 
                        task.wait(0.5)
                        GUI.MusicSound:Play() 
                    end
                    return true
                end
                return false
            end

            -- Check if file exists and acts valid (basic check)
            if not isfile(MUSIC_PATH) then
                print("[MUSIC] Downloading large asset from: " .. MUSIC_URL)
                if progressCallback then progressCallback("Downloading music (Large)...", 0.35) end
                
                local success, data = pcall(function() return game:HttpGet(MUSIC_URL) end)
                if success and data then
                    print("[MUSIC] Download success (" .. #data .. " bytes)")
                    writefile(MUSIC_PATH, data)
                    LoadMusic()
                else
                    warn("[MUSIC] Download failed!")
                    if progressCallback then progressCallback("Music download failed", 0.4) end
                end
            else
                print("[MUSIC] Found cached file")
                LoadMusic()
            end
        end)
    end)

    task.spawn(function()
        pcall(function()
            if progressCallback then progressCallback("Checking background...", 0.6) end
            
            local function LoadBg()
                local asset = getcustomasset or getsynasset
                if asset and isfile(BG_PATH) and GUI.BackgroundImage then
                    print("[BG] Loading from: " .. BG_PATH)
                    GUI.BackgroundImage.Image = asset(BG_PATH)
                    if progressCallback then progressCallback("Background loaded", 0.8) end
                end
            end

            if not isfile(BG_PATH) then
                print("[BG] Downloading from: " .. BG_URL)
                local success, data = pcall(function() return game:HttpGet(BG_URL) end)
                if success and data then
                    print("[BG] Download success")
                    writefile(BG_PATH, data)
                    LoadBg()
                else
                    warn("[BG] Download failed")
                end
            else
                LoadBg()
            end
        end)
    end)
end

-- ============================================================================
-- GUI CREATION (PREMIUM READ-ONLY)
-- ============================================================================
function GUI.Init(vars)
    local lp = Players.LocalPlayer
    
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "SkibidiGui"
    GUI.SkibidiGui.ResetOnSpawn = false
    GUI.SkibidiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.SkibidiGui.IgnoreGuiInset = true
    
    pcall(function() GUI.SkibidiGui.Parent = CoreGui end)
    if not GUI.SkibidiGui.Parent then GUI.SkibidiGui.Parent = lp:WaitForChild("PlayerGui") end

    -- Blur Effect
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 20
    Blur.Enabled = false
    Blur.Parent = Lighting
    
    -- Main Container (Glassmorphism)
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    GUI.MainFrame.BackgroundTransparency = 0.2
    GUI.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    GUI.MainFrame.Size = UDim2.new(0, 400, 0, 300)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    -- Rounded Corners
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 20)
    MainCorner.Parent = GUI.MainFrame
    
    -- Gradient Stroke (Premium Border)
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.3
    MainStroke.Parent = GUI.MainFrame
    
    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(1, GUI.SecondColor)
    }
    StrokeGradient.Rotation = 45
    StrokeGradient.Parent = MainStroke

    -- Animated Border Pulse
    task.spawn(function()
        while GUI.MainFrame.Parent do
            local t = tick() % 2
            StrokeGradient.Rotation = StrokeGradient.Rotation + 1
            task.wait(0.02)
        end
    end)

    -- Background Image Container
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Name = "BG"
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.ImageTransparency = 0.8
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = GUI.MainFrame
    
    local BGCorner = Instance.new("UICorner")
    BGCorner.CornerRadius = UDim.new(0, 20)
    BGCorner.Parent = GUI.BackgroundImage

    -- Header
    local Header = Instance.new("TextLabel")
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 20, 0, 15)
    Header.Size = UDim2.new(1, -40, 0, 30)
    Header.Font = Enum.Font.GothamBlack
    Header.Text = "SKIBIDI FARM"
    Header.TextColor3 = Color3.fromRGB(240, 240, 255)
    Header.TextSize = 24
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = GUI.MainFrame

    local SubHeader = Instance.new("TextLabel")
    SubHeader.BackgroundTransparency = 1
    SubHeader.Position = UDim2.new(0, 20, 0, 42)
    SubHeader.Size = UDim2.new(1, -40, 0, 15)
    SubHeader.Font = Enum.Font.GothamBold
    SubHeader.Text = "PREMIUM AUTO-FARM • ACTIVE"
    SubHeader.TextColor3 = GUI.AccentColor
    SubHeader.TextSize = 10
    SubHeader.TextXAlignment = Enum.TextXAlignment.Left
    SubHeader.Parent = GUI.MainFrame

    -- Status Logic (Read-Only)
    local function CreateStatusRow(name, initialVal, yPos)
        local Row = Instance.new("Frame")
        Row.BackgroundTransparency = 1
        Row.Position = UDim2.new(0, 20, 0, yPos)
        Row.Size = UDim2.new(1, -40, 0, 30)
        Row.Parent = GUI.MainFrame
        
        local Key = Instance.new("TextLabel")
        Key.BackgroundTransparency = 1
        Key.Size = UDim2.new(0.4, 0, 1, 0)
        Key.Font = Enum.Font.GothamMedium
        Key.Text = name
        Key.TextColor3 = Color3.fromRGB(180, 180, 200)
        Key.TextSize = 14
        Key.TextXAlignment = Enum.TextXAlignment.Left
        Key.Parent = Row
        
        local Val = Instance.new("TextLabel")
        Val.BackgroundTransparency = 1
        Val.Position = UDim2.new(0.4, 0, 0, 0)
        Val.Size = UDim2.new(0.6, 0, 1, 0)
        Val.Font = Enum.Font.GothamBold
        Val.Text = initialVal
        Val.TextColor3 = Color3.fromRGB(255, 255, 255)
        Val.TextSize = 14
        Val.TextXAlignment = Enum.TextXAlignment.Right
        Val.Parent = Row
        
        return Val
    end

    vars.TargetLabel = CreateStatusRow("Current Target", "Searching...", 80)
    vars.StateLabel = CreateStatusRow("Status", "Initializing...", 115)
    vars.BountyLabel = CreateStatusRow("Bounty Earned", "+0", 150)
    vars.TimeLabel = CreateStatusRow("Elapsed Time", "00:00:00", 185)
    
    -- Bottom Info
    local Info = Instance.new("TextLabel")
    Info.BackgroundTransparency = 1
    Info.Position = UDim2.new(0, 0, 1, -30)
    Info.Size = UDim2.new(1, 0, 0, 20)
    Info.Font = Enum.Font.Gotham
    Info.Text = "Configs are hardcoded enabled for maximum efficiency"
    Info.TextColor3 = Color3.fromRGB(100, 100, 120)
    Info.TextSize = 10
    Info.Parent = GUI.MainFrame

    -- Dragging Logic
    local dragging, dragStart, startPos
    
    GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    GUI.MainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            TweenService:Create(GUI.MainFrame, TweenInfo.new(0.05), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    -- Toggle Keybind (RightShift)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            GUI.MainFrame.Visible = not GUI.MainFrame.Visible
            Blur.Enabled = GUI.MainFrame.Visible
        end
    end)
    
    -- Simple Logger for Toast-like notifications handled by main script via GUI update
    local Logger = {}
    function Logger:Log(msg) vars.StateLabel.Text = msg end
    function Logger:Target(msg) vars.TargetLabel.Text = msg end
    function Logger:Success(msg) vars.StateLabel.Text = "✅ " .. msg end
    function Logger:Warning(msg) vars.StateLabel.Text = "⚠️ " .. msg end
    
    return Logger
end

return GUI
