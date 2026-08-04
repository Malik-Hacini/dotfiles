-- Keep Omarchy's complete default keymap and layer only the personal i3 app
-- shortcuts on top. Existing actions on these exact keys are unbound first.

hl.unbind("SUPER + G") -- Was: toggle window grouping.
hl.unbind("SUPER + O") -- Was: pop window out.
hl.unbind("SUPER + T") -- Was: toggle window floating/tiling.
hl.unbind("SUPER + P") -- Was: pseudo window.
hl.unbind("SUPER + SLASH") -- Was: monitor scaling up.
hl.unbind("SUPER + J") -- Was: toggle window split.
hl.unbind("SUPER + K") -- Was: show key bindings.
hl.unbind("SUPER + L") -- Was: toggle workspace layout.
hl.unbind("ALT + TAB") -- Let applications such as tmux receive Alt+Tab.

o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + Z", "Zen Browser", "omarchy launch browser")
o.bind("SUPER + N", "Neovim", "omarchy launch tui nvim")
o.bind("SUPER + G", "Lazygit", "omarchy launch tui lazygit")
o.bind("SUPER + O", "OpenCode", "omarchy launch tui opencode")
o.bind("SUPER + D", "Application launcher", "omarchy menu toggle apps")
o.bind("SUPER + T", "Tmux session picker", "rofi-tmux-sessions")
o.bind("SUPER + P", "Power menu", "omarchy menu toggle system")
o.bind("SUPER + SLASH", "Personal keybinding cheatsheet", "rofi-cheatsheet")
o.bind("SUPER + H", "Focus left or previous grouped window", function()
  local window = hl.get_active_window()
  if window and window.group and window.group.current_index > 1 then
    hl.dispatch(hl.dsp.group.prev({ window = window }))
  else
    hl.dispatch(hl.dsp.focus({ direction = "l" }))
  end
end)
o.bind("SUPER + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus right or next grouped window", function()
  local window = hl.get_active_window()
  if window and window.group and window.group.current_index < window.group.size then
    hl.dispatch(hl.dsp.group.next({ window = window }))
  else
    hl.dispatch(hl.dsp.focus({ direction = "r" }))
  end
end)
