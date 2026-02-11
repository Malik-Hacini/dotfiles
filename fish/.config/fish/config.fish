if status is-interactive
    # Commands to run in interactive sessions can go here
end

# removes the mapping <C-t> which is being used to close the terminal in NeoVim
bind --erase --all \ct

# fish is aware of the paths set by brew:
# to ensure that brew paths are recognized inside fish, run:
#    /opt/brew/bin/brew shellenv >> ~/.config/fish/config.fish 

fish_config prompt choose scales

# Customize the prompt to use ->
function fish_prompt
    set -l last_status $status
    
    # Print the current directory
    set_color normal
    echo -n (prompt_pwd) 
    set_color normal
    
    # Print -> as prompt character
    echo -n " ➜ "
end

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

# opencode (only if installed)
if test -d $HOME/.opencode/bin
    fish_add_path $HOME/.opencode/bin
end

# Zen browser alias (only if installed)
if test -x $HOME/.local/opt/zen/zen
    alias zen $HOME/.local/opt/zen/zen
end

# Use portal for file picker
set -gx GTK_USE_PORTAL 1
