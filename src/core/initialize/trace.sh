#!/usr/bin/env bash
set -euo pipefail

# trace - Armbian Config V3 module

trace() {
	local cmd="${1:-}" msg="${2:-}"
	case "$cmd" in
		help)
			_about_trace
			;;
		reset)
			_trace_start=$(date +%s)
			_trace_time=$_trace_start
			;;
		total)
			if [[ -n "${TRACE:-}" ]]; then
				_trace_time=${_trace_start:-$(date +%s)}
				trace "TOTAL time elapsed"
			fi
			trace reset
			;;
		*)
			if [[ -n "${TRACE:-}" ]]; then
				local now elapsed
				now=$(date +%s)
				: "${_trace_time:=$now}"  # Initialize if unset
				elapsed=$((now - _trace_time))
				printf "%-30s %4d sec\n" "$cmd" "$elapsed"
				_trace_time=$now
			fi
			;;
	esac
}

_about_trace() {
	cat <<EOF

Usage: trace <option> || <"message string">
Options:
	help               Show this help message
	"message string"   Show trace message (trace non-zero)
	reset              (Re)set starting point
	total              Show total time and reset

	When providing a "message string", elapsed time since last trace call is shown if trace is set.
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	TRACE="true"
	trace reset
	trace "trace initialized"

	# --- Capture and assert help output ---
	help_output="$(trace help)"              # Capture
	echo "$help_output" | grep -q "Usage: trace" || {  # Assert
		echo "fail: Help output does not contain expected usage string"
		trace "test complete"
		exit 1
	}
	# --- end assertion ---

	trace "$help_output"
	trace "test complete"
	trace total
fi
