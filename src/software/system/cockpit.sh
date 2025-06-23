#!/usr/bin/env bash
set -euo pipefail

# cockpit - mini module
# Relative path: src/software/system/cockpit.sh

_about_cockpit() {
	cat <<-EOF
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
	EOF
}

cockpit() {
	# Check for root privileges
	if [[ $EUID -ne 0 ]]; then
		echo "Error: Please run as root (use sudo or log in as root)" >&2
		return 1
	fi

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
		help|--help|-h|"")
			_about_cockpit
			;;
		*)
			echo "Unknown command: $1"
			echo "Try: cockpit help"
			return 1
			;;
	esac
}

# DEMO Menu Interface
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# If running in CI, run the cockpit function with any arguments
	if [[ -n "${1:-}" ]]; then
		# CI automation
		cockpit "$@"
	else
		# DEMO submenu integration
		DEBUG=${DEBUG:-1}
		source src/core/initialize/debug.sh
		debug reset
		DIALOG=${DIALOG:-read}
		source ./src/core/interface/submenu.sh
		debug "showing a \$DIALOG based menu"
		debug "try: DIALOG=whiptail command"
		submenu cockpit
	fi
fi
