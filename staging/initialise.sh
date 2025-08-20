#!/usr/bin/env bash
set -euo pipefail

# ./initialise.sh - Armbian Config V2 module

initialise() {
	case "${1:-}" in
		help|-h|--help)
			_about_initialise
			;;
		*)
			_initialise_main
			;;
	esac
}

_initialise_vars() {

	# OS defined varibles
	OS_RELEASE="/etc/armbian-release"
	OS_INFO="/etc/os-release"
	source "$OS_INFO"
	source "$OS_RELEASE"

	# Config NG defined varibles
	# requres os defined
	BIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	LIB_ROOT="${LIB_ROOT:-$BIN_ROOT/../LIB}"
	WEB_ROOT="${WEB_ROOT:-$BIN_ROOT/../html}"
	DOC_ROOT="${DOC_ROOT:-$BIN_ROOT/../doc}"
	SHARE_ROOT="${SHARE_ROOT:-$BIN_ROOT/../share}"

	# TUI varibles
	# requres Config NG and os defined
	BACKTITLE="${BACKTITLE:-"Contribute: https://github.com/armbian/configng"}"
	TITLE="${TITLE:-"$VENDOR configuration utility"}"

	# Config legacy varibles
	# requres os defined
	DISTRO=${ID:-Unknown}
	DISTROID=${VERSION_CODENAME:-Unknown}
	KERNELID=$(uname -r)
	DEFAULT_ADAPTER=$(ip -4 route ls | grep default | tail -1 | grep -Po '(?<=dev )(\S+)')
	LOCALIPADD=$(ip -4 addr show dev $DEFAULT_ADAPTER | awk '/inet/ {print $2}' | cut -d'/' -f1)
	LOCALSUBNET=$(echo ${LOCALIPADD} | cut -d"." -f1-3).0/24

}


_about_initialise() {
	cat <<EOF
Usage: initialise <command> [options]

Commands:
	test        - Run a basic test of the initialise module
	foo         - Example 'foo' operation (replace with real command)
	bar         - Example 'bar' operation (replace with real command)
	help        - Show this help message

Examples:
	# Run the test operation
	initialise test

	# Perform the foo operation with an argument
	initialise foo arg1

	# Show help
	initialise help

Notes:
	- Replace 'foo' and 'bar' with real commands for your module.
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}

### START ./initialise.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(initialise help)"
	echo "$help_output" | grep -q "Usage: initialise" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	initialise "$@"
fi

### END ./initialise.sh - Armbian Config V2 test entrypoint

