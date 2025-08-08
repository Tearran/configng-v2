#!/usr/bin/env bash
set -euo pipefail

# ./plexmediaserver.sh - Armbian Config V2 module

plexmediaserver() {
	local title="plexmediaserver"
	local condition=$(which "$title" 2>/dev/null)

	case "${1:-}" in
		help|-h|--help|"")
			_about_plexmediaserver
			;;
		"install")
			if [ ! -f /etc/apt/sources.list.d/plexmediaserver.list ]; then
				echo "deb [arch=$(dpkg --print-architecture) \
				signed-by=/usr/share/keyrings/plexmediaserver.gpg] https://downloads.plex.tv/repo/deb public main" \
				| sudo tee /etc/apt/sources.list.d/plexmediaserver.list > /dev/null 2>&1
			else
				sed -i "/downloads.plex.tv/s/^#//g" /etc/apt/sources.list.d/plexmediaserver.list > /dev/null 2>&1
			fi
			# Note: for compatibility with existing source file in some builds format must be gpg not asc
			# and location must be /usr/share/keyrings
			wget -qO- https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor \
			| sudo tee /usr/share/keyrings/plexmediaserver.gpg > /dev/null 2>&1
			pkg_update
			pkg_install plexmediaserver
		;;
		"remove")
			sed -i '/plexmediaserver.gpg/s/^/#/g' /etc/apt/sources.list.d/plexmediaserver.list
			pkg_remove plexmediaserver
		;;
		"status")
			if pkg_installed plexmediaserver; then
				return 0
			else
				return 1
			fi
		;;
		*)
			echo "Uknown command"
	esac
}

_about_plexmediaserver() {
	cat <<EOF
Usage: plexmediaserver <command> [options]

Commands:
	install       Install the Plex Media Server.
	remove        Remove the Plex Media Server.
	status        Check if the Plex Media Server is installed.
	help          Show this help message.

Examples:

	plexmediaserver install
	plexmediaserver remove
	plexmediaserver status
	plexmediaserver help

Notes:
	- This script is intended for use with Armbian Config V2.
	- It installs the Plex Media Server from the official repository.
	- The server will be available on port 32400 by default.
	- Ensure that you have the necessary permissions to run this script.
	- Use 'sudo' if required to execute commands that need elevated privileges.
	- Keep this help message up to date if commands change.

EOF
}

### START ./plexmediaserver.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(plexmediaserver help)"
	echo "$help_output" | grep -q "Usage: plexmediaserver" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	plexmediaserver "$@"
fi

### END ./plexmediaserver.sh - Armbian Config V2 test entrypoint

