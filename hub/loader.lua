local BASE = "https://raw.githubusercontent.com/rabuhin/tHUB/main/"

local function http(url)
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok then error("HTTP fail: " .. url, 0) end
    return body
end

-- Загружаем UI и конфиг
local UI = loadstring(http(BASE .. "hub/ui.lua"))()
local config = loadstring(http(BASE .. "hub/config.lua"))()
local placeId = game.PlaceId

-- Фильтруем доступные читы
local available = {}
for _, cheat in ipairs(config) do
    if cheat.placeId == nil or cheat.placeId == placeId then
        table.insert(available, cheat)
    end
end

-- Создаём окно через наш uiLibrary
local window = UI.windowClass.new({
    title = "tHUB",
    size  = Vector2.new(600, 450),
})

local tab = window:addTab("Main")

-- Собираем названия читов для списка
local options = {}
for _, c in ipairs(available) do
    table.insert(options, c.name)
end

-- Создаём выпадающий список
local dropdown = tab:addDropdown({
    text    = "Выбери скрипт:";
    options = options;
    flag    = "cheat_select";
}, 1)

-- Событие при выборе чита из списка
dropdown.flag:OnChanged(function(selected)
    for _, c in ipairs(available) do
        if c.name == selected then
            -- Включаем FFlags, если они есть
            if c.fflags and setfflag then
                for k, v in pairs(c.fflags) do
                    pcall(setfflag, k, v)
                end
            end
            
            -- Загружаем и запускаем сам чит
            local src = http(c.url)
            local fn, err = loadstring(src)
            if not fn then
                window:notify("Ошибка компиляции: " .. tostring(err), 3)
                return
            end
            
            local ok, runErr = pcall(fn)
            if not ok then
                window:notify("Ошибка запуска: " .. tostring(runErr), 3)
            else
                window:notify("Успешно загружено: " .. c.name, 3)
            end
        end
    end
end)
