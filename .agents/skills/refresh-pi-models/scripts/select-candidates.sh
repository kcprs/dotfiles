#!/usr/bin/env bash
# Collect explicit approval once for the entire run, without exposing provider keys.
set -euo pipefail

if [[ $# -ne 2 ]]; then
    printf 'Usage: bash %s candidates.tsv selected.txt\n' "$0" >&2
    exit 2
fi

input=$1
output=$2
if [[ -e "$output" ]]; then
    printf 'Refusing to reuse existing selection file: %s\n' "$output" >&2
    exit 2
fi
if [[ ! -t 0 || ! -t 1 ]]; then
    printf 'Run this picker in an interactive terminal; no selection was saved.\n' >&2
    exit 2
fi
if ! command -v gum >/dev/null 2>&1; then
    printf 'gum is required; no selection was saved.\n' >&2
    exit 2
fi

# Opaque keys decouple labels from the exact update, removal, or addition.
options=()
keys=()
while IFS= read -r row || [[ -n "$row" ]]; do
    if [[ "$row" != *$'\t'* ]]; then
        printf 'Each candidate must have a key and label separated by a tab.\n' >&2
        exit 2
    fi
    key=${row%%$'\t'*}
    label=${row#*$'\t'}
    if [[ ! "$key" =~ ^candidate-[0-9]+$ || -z "$label" || "$label" == *$'\t'* || "$label" == *$'\r'* ]]; then
        printf 'Invalid candidate key or label.\n' >&2
        exit 2
    fi
    for previous in "${keys[@]}"; do
        if [[ "$previous" == "$key" ]]; then
            printf 'Duplicate candidate key: %s\n' "$key" >&2
            exit 2
        fi
    done
    keys+=("$key")
    options+=("$label"$'\t'"$key")
done < "$input"
if [[ ${#keys[@]} -eq 0 ]]; then
    printf 'No candidates; skip the picker.\n' >&2
    exit 2
fi
options+=("Make no changes"$'\t'"__none__")

# Explicit arguments keep stdin attached to the terminal. Clearing inherited
# selection defaults ensures that every action really is an opt-in.
if selection=$(gum choose --no-limit --ordered --selected='' \
    --label-delimiter=$'\t' --output-delimiter=$'\n' \
    --header='Select model updates, removals, and additions (space toggles; enter confirms)' \
    -- "${options[@]}"); then
    :
else
    status=$?
    printf 'Picker cancelled or failed; no selection was saved.\n' >&2
    exit "$status"
fi

if [[ "$selection" == '__none__' || -z "$selection" ]]; then
    selection=''
else
    while IFS= read -r selected; do
        valid=false
        for key in "${keys[@]}"; do
            if [[ "$selected" == "$key" ]]; then
                valid=true
                break
            fi
        done
        if [[ "$valid" != true ]]; then
            printf 'Invalid selection (do not combine “Make no changes” with actions).\n' >&2
            exit 2
        fi
    done <<< "$selection"
fi

# Create only on successful confirmation, and never overwrite an older approval.
# An empty file deliberately represents a confirmed choice to change nothing.
if [[ -n "$selection" ]]; then
    (set -o noclobber; printf '%s\n' "$selection" > "$output")
else
    (set -o noclobber; printf '' > "$output")
fi
printf 'Selection saved to %s\n' "$output"
