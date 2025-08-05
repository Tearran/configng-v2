#!/usr/bin/env bash
set -euo pipefail

# configng_v2 - Armbian Config V2 Entry Point

# Get absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set project root as the parent directory of SCRIPT_DIR
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Set library directory relative to project root
LIB_DIR="$ROOT_DIR/lib/armbian-config"

# Set the default dialog box whiptail or dialog
# You can override this by setting the DIALOG environment variable

# Check if the dialog command is available
# Check for available dialog command, defaulting to whiptail

DIALOG="${DIALOG:-whiptail}"

# At this point, DIALOG is set to a valid command
echo "Using dialog command: $DIALOG"
# Check if the library directory exists
if [ ! -d "$LIB_DIR" ]; then
	echo "Error: Library directory $LIB_DIR does not exist."
	echo "Consolidating ./src modueles into $LIB_DIR"
	# If the library directory does not exist, run the consolidation script
	[[ "$EUID" != "0" ]] && "$ROOT_DIR/workflow/40_consolidate_module.sh" ;
	# Check again if the library directory exists after consolidation
	if [ ! -d "$LIB_DIR" ]; then
		echo "Error: Library directory $LIB_DIR still does not exist after consolidation."
		exit 1
	fi
fi


# Load core logic
source "$LIB_DIR/core.sh" || exit 1

# set TRACE=true for rolling info output
# MAy be usefule for manual debugging
trace reset
trace "OK: sourced core modules"

### START source staging ###
# If the staging directory exists, consolidate mini modules and source staged scripts
# staged modules only avalible as a backent commands
# and not as a menu entry point
# useage config_v2.sh <module_name> <module_option> <module_args>
if [[ -d "$ROOT_DIR/staging" ]]; then
	# Set trace true for staging development show times
	# Verbose output and timers
	TRACE=true
	trace "OK: Staging"
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

# handel and parse 3 CLI args
user_cmd="${1:-}"
user_opt="${2:-}"
user_args="${3:-}"

case "$user_cmd" in
	"--help"|"-h"|"help")
		user_opt="${user_opt:-help}"
		list_options "$user_opt"
		trace "OK: list_options $user_opt"
		;;
	"")
		# If no command is provided, show the main menu
		user_opt="${user_opt:-help}"
		trace "OK: list_options $user_opt"
		# Show the main menu with options
		if choice_text=$(menu "list_options" "$user_opt"); then
			trace "OK: menu list"
			# If a choice is made, call the submenu function with the choice text
			choice=$(submenu <<< "$choice_text") || exit 0
		else
			exit 0
		fi

		[[ -n "$choice" ]] && menu "$choice"
		;;
	*)
		# If the first argument is not a recognized command, treat it as a module name

		"$@"
		;;
esac

trace total
