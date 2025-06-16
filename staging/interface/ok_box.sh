#!/usr/bin/env bash


function _about_interface_message() {
	cat <<EOF
Usage: interface_message ["message"]
Examples:
	interface_ok_box "Operation completed successfully."
	echo "Hello from stdin" | interface_ok_box
	interface_ok_box <<< "Message from here-string"
EOF

}

function interface_ok_box() {
	local message="${1:-}"

	if [[ "$message" == "help" || "$message" == "-h" ]]; then
		_about_interface_message
		return 0
	fi

	if [[ -z "$message" ]]; then
		echo "Error: Missing message." >&2
		_about_interface_message
		return 1
	fi

	local dialog="${DIALOG:-whiptail}"

	case "$dialog" in
		dialog)
			dialog --title "${TITLE:-Info}" --msgbox "$message" 10 80 >/dev/tty 2>&1
			;;
		whiptail)
			whiptail --title "${TITLE:-Info}" --msgbox "$message" 10 80 3>&1 1>&2 2>&3
			;;
		read)
			echo "$message"
			;;
		*)
			echo "$message"
			return 1
			;;
	esac
}
