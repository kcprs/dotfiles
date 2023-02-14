# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set up history
HISTFILE=$HOME/zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history hist_ignore_dups
 
# some useful options (man zshoptions)
setopt auto_cd extended_glob nomatch menu_complete interactive_comments correct correct_all # no_nomatch
# zle_highlight=('paste:none')
 
# beeping is annoying
setopt no_beep
 
# completions
# zmodload zsh/complist # Must be loaded before call to compinit?
autoload -U compinit && compinit
zstyle ':completion:*' menu select # Enable completions via menu
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' # Fall back to case-insensitive matches
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' # Fall back to partial matches
_comp_options+=(globdots)		# Include hidden files in completions
#
# 
# autoload -U up-line-or-beginning-search
# autoload -U down-line-or-beginning-search
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search
# 
# # Colors
# autoload -Uz colors && colors

# Useful Functions
source "$ZDOTDIR/zsh-functions"
 
# Normal files to source
zsh_add_file "zsh-exports"
zsh_add_file "zsh-aliases"
zsh_add_file "zsh-vim-mode"
# zsh_add_file "zsh-prompt" # unused - using p10k instead
 
 
# Key-bindings
bindkey '^R' history-incremental-search-backward 
# bindkey -s '^o' 'ranger^M'
# bindkey -s '^f' 'zi^M'
# bindkey -s '^s' 'ncdu^M'
# # bindkey -s '^n' 'nvim $(fzf)^M'
# # bindkey -s '^v' 'nvim\n'
# bindkey -s '^z' 'zi^M'
# bindkey '^[[P' delete-char
# bindkey "^p" up-line-or-beginning-search # Up
# bindkey "^n" down-line-or-beginning-search # Down
# bindkey "^k" up-line-or-beginning-search # Up
# bindkey "^j" down-line-or-beginning-search # Down
# bindkey -r "^u"
# bindkey -r "^d"

# # FZF 
# # TODO update for mac
# [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
# [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
# [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
# [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# [ -f $ZDOTDIR/completion/_fnm ] && fpath+="$ZDOTDIR/completion/"
# # export FZF_DEFAULT_COMMAND='rg --hidden -l ""'
# compinit
# 
# # Edit line in vim with ctrl-e:
# autoload edit-command-line; zle -N edit-command-line
# # bindkey '^e' edit-command-line
 
# # Environment variables set everywhere
export EDITOR="$(command -v nvim 2>/dev/null || command -v vim)"
export VISUAL="$EDITOR"
# export TERMINAL="alacritty"
# export BROWSER="brave"

# Plugins
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "hlissner/zsh-autopair"
zsh_add_plugin "agkozak/zsh-z"
zsh_add_plugin "romkatv/powerlevel10k"
# zsh_add_completion "esc/conda-zsh-completion" false
# For more plugins: https://github.com/unixorn/awesome-zsh-plugins
# More completions https://github.com/zsh-users/zsh-completions
 
# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
