local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rabuhin/tHUB/main/hub/ui.lua"))()
-- Уведомление без создания окна
local dummy = UI.windowClass.new({ title = "", size = Vector2.new(1, 1) })
dummy:notify("Universal cheat loaded!", 5)
dummy:toggle(false) -- скрываем пустое окно
print("Universal cheat is working!")
