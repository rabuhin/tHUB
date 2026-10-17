local BASE = "https://raw.githubusercontent.com/rabuhin/tHUB/main/"

local function http(url)
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok then error("HTTP fail: " .. url, 0) end
    return body
end

local config = loadstring(http(BASE .. "hub/config.lua"))()
local placeId = game.PlaceId

local available = {}
for _, cheat in ipairs(config) do
    if cheat.placeId == nil or cheat.placeId == placeId then
        table.insert(available, cheat)
    end
end

-- ==========================================
-- РИСУЕМ СВОЕ МЕНЮ НА ScreenGui
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local oldHub = CoreGui:FindFirstChild("tHUB_Menu")
if oldHub then oldHub:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "tHUB_Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.BorderSizePixel = 0
title.Text = "tHUB Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.Code
title.TextSize = 16
title.Parent = mainFrame

local selectedCheat = available[1]

-- Создаем кнопки для каждого чита
local yPos = 40
for i, c in ipairs(available) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = "Select: " .. c.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.Parent = mainFrame
    
    btn.MouseButton1Click:Connect(function()
        selectedCheat = c
        -- Сбрасываем цвета у всех
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Text:find("Select") then
                child.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end
        -- Красим выбранную
        btn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    end)
    
    yPos = yPos + 40
end

-- Кнопка загрузки
local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(0, 280, 0, 40)
loadBtn.Position = UDim2.new(0, 10, 1, -60)
loadBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
loadBtn.BorderSizePixel = 0
loadBtn.Text = "LOAD SCRIPT"
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.Font = Enum.Font.Code
loadBtn.TextSize = 16
loadBtn.Parent = mainFrame

-- Уведомления (сверху)
local function notify(text)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 250, 0, 30)
    notif.Position = UDim2.new(1, -260, 0, 10) -- Правый верх
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.Text = text
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Font = Enum.Font.Code
    notif.TextSize = 14
    notif.Parent = screenGui
    
    task.delay(3, function()
        notif:Destroy()
    end)
end

-- ==========================================
-- ЛОГИКА ЗАГРУЗКИ
-- ==========================================
loadBtn.MouseButton1Click:Connect(function()
    local c = selectedCheat
    if not c then return end

    -- Скрываем меню
    screenGui.Enabled = false

    if c.fflags and setfflag then
        for k, v in pairs(c.fflags) do
            pcall(setfflag, k, v)
        end
    end
    
    notify("Loading: " .. c.name)
    
    local src = http(c.url)
    local fn, err = loadstring(src)
    if not fn then
        notify("Compile fail!")
        print("[tHUB] Compile fail: " .. tostring(err))
        screenGui.Enabled = true
        return
    end
    
    local ok, runErr = pcall(fn)
    if not ok then
        notify("Runtime error!")
        print("[tHUB] Runtime err: " .. tostring(runErr))
        screenGui.Enabled = true
    else
        notify("Loaded: " .. c.name)
        print("[tHUB] Successfully loaded: " .. c.name)
    end
end)
