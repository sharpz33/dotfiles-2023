local wezterm = require("wezterm")

config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disable the title bar but enable the resizable border
	default_cursor_style = "BlinkingBar",
	color_scheme = "Nord (Gogh)",
	font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
	font_size = 12.5,
	background = {
		{
			source = {
				--		    File = "/Users/e-uzoi/Documents/wallpapers/wp13952755-4k-akira-wallpapers.jpg",
				File = "/Users/e-uzoi/Pictures/export/2025.01.25 - karkonosze_srgb_100/IMG_0386-2024_sRGB_80 invert.jpg",
			},
			hsb = {
				hue = 1.0,
				saturation = 0.02,
				brightness = 0.15,
			},
			width = "100%",
			height = "100%",
		},
		{
			source = {
				Color = "#282c35",
			},
			width = "100%",
			height = "100%",
			opacity = 0.55,
		},
	},
	window_padding = {
		left = 3,
		right = 3,
		top = 0,
		bottom = 0,
	},
}

return config
