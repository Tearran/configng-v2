#!/usr/bin/env bash

# Print usage/help for this function.
function _about_yes_no_box() {
	cat <<EOF
Usage: yes_no_box <message> <callback_function>
	<message>           Message to show in the Yes/No dialog.
	<callback_function> Function to call with result ("No" if cancelled).
	help                Show this message.

Example:
	yes_no_box "Are you sure?" _process_yes_no_box
EOF
}

# Example callback function.
function _process_yes_no_box() {
	local input="${1:-}"
	if [[ "$input" == "No" ]]; then
		echo "User canceled. Exiting."
		exit 1
	else
		echo "User confirmed."
		# Place your custom logic here.
	fi
}

# Main yes/no dialog function.
function yes_no_box() {
	local message="${1:-}"
	local callback="${2:-}"

	if [[ "$message" == "help" || "$message" == "-h" ]]; then
		_about_yes_no_box
		return 0
	fi

	if [[ -z "$message" || -z "$callback" ]]; then
		echo "Error: Missing arguments." >&2
		_about_yes_no_box
		return 1
	fi

	# Optionally restrict callbacks here, or trust caller
	if declare -F "$callback" > /dev/null; then
		: # OK
	else
		echo "Error: Callback function '$callback' not found." >&2
		return 2
	fi

	local dialog="${DIALOG:-whiptail}"

	if "$dialog" --yesno "$message" 10 80 3>&1 1>&2 2>&3; then
		"$callback"
	else
		"$callback" "No"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG=${DEBUG:-true}
	DIALOG=${DIALOG:-whiptail}
	source ./src/initialize/debug.sh
	debug "debug initialized"
	yes_no_box "$@"  _process_yes_no_box

	debug "test complete"
	debug total
fi
