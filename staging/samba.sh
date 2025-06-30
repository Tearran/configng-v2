#!/usr/bin/env bash
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


# ======= BEGIN: unit test =======
test () {
	# Make sure the array is upto date
	tools/30_consolidate_module.sh > /dev/null
	source lib/armbian-config/software.sh
	source lib/armbian-config/module_options_arrays.sh

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	test
	samba "${1:-status}"
fi


# ======= END: unit test =======
