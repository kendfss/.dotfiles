local wez = require("wezterm")
local please = wez.action
-- local set = {}
local set = wez.config_builder()
local hook = wez.on
local font = wez.font
local clock = wez.strftime
local shell = wez.run_child_process
local bind = wez.action_callback
local resurrect = wez.plugin.require("https://github.com/kendfss/resurrect.wezterm")
local debug = true
set.default_cwd = wez.home_dir
wez = nil

local function toast(window, message)
	local time = os.date("%I:%M:%S %p")
	if type(message) ~= "string" then
		-- window:toast_notification("wezterm", message .. " - " .. os.date("%I:%M:%S %p"), nil, 1000)
		message = string.format("%s", message)
	end
	window:toast_notification("wezterm", message .. " - " .. time, nil, 1000)
	if debug then
		print(time .. message)
	end
end

-- local toasts = {}

hook("window-config-reloaded", function(window, pane)
	toast(window, "Configuration reloaded!")
end)

set.enable_scroll_bar = true
set.enable_kitty_keyboard = true
set.audible_bell = "SystemBeep"
hook("bell", function(window, pane)
	os.execute("aplay /usr/share/sounds/speech-dispatcher/test.wav 2>/dev/null &")
end)

set.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
}
set.colors = {
	visual_bell = "#202020",
}

-- Font
set.font = font("Iosevka Term Extended", { weight = "ExtraBlack" })
set.font_size = 12.0
set.cell_width = 0.8
set.line_height = 0.9
set.harfbuzz_features = { "calt=1", "clig=1", "liga=1" } -- ligatures enabled
set.tab_max_width = 8
-- Window and UI
set.window_background_opacity = 0.75
set.win32_system_backdrop = "Auto"
set.initial_cols = 70
set.initial_rows = 20
set.tab_bar_at_bottom = false
set.use_fancy_tab_bar = false
-- set.tab_max_width = 32
set.show_tab_index_in_tab_bar = true
set.show_new_tab_button_in_tab_bar = false
set.hide_tab_bar_if_only_one_tab = false
set.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Show which key table is active in the status area

hook("update-right-status", function(window, pane)
	local table = window:active_key_table()
	local path = os.getenv("HOME") .. "/.dotfiles/scripts/battery-info"
	-- Run the script directly
	local succ, out, err = shell({ path })
	-- Check if output is valid
	if succ or type(out) == "string" then
		local bat_info = " " .. out:gsub("\n", "")
		local time = os.date("%H:%M")
		local table_str = table or ""
		window:set_right_status(table_str .. " " .. bat_info .. " " .. time)
	else
		toast("update-right-status:" .. err)
		-- Handle failure gracefully
		local time = os.date("%H:%M")
		local table_str = table or ""
		window:set_right_status(table_str .. " " .. time .. " ⚡?")
	end
end)

-- Shell
set.term = "wezterm"
set.color_scheme = "rose-pine"
set.color_scheme = "Catppuccin Mocha"
-- set.default_prog = { "zsh" }
set.notification_handling = "SuppressFromFocusedWindow"
set.selection_word_boundary = " \t\n{}[]()\"'"

set.leader = nil
-- set.leader = { key = "Escape" }
-- set.disable_default_key_bindings = true
set.key_tables = {
	prefix = {
		{ key = "\\", action = please.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", action = please.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "c", action = please.SpawnCommandInNewTab({ cwd = set.default_cwd }) },
		{ key = "x", action = please.CloseCurrentPane({ confirm = false }) },
		{ key = "q", action = please.QuitApplication },
		{ key = " ", action = please.ActivateCommandPalette },
		{ key = "[", action = please.ActivateCopyMode },
		{ key = "z", action = please.TogglePaneZoomState },
		-- { key = "Delete", action = please.ActivatePaneDirection("Right") },
		{ key = "Delete", action = please.CloseCurrentTab({ confirm = false }) },
		{ key = "UpArrow", mod = "ALT", action = please.AdjustPaneSize({ "Up", 5 }) },
		{ key = "DownArrow", mod = "ALT", action = please.AdjustPaneSize({ "Down", 5 }) },
		{ key = "LeftArrow", mod = "ALT", action = please.AdjustPaneSize({ "Left", 5 }) },
		{ key = "RightArrow", mod = "ALT", action = please.AdjustPaneSize({ "Right", 5 }) },
		{ key = "UpArrow", action = please.ActivatePaneDirection("Up") },
		{ key = "DownArrow", action = please.ActivatePaneDirection("Down") },
		{ key = "LeftArrow", action = please.ActivatePaneDirection("Left") },
		{ key = "RightArrow", action = please.ActivatePaneDirection("Right") },
		{
			-- key = "Escape",
			key = "VoidSymbol",
			-- action = "PopKeyTable",
			-- action = please.PopKeyTable,
			action = bind(function(window, pane)
				-- window:pop_key_table()
				please.PopKeyTable()
				-- pane:send_text("\x1b")
				-- pane:send_text("fuck")
				-- pane:send_paste("shit")
				-- please.SendKey({ key = "Escape" })
				please.SendString("\x1b")
			end),
		},
	},
	resurrect = {
		{
			key = "s",
			action = bind(function(w, p)
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
				resurrect.window_state.save_window_action()
			end),
		},
		{
			key = "r",
			action = bind(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
					local type = string.match(id, "^([^/]+)") -- match before '/'
					id = string.match(id, "([^/]+)$") -- match after '/'
					id = string.match(id, "(.+)%..+$") -- remove file extention
					local opts = {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					}
					if type == "workspace" then
						local state = resurrect.state_manager.load_state(id, "workspace")
						resurrect.workspace_state.restore_workspace(state, opts)
					elseif type == "window" then
						local state = resurrect.state_manager.load_state(id, "window")
						resurrect.window_state.restore_window(pane:window(), state, opts)
					elseif type == "tab" then
						local state = resurrect.state_manager.load_state(id, "tab")
						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
					end
				end)
			end),
		},
	},
}

set.keys = {
	{
		-- key = "b",
		-- mods = "CTRL",
		key = "VoidSymbol",
		-- key = "Escape",
		action = please.ActivateKeyTable({ name = "prefix", one_shot = true }),
		-- action = please.ActivateKeyTable({ name = "prefix", timeout_milliseconds = 1000000 }),
	},
	{ key = "LeftArrow", mods = "CTRL", action = please.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL", action = please.ActivateTabRelative(1) },
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = please.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = please.MoveTabRelative(1) },
	-- Font sizing
	{ key = "Equal", mods = "CTRL", action = please.IncreaseFontSize },
	{ key = "Minus", mods = "CTRL", action = please.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = please.ResetFontSize },

	-- {
	-- 	key = "s",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = bind(function(window, pane)
	-- 		window:perform_action(please.SelectTextAtMouseCursor("Semantic"), pane)
	-- 		-- Now you can use Shift+Arrows to extend selection
	-- 	end),
	-- },

	-- bind -N "shift window to left" -n C-S-Left swap-window -d -t -1
	-- bind -N "shift window to right" -n C-S-Right swap-window -d -t +1
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = bind(function(window, pane)
			shell({
				"tmux",
				"swap-window",
				"-d",
				"-t",
				"+1",
			})
		end),
	},
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = bind(function(window, pane)
			shell({
				"tmux",
				"swap-window",
				"-d",
				"-t",
				"-1",
			})
		end),
	},

	-- Opacity (Alt+/-)
	{
		key = "Minus",
		mods = "ALT",
		action = bind(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = math.max(0.15, (overrides.window_background_opacity or 0.75) - 0.15)
			window:set_config_overrides(overrides)
		end),
	},
	{
		key = "Equal",
		mods = "ALT",
		action = bind(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = math.min(1.0, (overrides.window_background_opacity or 0.75) + 0.15)
			window:set_config_overrides(overrides)
		end),
	},
	{
		key = "0",
		mods = "ALT",
		action = bind(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			overrides.window_background_opacity = 0.75
			window:set_config_overrides(overrides)
		end),
	},

	-- -- set management
	-- {
	-- 	key = ",",
	-- 	mods = "CTRL",
	-- 	action = bind(function(window, pane)
	-- 		local cmd = {
	-- 			"tmux",
	-- 			"display-popup",
	-- 			"-w",
	-- 			"90%",
	-- 			"-h",
	-- 			"90%",
	-- 			"-E",
	-- 			"hx ~/.dotfiles/.wezterm.lua",
	-- 		}
	-- 		shell(cmd)
	-- 	end),
	-- },
	-- {
	-- 	key = ",",
	-- 	mods = "ALT",
	-- 	action = bind(function(window, pane)
	-- 		local cmd = {
	-- 			"tmux",
	-- 			"display-popup",
	-- 			"-w",
	-- 			"90%",
	-- 			"-h",
	-- 			"90%",
	-- 			"-E",
	-- 			"hx ~/.dotfiles/.tmux.conf && tmux source-file ~/.dotfiles/.tmux.conf && tmux display 'tmux conf reloaded!'",
	-- 		}
	-- 		shell(cmd)
	-- 	end),
	-- },
	-- {
	-- 	key = ".",
	-- 	mods = "ALT",
	-- 	action = bind(function(window, pane)
	-- 		local cmd = {
	-- 			"tmux",
	-- 			"display-popup",
	-- 			"-w",
	-- 			"90%",
	-- 			"-h",
	-- 			"90%",
	-- 			"-E",
	-- 			[[
	--            cd $HOME/.dotfiles;
	--            if command -v sk >/dev/null 2>&1; then
	--          		fuzzy_finder=sk
	--            elif command -v fzf >/dev/null 2>&1; then
	--            	fuzzy_finder=fzf
	--            else
	--                echo "Error: Neither sk nor fzf found." >&2
	--            fi
	--            choices=$(git ls-files | $fuzzy_finder -m --tiebreak index --tac --bind="tab:toggle")
	--            if [ ! $? = 0 ]; then
	--            	exit $?
	--            fi
	--            hx "${=choices[@]}"
	--        ]],
	-- 		}
	-- 		shell(cmd)
	-- 	end),
	-- },

	-- Copy/Paste
	{ key = "c", mods = "CTRL|SHIFT", action = please.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = please.PasteFrom("Clipboard") },

	-- Exit
	{ key = "F4", mods = "ALT", action = please.CloseCurrentTab({ confirm = false }) },
}

for i = 1, 9 do
	table.insert(set.key_tables.prefix, {
		key = tostring(i),
		action = please.ActivateTab(i - 1),
	})
	table.insert(set.key_tables.prefix, {
		key = tostring(i),
		mods = "ALT",
		action = please.ActivateWindow(i - 1),
	})
end

set.hyperlink_rules = {
	-- Default URL pattern
	{
		regex = [[\b\w+(-\w+)*://[\w.-]+(\.[a-z]{2,15})?\S*\b]],
		format = "$0",
	},
}

set.mouse_bindings = {
	-- Alt + Left Mouse to start selection
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "ALT",
		action = please.CompleteSelection("Clipboard"),
	},
}

-- set.mouse_bindings = {
-- 	{
-- 		event = { Drag = { streak = 1, button = "Left" } },
-- 		mods = "ALT",
-- 		action = please.SelectTextAtMouseCursor("Block"),
-- 	},
-- 	{
-- 		event = { Up = { streak = 1, button = "Left" } },
-- 		mods = "ALT",
-- 		action = please.CompleteSelection("Clipboard"),
-- 	},
-- }

return set
