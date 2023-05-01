. "$HOME/.cargo/env"

# Init homebrew on macOS
if [[ $(uname) -eq "Darwin" ]]; then
  if [[ $(uname -m) -eq arm64  ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else if [[ $(uname -m) -eq arm64  ]]
    return 1 # TODO: use intel mac path here
  fi
fi

