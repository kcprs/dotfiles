#!/usr/bin/env bash

print_cmd() {
	printf "\n%s\n" "$*"
}

run_cmd() {
	print_cmd "$@"
	"$@"
}

print_args() {
	shift # Discard cmd
	for arg in "$@"; do
		printf "%s\n" "$arg"
	done
}

mise_task_utils_main() {
	set -e

	local print_args_flag=false
	local print_cmd_flag=false

	while getopts ":a:p" opt; do
		case ${opt} in
		a) print_args_flag=true ;;
		p) print_cmd_flag=true ;;
		\?)
			echo "Invalid option: -$OPTARG" 1>&2
			return 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." 1>&2
			return 1
			;;
		esac
	done

	# Look for the `--` separator
	local fwd_args=()
	while [[ "$1" != "--" && "$1" != "" ]]; do
		shift
	done
	if [[ "$1" == "--" ]]; then
		shift
		fwd_args=("$@")
	fi

	# Now we can call a subcommand
	if [ "$print_cmd_flag" = true ]; then
		print_cmd "${fwd_args[@]}"
		return
	elif [ "$print_args_flag" = true ]; then
		print_args "${fwd_args[@]}"
		return
	fi

	run_cmd "${fwd_args[@]}"
}
