source /usr/share/cachyos-fish-config/cachyos-config.fish
fish_add_path $HOME/.dotnet/tools
fnm env --use-on-cd --shell fish | source

if status is-interactive
    # Import the systemd user environment variables into the active fish session
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/keyring/ssh
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

function dotfiles
    git --git-dir=$HOME/dotfiles/.git --work-tree=$HOME $argv
end
