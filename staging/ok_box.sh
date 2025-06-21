#!/usr/bin/env bash
set -euo pipefail

function _about_ok_box() {
	cat <<EOF
Usage: ok_box ["message"]
Examples:
	ok_box "Operation completed successfully."
	echo "Hello from stdin" | ok_box
	ok_box <<< "Message from here-string"
EOF

}

function ok_box() {
	local message="${1:-}"

	if [[ "$message" == "help" || "$message" == "-h" ]]; then
		_about_ok_box
		return 0
	fi

	if [[ -z "$message" ]]; then
		echo "Error: Missing message." >&2
		_about_ok_box
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


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "ok_box - Armbian Config V3 test"
	echo "# TODO: implement module logic"
	exit 1
fi

