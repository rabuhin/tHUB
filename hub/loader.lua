local BASE = "https://raw.githubusercontent.com/rabuhin/tHUB/main/"

local function http(url)
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok then
        error("HTTP fail: " .. url, 0)
    end
    return body
end

-- загружаем список читов
local config = loadstring(http(BASE .. "hub/config.lua"))()
local placeId = game.PlaceId

-- фильтруем: universal + тот чит, что подходит под этот плейс
local available = {}
for _, cheat in ipairs(config) do
    if cheat.placeId == nil or cheat.placeId == placeId then
        table.insert(available, cheat)
    end
end

-- загружаем UI
local Rayfield = loadstring(http(BASE .. "hub/ui.lua"))()

-- создаём окно
Rayfield:CreateWindow({
    Name = "tHUB",
    LoadingTitle = "tHUB",
    LoadingSubtitle = "by rabuhin",
})

-- выпадающий список с читами
local options = {}
for _, c in ipairs(available) do
    table.insert(options, c.name)
end

Rayfield:CreateDropdown({
    Name = "Выбери чит",
    Options = options,
    CurrentOption = {},
    Flag = "cheat_select",
    Callback = function(selected)
        for _, c in ipairs(available) do
            if c.name == selected then
                if c.fflags and setfflag then
                    for k, v in pairs(c.fflags) do
                        pcall(setfflag, k, v)
                    end
                end
                local src = http(c.url)
                local fn, err = loadstring(src)
                if not fn then
                    warn("compile fail: " .. tostring(err))
                    return
                end
                local ok, runErr = pcall(fn)
                if not ok then
                    warn("runtime: " .. tostring(runErr))
                end
            end
        end
    end,
})
