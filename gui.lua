local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local GUI = {}
GUI.Config = {}
GUI.AccentColor = Color3.fromRGB(138, 43, 226) 
GUI.SkibidiGui = nil
GUI.MainFrame = nil
GUI.BackgroundImage = nil
GUI.MusicSound = nil

-- Configuration
local WORKSPACE_FOLDER = "cuackerdoing"
local MUSIC_FILENAME = "sound.mp3"
local BG_FILENAME = "backlua.png"
local TIME_FILENAME = "musictime.txt"
local MUSIC_PATH = WORKSPACE_FOLDER .. "/" .. MUSIC_FILENAME
local BG_PATH = WORKSPACE_FOLDER .. "/" .. BG_FILENAME
local TIME_PATH = WORKSPACE_FOLDER .. "/" .. TIME_FILENAME
local ASSETS_REPO = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"
local FALLBACK_BG_ID = "rbxassetid://14241601150"

GUI.Config = {
    AutoFarmEnabled = true,
    InstaTeleportEnabled = true,
    AntiRagdollEnabled = true,
    FruitAttackEnabled = true,
    MusicEnabled = true,
    MusicVolume = 0.5
}

function GUI.SaveMusicState()
    if GUI.MusicSound and GUI.MusicSound.IsPlaying then
        pcall(function() writefile(TIME_PATH, tostring(GUI.MusicSound.TimePosition)) end)
    end
end

function GUI.InitAssets(progressCallback)
    if makefolder and not isfolder(WORKSPACE_FOLDER) then makefolder(WORKSPACE_FOLDER) end

    -- Music
    GUI.MusicSound = Instance.new("Sound")
    GUI.MusicSound.Name = "SkibidiMusic"
    GUI.MusicSound.Looped = true
    GUI.MusicSound.Volume = GUI.Config.MusicVolume
    GUI.MusicSound.Parent = SoundService

    task.spawn(function()
        local function LoadMusic()
            local asset = getcustomasset or getsynasset
            if asset and isfile(MUSIC_PATH) then
                GUI.MusicSound.SoundId = asset(MUSIC_PATH)
                if isfile(TIME_PATH) then
                    local saved = tonumber(readfile(TIME_PATH))
                    if saved then GUI.MusicSound.TimePosition = saved end
                end
                GUI.MusicSound:Play()
            end
        end
        if not isfile(MUSIC_PATH) then
            local s, d = pcall(function() return game:HttpGet(ASSETS_REPO .. MUSIC_FILENAME) end)
            if s and d then writefile(MUSIC_PATH, d) LoadMusic() end
        else
            LoadMusic()
        end
    end)

    -- Image
    task.spawn(function()
        local function LoadBg()
            local asset = getcustomasset or getsynasset
            if asset and isfile(BG_PATH) and GUI.BackgroundImage then
                GUI.BackgroundImage.Image = asset(BG_PATH)
            else
                if GUI.BackgroundImage then GUI.BackgroundImage.Image = FALLBACK_BG_ID end
            end
        end
        if not isfile(BG_PATH) then
            local s, d = pcall(function() return game:HttpGet(ASSETS_REPO .. BG_FILENAME) end)
            if s and d then writefile(BG_PATH, d) LoadBg()
            else if GUI.BackgroundImage then GUI.BackgroundImage.Image = FALLBACK_BG_ID end end
        else
            LoadBg()
        end
    end)
end

function GUI.Init(vars)
    if GUI.SkibidiGui then GUI.SkibidiGui:Destroy() end
    local lp = Players.LocalPlayer
    
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "SkibidiGui"
    GUI.SkibidiGui.ResetOnSpawn = false
    GUI.SkibidiGui.IgnoreGuiInset = true
    pcall(function() GUI.SkibidiGui.Parent = CoreGui end)
    if not GUI.SkibidiGui.Parent then GUI.SkibidiGui.Parent = lp:WaitForChild("PlayerGui") end

    -- Main Vertical Frame
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    GUI.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    GUI.MainFrame.Size = UDim2.new(0, 300, 0, 400) -- Vertical aspect ratio
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = GUI.MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Color = GUI.AccentColor
    Stroke.Parent = GUI.MainFrame

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then debugging = false dragging = false end
            end)
        end
    end)
    GUI.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            GUI.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Background
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.5
    GUI.BackgroundImage.Parent = GUI.MainFrame
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 16)
    BgCorner.Parent = GUI.BackgroundImage

    -- Header
    local Header = Instance.new("TextLabel")
    Header.Text = "SKIBIDI FARM"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Font = Enum.Font.GothamBlack
    Header.TextColor3 = Color3.WHITE
    Header.TextSize = 24
    Header.Parent = GUI.MainFrame

    -- Status List (Vertical)
    local StatusContainer = Instance.new("Frame")
    StatusContainer.Position = UDim2.new(0, 15, 0, 50)
    StatusContainer.Size = UDim2.new(1, -30, 1, -60)
    StatusContainer.BackgroundTransparency = 1
    StatusContainer.Parent = GUI.MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = StatusContainer

    local function CreateRow(label, val)
        local F = Instance.new("Frame")
        F.Size = UDim2.new(1, 0, 0, 30)
        F.BackgroundTransparency = 0.8
        F.BackgroundColor3 = Color3.BLACK
        F.Parent = StatusContainer
        
        local C = Instance.new("UICorner")
        C.Parent = F
        
        local L = Instance.new("TextLabel")
        L.Size = UDim2.new(0.4, 0, 1, 0)
        L.Position = UDim2.new(0.05, 0, 0, 0)
        L.BackgroundTransparency = 1
        L.Text = label
        L.TextColor3 = Color3.fromRGB(200, 200, 200)
        L.Font = Enum.Font.Gotham
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.Parent = F
        
        local V = Instance.new("TextLabel")
        V.Size = UDim2.new(0.5, 0, 1, 0)
        V.Position = UDim2.new(0.45, 0, 0, 0)
        V.BackgroundTransparency = 1
        V.Text = val
        V.TextColor3 = GUI.AccentColor
        V.Font = Enum.Font.GothamBold
        V.TextXAlignment = Enum.TextXAlignment.Right
        V.Parent = F
        return V
    end

    vars.TargetLabel = CreateRow("Target:", "None")
    vars.StateLabel = CreateRow("State:", "Idle")
    vars.BountyLabel = CreateRow("Bounty:", "+0")
    vars.TimeLabel = CreateRow("Time:", "00:00:00")
    vars.FarmedLabel = CreateRow("Farmed:", "0")

    local Logger = {}
    function Logger:Log(m) vars.StateLabel.Text = m end
    function Logger:Info(m) vars.StateLabel.Text = "ℹ️ " .. m end
    function Logger:Success(m) vars.StateLabel.Text = "✅ " .. m end
    function Logger:Warning(m) vars.StateLabel.Text = "⚠️ " .. m end
    function Logger:Error(m) vars.StateLabel.Text = "❌ " .. m end
    function Logger:Target(m) vars.TargetLabel.Text = m end
    return Logger
end

return GUI
