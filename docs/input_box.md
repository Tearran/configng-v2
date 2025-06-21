#!/usr/bin/env bash
set -euo pipefail

_about_input_box() {
	cat <<EOF
Usage: input_box ["prompt_message"] [default_value]
Prompt the user for input using whiptail, dialog, or shell.
Returns the user input via stdout.

Examples:
	echo "Enter your name:" | input_box
	input_box <<< "Enter password:"
	input_box "Enter hostname:" "localhost"
	result=$(input_box "Enter port:" "8080")

Pass "help" or "-h" as the message to show this help.
EOF
}

input_box() {
	local message="${1:-$(cat)}"
	local default_value="${2:-}"

	if [ "$message" = "help" ] || [ "$message" = "-h" ]; then
		_about_input_box
		return 0
	fi
	if [ -z "$message" ]; then
		echo "Error: Missing prompt message" >&2
		return 2
	fi

	local result
	local title="${TITLE:-Input}"

	case "$DIALOG" in
		whiptail)
			result=$(whiptail --title "$title" --inputbox "$message" 10 60 "$default_value" 3>&1 1>&2 2>&3) || return $?
			echo "$result"
			return 0
			;;
		dialog)
			result=$(dialog --title "$title" --inputbox "$message" 10 60 "$default_value" 3>&1 1>&2 2>&3) || return $?
			echo "$result"
			return 0
			;;
		read)
			echo "$message"
			if [ -n "$default_value" ]; then
				read -p "[$default_value]: " -e -i "$default_value" result < /dev/tty
			else
				read -p ": " result < /dev/tty
			fi
			echo "$result"
			return 0
			;;
		"") # DIALOG not set
			echo "Error: DIALOG variable not set" >&2
			return 3
			;;
		*) # Unknown backend
			echo "Error: Unknown dialog backend: $DIALOG" >&2
			return 4
			;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DIALOG="whiptail"
	TITLE="$DIALOG Test"
	result=$(input_box <<< "Enter your name (whiptail):")
	echo "You entered: $result"

	DIALOG="dialog"
	TITLE="$DIALOG Test"
	result=$(input_box "Enter your email (dialog):" "user@example.com")
	echo "You entered: $result"

	DIALOG="read"
	TITLE="$DIALOG Test"
	result=$(input_box "Enter a number (read):" "42")
	echo "You entered: $result"
fi
</newLines>
<newLines>
#!/bin/bash
set -euo pipefail

# input_box - Armbian Config V3 module
# This module has been moved to src/framework/input_box.sh

# Source the actual implementation
source "$(dirname "${BASH_SOURCE[0]}")/../src/framework/input_box.sh"