#!/usr/bin/env bash
set -euo pipefail

# package.sh

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
	local status=$(dpkg -s "$1" 2>/dev/null | sed -n "s/Status: //p")
	! [[ -z "$status" || "$status" = *deinstall* || "$status" = *not-installed* ]]
}


pkg_remove() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y autopurge "$@" || apt-get -y autopurge "$@"
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
	upgrade            - Upgrade installed packages
	full-upgrade       - Full system upgrade (may remove obsolete packages)
	install <pkgs>     - Install one or more packages
	remove <pkgs>      - Remove and autopurge one or more packages
	configure <pkgs>   - Configure unpacked but unconfigured packages
	installed <pkg>    - Test if a package is installed (returns 0 if present)

Examples:
	package install nano
	package installed nano && echo "nano is installed"

EOF
}

# modules/package.sh - Armbian Config V2 test

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "package - Armbian Config V2 test"
	_about_package
	exit 1
fi
