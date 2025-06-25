#!/usr/bin/env bash
set -euo pipefail

# configng_v2 - Armbian Config V2 Entry Point

SCRIPT_DIR="$(dirname "$0")"
LIB_DIR="$SCRIPT_DIR/../lib/armbian-config"
INIT_DIR="$SCRIPT_DIR/../src/core/initialize"

DEBUG="${DEBUG:-}"
DIALOG="${DIALOG:-read}"

# Load core logic
source "$LIB_DIR/core.sh" || exit 1
source "$LIB_DIR/software.sh" || exit 1
source "$LIB_DIR/network.sh" || exit 1
# source "$LIB_DIR/system.sh" || exit 1

debug reset
debug "OK: sourced core functions"

# Load metadata arrays
unset module_options 2>/dev/null || true
declare -A module_options

source "$LIB_DIR/module_options_arrays.sh" || exit 1
debug "OK: sourced Metadata array"

# Merge arrays into module_options
_merge_list_options core_options system_options software_options network_options

# Parse CLI args
user_cmd="${1:-list_options}"
user_opt="${2:-main}"
user_args="${3:-}"

case "$user_cmd" in
	--help|-h)
		list_options help
	;;
	list_options)
		list_options "$user_opt"
	;;
	*)
	if declare -F "$user_cmd" >/dev/null; then
		"$user_cmd" "$user_opt" "$user_args"
	else
		debug "Error: unknown command '$user_cmd'" >&2
		list_options help
		exit 1
	fi
	;;
esac
