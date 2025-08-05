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



### START ./cockpit.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(cockpit help)"
	echo "$help_output" | grep -q "Usage: cockpit" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	cockpit "$@"
fi

### END ./cockpit.sh - Armbian Config V2 test entrypoint


