. "$HOME/.cargo/env"

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

