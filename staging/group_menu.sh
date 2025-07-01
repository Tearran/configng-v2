#!/usr/bin/env bash
set -euo pipefail

# groupmenu - Menu dispatcher for group selection under a parent

groupmenu() {
	local parent="${1:-}"
	shift || true

	if [[ -z "$parent" ]]; then
		echo "Usage: groupmenu <parent>"
		return 1
	fi

	local groups=()
	local descs=()
	local key

	# Find all groups belonging to the parent
	for key in "${!group_options[@]}"; do
		[[ "$key" =~ ,parent$ ]] || continue
		local group="${key%%,*}"
		if [[ "${group_options[$group,parent]}" == "$parent" ]]; then
			groups+=("$group")
			descs+=("${group_options[$group,description]:-No description}")
		fi
	done

	if (( ${#groups[@]} == 0 )); then
		echo "No groups found for parent: $parent"
		return 1
	fi

	# Display menu
	local choice=""
	case "${DIALOG:-read}" in
		dialog)
			local dialog_options=()
			for ((i=0; i<${#groups[@]}; i++)); do
				dialog_options+=("${groups[i]}" "${descs[i]}")
			done
			choice=$(dialog --title "${parent^} - Groups" --menu "Choose a group:" 0 80 9 "${dialog_options[@]}" 2>&1 >/dev/tty)
			;;
		whiptail)
			local whiptail_options=()
			for ((i=0; i<${#groups[@]}; i++)); do
				whiptail_options+=("${groups[i]}" "${descs[i]}")
			done
			choice=$(whiptail --title "${parent^} - Groups" --menu "Choose a group:" 0 80 9 "${whiptail_options[@]}" 3>&1 1>&2 2>&3)
			;;
		read|*)
			echo "Available groups for $parent:"
			echo "0. Cancel"
			for ((i=0; i<${#groups[@]}; i++)); do
				printf "%d. %s - %s\n" "$((i + 1))" "${groups[i]}" "${descs[i]}"
			done
			while true; do
				read -p "Enter choice number (or press Enter/0 to cancel): " choice_index
				if [[ -z "$choice_index" || "$choice_index" == "0" ]]; then
					echo "Menu canceled."
					return 1
				elif [[ "$choice_index" =~ ^[0-9]+$ ]] && (( choice_index >= 1 && choice_index <= ${#groups[@]} )); then
					break
				else
					echo "Invalid choice. Try again."
				fi
			done
			choice="${groups[choice_index-1]}"
			;;
	esac

	if [[ -z "${choice:-}" ]]; then
		echo "Menu canceled."
		return 1
	fi

	# Here you can call a function or script for the chosen group, e.g.:
	# group_${parent}_${choice} "$@"
	echo "Selected group: $choice"
}

# Unit test
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	declare -A group_options
	# Example data (replace with: source lib/armbian-config/module_options_arrays.sh)
	group_options[media,parent]="software"
	group_options[media,description]="Audio and video software"
	group_options[dev,parent]="software"
	group_options[dev,description]="Development tools"
	group_options[network,parent]="system"
	group_options[network,description]="Network configuration"
	group_options[users,parent]="system"
	group_options[users,description]="User management"

	DIALOG=${DIALOG:-read}
	groupmenu "$@"
fi