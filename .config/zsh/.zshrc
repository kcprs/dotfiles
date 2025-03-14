# Init homebrew
case $(uname) in
    Linux)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ;;
    Darwin)
        if [[ $(uname -m) -eq "arm64"  ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        return 1 # TODO: use intel mac path here
    fi
    ;;
esac

# Completions dir
fpath=($fpath "$ZDOTDIR/completions")

# Zap setup
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

export VI_MODE_ESC_INSERT="jk" && plug "zap-zsh/vim" # Should be sourced first because otherwise it overwrites previously set keybinds

plug "zap-zsh/supercharge" # Set basic zsh options to sensible defaults
bindkey -r '^x'            # Set by supercharge but I don't want it
setopt INC_APPEND_HISTORY  # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY       # Share history between all sessions.
unsetopt NOMATCH           # Causes problems sometimes
unsetopt AUTO_CD           # Problematic when a dir shares a name with a command

plug "zap-zsh/completions"
plug "zsh-users/zsh-autosuggestions" && bindkey '^y' autosuggest-accept
plug "hlissner/zsh-autopair"
plug "MichaelAquilina/zsh-you-should-use" # Reminds of existing aliases

# Other config files to source
source "$ZDOTDIR/zsh-exports"
source "$ZDOTDIR/zsh-aliases"
source "$ZDOTDIR/zsh-keybinds"

# Init tools
eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(direnv hook zsh)"
# eval "$(zellij setup --generate-auto-start zsh)" # Open zellij when opening shell

plug "zsh-users/zsh-syntax-highlighting" # Should be sourced at the end of the .zshrc file
