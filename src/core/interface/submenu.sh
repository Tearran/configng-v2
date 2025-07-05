#!/usr/bin/env bash
set -euo pipefail

# submenu - Menu dispatcher/helper for config-v3 modules

submenu() {
	local cmd="${1:-help}"
	shift || true

	case "$cmd" in
		help|-h|--help)
			_about_submenu
			;;
		*)
			_submenu "$cmd" "$@"
			;;
	esac
}

_about_submenu() {
	cat <<-EOF
	Usage: submenu <command-or-module> [args...]
	Commands:
		help	- Show this help.
	<function_name>	- Show the interactive submenu for a module.
	EOF
}


_about_submenu() {
	cat <<EOF
Usage: submenu <command>

Commands:
	<function_name>	- Show the interactive submenu for a module.
	help        - Show this help message

Examples:
	# Run the test operation
	submenu cockpit

	# Show help
	submenu help

Notes:
	- Replace 'foo' and 'bar' with real commands for your module.
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}


_submenu() {
	local function_name="${1:-}"
	shift || true

	if [[ -z "$function_name" ]]; then
		echo "No function specified for submenu."
		return 1
	fi

	local help_message
	help_message=$("$function_name" help 2>/dev/null || true)
	if [[ -z "$help_message" ]]; then
		echo "No help message from: $function_name"
		return 1
	fi

	local menu_items=()
	local item_keys=()
	while IFS= read -r line; do
		if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*-\s*(.*)$ ]]; then
			menu_items+=("${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}")
			item_keys+=("${BASH_REMATCH[1]}")
		fi
	done <<< "$help_message"

	local choice=""
	case "${DIALOG:-read}" in
		dialog)
			local dialog_options=()
			for ((i=0; i<${#item_keys[@]}; i++)); do
				dialog_options+=("${item_keys[i]}" "${menu_items[i]#*- }")
			done
			choice=$(dialog --title "${function_name^}" --menu "Choose an option:" 0 80 9 "${dialog_options[@]}" 2>&1 >/dev/tty)
			;;
		whiptail)
			local whiptail_options=()
			for ((i=0; i<${#item_keys[@]}; i++)); do
				whiptail_options+=("${item_keys[i]}" "${menu_items[i]#*- }")
			done
			choice=$(whiptail --title "${function_name^}" --menu "Choose an option:" 0 80 9 "${whiptail_options[@]}" 3>&1 1>&2 2>&3)
			;;
		read|*)
			echo "Available options:"
			echo "0. Cancel"
			for ((i=0; i<${#menu_items[@]}; i++)); do
				printf "%d. %s\n" "$((i + 1))" "${menu_items[i]}"
			done

			# $1 is the candidate menu index if provided, otherwise prompt
			if [[ "${1:-}" =~ ^[0-9]+$ ]] && (( $1 >= 0 && $1 <= ${#item_keys[@]} )); then
				choice_index="$1"
			else
				while true; do
					read -p "Enter choice number (or press Enter/0 to cancel): " choice_index
					if [[ -z "$choice_index" || "$choice_index" == "0" ]]; then
						echo "Menu canceled."
						return 1
					elif [[ "$choice_index" =~ ^[0-9]+$ ]] && (( choice_index >= 1 && choice_index <= ${#item_keys[@]} )); then
						break
					else
						echo "Invalid choice. Try again."
					fi
				done
			fi

			if [[ "$choice_index" == "0" ]]; then
				echo "Menu canceled."
				return 1
			fi

			choice="${item_keys[choice_index-1]}"
			;;
	esac

	if [[ -z "${choice:-}" ]]; then
		echo "Menu canceled."
		return 1
	fi

	"$function_name" "$choice"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG=${DEBUG:-1}
	DIALOG=${DIALOG:-read}
	submenu "$@"
fi

