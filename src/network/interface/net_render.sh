#!/usr/bin/env bash
set -euo pipefail

# src/network/interface/net_render.sh

net_render() {
	NETPLAN_FILE=$(find /etc/netplan -name '*.yaml' | head -n 1)
	if [[ ! -f "$NETPLAN_FILE" ]]; then
		echo "No Netplan config file found in /etc/netplan."
		exit 1
	fi

	CURRENT=$(awk '/renderer:/ {print $2; exit}' "$NETPLAN_FILE" || echo "none")

	case "${1:-}" in
		NetworkManager|networkd)
			TARGET="$1"
			if [[ "$CURRENT" == "$TARGET" ]]; then
				echo "Renderer already set to $TARGET."
			else
				echo "Setting renderer to $TARGET in $NETPLAN_FILE"
				sed -i "s/renderer: .*/renderer: $TARGET/" "$NETPLAN_FILE"
				if command -v netplan >/dev/null; then
					netplan apply
					echo "Netplan applied."
				else
					echo "Netplan CLI not found. Please apply changes manually if needed."
				fi
			fi
			;;
		status)
			echo "Netplan YAML: $NETPLAN_FILE"
			echo "Current renderer: $CURRENT"
			;;
		help|-h|--help)
			_about_net_render
			;;
		*)
			_about_net_render
			;;
	esac
}

_about_net_render() {
	cat <<EOF
Usage: net_render <command>

Commands:
	NetworkManager    - Set Netplan renderer to 'NetworkManager'
	networkd          - Set Netplan renderer to 'networkd'
	status            - Show current Netplan YAML and renderer
	help              - Show this help message

Examples:
	# Set the renderer to 'networkd'
	net_render networkd

	# Set the renderer to 'NetworkManager'
	net_render NetworkManager

	# Show current renderer status
	net_render status

Notes:
	- Only 'NetworkManager' and 'networkd' are supported renderers for this module.
	- Requires root privileges to modify /etc/netplan/*.yaml.
	- The renderer is changed by editing the first .yaml file found in /etc/netplan.
	- The Netplan CLI (netplan) will be used to apply changes if available.
	- If Netplan CLI is not found, you may need to apply changes manually.
	- Keep this help message up to date if commands change.

EOF
}

##---------- Start DEMO/test code block

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	TITLE="${TITLE:-net_render}" # title for dialog boxes
	DIALOG=${DIALOG:-whiptail} # options whiptail dialog
	# Load trace module
	TRACE="eurt" # Any non null will enable trace output
	source src/core/initialize/trace.sh || exit 1
	# start trace checkpoint timer
	trace reset
	trace "Loaded and started trace module"
	trace "Start trace comments"

	trace "Loading submenu module"
	source src/core/interface/submenu.sh || exit 1

	trace "loading Yes No Box module"
	source src/core/interface/yes_no_box.sh || exit 1

	trace "Loading message box module"
	source src/core/interface/ok_box.sh || exit 1

	trace "Loading Checking for Admin privileges"
	[[ $EUID != 0 ]] && ok_box <<< "this module requires root privileges" && exit 1

	trace "Loading submenu for net_render module"
	[[ ! ${1:-} ]] && submenu net_render || net_render "$@"
	trace total
	exit 0
fi

##------------- End DEMO/test code block
