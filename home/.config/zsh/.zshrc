# Init homebrew
case $(uname) in
	Linux)
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		;;
	Darwin)
		if [[ $(uname -m) -eq arm64  ]]; then
			eval "$(/opt/homebrew/bin/brew shellenv)"
		else if [[ $(uname -m) -eq arm64  ]]
			return 1 # TODO: use intel mac path here
		fi
		;;
esac

# Completions dir
fpath=($fpath "$ZDOTDIR/completions")

# Zap setup
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

plug "zap-zsh/supercharge" # Set basic zsh options to sensible defaults
setopt INC_APPEND_HISTORY  # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY       # Share history between all sessions.
unsetopt NOMATCH           # Causes problems sometimes

plug "zap-zsh/completions"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "agkozak/zsh-z"
plug "zap-zsh/vim"
plug "hlissner/zsh-autopair"
plug "MichaelAquilina/zsh-you-should-use" # Reminds of existing aliases

plug "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up # up arrow
bindkey '^[[B' history-substring-search-down # down arrow
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# Further configuration possible: https://github.com/zsh-users/zsh-history-substring-search

# Useful mv alternative
autoload zmv

# Files to source
source "$ZDOTDIR/zsh-exports"
source "$ZDOTDIR/zsh-aliases"
source "$ZDOTDIR/zsh-local-config"

# Starship prompt
eval "$(starship init zsh)"

# Open zellij when opening shell
eval "$(zellij setup --generate-auto-start zsh)"
