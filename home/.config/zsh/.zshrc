# Zap setup
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"
plug "zap-zsh/supercharge" #  Sets basic zsh options to sensible defaults
plug "zap-zsh/completions"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "agkozak/zsh-z"
plug "zap-zsh/vim"
plug "hlissner/zsh-autopair"
 
plug "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# Further configuration possible: https://github.com/zsh-users/zsh-history-substring-search

# Files to source
source "$ZDOTDIR/zsh-exports"
source "$ZDOTDIR/zsh-aliases"

# Starship prompt
eval "$(starship init zsh)"

