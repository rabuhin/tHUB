local BASE = "https://raw.githubusercontent.com/rabuhin/tHUB/main/"

local function http(url)
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok then error("HTTP fail: " .. url, 0) end
    return body
end

local UI = loadstring(http(BASE .. "hub/ui.lua"))()

if not Drawing then
    loadstring(http(BASE .. "cheats/trident-survival/drawingfix.lua"))()
end

local espLibrary = loadstring(http(BASE .. "cheats/trident-survival/espLibrary.lua"))()

local settings = { box = true, name = true, distance = true, healthbar = true, weapon = true }
local playerCache = {}

-- ==========================================
-- СОЗДАЕМ МЕНЮ ДЛЯ ЧИТА (ОНО ЗАМЕНИТ ХАБ)
-- ==========================================
local cheatWindow = UI.windowClass.new({
    title = "Trident ESP",
    size  = Vector2.new(450, 400),
})
local mainTab = cheatWindow:addTab("Settings")

local toggleBox = mainTab:addToggle({ text = "Show Box", default = settings.box }, 1)
toggleBox.flag:OnChanged(function(val) settings.box = val end)

local toggleName = mainTab:addToggle({ text = "Show Name", default = settings.name }, 1)
toggleName.flag:OnChanged(function(val) settings.name = val end)

local toggleDist = mainTab:addToggle({ text = "Show Distance", default = settings.distance }, 1)
toggleDist.flag:OnChanged(function(val) settings.distance = val end)

local toggleHealth = mainTab:addToggle({ text = "Show Health", default = settings.healthbar }, 1)
toggleHealth.flag:OnChanged(function(val) settings.healthbar = val end)

local toggleWeapon = mainTab:addToggle({ text = "Show Weapon", default = settings.weapon }, 1)
toggleWeapon.flag:OnChanged(function(val) settings.weapon = val end)

-- ==========================================
-- ЛОГИКА ОТРИСОВКИ ESP
-- ==========================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        
        if not playerCache[plr] then
            local ok, esp = pcall(espLibrary.playerESP.new, plr)
            if ok then playerCache[plr] = esp end
        end
        
        local esp = playerCache[plr]
        if esp and esp.current then
            pcall(esp.loop, esp, settings)
        end
    end
end)
