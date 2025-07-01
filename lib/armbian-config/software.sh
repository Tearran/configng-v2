
####### ./src/software/transfer/samba.sh #######
set -euo pipefail

samba() {
	local title="samba"
	local condition
	condition=$(command -v smbd || true)

	# Set the interface for dialog tools (if needed; stub for now)
	# set_interface

	# Define commands
	local commands=(help install remove start stop enable disable configure default status)
	case "${1:-}" in
		help|"")
			_about_samba
			;;
		install)
			pkg_install samba
			if [[ ! -f "/etc/samba/smb.conf" ]]; then
				if [[ -f "/usr/share/samba/smb.conf" ]]; then
					cp "/usr/share/samba/smb.conf" "/etc/samba/smb.conf"
				else
					echo "Warning: Missing configuration file. Use the <configure> option."
				fi
			fi
			echo "Samba installed successfully."
			;;
		remove)
			srv_disable smbd
			pkg_remove samba
			echo "$title remove complete."
			;;
		start)
			srv_start smbd
			echo "Samba service started."
			;;
		stop)
			srv_stop smbd
			echo "Samba service stopped."
			;;
		enable)
			srv_enable smbd
			echo "Samba service enabled."
			;;
		disable)
			srv_disable smbd
			echo "Samba service disabled."
			;;
		configure|default)
			echo "Using package default configuration..."
			if [[ -f "/usr/share/samba/smb.conf" && -d "/etc/samba" ]]; then
				cp /usr/share/samba/smb.conf /etc/samba/smb.conf
				echo "Default configuration copied to /etc/samba/smb.conf."
			else
				[[ ! -f "/usr/share/samba/smb.conf" ]] && echo "Error: /usr/share/samba/smb.conf not found."
				[[ ! -d "/etc/samba" ]] && echo "Error: /etc/samba directory does not exist."
				return 1
			fi
			;;
		status)
			if srv_active smbd; then
				echo "active"
				return 0
			elif ! srv_enabled smbd; then
				echo "inactive"
				return 1
			else
				echo "Samba service is in an unknown state."
				return 1
			fi
			;;
		*)
			echo "Invalid command. Try: ${commands[*]}"
			;;
	esac
}

_about_samba() {
	cat <<EOF
Usage: samba <command>

Commands:
	install    - Install Samba package and default configuration
	remove     - Remove Samba and disable service
	start      - Start Samba service
	stop       - Stop Samba service
	enable     - Enable Samba service at boot
	disable    - Disable Samba service at boot
	configure  - Copy default Samba configuration (if missing)
	default    - Same as 'configure'
	status     - Show Samba service status
	help       - Show this help message

Examples:
	samba install
	samba start
	samba status

Notes:
	- Requires package manager and service management helpers.
	- Output is simple for integration with config-v2 UI/scripts.

EOF
}





####### ./src/software/user/cockpit.sh #######


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



