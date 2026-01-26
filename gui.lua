local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local GUI = {}
GUI.Config = {}
GUI.AccentColor = Color3.fromRGB(138, 43, 226) 
GUI.SecondColor = Color3.fromRGB(0, 255, 255)  
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
local TIME_FILENAME = "musictime.txt"

-- Try to resolve absolute path for getcustomasset consistency if supported
local MUSIC_PATH = WORKSPACE_FOLDER .. "/" .. MUSIC_FILENAME
local BG_PATH = WORKSPACE_FOLDER .. "/" .. BG_FILENAME
local TIME_PATH = WORKSPACE_FOLDER .. "/" .. TIME_FILENAME

local ASSETS_REPO = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"
local MUSIC_URL = ASSETS_REPO .. MUSIC_FILENAME
local BG_URL = ASSETS_REPO .. BG_FILENAME

-- Fallback Image (Generic Sci-Fi Background) if local load fails
local FALLBACK_BG_ID = "rbxassetid://14241601150" -- Example ID

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
-- HELPER FUNCTIONS
-- ============================================================================
function GUI.SaveMusicState()
    if GUI.MusicSound and GUI.MusicSound.IsPlaying then
        pcall(function()
            writefile(TIME_PATH, tostring(GUI.MusicSound.TimePosition))
        end)
    end
end

-- ============================================================================
-- ASSET LOADER
-- ============================================================================
function GUI.InitAssets(progressCallback)
    print("[ASSETS] Initializing...")
    
    if makefolder and not isfolder(WORKSPACE_FOLDER) then
        makefolder(WORKSPACE_FOLDER)
    end

    GUI.MusicSound = Instance.new("Sound")
    GUI.MusicSound.Name = "SkibidiMusic"
    GUI.MusicSound.Looped = true
    GUI.MusicSound.Volume = GUI.Config.MusicVolume
    GUI.MusicSound.Parent = SoundService

    task.spawn(function()
        pcall(function()
            if progressCallback then progressCallback("Checking Music...", 0.3) end
            
            local function LoadMusic()
                local asset = getcustomasset or getsynasset
                if asset and isfile(MUSIC_PATH) then
                    GUI.MusicSound.SoundId = asset(MUSIC_PATH)
                    
                    if isfile(TIME_PATH) then
                        local saved = tonumber(readfile(TIME_PATH))
                        if saved then GUI.MusicSound.TimePosition = saved end
                    end
                    
                    if progressCallback then progressCallback("Music Ready", 0.5) end
                    if GUI.Config.MusicEnabled then 
                        task.wait(0.5)
                        GUI.MusicSound:Play() 
                    end
                    return true
                end
                return false
            end
            
            if not isfile(MUSIC_PATH) then
                if progressCallback then progressCallback("Downloading Music...", 0.35) end
                local success, data = pcall(function() return game:HttpGet(MUSIC_URL) end)
                if success and data then
                    writefile(MUSIC_PATH, data)
                    LoadMusic()
                else
                    if progressCallback then progressCallback("Music Download Failed", 0.4) end
                end
            else
                LoadMusic()
            end
        end)
    end)

    task.spawn(function()
        pcall(function()
            if progressCallback then progressCallback("Checking Image...", 0.6) end
            
            local function LoadBg(useAuth)
                local asset = getcustomasset or getsynasset
                if asset and isfile(BG_PATH) and GUI.BackgroundImage then
                    -- Attempt standard custom asset load
                    local assetId = asset(BG_PATH)
                    GUI.BackgroundImage.Image = assetId
                    if progressCallback then progressCallback("Background Loaded", 0.8) end
                else
                    warn("[BG] Asset loader missing or file empty")
                    -- Use Fallback
                    if GUI.BackgroundImage then GUI.BackgroundImage.Image = FALLBACK_BG_ID end
                end
            end

            if not isfile(BG_PATH) then
                if progressCallback then progressCallback("Downloading Image...", 0.65) end
                local success, data = pcall(function() return game:HttpGet(BG_URL) end)
                if success and data then
                    writefile(BG_PATH, data)
                    LoadBg()
                else
                    warn("[BG] Download Failed")
                    if GUI.BackgroundImage then GUI.BackgroundImage.Image = FALLBACK_BG_ID end
                end
            else
                LoadBg()
            end
        end)
    end)
end

-- ============================================================================
-- GUI CREATION
-- ============================================================================
function GUI.Init(vars)
    local lp = Players.LocalPlayer
    if GUI.SkibidiGui then GUI.SkibidiGui:Destroy() end
    
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "SkibidiGui"
    GUI.SkibidiGui.ResetOnSpawn = false
    GUI.SkibidiGui.IgnoreGuiInset = true
    
    pcall(function() GUI.SkibidiGui.Parent = CoreGui end)
    if not GUI.SkibidiGui.Parent then GUI.SkibidiGui.Parent = lp:WaitForChild("PlayerGui") end

    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    GUI.MainFrame.BackgroundTransparency = 0.1
    GUI.MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    GUI.MainFrame.Size = UDim2.new(0, 420, 0, 320)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = GUI.MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 2
    MainStroke.Color = GUI.AccentColor
    MainStroke.Parent = GUI.MainFrame

    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.Image = "" -- Loaded by InitAssets
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.5
    GUI.BackgroundImage.Parent = GUI.MainFrame
    
    local BGCorner = Instance.new("UICorner")
    BGCorner.CornerRadius = UDim.new(0, 16)
    BGCorner.Parent = GUI.BackgroundImage

    local Header = Instance.new("TextLabel")
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 20, 0, 15)
    Header.Size = UDim2.new(1, -40, 0, 30)
    Header.Font = Enum.Font.GothamBlack
    Header.Text = "SKIBIDI FARM"
    Header.TextColor3 = Color3.fromRGB(240, 240, 255)
    Header.TextSize = 26
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = GUI.MainFrame

    local Sub = Instance.new("TextLabel")
    Sub.BackgroundTransparency = 1
    Sub.Position = UDim2.new(0, 20, 0, 45)
    Sub.Size = UDim2.new(1, -40, 0, 15)
    Sub.Font = Enum.Font.GothamBold
    Sub.Text = "STATUS: ACTIVE • GOONER EDITION"
    Sub.TextColor3 = GUI.AccentColor
    Sub.TextSize = 11
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Parent = GUI.MainFrame

    local StatusContainer = Instance.new("Frame")
    StatusContainer.BackgroundTransparency = 1
    StatusContainer.Position = UDim2.new(0, 20, 0, 80)
    StatusContainer.Size = UDim2.new(1, -40, 1, -100)
    StatusContainer.Parent = GUI.MainFrame
    
    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 5)
    List.Parent = StatusContainer

    local function CreateRow(label, default)
        local R = Instance.new("Frame")
        R.BackgroundTransparency = 1
        R.Size = UDim2.new(1, 0, 0, 25)
        R.Parent = StatusContainer
        
        local K = Instance.new("TextLabel")
        K.BackgroundTransparency = 1
        K.Size = UDim2.new(0.5, 0, 1, 0)
        K.Font = Enum.Font.Gotham
        K.Text = label
        K.TextColor3 = Color3.fromRGB(180, 180, 200)
        K.TextSize = 13
        K.TextXAlignment = Enum.TextXAlignment.Left
        K.Parent = R
        
        local V = Instance.new("TextLabel")
        V.BackgroundTransparency = 1
        V.Position = UDim2.new(0.5, 0, 0, 0)
        V.Size = UDim2.new(0.5, 0, 1, 0)
        V.Font = Enum.Font.GothamBold
        V.Text = default
        V.TextColor3 = Color3.WHITE
        V.TextSize = 13
        V.TextXAlignment = Enum.TextXAlignment.Right
        V.Parent = R
        return V
    end

    vars.TargetLabel = CreateRow("Target", "Searching...")
    vars.StateLabel = CreateRow("Status", "Init...")
    vars.BountyLabel = CreateRow("Bounty", "0")
    vars.TimeLabel = CreateRow("Session Time", "00:00:00")
    vars.FarmedLabel = CreateRow("Farmed", "0")

    local dragging, dragStart, startPos
    GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    GUI.MainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            GUI.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Logger = {}
    function Logger:Log(msg) vars.StateLabel.Text = msg end
    function Logger:Info(msg) vars.StateLabel.Text = "ℹ️ " .. msg end
    function Logger:Success(msg) vars.StateLabel.Text = "✅ " .. msg end
    function Logger:Warning(msg) vars.StateLabel.Text = "⚠️ " .. msg end
    function Logger:Error(msg) vars.StateLabel.Text = "❌ " .. msg end
    function Logger:Target(msg) vars.TargetLabel.Text = msg end
    
    return Logger
end

return GUI
