#!/usr/bin/env bash
set -euo pipefail

# configng_v2 - Armbian Config V2 Entry Point

# Get absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set project root as the parent directory of SCRIPT_DIR
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Set library directory relative to project root
LIB_DIR="$ROOT_DIR/lib/armbian-config"

# Load core logic
source "$LIB_DIR/core.sh" || exit 1

# If the staging directory exists, consolidate mini modules and source staged scripts
if [[ -d "$ROOT_DIR/staging" ]]; then
	"$ROOT_DIR/tools/30_consolidate_module.sh"
	for file in "$ROOT_DIR"/staging/*.sh; do
		# Only source if a matching file exists (avoid globbing if no .sh files)
		[[ -f "$file" ]] && source "$file"

	done
fi

trace reset
trace "OK: sourced core modules"

source "$LIB_DIR/software.sh" || exit 1

trace "OK: sourced software modules"

source "$LIB_DIR/network.sh" || exit 1
trace "OK: sourced network module"

# TODO: source "$LIB_DIR/system.sh" || exit 1
# trace "OK: sourced system module

trace "Load metadata arrays"
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
	--help|-h)
		list_options help
		trace "OK: list_options help"
		;;
	list_options)
		list_options "$user_opt"
		trace "OK: list_options $user_opt"
		;;
	core|system|software|network|help)
		list_options "$user_cmd"
		trace "OK: list_options $user_cmd"
		;;
	*)
		echo "Unknown command: $user_cmd" >&2
		list_options help
		trace "WARN: unknown command $user_cmd"
		exit 1
	;;
esac

trace total
