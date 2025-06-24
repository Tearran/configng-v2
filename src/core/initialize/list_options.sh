#!/usr/bin/env bash
set -euo pipefail

# Function: merge_arrays
# Merges multiple associative arrays into the global module_options array.
_merge_list_options() {
	for array_name in "$@"; do
		local -n src="$array_name"
		for key in "${!src[@]}"; do
			module_options["$key"]="${src[$key]}"
		done
	done
}


_parse_list_options() {
	local array_name="$1"

	local -n options_array="$array_name"

	# Show only the filename, not the full path ($0 may be absolute or relative)
	local prog_name
	prog_name="$(basename "$0")"


	local mod_message="Usage: ${prog_name} [options]\n\n"
	local i=1

	for function_name in "${!options_array[@]}"; do
		# Parse out the function name if your keys are like "foo,feature"
		[[ "$function_name" =~ ^([^,]+),feature$ ]] || continue
		fn_name="${BASH_REMATCH[1]}"
		type="feature" # Only features are listed
		if [[ "$type" == "feature" ]]; then
			example="${options_array["$fn_name,options"]}"
			mod_message+="$i. ${options_array["$fn_name,description"]}\n\t${options_array["$fn_name,feature"]} $example\n\n"
			((i++))
		fi
	done
	echo -e "$mod_message"
}

list_options() {
	case "${1:-}" in
		""|main)
			# Example: show core options (define core_options in your arrays file)
			_parse_list_options module_options
			;;
		core)
			# Example: show core options (define core_options in your arrays file)
			_parse_list_options core_options
			;;
		network)
			# Example: show core options (define core_options in your arrays file)
			_parse_list_options network_options
			;;
		software)
			# Example: show software options
			_parse_list_options software_options
			;;
		system)
			# Example: show software options
			_parse_list_options system_options
			;;
		help|--help|-h)
			# Show available commands/modules
			_about_list_options
			;;
		*)
			echo "Unrecognized command: $1"
			_parse_list_options module_options
			exit 1
			;;
	esac
}

_about_list_options() {
	cat <<-EOF
	list_options - Show available option groups and their usage

	Usage:
		list_options [all|core|software|help]

	Examples:
		list_options core
		list_options software
		list_options help

	This command lists available features and options for config-ng modules,
	such as core or software. It displays a numbered summary with example usage for each option group.

	Use "help", "--help", or "-h" to display all available option groups.
	EOF
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	SCRIPT_DIR="$(dirname "$0")"
	LIB_DIR="$SCRIPT_DIR/../lib/armbian-config"
	TOOLS_DIR="$SCRIPT_DIR/../tools"

	unset module_options
	declare -A core_options
	declare -A system_options
	declare -A network_options
	declare -A software_options
	declare -A module_options

	source "$LIB_DIR/module_options_arrays.sh" || exit 1
	_merge_list_options system_options software_options network_options

	list_options "$@"

fi
