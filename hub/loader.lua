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

-- ==========================================
-- СВОЯ СИСТЕМА УВЕДОМЛЕНИЙ
-- ==========================================
local activeNotifications = {}

local function notify(text, duration)
    duration = duration or 3
    local yOffset = 50

    -- Сдвигаем все старые уведомления вниз
    for _, notif in ipairs(activeNotifications) do
        notif.bg.Position = notif.bg.Position + Vector2.new(0, 25)
        notif.line.Position = notif.line.Position + Vector2.new(0, 25)
        notif.text.Position = notif.text.Position + Vector2.new(0, 25)
    end

    -- Создаем новые элементы
    local bg = Drawing.new("Square")
    bg.Size = Vector2.new(200, 20)
    bg.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 210, yOffset)
    bg.Color = Color3.fromRGB(30, 30, 30)
    bg.Transparency = 0.5
    bg.Filled = true
    bg.Visible = true

    local line = Drawing.new("Square")
    line.Size = Vector2.new(3, 20)
    line.Position = bg.Position
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Filled = true
    line.Visible = true

    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Size = 14
    txt.Color = Color3.fromRGB(255, 255, 255)
    txt.Position = bg.Position + Vector2.new(10, 2)
    txt.Visible = true
    txt.Font = 2 -- System font

    local notif = { bg = bg, line = line, text = txt, time = tick() }
    table.insert(activeNotifications, notif)

    -- Цикл удаления
    task.spawn(function()
        while tick() - notif.time < duration do
            task.wait(0.1)
        end
        -- Удаляем графику
        bg:Remove()
        line:Remove()
        txt:Remove()
        
        -- Убираем из списка
        for i, v in ipairs(activeNotifications) do
            if v == notif then
                table.remove(activeNotifications, i)
                break
            end
        end
    end)
end

-- ==========================================
-- ЛОГИКА МЕНЮ
-- ==========================================
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
