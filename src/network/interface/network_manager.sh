#!/usr/bin/env bash
set -euo pipefail

# src/network/interface/network_manager.sh

network_manager() {
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
			_about_network_manager
			;;
		*)
			_about_network_manager
			;;
	esac
}

_about_network_manager() {
	cat <<EOF
Usage: network_manager <command>

Commands:
	NetworkManager    - Set Netplan renderer to 'NetworkManager'
	networkd          - Set Netplan renderer to 'networkd'
	status            - Show current Netplan YAML and renderer
	help              - Show this help message

Examples:
	# Set the renderer to 'networkd'
	network_manager networkd

	# Set the renderer to 'NetworkManager'
	network_manager NetworkManager

	# Show current renderer status
	network_manager status

Notes:
	- Only 'NetworkManager' and 'networkd' are supported renderers for this module.
	- Requires root privileges to modify /etc/netplan/*.yaml.
	- The renderer is changed by editing the first .yaml file found in /etc/netplan.
	- The Netplan CLI (netplan) will be used to apply changes if available.
	- If Netplan CLI is not found, you may need to apply changes manually.
	- Keep this help message up to date if commands change.

EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	source lib/armbian-config/core.sh
	submenu network_manager
fi
