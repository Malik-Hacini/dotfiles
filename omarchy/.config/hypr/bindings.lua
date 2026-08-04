-- Keep Omarchy's complete default keymap and layer only the personal i3 app
-- shortcuts on top. Existing actions on these exact keys are unbound first.

hl.unbind("SUPER + G") -- Was: toggle window grouping.
hl.unbind("SUPER + O") -- Was: pop window out.
hl.unbind("SUPER + T") -- Was: toggle window floating/tiling.
hl.unbind("SUPER + P") -- Was: pseudo window.
hl.unbind("SUPER + SLASH") -- Was: monitor scaling up.

o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + Z", "Zen Browser", "omarchy launch browser")
o.bind("SUPER + N", "Neovim", "omarchy launch tui nvim")
o.bind("SUPER + G", "Lazygit", "omarchy launch tui lazygit")
o.bind("SUPER + O", "OpenCode", "omarchy launch tui opencode")
o.bind("SUPER + D", "Application launcher", "omarchy menu toggle apps")
o.bind("SUPER + T", "Tmux session picker", "rofi-tmux-sessions")
o.bind("SUPER + P", "Power menu", "omarchy menu toggle system")
o.bind("SUPER + SLASH", "Personal keybinding cheatsheet", "rofi-cheatsheet")
