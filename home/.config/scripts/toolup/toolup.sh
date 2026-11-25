#!/bin/bash
# Tool up the current directory. Bash 3.2 and jq handle JSON on macOS.
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
warnings=()
current_file=''
writing=no

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
require() { command -v "$1" >/dev/null || fail "$1 is required. $2"; }
exists() { [[ -e "$1" || -L "$1" ]]; }
queue_warning() { warnings+=("$*"); }

choose_yes_no() {
    local answer
    answer=$(gum choose --header "$1" --selected no no yes) || return $?
    [[ "$answer" == yes || "$answer" == no ]] || fail "No valid $2 answer selected."
    printf '%s\n' "$answer"
}

# Present decision-dependent warnings together, including when no targets are selected.
print_warnings() {
    if ((${#warnings[@]})); then
        printf '\nWarnings:\n'
        printf '  %s\n' "${warnings[@]}"
    fi
}

# Validate early for useful feedback, then again after the interactive pause.
# These checks are best-effort, not protection against concurrent filesystem changes.
check_target_directories() {
    local directory
    if [[ "$policy" != none ]]; then
        for directory in .nono .pi; do
            if exists "$directory" && [[ ! -d "$directory" || -L "$directory" ]]; then
                fail "$directory must be a real directory, not a file or symlink."
            fi
        done
    fi
}

# Quote even ordinary paths, and prevent expansion when direnv reads the file.
write_source_env() {
    local path=$1
    path=${path//\\/\\\\}
    path=${path//\"/\\\"}
    path=${path//\$/\\\$}
    path=${path//\`/\\\`}
    printf 'source_env "%s"\n' "$path"
}

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

# Keep template names in one place so validation and generation cannot drift.
template_for_target() {
    case "$1" in
        .justfile|.clang-tidy|.opencode.json|.fdignore)
            printf '%s/%s\n' "$template_dir" "${1#.}"
            ;;
        .pi/mcp.json) printf '%s/pi-mcp.json\n' "$template_dir" ;;
        *) return 1 ;;
    esac
}

# Replace literal placeholders, not shell expressions. Templates are data and
# are never sourced or evaluated; quoting and JSON encoding happen at the call site.
render_template() {
    local content
    content=$(cat "$1")
    content=${content//"$2"/"$3"}
    printf '%s\n' "$content"
}

# Match the requested 100-column divider width and center each section title against it.
write_envrc_section_header() {
    local title=$1 width=100 title_column separator
    separator=$(printf '%*s' "$width" '')
    separator=${separator// /#}
    title_column=$(((width - ${#title}) / 2))
    printf '%s\n#%*s%s\n%s\n' "$separator" "$((title_column - 1))" '' "$title" "$separator"
}

# Add the schema while keeping the generated profile intact if jq rejects it.
add_profile_schema() {
    local path=$1 temporary
    temporary=$(mktemp "${path}.XXXXXX")
    if ! cp -p "$path" "$temporary"; then
        rm -f "$temporary"
        return 1
    fi
    if jq -S --arg schema profile.schema.json '. + {"$schema": $schema}' \
        "$path" > "$temporary"; then
        if mv "$temporary" "$path"; then
            return 0
        fi
    fi
    rm -f "$temporary"
    return 1
}

# Preserve the exact backup-to-target pairs so the migration skill never guesses
# which timestamped backups came from this successful run.
write_migration_handoff() {
    local replacement_count=0 i handoff_status=0
    migration_manifest=''
    for ((i=0; i<${#files[@]}; i++)); do
        [[ ${actions[i]} != replace ]] || replacement_count=$((replacement_count + 1))
    done
    ((replacement_count)) || return 0

    if [[ -L tmp || ( -e tmp && ! -d tmp ) ]]; then
        warn 'Could not create the migration handoff: tmp must be a real directory.'
        return 1
    fi
    if [[ ! -d tmp ]] && ! mkdir tmp; then
        warn 'Could not create the migration handoff directory: tmp.'
        return 1
    fi
    if ! migration_manifest=$(mktemp "tmp/toolup-migration-$timestamp.XXXXXX"); then
        migration_manifest=''
        warn 'Could not create the migration handoff file.'
        return 1
    fi
    # The caller handles failure explicitly, so check every write rather than
    # relying on errexit (which is disabled within a tested function call).
    {
        printf 'toolup-migration-manifest-v1\n' || handoff_status=1
        for ((i=0; i<${#files[@]}; i++)); do
            if [[ ${actions[i]} == replace ]]; then
                printf '%s\t%s\n' "${files[i]}" "${backups[i]}" || handoff_status=1
            fi
        done
    } > "$migration_manifest" || handoff_status=1
    if ((handoff_status)); then
        rm -f "$migration_manifest"
        migration_manifest=''
        warn 'Could not write the migration handoff file.'
        return 1
    fi
    return 0
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

# --- Choices and discovery ---

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
    require pi 'Install Pi before configuring AI tools.'
    require nono 'Install nono before configuring AI tools.'
    require jq 'Install it with: brew install jq'
    [[ -n "$profile_name" ]] || fail 'The directory name cannot be converted to a nono profile name.'
    policy_env="$HOME/.ai.$policy.envrc"
    [[ -f "$policy_env" ]] || fail "The selected AI policy file does not exist: $policy_env"
    [[ "$profile_name" == "$project_name" ]] || queue_warning "nono profile name normalized to: $profile_name"

    # Keep private network permissions in local bases, not in project files.
    pi_base=pi
    opencode_base=opencode
    if [[ "$policy" == confidential ]]; then
        pi_base=pi-confidential
        opencode_base=opencode-confidential
    fi
    for base_profile in "$pi_base" "$opencode_base"; do
        if ! run_quietly nono profile show --json "$base_profile"; then
            fail "nono base profile cannot be resolved: $base_profile"
        fi
    done

    # Query the CLI rather than duplicating provider/model configuration logic.
    # Keep command stdout separate from spinner UI and diagnostics so only model
    # IDs are captured, while errors remain visible and retain their exit status.
    # Pi prints separate provider and model columns. Joining only those columns
    # preserves model IDs containing slashes and avoids parsing display metadata.
    # Credentials arrive only after the generated .envrc is trusted. Static
    # model listing needs nonempty keys, not valid ones; scope placeholders to
    # this subprocess so they cannot reach OpenCode or generated configuration.
    # TODO: Extend this list when another configured provider needs a key.
    if ! model_list=$(gum spin --title 'Loading Pi models…' \
        --show-stdout --show-stderr -- env \
        FHGENIE_API_KEY=toolup-discovery-placeholder \
        FHGENIE_ONPREM_API_KEY=toolup-discovery-placeholder \
        AME_LITELLM_API_KEY=toolup-discovery-placeholder \
        pi --list-models); then
        fail 'Pi model discovery failed.'
    fi
    models=()
    while read -r provider model_id rest; do
        [[ "$provider" == provider && "$model_id" == model ]] && continue
        if [[ "$provider" =~ ^[^[:space:]/]+$ && "$model_id" =~ ^[^[:space:]]+$ && -n "$rest" ]]; then
            models+=("$provider/$model_id")
        fi
    done <<< "$model_list"
    ((${#models[@]})) || fail 'Pi returned no usable provider/model IDs.'

    # No configured default is detected or preselected; preserve CLI list order.
    model=$(gum filter --header 'Default AI model (type to search)' --strict \
        --no-fuzzy-sort "${models[@]}")
    valid=no
    for candidate in "${models[@]}"; do [[ "$candidate" != "$model" ]] || valid=yes; done
    [[ "$valid" == yes ]] || fail 'No valid model selected.'
    model_provider=${model%%/*}
    model_id=${model#*/}

    # OpenCode may list additional built-in models. Only the selected Pi model
    # needs to match; a mismatch is informative, not a reason to block setup.
    if ! opencode_models=$(gum spin --title 'Loading OpenCode models…' \
        --show-stdout --show-stderr -- opencode models --standalone); then
        fail 'OpenCode model discovery failed.'
    fi
    valid=no
    usable=no
    while IFS= read -r candidate; do
        if [[ "$candidate" =~ ^[^[:space:]/]+/[^[:space:]]+$ ]]; then
            usable=yes
            [[ "$candidate" != "$model" ]] || valid=yes
        fi
    done <<< "$opencode_models"
    [[ "$usable" == yes ]] || fail 'OpenCode returned no usable provider/model IDs.'
    [[ "$valid" == yes ]] || queue_warning "Selected Pi model is not listed by OpenCode: $model"
fi

rust=$(choose_yes_no 'Set up Rust tools?' Rust)
cpp=$(choose_yes_no 'Set up C/C++ tools?' C/C++)
python=$(choose_yes_no 'Set up a Python venv?' Python)

# --- Warnings, dependencies, and target selection ---

# All choices are now known, so warnings can describe the actual replacement plan.
if [[ "$policy" == none ]]; then
    ai_config_paths=(
        .opencode.json .opencode.jsonc opencode.json opencode.jsonc
        .opencode/opencode.json .opencode/opencode.jsonc
        .pi/settings.json .pi/mcp.json
        .nono/profile.jsonc .nono/profile.schema.json .nono/profile.json
        .nono/agent-pi.json .nono/agent-opencode.json
        .nono/agent-pi.jsonc .nono/agent-opencode.jsonc
        .fdignore
    )
    for file in "${ai_config_paths[@]}"; do
        if exists "$file"; then queue_warning "Existing AI configuration will not be touched: $file"; fi
    done
    if [[ -f .envrc ]] && grep -Eq 'source_env.*\.ai\.|NONO_PROFILE' .envrc; then
        if [[ "$rust" == yes || "$cpp" == yes || "$python" == yes ]]; then
            queue_warning 'Existing .envrc contains AI settings; tool setup will replace it with a backup after confirmation, removing those settings.'
        else
            queue_warning 'Existing .envrc contains AI settings; it will be left untouched.'
        fi
    fi
fi

# These tools are needed to use the selected configuration, even though setup
# deliberately does not build the project or activate direnv.
if [[ "$policy" != none || "$cpp" == yes || "$python" == yes || "$rust" == yes ]]; then
    require direnv 'Install it with: brew install direnv'
    files+=(.envrc)
fi
if [[ "$cpp" == yes ]]; then
    require cmake 'Install it with: brew install cmake'
    require just 'Install it with: brew install just'
    files+=(.justfile .clang-tidy)
fi
if [[ "$python" == yes ]]; then require python3 'Install it with: brew install python'; fi
if [[ "$policy" != none ]]; then
    files+=(.opencode.json .pi/settings.json .pi/mcp.json .nono/profile.schema.json .nono/profile.json .nono/agent-pi.json .nono/agent-opencode.json .fdignore)
fi

if ((${#files[@]} == 0)); then
    printf 'No files to create.\n'
    print_warnings
    exit 0
fi
# --- Validation and replacement plan ---

for file in "${files[@]}"; do
    if template=$(template_for_target "$file"); then
        [[ -f "$template" && -r "$template" ]] || fail "Required template is missing or unreadable: $template"
    fi
done
check_target_directories

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
    printf 'C/C++ tools: %s\nPython venv: %s\nRust tools: %s\n' "$cpp" "$python" "$rust"
    [[ "$cpp" != yes ]] || printf 'Build variable: %s=_build\n' "$build_var"
    printf '\nFiles:\n'
    for ((i=0; i<${#files[@]}; i++)); do
        printf '  %s: %s\n' "${actions[i]}" "${files[i]}"
        if [[ -n ${backups[i]} ]]; then printf '    backup: %s\n' "${backups[i]}"; fi
    done
    print_warnings
)
# --- Confirmation and writes ---

gum style --border rounded --border-foreground "${BORDER_FOREGROUND-6}" \
    --padding '1 2' --margin '1 0' "$summary"
confirmation_prompt='Write the files listed above?'
# Gum also uses exit 1 for UI failures. Capture the chosen action to distinguish
# a declined confirmation from an error, while leaving UI and diagnostics visible.
if confirmation_output=$(gum confirm "$confirmation_prompt" --default=true --show-output); then
    :
else
    status=$?
    case "$status" in
        1)
            if [[ "$confirmation_output" == "$confirmation_prompt No" ]]; then
                printf 'Cancelled. No files written.\n'
                exit 0
            fi
            ;;
        130)
            printf 'Interrupted. No files written.\n' >&2
            exit 130
            ;;
    esac
    printf 'Error: confirmation failed (exit %s). No files written.\n' "$status" >&2
    exit "$status"
fi

check_target_directories
writing=yes
# Create shared parents once; individual targets no longer depend on write order.
if [[ "$policy" != none ]]; then
    mkdir -p .pi .nono
fi
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
    template=$(template_for_target "$current_file") || template=''
    case "$current_file" in
        .envrc)
            {
                section_separator=''
                if [[ "$policy" != none ]]; then
                    printf '%s' "$section_separator"
                    write_envrc_section_header 'AI Tools'
                    write_source_env "$policy_env"
                    printf '\nexport NONO_PROFILE=.nono/agent-pi.json\n# export NONO_PROFILE=.nono/agent-opencode.json\n'
                    section_separator=$'\n'
                fi
                if [[ "$rust" == yes ]]; then
                    # Keep dependency-cache writes inside the sandbox's writable project.
                    # Resolve at activation so moving the checkout needs no regeneration.
                    printf '%s' "$section_separator"
                    write_envrc_section_header 'Rust'
                    # shellcheck disable=SC2016
                    printf 'CARGO_HOME="$(expand_path .cargo-home)"\nexport CARGO_HOME\n'
                    section_separator=$'\n'
                fi
                if [[ "$python" == yes ]]; then
                    printf '%s' "$section_separator"
                    write_envrc_section_header 'Python'
                    printf 'layout python3\n'
                    section_separator=$'\n'
                fi
                if [[ "$cpp" == yes ]]; then
                    printf '%s' "$section_separator"
                    write_envrc_section_header 'C/C++'
                    printf 'export %s=_build\n' "$build_var"
                fi
            } > "$current_file"
            ;;
        .justfile)
            render_template "$template" '__BUILD_DIR_VAR__' "$build_var" > "$current_file"
            ;;
        .clang-tidy|.fdignore)
            cp "$template" "$current_file"
            ;;
        .opencode.json)
            # Keep the generated config strict JSON; jq safely encodes model IDs as strings.
            # The MCP example is included as JSON and remains disabled by default.
            jq -S --arg model "$model" '.model = $model' \
                "$template" > "$current_file"
            ;;
        .pi/settings.json)
            jq -n -S --arg schema 'https://pi.dev/schemas/settings.schema.json' \
                --arg provider "$model_provider" --arg model "$model_id" \
                '{"$schema": $schema, defaultProvider: $provider, defaultModel: $model}' > "$current_file"
            ;;
        .pi/mcp.json)
            # Copy rather than interpolate: Pi resolves these variables only
            # when the user enables the server with credentials available.
            cp "$template" "$current_file"
            ;;
        .nono/profile.schema.json)
            run_quietly nono profile schema --output "$current_file"
            ;;
        .nono/profile.json)
            init_args=(profile init --output "$current_file")
            [[ ${actions[i]} != replace ]] || init_args+=(--force)
            run_quietly nono "${init_args[@]}" "$profile_name"
            # Rewrite through a sibling temp file so malformed generated JSON leaves the source intact.
            add_profile_schema "$current_file"
            ;;
        .nono/agent-pi.json|.nono/agent-opencode.json)
            # The shared project base is resolved by sibling name, not by path.
            base_profile=$pi_base
            agent=pi
            if [[ "$current_file" == .nono/agent-opencode.json ]]; then
                base_profile=$opencode_base
                agent=opencode
            fi
            jq -n -S --arg name "$profile_name-$agent" --arg base "$base_profile" \
                '{"$schema": "profile.schema.json", meta: {name: $name}, extends: [$base, "profile"]}' > "$current_file"
            ;;
    esac
    written+=("$current_file")
    printf 'Written: %s\n' "$current_file"
    current_file=''
done
# --- Migration handoff ---

if ! write_migration_handoff; then
    printf 'Scaffolding completed, but migration handoff failed. Files and backups remain in place.\n' >&2
    exit 1
fi
printf "\nDone. No environment was activated. Run \`direnv allow\` yourself when ready.\n"
if [[ -n "$migration_manifest" ]]; then
    printf 'To help migrate old configs, run this in Pi:\n/skill:toolup-migrate\n'
fi
