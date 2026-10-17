-- hub/loader.lua
local BASE = "https://raw.githubusercontent.com/rabuhin/tHUB/main/"

local function http(url)
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok then error("HTTP fail: " .. url, 0) end
    return body
end

local UI     = loadstring(http(BASE .. "hub/ui.lua"))()
local config = loadstring(http(BASE .. "hub/config.lua"))()
local placeId = game.PlaceId

local available = {}
for _, cheat in ipairs(config) do
    if cheat.placeId == nil or cheat.placeId == placeId then
        table.insert(available, cheat)
    end
end

local options = {}
for _, c in ipairs(available) do
    table.insert(options, c.name)
end

local window = UI.windowClass.new({
    title = "tHUB",
    size  = Vector2.new(600, 500),
})

local tab = window:addTab("Main")

local dropdown = tab:addDropdown({
    text    = "Выбери чит";
    options = options;
    flag    = "cheat_select";
}, 1)

dropdown.flag:OnChanged(function(selected)
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
                window:notify("compile fail: " .. tostring(err), 3)
                return
            end
            local ok, runErr = pcall(fn)
            if not ok then
                window:notify("runtime: " .. tostring(runErr), 3)
            end
        end
    end
end)
