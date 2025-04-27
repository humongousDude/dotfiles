local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.window_background_opacity = 0.7
config.text_background_opacity = 0.5
config.enable_tab_bar = false
config.window_close_confirmation = 'NeverPrompt'

config.font = wezterm.font 'MonaspaceNeon'
-- for Monaspace
config.harfbuzz_features = { "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "calt", "dlig" }

-- 00112233445566778899 The quick brown fox jumps over the lazy cow or whatever that quote was I don't remember lol

return config
