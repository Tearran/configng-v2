#!/usr/bin/env bash
set -euo pipefail

# boot_kernel.sh - Armbian Config V2 module

boot_kernel() {
	case "${1:-}" in
		help|-h|--help)
			_about_boot_kernel
			;;
		hold|freeze)
			_boot_kernel_hold
			;;
		unhold|unfreeze)
			_boot_kernel_unhold
			;;
		status)
			_boot_kernel_status
			;;
		update|upgrade)
			_boot_kernel_update
			;;
		*)
			_about_boot_kernel
			exit 1
			;;
	esac
}

_boot_kernel_hold() {
	echo "Holding kernel, bootloader (U-Boot), and related Armbian packages..."
	for pkg in $(dpkg -l | awk '/^ii/ && ($2 ~ /linux-/ || $2 ~ /armbian-/) {print $2}'); do
		echo "Holding package: $pkg"
		sudo apt-mark hold "$pkg"
	done
	echo "Hold complete."
}

_boot_kernel_unhold() {
	echo "Unholding kernel, bootloader (U-Boot), and related Armbian packages..."
	for pkg in $(apt-mark showhold | grep -E 'linux-|armbian-'); do
		echo "Unholding package: $pkg"
		sudo apt-mark unhold "$pkg"
	done
	echo "Unhold complete."
}

_boot_kernel_status() {
	echo "Status of kernel, bootloader (U-Boot), and related Armbian packages:"
	echo
	echo "Held packages:"
	apt-mark showhold | grep -E 'linux-|armbian-' || echo "None"
	echo
	echo "Upgradable packages (related):"
	apt list --upgradable 2>/dev/null | grep -E 'linux-|armbian-' || echo "None"
}

_boot_kernel_update() {
	echo "Updating kernel, bootloader (U-Boot), and related Armbian packages..."
	sudo apt update
	relevant_pkgs=$(apt list --upgradable 2>/dev/null | grep -E 'linux-|armbian-' | cut -d/ -f1)
	if [[ -z "$relevant_pkgs" ]]; then
		echo "No upgradable kernel or Armbian-related packages found."
	else
		echo "Upgrading packages: $relevant_pkgs"
		sudo apt install $relevant_pkgs
	fi
	echo "Update complete."
}

_about_boot_kernel() {
	cat <<EOF
Usage: boot_kernel <command> [options]

Commands:
	hold		- Hold all kernel, bootloader (U-Boot), and related Armbian packages (prevent updates)
	unhold		- Unhold all kernel, bootloader (U-Boot), and related Armbian packages (allow updates)
	status         	- Show hold and upgrade status of kernel, bootloader (U-Boot), and related Armbian packages
	upgrade		- Update all kernel, bootloader (U-Boot), and related Armbian packages to the latest available version
	help            - Show this help message

Examples:
	boot_kernel hold
	boot_kernel unhold
	boot_kernel status
	boot_kernel update
	boot_kernel help

Notes:
	- This module is intended for use with the Armbian Config V2 menu and scripting.
	- It will operate on all installed packages matching 'linux-*' or 'armbian-*'.
	- Keep this help message up to date if commands change.
EOF
}

### START ./boot_kernel.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(boot_kernel help)"
	echo "$help_output" | grep -q "Usage: boot_kernel" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	boot_kernel "$@"
fi

### END ./boot_kernel.sh - Armbian Config V2 test entrypoint