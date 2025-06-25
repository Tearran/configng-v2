#!/usr/bin/env bash
set -euo pipefail

# configng_v2 - Armbian Config V2 Test

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	# Set script variable keys
	SCRIPT_DIR="$(dirname "$0")"
	LIB_DIR="$SCRIPT_DIR/../lib/armbian-config"
	TOOLS_DIR="$SCRIPT_DIR/../tools"
	DEBUG="${DEBUG:-}"
	DIALOG="${DIALOG:-read}"

	# Load core functions
	source "$LIB_DIR/core.sh" || exit 1
	source "$LIB_DIR/software.sh" || exit 1
	source "$LIB_DIR/network.sh" || exit 1
	# TODO: migrate a system module
	# source "$LIB_DIR/system.sh" || exit 1

	debug reset
	debug "OK: sourced core functions"

	# Load and merge option arrays
	{
		unset module_options 2>/dev/null || true
		declare -A module_options

		source "$LIB_DIR/module_options_arrays.sh" || exit 1
		debug "OK: sourced Metadata array"

		# Group order is important
		groups=(system software network core main)
		debug "Ok: metadata groups: ${groups[*]}"

		# Build argument list for merge
		option_array_args=()
		for prefix in "${groups[@]}"; do
			option_array_args+=("${prefix}_options")
		done

		# Merge arrays into module_options (function must use namerefs)
		_merge_list_options "${option_array_args[@]}"
		debug "OK: Merged metadata groups: ${option_array_args[*]}"
	}

	# Parse CLI arguments (default to list_options main)
	# "function" is the first arg, option the second, args the rest
	user_cmd="${1:-list_options}"
	user_opt="${2:-main}"
	user_args="${3:-}"

	# Command wrangler: route to the function if it exists, complain if not
	if declare -F "$user_cmd" >/dev/null; then
		"$user_cmd" "$user_opt" "$user_args"
	else
		echo "Error: Command or function '$user_cmd' not found." >&2
		exit 1
	fi

fi
