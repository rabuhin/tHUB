local BASE = "https://raw.githubusercontent.com/rabuhin/tHUB/main/"

local function http(url)
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok then error("HTTP fail: " .. url, 0) end
    return body
end

local UI = loadstring(http(BASE .. "hub/ui.lua"))()
local dummy = UI.windowClass.new({ title = "", size = Vector2.new(1, 1) })
dummy:toggle(false)

if not Drawing then
    loadstring(http(BASE .. "cheats/trident-survival/drawingfix.lua"))()
end

local espLibrary = loadstring(http(BASE .. "cheats/trident-survival/espLibrary.lua"))()

local settings = { box = true, name = true, distance = true, healthbar = true, weapon = true }
local playerCache = {}

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

dummy:notify("Trident ESP Loaded!", 3)
