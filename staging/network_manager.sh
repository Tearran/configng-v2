#!/bin/bash
set -euo pipefail

# network_manager - Armbian Config V3 module

network_manager() {

	NETPLAN_FILE=$(find /etc/netplan -name '*.yaml' | head -n 1)

	if [[ ! -f "$NETPLAN_FILE" ]]; then
		echo "No Netplan config file found."
		exit 1
	fi

	CURRENT=$(grep 'renderer:' "$NETPLAN_FILE" | awk '{print $2}')
	TARGET=""

	if [[ "$CURRENT" == "networkd" ]]; then
		TARGET="NetworkManager"
	elif [[ "$CURRENT" == "NetworkManager" ]]; then
		TARGET="networkd"
	else
		echo "Unknown or missing renderer. Defaulting to NetworkManager."
		TARGET="NetworkManager"
	fi

	echo "Switching renderer from $CURRENT to $TARGET"
	sudo sed -i "s/renderer: .*/renderer: $TARGET/" "$NETPLAN_FILE"

	echo "Applying Netplan..."
	sudo netplan apply

	if [[ "$TARGET" == "NetworkManager" ]]; then
		echo "Enabling NetworkManager..."
		sudo apt install -y network-manager
		sudo systemctl enable --now NetworkManager
	else
		echo "Enabling systemd-networkd..."
		sudo systemctl enable --now systemd-networkd
	fi

	echo "Renderer switched to $TARGET."
}

_about_network_manager() {
	# TODO: implement standard help message
	echo "use: network_manager - ..."
	echo "help - this message"
}

# network_manager - Armbian Config V3 Test

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "network_manager - Armbian Config V3 test"
	echo "# TODO: implement module logic"
	exit 1
fi

