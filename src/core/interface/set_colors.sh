#!/usr/bin/env bash
set -euo pipefail

# src/core/interface/set_colors.sh

_about_set_colors() {
	cat <<-EOF
	Usage: set_colors <code>
	Set terminal and whiptail/dialog background color.
	Colors: 0=black, 1=red, 2=green, 3=yellow, 4=blue, 5=magenta, 6=cyan, 7=white

	Examples:
		set_colors 0   # Black
		set_colors 3   # Yellow
	Notes:
		- Whiptail/dialog backgrounds use NEWT_COLORS.
		- Terminal color codes use ANSI sequences (may not work on all emulators).
		- _reset_colors restores defaults and clears visible screen.
	EOF
}

_set_colors() {
	local color_code="${1:-0}"	# Default to black (0) if not set
		_set_newt_colors "$color_code"
		_set_term_colors "$color_code"
}

# Helper: set whiptail (newt) background color
_set_newt_colors() {
	local code="${1:-0}"
	local color
	case "$code" in
		0) color="black" ;;
		1) color="red" ;;
		2) color="green" ;;
		3) color="yellow" ;;
		4) color="blue" ;;
		5) color="magenta" ;;
		6) color="cyan" ;;
		7) color="white" ;;
		*) echo "Invalid color code for whiptail"; return 1 ;;
	esac
	export NEWT_COLORS="root=,$color"
}

# Helper: (terminal) background color
# may not work on all terminals, but should work on most
_set_term_colors() {
	local code="${1:-0}"
	local seq
	case "$code" in
		0) seq="\e[40m" ;; # black
		1) seq="\e[41m" ;; # red
		2) seq="\e[42m" ;; # green
		3) seq="\e[43m" ;; # yellow
		4) seq="\e[44m" ;; # blue
		5) seq="\e[45m" ;; # magenta
		6) seq="\e[46m" ;; # cyan
		7) seq="\e[47m" ;; # white
		*) echo "Invalid color code for dialog"; return 1 ;;
	esac
	echo -e "$seq"
}

# Helper: reset terminal colors to default
_reset_colors() {
	echo -e "\e[H\e[2J"
	echo -e "\e[0m"
	echo -e "\e[H\e[2J"
}

# Main entry: safe for sourcing or running directly
set_colors() {
	local case="${1:-}"
	case "$case" in
		--help|-h|help)
			_about_module_name
			return 0
			;;
		*)
			_set_colors "${1:-0}"
			;;
	esac
}

# Demo/test block (run directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo -e "\e[H\e[2J"
	set_colors "${1:-0}"
	whiptail --title "Dark Demo" --msgbox "This is a dark backgroound whiptail box." 10 40
	echo -e "\e[H\e[2J"
	echo -e "\nThis is a Dark backgroound CLI."
	sleep 1
	_reset_colors
fi