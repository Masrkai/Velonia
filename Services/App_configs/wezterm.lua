-- WezTerm configuration inspired by Ghostty
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration (Ghostty uses clean, modern fonts)
config.font = wezterm.font 'Iosevka Nerd Font'
config.font_size = 14.0
-- config.freetype_load_target = 'Normal'
-- config.freetype_render_target = 'HorizontalLcd'

-- Color scheme - Ghostty's default dark theme
config.color_scheme = 'Tokyo Night'

-- Tab bar styling (Ghostty-like minimal tabs)
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false

config.colors = {
  tab_bar = {
    background = '#1a1b26',
    active_tab = {
      bg_color = '#7aa2f7',
      fg_color = '#1a1b26',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#24283b',
      fg_color = '#787c99',
    },
    inactive_tab_hover = {
      bg_color = '#414868',
      fg_color = '#c0caf5',
    },
  },
}

-- Performance optimizations (Ghostty is known for speed)
config.enable_wayland = true
-- config.front_end = 'Software'
config.front_end = 'OpenGL'
-- config.front_end = 'WebGpu'

config.max_fps = 60
config.animation_fps = 60

-- Cursor styling
-- config.default_cursor_style = 'SteadyBar'
-- config.default_cursor_style = 'BlinkingBar'
config.default_cursor_style = 'BlinkingUnderline'

config.cursor_blink_rate = 500
config.cursor_thickness = 5

-- Scrollback
config.scrollback_lines = 10000

-- Window behavior
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = true
config.window_background_opacity = 0.8
config.text_background_opacity = 1.0

-- Tab title formatting
-- config.tab_max_width = 32
-- wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
--   local title = tab.active_pane.title
--   if title and #title > 0 and title ~= 'bash' and title ~= 'zsh' and title ~= 'fish' then
--     return ' ' .. title .. ' '
--   end
--   return ' ' .. (tab.tab_index + 1) .. ' '
-- end)

-- Key bindings (Ghostty-inspired)
config.keys = {
  -- Tab navigation
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
  { key = 'LeftArrow', mods = 'SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'SHIFT', action = wezterm.action.ActivateTabRelative(1) },

  -- Pane navigation
  { key = '}', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '{', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = false } },


  -- Font size
  { key = '+', mods = 'CTRL|SHIFT', action = wezterm.action.IncreaseFontSize },
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },

  -- Copy/Paste
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },

  -- Search
  { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
}

-- Mouse bindings
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- Hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Disable annoying default behaviors
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

return config