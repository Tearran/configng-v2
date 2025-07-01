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

# See Trace for info should these be more verbose?
#
trace reset
trace "OK: sourced core modules"

### START source staging ###
# If the staging directory exists, consolidate mini modules and source staged scripts
if [[ -d "$ROOT_DIR/staging" ]]; then
	TRACE=true
	trace "OK: Staging"
	"$ROOT_DIR/tools/30_consolidate_module.sh"
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

# Print all modules under a parent group for any options array
# List unique subgroups under a parent group (excluding 'internal')
list_subgroups() {
	local -n opts="$1"
	local parent="$2"
	declare -A seen=()
	for key in "${!opts[@]}"; do
		if [[ $key =~ ^([^,]+),parent$ ]] && [[ "${opts[$key]}" == "$parent" ]]; then
			local module="${BASH_REMATCH[1]}"
			local subgroup="${opts[$module,group]:-}"
			[[ -n "$subgroup" && "$subgroup" != "internal" ]] && seen["$subgroup"]=1
		fi
	done
	# Print all unique subgroups
	for subgroup in "${!seen[@]}"; do
		echo "$subgroup"
	done
}


# Parse CLI args
user_cmd="${1:-}"
user_opt="${2:-}"
user_args="${3:-}"

case "$user_cmd" in
	"--help"|"-h")
		if [[ -n "$user_opt" ]]; then
			list_options ${user_opt:-main}
			trace "OK: list_options help"
		else
			list_options help
		fi

		;;
	"--menu"|"-m"|"")
		DIALOG="${DIALOG:-whiptail}"
		#info_box <<< "$(submenu "${2:-list_options}")"
		list_group_modules software_options software

		;;
	*)
		"$@" || exit 1
		;;
esac

trace total

