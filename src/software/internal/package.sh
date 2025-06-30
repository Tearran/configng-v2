#!/usr/bin/env bash
set -euo pipefail

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

# ======= BEGIN: unit test =======

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	source lib/armbian-config/core.sh
	submenu package

fi

# ======= END: unit test =======
