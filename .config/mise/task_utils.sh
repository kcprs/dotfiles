#!/usr/bin/env bash

run_cmd() {
	printf "\n%s\n" "$*"
	"$@"
}

print_args() {
	for arg in "${@:1}"; do
		printf "%s\n" "$arg"
	done
}

mise_task_utils_main() {
	set -e

	local print_args_flag=false

	while getopts ":a" opt; do
		case ${opt} in
		a) print_args_flag=true ;;
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
	if [ "$print_args_flag" = true ]; then
		print_args "${fwd_args[@]}"
		return
	fi

	run_cmd "${fwd_args[@]}"
}
