#!/usr/bin/env bash
set -euo pipefail

# ./webmin.sh - Armbian Config V2 module

_about_webmin() {
	cat <<EOF
Usage: webmin <command>

Commands:
	help        - Show this help message
	install     - Install Webmin
	remove      - Remove Webmin
	start       - Start the Webmin service
	stop        - Stop the Webmin service
	enable      - Enable Webmin to start on boot
	disable     - Disable Webmin from starting on boot
	status      - Show the status of the Webmin service
	check       - Perform a basic check of Webmin

Examples:
	# Install Webmin
	webmin install

	# Start Webmin
	webmin start

	# Check Webmin status
	webmin status

Notes:
	- Maintainer: @Tearran
	- Author: @Tearran
	- Status: Active
	- Documentation: https://webmin.com/docs/
	- Port: 10000
	- Supported Architectures: x86-64 arm64 armhf
	- Group: Management

EOF
}


function webmin() {
	local title="webmin"
	local condition=$(which "$title" 2>/dev/null)


	case "${1:-}" in
		help|-h|--help)
			## help/menu options for the module
			_about_webmin
		;;
		"install")
			## install webmin
			pkg_update
			pkg_install wget apt-transport-https
			echo "deb [signed-by=/usr/share/keyrings/webmin-archive-keyring.gpg] http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
			wget -qO- http://www.webmin.com/jcameron-key.asc | gpg --dearmor | tee /usr/share/keyrings/webmin-archive-keyring.gpg > /dev/null
			pkg_update
			pkg_install webmin
			echo "Webmin installed successfully."
		;;
		remove|purge)
			## remove webmin
			srv_disable webmin
			pkg_remove webmin
			rm -f /etc/apt/sources.list.d/webmin.list
			rm -f /usr/share/keyrings/webmin-archive-keyring.gpg
			pkg_update
			echo "Webmin removed successfully."
		;;

		"start")
			srv_start webmin
			echo "Webmin service started."
			;;

		"stop")
			srv_stop webmin
			echo "Webmin service stopped."
			;;

		"enable")
			srv_enable webmin
			echo "Webmin service enabled."
			;;

		"disable")
			srv_disable webmin
			echo "Webmin service disabled."
			;;

		"status")
			srv_status webmin
			;;

		"check")
			## check webmin status
			if srv_active webmin; then
				echo "Webmin service is active."
				return 0
			elif ! srv_enabled webmin; then
				echo "Webmin service is disabled."
				return 1
			else
				echo "Webmin service is in an unknown state."
				return 1
			fi
			;;
		*)
		echo "Invalid command.try: 'webmin --help'"

		;;
	esac
}


### START ./webmin.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(webmin help)"
	echo "$help_output" | grep -q "Usage: webmin" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	webmin "$@"
fi

### END ./webmin.sh - Armbian Config V2 test entrypoint
