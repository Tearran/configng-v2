#!/usr/bin/env bash
set -euo pipefail

_about_ok_box() {
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
	TITLE="${TITLE:-}"

	case "$DIALOG" in
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
	TITLE="${TITLE:-$DIALOG}"
	ok_box <<< "Showing $DIALOG box"

	DIALOG="dialog"
	TITLE="$DIALOG"
	echo "Showing a $DIALOG box" | ok_box

	DIALOG="read"
	TITLE="$DIALOG"
	ok_box <<< "Showing $DIALOG promt"
fi
