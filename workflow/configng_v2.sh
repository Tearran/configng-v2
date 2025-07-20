#!/usr/bin/env bash
set -euo pipefail

# configng_v2 - Armbian Config V2 Entry Point

# Get absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set project root as the parent directory of SCRIPT_DIR
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Set library directory relative to project root
LIB_DIR="$ROOT_DIR/lib/armbian-config"
DIALOG="${DIALOG:-whiptail}"
# Load core logic
source "$LIB_DIR/core.sh" || exit 1

# set TRACE=true for rolling info
trace reset
trace "OK: sourced core modules"

### START source staging ###
# If the staging directory exists, consolidate mini modules and source staged scripts
if [[ -d "$ROOT_DIR/staging" ]]; then
	# Set trace true for staging development
	TRACE=true
	trace "OK: Staging"
	"$ROOT_DIR/workflow/40_consolidate_module.sh"
	for file in "$ROOT_DIR"/staging/*.sh; do
		# Only source if a matching file exists (avoid globbing if no .sh files)
		[[ -f "$file" ]] && source "$file"
	done
fi

### END source staging/ ###

source "$LIB_DIR/software.sh" || exit 1
trace "OK: sourced software modules"

source "$LIB_DIR/network.sh" || exit 1
trace "OK: sourced network module"

source "$LIB_DIR/system.sh" || exit 1
trace "OK: sourced system module"

unset module_options 2>/dev/null || true
declare -A module_options

source "$LIB_DIR/module_options_arrays.sh" || exit 1
trace "OK: sourced Metadata array"

# Merge arrays into module_options
_merge_list_options system_options software_options network_options

trace "OK: merged Metadata array"

# Parse CLI args
user_cmd="${1:-}"
user_opt="${2:-}"
user_args="${3:-}"

case "$user_cmd" in
	"--help"|"-h")
		user_opt="${user_opt:-all}"
		list_options "$user_opt"
		trace "OK: list_options $user_opt"
		;;
	"--menu"|"-m"|"")

		if ! command -v menu_from_options &>/dev/null; then
			echo "ERR: menu_from_options not found" >&2
			exit 1
		fi

		#if ! choice=$(menu_from_options <<< "$(menu "list_options")"); then
		#	# user cancelled -> clean exit rather than fall-through
		#	exit 0
		#fi

		if choice_text=$(menu "list_options"); then
			choice=$(menu_from_options <<< "$choice_text") || exit 0
		else
			exit 0
		fi

		[[ -n "$choice" ]] && menu "$choice"
		;;
	*)

		menu "$@"
		#echo "Error: Unknown command"
		#exit 1
		;;
esac

trace total
