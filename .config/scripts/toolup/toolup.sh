#!/bin/bash
# Tool up the current directory. Bash 3.2 and the system Perl are sufficient on macOS.
set -Eeo pipefail
export LC_ALL=C

# ANSI palette indexes follow the terminal theme instead of Gum's fixed colors.
# Respect existing GUM_* preferences, including empty values for terminal defaults.
export GUM_CHOOSE_CURSOR_FOREGROUND=${GUM_CHOOSE_CURSOR_FOREGROUND-6}
export GUM_CHOOSE_HEADER_FOREGROUND=${GUM_CHOOSE_HEADER_FOREGROUND-4}
export GUM_CHOOSE_SELECTED_FOREGROUND=${GUM_CHOOSE_SELECTED_FOREGROUND-6}
export GUM_FILTER_INDICATOR_FOREGROUND=${GUM_FILTER_INDICATOR_FOREGROUND-6}
export GUM_FILTER_SELECTED_PREFIX_FOREGROUND=${GUM_FILTER_SELECTED_PREFIX_FOREGROUND-6}
export GUM_FILTER_UNSELECTED_PREFIX_FOREGROUND=${GUM_FILTER_UNSELECTED_PREFIX_FOREGROUND-8}
export GUM_FILTER_HEADER_FOREGROUND=${GUM_FILTER_HEADER_FOREGROUND-4}
export GUM_FILTER_MATCH_FOREGROUND=${GUM_FILTER_MATCH_FOREGROUND-6}
export GUM_FILTER_PROMPT_FOREGROUND=${GUM_FILTER_PROMPT_FOREGROUND-8}
export GUM_FILTER_PLACEHOLDER_FOREGROUND=${GUM_FILTER_PLACEHOLDER_FOREGROUND-8}
export GUM_SPIN_SPINNER_FOREGROUND=${GUM_SPIN_SPINNER_FOREGROUND-6}
export GUM_CONFIRM_PROMPT_FOREGROUND=${GUM_CONFIRM_PROMPT_FOREGROUND-4}
export GUM_CONFIRM_SELECTED_FOREGROUND=${GUM_CONFIRM_SELECTED_FOREGROUND-0}
export GUM_CONFIRM_SELECTED_BACKGROUND=${GUM_CONFIRM_SELECTED_BACKGROUND-6}
export GUM_CONFIRM_UNSELECTED_FOREGROUND=${GUM_CONFIRM_UNSELECTED_FOREGROUND-}
export GUM_CONFIRM_UNSELECTED_BACKGROUND=${GUM_CONFIRM_UNSELECTED_BACKGROUND-}

files=()
actions=()
backups=()
written=()
current_file=''
writing=no

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
require() { command -v "$1" >/dev/null || fail "$1 is required. $2"; }
exists() { [[ -e "$1" || -L "$1" ]]; }

# Hide successful command output, but retain full diagnostics and the exit status
# when generation fails
run_quietly() {
    local output status
    if output=$("$@" 2>&1); then
        return 0
    else
        status=$?
        printf '%s\n' "$output" >&2
        return "$status"
    fi
}

# Stow can expose the script through a symlink. Resolve it without changing the
# project's working directory so templates stay beside the installed script.
script_path=${BASH_SOURCE[0]}
while [[ -L "$script_path" ]]; do
    script_dir=$(cd -P "$(dirname "$script_path")" && pwd)
    script_path=$(readlink "$script_path")
    [[ "$script_path" == /* ]] || script_path="$script_dir/$script_path"
done
template_dir=$(cd -P "$(dirname "$script_path")" && pwd)/toolup-templates

# Replace literal placeholders, not shell expressions. Templates are data and
# are never sourced or evaluated; quoting and JSON encoding happen at the call site.
render_template() {
    local content
    content=$(cat "$1")
    content=${content//"$2"/"$3"}
    printf '%s\n' "$content"
}

# Failures intentionally leave partial results, including backups, for inspection.
report_failure() {
    local status=$?
    trap - ERR
    printf 'Error: failed while processing %s (exit %s).\n' "${current_file:-setup}" "$status" >&2
    if [[ "$writing" == yes ]]; then
        printf 'Files already written:\n' >&2
        if ((${#written[@]})); then printf '  %s\n' "${written[@]}" >&2; else printf '  (none)\n' >&2; fi
        [[ -z "$current_file" ]] || printf 'The failed file may contain partial results: %s\n' "$current_file" >&2
        printf 'Partial results and any backups have been left in place.\n' >&2
    fi
    exit "$status"
}
trap report_failure ERR
trap 'printf "Interrupted.\n" >&2; (exit 130); report_failure' INT TERM

require gum 'Install it with: brew install gum'
[[ $(uname -s) == Darwin ]] || fail 'This script currently supports macOS only.'
[[ ${HOME:-} == /* ]] || fail 'HOME must be an absolute path.'
project_name=${PWD##*/}
[[ -n "$project_name" ]] || fail 'Run this script in a project directory, not the filesystem root.'
build_var=$(printf '%s' "$project_name" | sed -E 's/[^[:alnum:]]+/_/g' | tr '[:lower:]' '[:upper:]')
[[ "$build_var" != [0-9]* ]] || build_var="_$build_var"
build_var="${build_var}_BUILD_DIR"

# nono accepts only alphanumeric characters and hyphens, unlike directory names.
profile_name=$(printf '%s' "$project_name" | sed -E 's/[^[:alnum:]-]+/-/g; s/^-+//; s/-+$//')
model=''
policy=$(gum choose --header 'AI policy' --selected restricted none confidential restricted public)
case "$policy" in
    none|confidential|restricted|public) ;;
    *) fail 'No valid AI policy selected.' ;;
esac

if [[ "$policy" != none ]]; then
    require opencode 'Install OpenCode v2 before configuring AI tools.'
    require nono 'Install nono before configuring AI tools.'
    require perl 'The macOS system Perl is required for JSON handling.'
    [[ -n "$profile_name" ]] || fail 'The directory name cannot be converted to a nono profile name.'
    policy_env="$HOME/.ai.$policy.envrc"
    [[ -f "$policy_env" ]] || fail "The selected AI policy file does not exist: $policy_env"
    [[ "$profile_name" == "$project_name" ]] || warn "nono profile name normalized to: $profile_name"

    # Query the CLI rather than duplicating provider/model configuration logic.
    # Keep command stdout separate from spinner UI and diagnostics so only model
    # IDs are captured, while errors remain visible and retain their exit status.
    if ! model_list=$(gum spin --title 'Loading OpenCode models…' \
        --show-stdout --show-stderr -- opencode models --standalone); then
        fail 'OpenCode model discovery failed.'
    fi
    models=()
    while IFS= read -r candidate; do
        [[ "$candidate" =~ ^[^[:space:]/]+/[^[:space:]]+$ ]] && models+=("$candidate")
    done <<< "$model_list"
    ((${#models[@]})) || fail 'OpenCode returned no usable provider/model IDs.'

    # No configured default is detected or preselected; preserve CLI list order.
    model=$(gum filter --header 'Default AI model (type to search)' --strict \
        --no-fuzzy-sort "${models[@]}")
    valid=no
    for candidate in "${models[@]}"; do [[ "$candidate" != "$model" ]] || valid=yes; done
    [[ "$valid" == yes ]] || fail 'No valid model selected.'
else
    for file in .opencode.jsonc opencode.json opencode.jsonc .opencode/opencode.json .opencode/opencode.jsonc .nono/profile.jsonc .nono/profile.schema.json; do
        if exists "$file"; then warn "Existing AI configuration will not be touched: $file"; fi
    done
    if [[ -f .envrc ]] && grep -Eq 'source_env.*\.ai\.|NONO_PROFILE' .envrc; then
        warn 'Existing .envrc contains AI settings; selected tool setup will replace it with a backup after final confirmation.'
    fi
fi

cpp=$(gum choose --header 'Set up C/C++ tools?' --selected no no yes)
python=$(gum choose --header 'Set up a Python venv?' --selected no no yes)
[[ "$cpp" == yes || "$cpp" == no ]] || fail 'No valid C/C++ answer selected.'
[[ "$python" == yes || "$python" == no ]] || fail 'No valid Python answer selected.'

# These tools are needed to use the selected configuration, even though setup
# deliberately does not build the project or activate direnv.
if [[ "$policy" != none || "$cpp" == yes || "$python" == yes ]]; then
    require direnv 'Install it with: brew install direnv'
    files+=(.envrc)
fi
if [[ "$cpp" == yes ]]; then
    require cmake 'Install it with: brew install cmake'
    require just 'Install it with: brew install just'
    files+=(.justfile .clang-tidy)
fi
if [[ "$python" == yes ]]; then require python3 'Install it with: brew install python'; fi
if [[ "$policy" != none ]]; then files+=(.opencode.jsonc .nono/profile.schema.json .nono/profile.jsonc); fi

if ((${#files[@]} == 0)); then printf 'No files to create.\n'; exit 0; fi
for file in "${files[@]}"; do
    case "$file" in
        .justfile|.clang-tidy|.opencode.jsonc)
            template="$template_dir/${file#.}"
            [[ -f "$template" && -r "$template" ]] || fail "Required template is missing or unreadable: $template"
            ;;
    esac
done
if [[ "$policy" != none ]] && exists .nono && [[ ! -d .nono || -L .nono ]]; then
    fail '.nono must be a real directory, not a file or symlink.'
fi

# Plan all replacements before the final confirmation. Backups remain siblings
# of their originals, and suffixes prevent collisions even within the same second.
timestamp=$(date +%Y%m%d-%H%M%S)
for file in "${files[@]}"; do
    action=create
    backup=''
    if exists "$file"; then
        [[ ! -d "$file" ]] || fail "A target path is a directory: $file"
        action=replace
        backup="$file.bak-$timestamp"
        suffix=1
        while exists "$backup"; do backup="$file.bak-$timestamp-$suffix"; suffix=$((suffix + 1)); done
    fi
    actions+=("$action")
    backups+=("$backup")
done
# Keep summary construction separate from styling so file paths and indentation
# remain literal, while the panel border follows the terminal's cyan palette.
summary=$(
    printf 'Project: %s\nDirectory: %s\nAI policy: %s\n' "$project_name" "$PWD" "$policy"
    [[ -z "$model" ]] || printf 'Model: %s\nnono profile name: %s\n' "$model" "$profile_name"
    printf 'C/C++ tools: %s\nPython venv: %s\n' "$cpp" "$python"
    [[ "$cpp" != yes ]] || printf 'Build variable: %s=_build\n' "$build_var"
    printf '\nFiles:\n'
    for ((i=0; i<${#files[@]}; i++)); do
        printf '  %s: %s\n' "${actions[i]}" "${files[i]}"
        if [[ -n ${backups[i]} ]]; then printf '    backup: %s\n' "${backups[i]}"; fi
    done
)
gum style --border rounded --border-foreground "${BORDER_FOREGROUND-6}" \
    --padding '1 2' --margin '1 0' "$summary"
if ! gum confirm 'Write the files listed above?' --default=true; then printf 'Cancelled. No files written.\n'; exit 0; fi

writing=yes
for ((i=0; i<${#files[@]}; i++)); do
    current_file=${files[i]}
    # Recheck paths after confirmation so newly appeared files are not overwritten.
    if [[ ${actions[i]} == create ]] && exists "$current_file"; then
        printf 'Error: target appeared after confirmation: %s\n' "$current_file" >&2
        false
    fi
    if [[ ${actions[i]} == replace ]]; then
        # Back up the latest contents, but do not replace a newly substituted directory.
        if [[ -d "$current_file" ]]; then
            printf 'Error: target became a directory after confirmation: %s\n' "$current_file" >&2
            false
        fi
        if exists "${backups[i]}"; then
            printf 'Error: backup appeared after confirmation: %s\n' "${backups[i]}" >&2
            false
        fi
        cp -Pp "$current_file" "${backups[i]}"
        printf 'Backup created: %s\n' "${backups[i]}"
        # Replacing a symlink must not overwrite the file it points to.
        if [[ -L "$current_file" ]]; then rm "$current_file"; fi
    fi
    case "$current_file" in
        .envrc)
            {
                if [[ "$policy" != none ]]; then
                    printf 'source_env %q\n\nexport NONO_PROFILE=.nono/profile.jsonc\n' "$policy_env"
                fi
                [[ "$python" != yes ]] || printf '\nlayout python3\n'
                [[ "$cpp" != yes ]] || printf '\nexport %s=_build\n' "$build_var"
            } > "$current_file"
            ;;
        .justfile)
            render_template "$template_dir/justfile" '__BUILD_DIR_VAR__' "$build_var" > "$current_file"
            ;;
        .clang-tidy)
            cp "$template_dir/clang-tidy" "$current_file"
            ;;
        .opencode.jsonc)
            model_json=$(perl -MJSON::PP -e 'print encode_json($ARGV[0])' "$model")
            render_template "$template_dir/opencode.jsonc" '__MODEL_JSON__' "$model_json" > "$current_file"
            ;;
        .nono/profile.schema.json)
            mkdir -p .nono
            run_quietly nono profile schema --output "$current_file"
            ;;
        .nono/profile.jsonc)
            mkdir -p .nono
            # Keep private network permissions in a local base, not in project files.
            base_profile=opencode
            [[ "$policy" != confidential ]] || base_profile=opencode-confidential
            init_args=(profile init --extends "$base_profile" --output "$current_file")
            [[ ${actions[i]} != replace ]] || init_args+=(--force)
            run_quietly nono "${init_args[@]}" "$profile_name"
            # Preserve the generated comments and formatting instead of reserializing JSONC.
            perl -0777 -i -pe 's/\A(\s*\{)/$1\n  "\$schema": "profile.schema.json",/ or die "Profile is not a JSON object\n"' "$current_file"
            ;;
    esac
    written+=("$current_file")
    printf 'Written: %s\n' "$current_file"
    current_file=''
done
printf "\nDone. No environment was activated. Run \`direnv allow\` yourself when ready.\n"
