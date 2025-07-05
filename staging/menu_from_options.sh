#!/usr/bin/env bash
# src/core/menu_from_options.sh

menu_from_options() {
	local help_message
	if [[ -t 0 ]]; then
		help_message="$1"
	else
		help_message="$(cat)"
	fi

	local menu_items=()
	local item_keys=()
	while IFS= read -r line; do
		if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*-[[:space:]]*(.*)$ ]]; then
			menu_items+=("${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}")
			item_keys+=("${BASH_REMATCH[1]}")
		fi
	done <<< "$help_message"

	if (( ${#menu_items[@]} == 0 )); then
		echo "No menu items found in help message."
		return 1
	fi

	local choice=""
	if command -v whiptail >/dev/null 2>&1 && [[ "${DIALOG:-}" == "whiptail" ]]; then
		local whiptail_options=()
		for ((i=0; i<${#item_keys[@]}; i++)); do
			whiptail_options+=("${item_keys[i]}" "${menu_items[i]#*- }")
		done
		choice=$(whiptail --title "Menu" --menu "Choose an option:" 0 70 10 "${whiptail_options[@]}" 3>&1 1>&2 2>&3)
	elif command -v dialog >/dev/null 2>&1; then
		local dialog_options=()
		for ((i=0; i<${#item_keys[@]}; i++)); do
			dialog_options+=("${item_keys[i]}" "${menu_items[i]#*- }")
		done
		choice=$(dialog --title "Menu" --menu "Choose an option:" 0 70 10 "${dialog_options[@]}" 2>&1 >/dev/tty)
	else
		echo "Available options:"
		echo "0. Cancel"
		for ((i=0; i<${#menu_items[@]}; i++)); do
			printf "%d. %s\n" "$((i + 1))" "${menu_items[i]}"
		done
		while true; do
			read -p "Enter choice number (or 0 to cancel): " choice_index
			if [[ -z "$choice_index" || "$choice_index" == "0" ]]; then
				echo "Menu canceled."
				return 1
			elif [[ "$choice_index" =~ ^[0-9]+$ ]] && (( choice_index >= 1 && choice_index <= ${#item_keys[@]} )); then
				choice="${item_keys[choice_index-1]}"
				break
			else
				echo "Invalid choice. Try again."
			fi
		done
	fi

	if [[ -z "$choice" ]]; then
		echo "Menu canceled."
		return 1
	fi

	echo "$choice"
}


_about_menu_from_options() {
	cat <<-EOF
	Usage: menu_from_options [HELP_MESSAGE]
	Parse a usage/help message and present the commands as an interactive menu.
	- Accepts a string argument or reads from stdin.
	- Uses whiptail (preferred), dialog, or plain read (fallback).
	- Returns the selected command string on success.

	Example:
		help_msg="Usage: configng_v2.sh [options]
		  adjust_motd     - Adjust welcome screen (motd)
		  cockpit         - Web-based admin interface for managing Linux servers.
		  package         - Helpers for bulk package operations."
		choice=\$(menu_from_options "\$help_msg")
		[[ -n "\$choice" ]] && echo "You chose: \$choice"

	Notes:
	- Intended for use in configng-v2 modules and scripts.
	- Only parses lines matching '<command> - <description>'.
	- Set DIALOG=dialog to prefer dialog, otherwise whiptail is default.
	EOF
}

# test/demo block (safe to remove if not needed)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	help_msg="Usage: configng_v2.sh [options]
		adjust_motd     - Adjust welcome screen (motd)
		cockpit         - Web-based administrative interface for managing Linux servers.
		network_manager - Minimal Netplan renderer switcher for configng-v2.
		package         - Helpers for bulk packages operations.
		service         - Systemd service management helpers."
	selection=$(menu_from_options "$help_msg")
	[[ -n "$selection" ]] && echo "You chose: $selection"
fi

