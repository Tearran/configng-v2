#!/bin/bash
set -euo pipefail

# src/modules/network_manager.bash - Minimal Netplan renderer toggle for configng-v2

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
	cat <<-EOF
	Usage: network_manager [status|switch|set <renderer>|help]

	Manage and inspect the current Netplan network renderer.

	Commands:
	  status           Show current renderer, installed, and running status.
	  switch           Toggle renderer between 'networkd' and 'NetworkManager'.
	  set <renderer>   Set renderer to 'networkd' or 'NetworkManager'.
	  help             Show this help message.

	Examples:
	  sudo bash ./src/modules/network_manager.bash status
	  sudo bash ./src/modules/network_manager.bash switch
	  sudo bash ./src/modules/network_manager.bash set NetworkManager

	(relative path: src/modules/network_manager.bash)
	EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	network_manager "$@"
fi