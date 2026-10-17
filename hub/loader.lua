local BASE = "https://raw.githubusercontent.com/rabuhin/tHUB/main/"

local function http(url)
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok then error("HTTP fail: " .. url, 0) end
    return body
end

local UI = loadstring(http(BASE .. "hub/ui.lua"))()
local config = loadstring(http(BASE .. "hub/config.lua"))()
local placeId = game.PlaceId

local available = {}
for _, cheat in ipairs(config) do
    if cheat.placeId == nil or cheat.placeId == placeId then
        table.insert(available, cheat)
    end
end

local window = UI.windowClass.new({
    title = "tHUB",
    size  = Vector2.new(600, 450),
})

local tab = window:addTab("Main")
local options = {}
for _, c in ipairs(available) do
    table.insert(options, c.name)
end

-- СИСТЕМА УВЕДОМЛЕНИЙ (GUI)
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local oldGui = CoreGui:FindFirstChild("tHUB_Notifications")
if oldGui then oldGui:Destroy() end

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "tHUB_Notifications"
notifGui.ResetOnSpawn = false
notifGui.IgnoreGuiInset = true
notifGui.Parent = CoreGui

local function notify(text, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.Position = UDim2.new(1, -210, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = notifGui

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 4, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    line.BorderSizePixel = 0
    line.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    for _, child in ipairs(notifGui:GetChildren()) do
        if child:IsA("Frame") and child ~= frame then
            local newPos = child.Position + UDim2.new(0, 0, 0, 35)
            TweenService:Create(child, TweenInfo.new(0.2), {Position = newPos}):Play()
        end
    end

    task.delay(duration, function()
        if frame and frame.Parent then
            local tween = TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            local tween2 = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1})
            local tween3 = TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            tween:Play(); tween2:Play(); tween3:Play()
            tween.Completed:Wait()
            frame:Destroy()
        end
    end)
end

-- ВЫБОР И ЗАГРУЗКА
local dropdown = tab:addDropdown({
    text    = "Select script:";
    options = options;
    flag    = "cheat_select";
}, 1)

local selectedCheat = available[1]
dropdown.flag:OnChanged(function(selected)
    for _, c in ipairs(available) do
        if c.name == selected then
            selectedCheat = c
            break
        end
    end
end)

local loadButton = tab:addToggle({
    text = "Load Script",
    default = false,
    risky = true,
    flag = "btn_load"
}, 1)

loadButton.flag:OnChanged(function(state)
    if not state then return end
    loadButton:setValue(false)

    local c = selectedCheat
    if not c then return end

    -- СКРЫВАЕМ МЕНЮ ХАБА
    window:toggle(false)

    if c.fflags and setfflag then
        for k, v in pairs(c.fflags) do
            pcall(setfflag, k, v)
        end
    end
    
    local src = http(c.url)
    local fn, err = loadstring(src)
    if not fn then
        notify("Compile fail!", 4)
        print("[tHUB] Compile fail: " .. tostring(err))
        return
    end
    
    local ok, runErr = pcall(fn)
    if not ok then
        notify("Runtime error!", 4)
        print("[tHUB] Runtime err: " .. tostring(runErr))
    else
        notify("Loaded: " .. c.name, 3)
        print("[tHUB] Successfully loaded: " .. c.name)
    end
end)
