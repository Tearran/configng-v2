#!/usr/bin/env bash
set -euo pipefail

function _about_ok_box() {
	cat <<EOF
Usage: ok_box ["message"]
Examples:
	echo "Hello from stdin" | ok_box
	ok_box <<< "Message from here-string"
EOF

}

function ok_box() {
	# Read the input from the pipe
	input=$(cat)
	TITLE="${DIALOG:-$TITLE}"

	case "${DIALOG:-}" in
	whiptail)
		whiptail --title "$TITLE" --msgbox "$input" 0 0
		;;
	dialog)
		dialog --title "$TITLE" --msgbox "$input" 0 0
		;;
	read)
		echo -e "$input"
		read -p "Press [Enter] to continue..." < /dev/tty
		;;
	*)
		echo -e "$input"
		;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DIALOG="whiptail"
	ok_box <<< "Showing a whiptail box"

	DIALOG="dialog"
	echo "Showing a dialog box" | ok_box

	DIALOG="read"
	echo "Showing read" | ok_box
fi