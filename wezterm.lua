local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- True on Windows machines only. target_triple looks like
-- "x86_64-pc-windows-msvc" on Windows, "...darwin"/"...linux" elsewhere.
local is_windows = wezterm.target_triple:find 'windows' ~= nil

--------------------------------------------------------------------------------
-- tmux-style keybindings (platform-neutral)
-- Leader = Ctrl+b, same as the tmux prefix. Workspaces stand in for sessions,
-- tabs for windows.
--------------------------------------------------------------------------------
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1500 }

config.keys = {
  -- Press Ctrl+b twice to send a literal Ctrl+b to the shell
  { key = 'b', mods = 'LEADER|CTRL', action = act.SendKey { key = 'b', mods = 'CTRL' } },

  -- Windows (tabs)
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|TABS' } },
  { key = '&', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then window:active_tab():set_title(line) end
      end),
    },
  },

  -- Panes: split in the current pane's directory, like the tmux config
  { key = '"', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '%', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'o', mods = 'LEADER', action = act.ActivatePaneDirection 'Next' },

  -- Vim-style pane navigation
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Vim-style pane resizing
  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Copy mode (vi keys by default: v to select, y to yank, Esc to cancel)
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = ']', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

  -- Sessions (workspaces): s = pick, $ = rename, S = new named session
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  {
    key = '$',
    mods = 'LEADER|SHIFT',
    action = act.PromptInputLine {
      description = 'Rename session (workspace)',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    },
  },
  {
    key = 'S',
    mods = 'LEADER|SHIFT',
    action = act.PromptInputLine {
      description = 'New session (workspace) name',
      action = wezterm.action_callback(function(window, pane, line)
        if line then window:perform_action(act.SwitchToWorkspace { name = line }, pane) end
      end),
    },
  },

  -- Reload config, same muscle memory as prefix+r in tmux
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
}

-- Leader+1..9 jumps to tab, like prefix+number in tmux
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1),
  })
end

--------------------------------------------------------------------------------
-- Windows-only settings (this file is meant to sync across machines via dotfiles)
--------------------------------------------------------------------------------
if is_windows then
  -- Start in Git Bash instead of PowerShell so unix commands are available.
  -- Full path avoids C:\Windows\System32\bash.exe, which is the WSL launcher.
  config.default_prog = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' }

  -- Make Shift+Enter insert a newline (for Claude Code etc.) instead of
  -- submitting. By default the terminal collapses it into a plain carriage
  -- return; sending ESC+CR forwards the multi-line signal instead.
  table.insert(config.keys, {
    key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString '\x1b\r',
  })
end

--------------------------------------------------------------------------------
-- Looks (platform-neutral)
--------------------------------------------------------------------------------
config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 1.0

return config
