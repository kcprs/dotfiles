#!/usr/bin/env bash

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
	echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
	echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
	echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
	exit 1
}

warning() {
	echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
	echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
	echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

tilde_path() {
	local var=$1
	echo "~${var#"$HOME"}"
}

get_linkables() {
	local home="$DOTFILES"/home
	find -H "$home" -maxdepth 1 -regex "$home/.*"
}

setup_symlinks() {
	title "Creating symlinks"

	for file in $(get_linkables); do
		target="$HOME/$(basename "$file")"
		if [ -e "$target" ]; then
			info "$(tilde_path "$target") already exists... Skipping."
		else
			info "Linking $(tilde_path "$target") to $(tilde_path "$file")"
			ln -s "$file" "$target"
		fi
	done
}

setup_homebrew() {
	title "Setting up Homebrew"

	if test ! "$(command -v brew)"; then
		info "Homebrew not installed. Installing."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		case $(uname) in
		Linux)
			brewpath="/home/linuxbrew/.linuxbrew/bin/brew "
			;;

		Darwin)
			if [[ $(uname -m) == "arm64" ]]; then
				brewpath="/opt/homebrew/bin/brew"
			else
				return 1 # TODO: set intel mac path here
			fi
			;;

		*)
			error "Unknown platform. Exiting."
			exit 1
			;;

		esac

		(
			echo
			echo "eval \"\$($brewpath shellenv)\""
		) >>$HOME/.profile
		eval "$($brewpath shellenv)"
	fi
}

get_os() {
	if [[ $(uname -r) == *"WSL"* ]]; then
		echo "w"
		return
	fi
	if [[ $(uname) == "Linux" ]]; then
		echo "l"
		return
	fi
	if [[ $(uname) == "Darwin" ]]; then
		echo "m"
		return
	fi
}

filter_by_os() {
	local -n dict=$1
	local os=$2
	local -a to_install=()
	for i in "${!dict[@]}"; do
		if [[ "${dict[$i]}" == *"$os"* ]]; then
			to_install+=("$i")
		fi
	done
	echo "${to_install[@]}"
}

setup_tools() {
	title "Setting up tools"

	if test ! "$(command -v brew)"; then
		info "Homebrew not installed. Quitting."
		return
	fi

	local os=$(get_os)

	local -Ar formulae=(
		["alacritty"]="lm"
		["clang-format"]="lmw"
		["cmake"]="lmw"
		["deno"]="lmw"
		["doxygen"]="lmw"
		["git"]="lmw"
		["git-lfs"]="lmw"
		["gnu-sed"]="m"
		["graphviz"]="lmw"
		["htop"]="lmw"
		["llvm"]="lmw"
		["neovim"]="lmw"
		["ninja"]="lmw"
		["python"]="lmw"
		["ripgrep"]="lmw"
		["sox"]="lmw"
		["starship"]="lmw"
		["tmux"]="lmw"
		["tree"]="lmw"
		["tree-sitter"]="lmw"
		["watch"]="lmw"
		["wget"]="lmw"
		["zsh"]="lw"
	)

	ulimit -n $(ulimit -Hn) # See: https://github.com/Homebrew/brew/issues/9120#issuecomment-726699074 - this persists for current shell only
	brew install $(filter_by_os formulae $os)

	# MacOS only
	if [[ "$os" == "m" ]]; then
		brew tap homebrew/cask-fonts
		brew install --cask font-jetbrains-mono-nerd-font neovide
		xattr -d com.apple.quarantine /Applications/Alacritty.app
		xattr -d com.apple.quarantine /Applications/Neovide.app
	fi

	# Linux only
	if [[ "$os" == "l" || "$os" == "w" ]]; then
		command -v zsh | sudo tee -a /etc/shells
		chsh -s $(which zsh)
	fi

	# Git setup
	git lfs install
	git config --global core.excludesfile ~/.gitignore_global
	git config --global pull.rebase true
	git config --global fetch.rebase true
	git config --global init.defaultBranch main

	# Rust
	curl https://sh.rustup.rs -sSf | sh

	# AstroNvim
	git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

	# Zap plugin manager for zsh
	zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
	rm ~/.config/zsh/.zshrc
	mv ~/.config/zsh/.zshrc_* ~/.config/zsh/.zshrc # Restore config overwritten by Zap

	info "Tools installed. It's recommended to reboot your machine now."
}

case "$1" in
link)
	setup_symlinks
	;;
homebrew)
	setup_homebrew
	;;
tools)
	setup_tools
	;;
# git)
#     setup_git
#     ;;
# backup)
#     backup
#     ;;
# shell)
#     setup_shell
#     ;;
# terminfo)
#     setup_terminfo
#     ;;
# macos)
#     setup_macos
#     ;;
# catppuccin)
#     fetch_catppuccin_theme
#     ;;
# all)
#     setup_symlinks
#     setup_terminfo
#     setup_homebrew
#     setup_shell
#     setup_git
#     setup_macos
#     ;;
*)
	echo -e $"\nUsage: $(basename "$0") {link|homebrew|tools}\n"
	exit 1
	;;
esac
