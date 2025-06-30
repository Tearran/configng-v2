#!/usr/bin/env bash
set -euo pipefail

_about_yes_no_box() {
	cat <<EOF
Usage: yes_no_box ["message"]
Prompt the user for a Yes/No answer using whiptail, dialog, or shell.

Examples:
	echo "Proceed with install?" | yes_no_box
	yes_no_box <<< "Continue with upgrade?"
	yes_no_box "Are you sure you want to reboot?"

Pass "help" or "-h" as the message to show this help.
EOF
}

yes_no_box() {
	local message="${1:-$(cat)}"
	if [ "$message" = "help" ] || [ "$message" = "-h" ]; then
		_about_yes_no_box
		return 0
	fi
	if [ -z "$message" ]; then
		echo "Error: Missing message argument" >&2
		return 2
	fi

	case "$DIALOG" in
		whiptail)
			whiptail --title "$TITLE" --yesno "$message" 10 60
			return $?
			;;
		dialog)
			dialog --title "$TITLE" --yesno "$message" 10 60
			return $?
			;;
		read)
			echo "$message"
			read -p "[y/N]: " reply < /dev/tty
			if [ "${reply,,}" != "y" ]; then
				echo "Canceled."
				return 1
			fi
			return 0
			;;
		"") # DIALOG not set
			echo "Error: DIALOG variable not set" >&2
			return 3
			;;
		*)
			echo "Error: Unknown dialog backend: $DIALOG" >&2
			return 4
			;;
	esac
}


# ======= BEGIN: unit test =======

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DIALOG="whiptail"
	TITLE="$DIALOG"
	yes_no_box "$@"
fi

# ======= END: unit test =======
