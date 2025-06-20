#!/usr/bin/env bash

_about_info_box() {
	cat <<EOF
Usage: info_box

Displays a rolling info box using dialog/whiptail.
Reads lines from stdin and displays them live.
If not used with a pipe, shows a single message.

Examples:

	echo <"string" or command> | info_box
	info_box <<< command or strings
	info_box -h --help help
EOF
}

info_box() {
	# Help flag: show about if -h or --help is the first argument
	case "${1:-}" in
		-h|--help|help)
			_about_info_box
			return 0
			;;
	esac

	local input
	local dialog="${DIALOG:-}"
	if [[ "$dialog" != "dialog" && "$dialog" != "whiptail" ]]; then
		dialog="whiptail"
	fi
	local title="${TITLE:-Info}"
	local -a buffer
	local lines=16 width=90 max_lines=18

	if [ -p /dev/stdin ]; then
		while IFS= read -r line; do
			buffer+=("$line")
			# Limit buffer size to max_lines
			((${#buffer[@]} > max_lines)) && buffer=("${buffer[@]:1}")
			# Show buffer in infobox
			TERM=ansi $dialog --title "$title" --infobox "$(printf "%s\n" "${buffer[@]}")" $lines $width
			sleep 0.5
		done
	else
		input="${1:-}"
		if [[ -z "$input" ]]; then
			echo "Error: No input provided." >&2
			_about_info_box
			return 1
		fi
		TERM=ansi $dialog --title "$title" --infobox "$input" 6 80
		sleep 2
	fi
	echo -ne '\033[3J' # clear the screen
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG=${DEBUG:-true}
	source ./src/initialize/debug.sh
	debug "debug initialized"
	info_box "$@"
	# --- end assertion ---

	debug "$help_output"
	debug "test complete"
	debug total

fi
