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
    fi
}

setup_tools() {
    title "Setting up tools"

    if test ! "$(command -v brew)"; then
        info "Homebrew not installed. Quitting."
        return
    fi

    brew tap homebrew/cask-fonts
    brew install --cask font-jetbrains-mono-nerd-font

    brew install clang-format cmake deno doxygen git git-lfs graphviz llvm neovim ninja python ripgrep sox tmux tree tree-sitter watch wget

    brew install alacritty
    xattr -d com.apple.quarantine /Applications/Alacritty.app

    curl https://sh.rustup.rs -sSf | sh
}

case "$1" in
    # backup)
    #     backup
    #     ;;
    link)
        setup_symlinks
        ;;
    # git)
    #     setup_git
    #     ;;
    homebrew)
        setup_homebrew
        ;;
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
        echo -e $"\nUsage: $(basename "$0") {backup|link|git|homebrew|shell|terminfo|macos|all}\n"
        exit 1
        ;;
esac
