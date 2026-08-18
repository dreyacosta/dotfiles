-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- to disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Close the active window with CTRL+Q instead of SUPER+W.
-- hl.unbind("SUPER + W")
-- o.bind("CTRL + Q", "Close window", hl.dsp.window.close())

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("CTRL + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Open the Omarchy menu with the physical Super key, which keyd maps to Control.
o.bind("CTRL + SPACE", "Omarchy menu", "omarchy-menu toggle root")
o.bind("CTRL + Q", "Close window", hl.dsp.window.close())

-- Switch workspaces and move windows with CTRL instead of SUPER.
-- for workspace = 1, 10 do
--   local key = "code:" .. tostring(workspace + 9)
--   hl.unbind("SUPER + " .. key)
--   hl.unbind("SUPER + SHIFT + " .. key)
--   o.bind("CTRL + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
--   o.bind("CTRL + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
-- end

-- Focus windows with SUPER + H/J/K/L instead of the arrow keys.
hl.unbind("SUPER + H")
hl.unbind("SUPER + L")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))

-- Swap windows with SUPER + SHIFT + H/J/K/L instead of the arrow keys.
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + RIGHT")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")
hl.unbind("SUPER + SHIFT + H")
hl.unbind("SUPER + SHIFT + L")
hl.unbind("SUPER + SHIFT + J")
hl.unbind("SUPER + SHIFT + K")
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + J", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + K", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
