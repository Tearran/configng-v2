#!/usr/bin/env bash
set -euo pipefail

# List available MOTD items
_list_adjust_motd() {
	grep THIS_SCRIPT= /etc/update-motd.d/* | cut -d"=" -f2 | sed 's/"//g'
}

# Return ON or OFF for a given item
_status_adjust_motd() {
	source /etc/default/armbian-motd
	if grep -qw "$1" <<<"${MOTD_DISABLE:-}"; then
		echo "OFF"
	else
		echo "ON"
	fi
}

# Map MOTD item names to human-readable descriptions
_desc_adjust_motd() {
	case "$1" in
		clear)     echo "Clear the MOTD screen";;
		header)    echo "System banner & version";;
		sysinfo)   echo "System info (load, CPU, memory)";;
		tips)      echo "Random Armbian tips";;
		commands)  echo "Suggested Armbian commands";;
		*)         echo "Unknown";;
	esac
}

# Show all items, their description, and status (columnar for checklist/TUI use)
_show_adjust_motd() {
	printf "%-10s %-30s %s\n" "Item" "Description" "Status"
	printf "%-10s %-30s %s\n" "--------" "------------------------------" "------"
	for v in $(_list_adjust_motd); do
		printf "%-10s %-30s %s\n" "$v" "$(_desc_adjust_motd "$v")" "$(_status_adjust_motd "$v")"
	done
}

# Show a preview of the actual MOTD output
_reload_adjust_motd() {

	run-parts --lsbsysinit /etc/update-motd.d

}

# Set item ON or OFF
_set_adjust_motd() {
	local item="${1:-}"
	local state="${2:-}"
	if [[ -z "$item" || -z "$state" ]]; then
		echo "Usage: adjust_motd set <item> <ON|OFF>" >&2
		return 1
	fi
	# Normalize state to uppercase for comparison
	state="${state^^}"

	# Validate state: must be exactly ON or OFF (case-insensitive)
	if [[ "$state" != "ON" && "$state" != "OFF" ]]; then
		echo "Error: State must be ON or OFF (case-insensitive). You entered: '$2'" >&2
		return 2
	fi

	source /etc/default/armbian-motd
	local disables="${MOTD_DISABLE:-}"

	# Remove exact matches of $item as a word (handles start/end/multiple spaces)
	disables="$(echo "$disables" | sed -E "s/(^|[[:space:]])$item($|[[:space:]])/ /g" | xargs)"

	if [[ "$state" == "OFF" ]]; then
		# Only add if not already present
		if ! grep -qw "$item" <<<"$disables"; then
			disables="$disables $item"
			disables="$(echo "$disables" | xargs)"
		fi
	fi

	# Update the config file
	sed -i "s/^MOTD_DISABLE=.*/MOTD_DISABLE=\"$disables\"/g" /etc/default/armbian-motd
	echo "Set $item to $state."
}

_about_adjust_motd() {
	cat <<EOF
Usage: adjust_motd <command> [arguments]

Commands:
	show                 List all MOTD items, descriptions, and their ON/OFF status
	set <item> <ON|OFF>  Enable or disable a MOTD item
	reload               Show a preview of the actual MOTD output
	help                 Show this help message

Examples:
	adjust_motd show
	adjust_motd set sysinfo OFF
	adjust_motd reload
EOF
}

adjust_motd() {
	local cmd="${1:-help}"
	case "$cmd" in
		show)    _show_adjust_motd;;
		set)
			_set_adjust_motd "${2:-}" "${3:-}"
			;;
		reload)  _reload_adjust_motd;;
		help|*)  _about_adjust_motd;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	adjust_motd "$@"
fi
