#!/usr/bin/env bash
set -euo pipefail


# src/software/system/cockpit.sh

_about_cockpit() {
	cat <<EOF
Usage: cockpit <command>

Commands:
	install    - Install Cockpit
	remove     - Remove Cockpit
	start      - Start Cockpit (socket + service)
	stop       - Stop Cockpit (socket + service)
	status     - Show Cockpit install/running status
	enable     - Enable Cockpit at boot
	disable    - Disable Cockpit at boot
	help       - Show this help message
Examples:
	# Check cockpits operation status
	cockpit status

	# Use the submenu to display a tui
	submenu cockpit

	# Show help
	cockpit help

Notes:

	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}

cockpit() {
	case "${1:-}" in
		install)
			echo "Installing Cockpit..."
			apt update && apt install -y cockpit
			;;
		remove)
			echo "Removing Cockpit..."
			apt remove --purge -y cockpit
			;;
		start)
			echo "Starting Cockpit (enabling socket)..."
			systemctl start cockpit.socket
			;;
		stop)
			echo "Stopping Cockpit service and socket..."
			systemctl stop cockpit.socket cockpit.service
			;;
		status)
			if ! dpkg -s cockpit &>/dev/null; then
				echo "Cockpit is not installed."
				return 1
			fi
			if systemctl is-active --quiet cockpit.socket; then
				echo "Cockpit is installed and running (socket active)."
			elif systemctl is-active --quiet cockpit; then
				echo "Cockpit is installed and running (service active)."
			else
				echo "Cockpit is installed but not running."
			fi
			;;
		enable)
			echo "Enabling Cockpit at boot (socket)..."
			systemctl enable cockpit.socket
			;;
		disable)
			echo "Disabling Cockpit at boot (socket)..."
			systemctl disable cockpit.socket
			;;
		help|--help|-h)
			_about_cockpit
			;;
		*)
			echo "Unknown command: $1"
			echo "Try: cockpit help"
			return 1
			;;
	esac
}



if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	TITLE="${TITLE:-"Cockpit"}" # title for dialog boxes
	DIALOG=${DIALOG:-whiptail} # options whiptail dialog

	# Load trace module
	TRACE="eurt" # Any non null will enable trace output
	source src/core/initialize/trace.sh || exit 1

	# start trace checkpoint timer
	trace reset
	trace "Loaded and started trace module"
	trace "Start trace comments"

	trace "Loading submenu module"
	source src/core/interface/submenu.sh || exit 1

	trace "loading Yes No Box module"
	source src/core/interface/yes_no_box.sh || exit 1

	trace "Loading OK box module"
	source src/core/interface/ok_box.sh || exit 1

	trace "Loading info box module"
	source src/core/interface/info_box.sh || exit 1

	trace "Check if not root and first argument is empty"

	trace "Loading submenu for cockpit module"
	[[ ! ${1:-} ]] && submenu cockpit || cockpit "$@"
	trace total
	exit 0


fi


