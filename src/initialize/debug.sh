#!/bin/bash
set -euo pipefail

# debug - Armbian Config V3 module

debug() {
	local cmd="${1:-}" msg="${2:-}"
	case "$cmd" in
		help)
			_about_debug
			;;
		reset)
			_debug_start=$(date +%s)
			_debug_time=$_debug_start
			;;
		total)
			if [[ -n "${DEBUG:-}" ]]; then
				_debug_time=${_debug_start:-$(date +%s)}
				debug "TOTAL time elapsed"
			fi
			debug reset
			;;
		*)
			if [[ -n "${DEBUG:-}" ]]; then
				local now elapsed
				now=$(date +%s)
				: "${_debug_time:=$now}"  # Initialize if unset
				elapsed=$((now - _debug_time))
				printf "%-30s %4d sec\n" "$cmd" "$elapsed"
				_debug_time=$now
			fi
			;;
	esac
}


# Displays usage information and available options for the debug function.
#
# Outputs:
#
# * Prints help text to STDOUT, describing how to use the debug utility and its available commands.
#
# Example:
#
# ```bash
# _about_debug
# ```
_about_debug() {
	cat <<-EOF

Usage: debug <option> || <"message string">
	Options:
		"message string"   Show debug message (DEBUG non-zero)
		reset              (Re)set starting point
		total              Show total time and reset
		help               Show this help screen

	When providing a "message string", elapsed time since last debug call is shown if DEBUG is set.
	EOF
}
