local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
-- config.font = wezterm.font("Cascadia Code PL", { weight = "Bold" })
config.font = wezterm.font("Iosevka Term Slab", { weight = "ExtraBlack" })
config.font = wezterm.font("Iosevka Term Slab Extended", { weight = "ExtraBlack" })
config.font = wezterm.font("Iosevka Term Extended", { weight = "ExtraBlack" })
-- config.font = wezterm.font("Iosevka Term", { weight = "ExtraBlack" })
config.font_size = 12.0
config.cell_width = 0.8
config.line_height = 0.9
-- config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" } -- ligatures enabled

-- Window and UI
config.window_background_opacity = 0.75
config.win32_system_backdrop = "Auto"
config.initial_cols = 70
config.initial_rows = 20
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Shell
config.default_prog = { "tmux" }

-- Notifications
config.notification_handling = "SuppressFromFocusedWindow"

-- Clipboard
config.selection_word_boundary = " \t\n{}[]()\"'"

-- Leader key
config.leader = nil

-- Keybindings
config.disable_default_key_bindings = true
config.keys = {
	-- Font sizing
	{ key = "Equal", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "Minus", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },

	-- Opacity (Alt+/-)
	{
		key = "Minus",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = math.max(0.15, (overrides.window_background_opacity or 0.75) - 0.15)
			window:set_config_overrides(overrides)
		end),
	},
	{
		key = "Equal",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = math.min(1.0, (overrides.window_background_opacity or 0.75) + 0.15)
			window:set_config_overrides(overrides)
		end),
	},
	{
		key = "0",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = 0.75
			window:set_config_overrides(overrides)
		end),
	},

	-- Config management
	{
		key = ",",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local cmd = {
				"tmux",
				"display-popup",
				"-w",
				"80%",
				"-h",
				"80%",
				"-E",
				"hx ~/.dotfiles/.wezterm.lua",
			}
			wezterm.run_child_process(cmd)
		end),
	},
	{
		key = ",",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local cmd = {
				"tmux",
				"display-popup",
				"-w",
				"80%",
				"-h",
				"80%",
				"-E",
				"hx ~/.dotfiles/.tmux.conf && tmux source-file ~/.dotfiles/.tmux.conf && tmux display 'tmux conf reloaded!'",
			}
			wezterm.run_child_process(cmd)
		end),
	},
	{
		key = ".",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local cmd = {
				"tmux",
				"display-popup",
				"-w",
				"80%",
				"-h",
				"80%",
				"-E",
				[[
            cd $HOME/.dotfiles;
            if command -v sk >/dev/null 2>&1; then
          		fuzzy_finder=sk
            elif command -v fzf >/dev/null 2>&1; then
            	fuzzy_finder=fzf
            else
                echo "Error: Neither sk nor fzf found." >&2
            fi
            choices=$(git ls-files | $fuzzy_finder -m --tiebreak index --tac --bind="tab:toggle")
            if [ ! $? = 0 ]; then
            	exit $?
            fi
            hx "${=choices[@]}"
        ]],
			}
			wezterm.run_child_process(cmd)
		end),
	},

	-- Copy/Paste
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },

	-- Exit
	{ key = "F4", mods = "ALT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },

	-- Leader key bindings
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
}

config.hyperlink_rules = {
	-- Default URL pattern
	{
		regex = [[\b\w+://[\w.-]+\.[a-z]{2,15}\S*\b]],
		format = "$0",
	},
	-- GitHub issues/PRs
	{
		regex = [[\b#(\d+)\b]],
		format = "https://github.com/your-repo/issues/$1",
	},
	-- JIRA tickets
	{
		regex = [[\b([A-Z]+-\d+)\b]],
		format = "https://jira.example.com/browse/$1",
	},
}

return config
