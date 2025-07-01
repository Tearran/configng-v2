
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





####### ./src/software/internal/service.sh #######

# src/software/internal/service.sh

_srv_system_running() {
	[[ $(systemctl is-system-running) =~ ^(running|degraded)$ ]];
}


srv_active() {
	# fail inside container
	_srv_system_running && systemctl is-active --quiet "$@"
}


srv_daemon_reload() {
	# ignore inside container
	_srv_system_running && systemctl daemon-reload || true
}

srv_disable() {
	systemctl disable "$@";
}


srv_enable() {
	systemctl enable "$@";
}



srv_enabled() {
	systemctl is-enabled "$@";
}

srv_mask() {
	systemctl mask "$@";
}


srv_reload() {
	# ignore inside container
	_srv_system_running && systemctl reload "$@" || true
}


srv_restart() {
	# ignore inside container
	_srv_system_running && systemctl restart "$@" || true
}


srv_start() {
	# ignore inside container
	_srv_system_running && systemctl start "$@" || true
}


srv_status() {
	systemctl status "$@";
}


srv_stop() {
	# ignore inside container
	_srv_system_running && systemctl stop "$@" || true
}


srv_unmask() {
	systemctl unmask "$@";
}

service() {
	case "${1:-}" in
		active)         shift; srv_active "$@";;
		daemon-reload)  shift; srv_daemon_reload "$@";;
		disable)        shift; srv_disable "$@";;
		enable)         shift; srv_enable "$@";;
		enabled)        shift; srv_enabled "$@";;
		mask)           shift; srv_mask "$@";;
		reload)         shift; srv_reload "$@";;
		restart)        shift; srv_restart "$@";;
		start)          shift; srv_start "$@";;
		status)         shift; srv_status "$@";;
		stop)           shift; srv_stop "$@";;
		unmask)         shift; srv_unmask "$@";;
		help|-h|--help|"")
			_about_service
			;;
		*)
			echo "Unknown command: $1" >&2
			_about_service
			return 1
			;;
	esac
}

_about_service() {
	cat <<EOF
Usage: service <command> [service_name]

Commands:
	active <service>         - Test if the service is active (running)
	daemon-reload            - Reload systemd manager configuration
	disable <service>        - Disable the service (prevent start at boot)
	enable <service>         - Enable the service (start at boot)
	enabled <service>        - Test if the service is enabled
	mask <service>           - Mask the service (prevent all starts)
	reload <service>         - Reload the service (if supported)
	restart <service>        - Restart the service
	start <service>          - Start the service
	status <service>         - Show status for the service
	stop <service>           - Stop the service
	unmask <service>         - Unmask the service
	help                     - Show this help message

Examples:
	# Start the ssh service
	service start ssh

	# Check if ssh is enabled and print a message
	service enabled ssh && echo "ssh enabled"

Notes:
	- All commands should be run as root or with appropriate permissions.
	- 'active', 'enabled', and similar commands return 0 for true, nonzero for false.
	- Commands that alter services (start, stop, enable, etc.) will not execute inside containers if systemd is not running.
	- This module is intended for use with the config-v2 menu and scripts.
	- See systemctl(1) for additional options and details.
	- Keep this help message up to date if commands change.

EOF
}




####### ./src/software/internal/package.sh #######

# src/software/internal/package.sh

# internal function
_pkg_have_stdin() { [[ -t 0 ]]; }


pkg_configure() {
	_pkg_have_stdin && debconf-apt-progress -- dpkg --configure "$@" || dpkg --configure "$@"
}


pkg_full_upgrade() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y full-upgrade "$@" || apt-get -y full-upgrade "$@"
}


pkg_install() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y install "$@" || apt-get -y install "$@"
}


pkg_installed() {
	local status
	status=$(dpkg -s "$1" 2>/dev/null | sed -n 's/Status: //p')
	! [[ -z "$status" || "$status" = *deinstall* || "$status" = *not-installed* ]]
}


pkg_remove() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y remove --purge --auto-remove "$@" \
		|| apt-get -y remove --purge --auto-remove "$@"
}


pkg_update() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y update || apt-get -y update
}


pkg_upgrade() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y upgrade "$@" || apt-get -y upgrade "$@"
}

package() {
	case "${1:-}" in
		update)           shift; pkg_update "$@";;
		upgrade)          shift; pkg_upgrade "$@";;
		full-upgrade)     shift; pkg_full_upgrade "$@";;
		install)          shift; pkg_install "$@";;
		remove)           shift; pkg_remove "$@";;
		configure)        shift; pkg_configure "$@";;
		installed)        shift; pkg_installed "$@";;
		help|-h|--help|"")
			_about_package
			;;
		*)
			echo "Unknown command: $1" >&2
			_about_package
			return 1
			;;
	esac
}

_about_package() {
	cat <<EOF
Usage: package <command> [package_name(s)]

Commands:
	update             - Update APT package lists
	upgrade            - Upgrade all installed packages
	full-upgrade       - Perform a full system upgrade (may remove obsolete packages)
	install <pkgs>     - Install one or more packages
	remove <pkgs>      - Remove and autopurge one or more packages
	configure <pkgs>   - Configure unpacked but unconfigured packages
	installed <pkg>    - Test if a package is installed (returns 0 if present)
	help               - Show this help message

Examples:
	# Install nano
	package install nano

	# Check if nano is installed and print a message
	package installed nano && echo "nano is installed"

Notes:
	- All commands use apt and require root privileges.
	- 'installed' returns success (0) if the package is present, nonzero otherwise.
	- Use quotes for multiple package names: package install "pkg1 pkg2"
	- This module is intended for use with the config-v2 menu and scripts.
	- Keep this help message up to date if any commands change.

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



