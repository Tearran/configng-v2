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
	local input
	if [[ -n "${1:-}" ]]; then
		input="$1"
	elif [ -p /dev/stdin ]; then
		input="$(cat)"
	fi
	TITLE="${TITLE:-}"


	if [ "$input" = "help" ] || [ "$input" = "-h" ]; then
		_about_ok_box
		return 0
	fi
	if [ -z "$input" ]; then
		echo "Error: Missing message argument" >&2
		return 2
	fi

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
	ok_box "$@"

fi
