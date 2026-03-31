if status is-interactive
    set -g fish_greeting

    fish_vi_key_bindings insert
    set -g fish_cursor_insert block

    set -g __prompt_cmd_duration_ms 0

    function __prompt_cmd_timer_start --on-event fish_preexec
        set -g __prompt_cmd_started_at_ms (date +%s%3N)
    end

    function __prompt_cmd_timer_stop --on-event fish_postexec
        if set -q __prompt_cmd_started_at_ms
            set -l end_ms (date +%s%3N)
            set -g __prompt_cmd_duration_ms (math $end_ms - $__prompt_cmd_started_at_ms)
            set -e __prompt_cmd_started_at_ms
        end
    end

    if type -q starship
        starship init fish | source

        function fish_right_prompt
            switch "$fish_key_bindings"
                case fish_hybrid_key_bindings fish_vi_key_bindings fish_helix_keybindings
                    set STARSHIP_KEYMAP "$fish_bind_mode"
                case '*'
                    set STARSHIP_KEYMAP insert
            end

            set STARSHIP_CMD_PIPESTATUS $pipestatus
            set STARSHIP_CMD_STATUS $status

            set -l STARSHIP_DURATION $__prompt_cmd_duration_ms
            if test -z "$STARSHIP_DURATION"
                if set -q cmd_duration
                    set STARSHIP_DURATION $cmd_duration
                else if set -q CMD_DURATION
                    set STARSHIP_DURATION $CMD_DURATION
                else
                    set STARSHIP_DURATION 0
                end
            end

            __starship_set_job_count

            if contains -- --final-rendering $argv; or test "$RIGHT_TRANSIENT" = "1"
                set -g RIGHT_TRANSIENT 0
                if type -q starship_transient_rprompt_func
                    starship_transient_rprompt_func --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
                else
                    printf ""
                end
            else
                switch $fish_bind_mode
                    case default
                        set_color --bold
                        echo -n "N "
                    case visual
                        set_color --bold
                        echo -n "V "
                    case replace replace_one replace-one
                        set_color --bold
                        echo -n "R "
                end

                set_color normal

                set -l starship_duration (command starship module cmd_duration --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS | string collect)

                if test -n "$starship_duration"
                    printf "%s" "$starship_duration"
                end

                command starship prompt --right --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
            end
        end
    else
        fish_config prompt choose scales >/dev/null
    end
end

# removes the mapping <C-t> which is being used to close the terminal in NeoVim
bind --erase --all \ct

# fish is aware of the paths set by brew:
# to ensure that brew paths are recognized inside fish, run:
#    /opt/brew/bin/brew shellenv >> ~/.config/fish/config.fish 

# Initialize zoxide
if type -q zoxide
    zoxide init fish --cmd cd | source
end

# set nvim as default editor
set -gx EDITOR nvim
set -gx VISUAL nvim
# CUDA Configuration (only if installed)
if test -d /usr/local/cuda
    # Use the highest version found, or a specific path like /usr/local/cuda-12.8
    set -l cuda_path /usr/local/cuda
    if test -d /usr/local/cuda-12.8
        set cuda_path /usr/local/cuda-12.8
    end
    set -gx CUDA_HOME $cuda_path
    set -gx CUDA_PATH $cuda_path
    fish_add_path $cuda_path/bin
    set -gx LD_LIBRARY_PATH $cuda_path/lib64 $LD_LIBRARY_PATH
end

# User bin directories (only if installed)
for path_dir in $HOME/.fzf/bin $HOME/.local/bin $HOME/.juliaup/bin $HOME/.opencode/bin $HOME/bin
    if test -d $path_dir
        fish_add_path $path_dir
    end
end

# Use portal for file picker
set -gx GTK_USE_PORTAL 1

set -l lazygit_config_home $HOME/.config
if set -q XDG_CONFIG_HOME
    set lazygit_config_home $XDG_CONFIG_HOME
end
set -gx LG_CONFIG_FILE "$lazygit_config_home/lazygit/config.yml,$lazygit_config_home/lazygit/theme.yml"

# Sync GUI/session environment from systemd user manager.
# This keeps long-lived shells (tmux/resurrect) aligned with the active X11 session.
if status is-interactive
    if type -q systemctl
        for entry in (systemctl --user show-environment 2>/dev/null)
            switch $entry
                case 'DISPLAY=*'
                    set -gx DISPLAY (string sub -s 9 -- $entry)
                case 'XAUTHORITY=*'
                    set -gx XAUTHORITY (string sub -s 12 -- $entry)
                case 'DBUS_SESSION_BUS_ADDRESS=*'
                    set -gx DBUS_SESSION_BUS_ADDRESS (string sub -s 26 -- $entry)
                case 'XDG_RUNTIME_DIR=*'
                    set -gx XDG_RUNTIME_DIR (string sub -s 17 -- $entry)
                case 'XDG_SESSION_TYPE=*'
                    set -gx XDG_SESSION_TYPE (string sub -s 18 -- $entry)
                case 'XDG_CURRENT_DESKTOP=*'
                    set -gx XDG_CURRENT_DESKTOP (string sub -s 21 -- $entry)
                case 'I3SOCK=*'
                    set -gx I3SOCK (string sub -s 8 -- $entry)
            end
        end
    end

    # Also refresh tmux server env for new panes/windows.
    if set -q TMUX
        for key in DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR XDG_SESSION_TYPE XDG_CURRENT_DESKTOP I3SOCK
            if set -q $key
                tmux set-environment -g $key $$key >/dev/null 2>&1
            end
        end
    end
end

# Machine-local overrides (optional):
# Put personal env vars, tokens, cloud project IDs, etc. in
# ~/.config/fish/local.fish so this public repo stays portable.
set -l fish_local_config "$HOME/.config/fish/local.fish"
if test -f "$fish_local_config"
    source "$fish_local_config"
end
