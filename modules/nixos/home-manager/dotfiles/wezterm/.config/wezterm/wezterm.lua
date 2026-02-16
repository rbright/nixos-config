local wezterm = require("wezterm")

local config = wezterm.config_builder and wezterm.config_builder() or {}
local home = os.getenv("HOME")
if not home or home == "" then
    home = "/home/" .. (os.getenv("USER") or "rbright")
end
local nu_bin = home .. "/.nix-profile/bin/nu"

local function file_exists(path)
    local file = io.open(path, "r")

    if file then
        file:close()
        return true
    end

    return false
end

if file_exists(nu_bin) then
    config.default_prog = { nu_bin }
else
    config.default_prog = { "zsh", "-l" }
end

config.alternate_buffer_wheel_scroll_speed = 1
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font Mono",
    "JetBrains Mono",
})
config.font_size = 14.0
config.harfbuzz_features = { "ss01", "ss05", "dlig" }
config.default_cursor_style = "BlinkingBlock"
config.hide_mouse_cursor_when_typing = true
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 1000000
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.tab_bar_at_bottom = false
config.use_dead_keys = false
config.use_fancy_tab_bar = false
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = "RESIZE"

local keys = {
    -- Preserve Meta+Enter semantics so terminal apps can map it to newline actions.
    { key = "Enter", mods = "ALT",   action = wezterm.action.SendString("\x1b\r") },
    { key = "Enter", mods = "SUPER", action = wezterm.action.SendString("\x1b\r") },
}

config.keys = keys

return config
