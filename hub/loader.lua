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

-- Выпадающий список (1 = левая колонка)
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

-- Кнопка загрузки (2 = правая колонка)
local loadButton = tab:addToggle({
    text = "Load Script",
    default = false,
    risky = true,
    flag = "btn_load"
}, 2)

loadButton.flag:OnChanged(function(state)
    if not state then return end
    local c = selectedCheat
    if not c then return end

    loadButton:setValue(false)

    if c.fflags and setfflag then
        for k, v in pairs(c.fflags) do
            pcall(setfflag, k, v)
        end
    end
    
    local src = http(c.url)
    local fn, err = loadstring(src)
    if not fn then
        window:notify("Compile fail: " .. tostring(err), 3)
        return
    end
    
    local ok, runErr = pcall(fn)
    if not ok then
        window:notify("Runtime err: " .. tostring(runErr), 3)
    else
        window:notify("Loaded: " .. c.name, 3)
    end
end)
