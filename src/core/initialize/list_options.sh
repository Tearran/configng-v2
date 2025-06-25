#!/usr/bin/env bash
set -euo pipefail

# Merge multiple associative arrays into global module_options
_merge_list_options() {
	for array_name in "$@"; do
		local -n src="$array_name"
		for key in "${!src[@]}"; do
			module_options["$key"]="${src[$key]}"
		done
	done
}

# List options from a given associative array with neat formatting
list_module_options() {
	local -n arr="$1"

	local prog_name
	prog_name="$(basename "$0")"

	echo -e "Usage: ${prog_name} [options]\n"

	local modules=()
	for key in "${!arr[@]}"; do
		if [[ $key =~ ^([^,]+),feature$ ]]; then
			modules+=("${BASH_REMATCH[1]}")
		fi
	done

	IFS=$'\n' sorted=($(sort <<<"${modules[*]}"))
	unset IFS

	for mod in "${sorted[@]}"; do
		local uid="${arr[$mod,unique_id]:-NOID}"
		local desc="${arr[$mod,description]:-No description}"
		local feature="${arr[$mod,feature]:-command}"
		local options="${arr[$mod,options]:-}"

		echo -e "${uid} - ${desc}\n\t${feature} ${options}\n"
	done
}

# Dispatch listing based on group name, defaulting to main group
list_options() {
	case "${1:-main}" in
		main|"")
			list_module_options module_options
		;;
		core|software|network|system)
			list_module_options "${1}_options"
		;;
		help|--help|-h)
			_about_list_options
		;;
		*)
			echo "Unrecognized option group: $1"
			echo
			_about_list_options
			exit 1
		;;
	esac
}

# Help text for list_options usage
_about_list_options() {
# Do not strip formatting with cat <<-EOF
cat << EOF
list_options - Show available option groups and their usage

Usage:
	list_options [main|core|software|network|system|help]

Examples:
	list_options core
	list_options software
	list_options help

This command lists available features and options for config-ng modules,
such as core or software. It displays a summary with example usage for each option group.

Use "help", "--help", or "-h" to display this help message.
EOF
}

# Main execution block, runs if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	SCRIPT_DIR="$(dirname "$0")"
	LIB_DIR="$SCRIPT_DIR/../../../lib/armbian-config"

	# Clear any existing arrays, then declare new ones
	unset module_options 2>/dev/null || true
	declare -A core_options
	declare -A system_options
	declare -A network_options
	declare -A software_options
	declare -A module_options

	# Source your arrays file with module metadata
	source "$LIB_DIR/module_options_arrays.sh" || exit 1

	# Merge all group arrays into one big associative array
	_merge_list_options core_options system_options software_options network_options

	# Call list_options with CLI argument or default to "main"
	list_options "$@"
fi
