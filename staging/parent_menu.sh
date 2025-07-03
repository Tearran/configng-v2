#!/usr/bin/env bash
set -euo pipefail

menu() {
	case "${1:-help}" in
		help|-h|--help)
			_about_menu
			#_group_menu

			;;
		*)
			show_groups_for_parent "$1"
			;;
	esac
}

_about_menu() {
	# Use keys from parent_options for menu order
	local key
	# Get all top-level sections from parent_options array
	local menu_keys
	menu_keys=$(for k in "${!parent_options[@]}"; do
		printf '%s\n' "${k%%,*}"
	done | sort -u)

	echo -e "Usage: software <command>:"
	echo -e "Commands:"
	for key in $menu_keys; do
		desc="${parent_options[$key,description]}"
		echo -e "\t$key\t- $desc"
	done
}

_group_menu() {
	# Get all unique group keys from group_options array
	local key
	local menu_keys
	menu_keys=$(for k in "${!group_options[@]}"; do
		printf '%s\n' "${k%%,*}"
	done | sort -u)

	echo -e "Usage: group <command>:"
	echo -e "Commands:"
	for key in $menu_keys; do
		desc="${group_options[$key,description]}"
		echo -e "\t$key\t- $desc"
	done
}

show_groups_for_parent() {
	local parent="$1"
	local group desc

	# Loop through all group keys in group_options
	for key in "${!group_options[@]}"; do
		# Only process keys that are descriptions
		[[ "$key" =~ ,description$ ]] || continue
		group="${key%%,*}"

		# Check if this group's parent matches the selected parent
		if [[ "${group_options[$group,parent]}" == "$parent" ]]; then
			desc="${group_options[$group,description]}"
			echo -e "\t$group\t- $desc"
		fi
	done
}

# ./software.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	declare -A parent_options
	declare -A group_options
	source lib/armbian-config/module_options_arrays.sh
	source lib/armbian-config/core.sh
	DIALOG=${DIALOG:-whiptail}
	submenu menu
fi
