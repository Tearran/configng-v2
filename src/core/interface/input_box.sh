#!/usr/bin/env bash
set -euo pipefail

_about_input_box() {
	cat <<EOF
Usage: input_box ["prompt"]
Prompts the user for a line of input using whiptail, dialog, or shell fallback.

Examples:
	echo "Enter your name:" | input_box
	input_box <<< "Type your username:"
	input_box "What is your password?"

Pass "help" or "-h" as the prompt to see this help.
EOF
}

input_box() {
	local prompt reply code
	# Accept prompt from positional arg, stdin, or fallback
	if [[ -n "${1:-}" ]]; then
		prompt="$1"
	elif [ -p /dev/stdin ]; then
		prompt="$(cat)"
		# Strip leading/trailing whitespace
		prompt="${prompt#"${prompt%%[![:space:]]*}"}"
		prompt="${prompt%"${prompt##*[![:space:]]}"}"
	else
		echo "Error: No prompt provided." >&2
		_about_input_box
		return 1
	fi

	# Help
	if [[ "$prompt" == "help" ]] || [[ "$prompt" == "-h" ]]; then
		_about_input_box
		return 0
	fi

	case "${DIALOG:-}" in
		whiptail)
			reply=$(whiptail --title "${TITLE:-Input}" --inputbox "$prompt" 10 60 3>&1 1>&2 2>&3)
			code=$?
			;;
		dialog)
			reply=$(dialog --title "${TITLE:-Input}" --inputbox "$prompt" 10 60 3>&1 1>&2 2>&3)
			code=$?
			;;
		read)
			echo "$prompt"
			read -p "> " reply < /dev/tty
			code=0
			;;
		"")
			echo "Error: DIALOG variable not set" >&2
			return 3
			;;
		*)
			echo "Error: Unknown dialog backend: $DIALOG" >&2
			return 4
			;;
	esac

	if [[ $code -eq 0 ]]; then
		echo "$reply"
		return 0
	else
		return $code
	fi
}

# Demo block (only runs if called directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DIALOG="${DIALOG:-whiptail}"
	TITLE="$DIALOG"
	# Source ok_box.sh unless already in it
	if [[ "$(basename "${BASH_SOURCE[0]}")" != "ok_box.sh" ]]; then
		source ./src/core/interface/ok_box.sh
	fi
	ok_box <<< "$(input_box "Enter something:")"

fi
