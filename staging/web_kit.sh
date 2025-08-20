#!/usr/bin/env bash
set -euo pipefail

# ./web_kit.sh - Armbian Config V2 module

web_kit() {
	case "${1:-}" in
		help|-h|--help)
			_about_web_kit
			;;
		server|-s)
			_web_kit_server_py "${2:-WEB_ROOT}"
			;;
		*)
			_about_web_kit
			;;
	esac
}

_web_kit_server_py() {

	cd $WEB_ROOT
	if ! command -v python3 &> /dev/null; then
		echo "Python 3 is required to run the server. Please install it."
		exit 1
	fi
	echo "Starting Python web server in dist/"
	python3 -m http.server 8080 &
	PYTHON_PID=$!
	echo "Python web server started with PID $PYTHON_PID"
	echo "You can access the server at http://localhost:8080/"
	echo "Press any key to stop the server..."
	read -r -n 1 -s
	echo "Stopping the server..."
	kill "$PYTHON_PID" && wait "$PYTHON_PID" 2>/dev/null
	echo "Test complete"
}


_about_web_kit() {
	cat <<EOF
Usage: web_kit <command> [options]

Commands:
	server, -s [PATH]   - Run a Python 3 simple web server for the specified path or use the default web root.
	help, -h            - Show this help message

Examples:
	# Set web root
	web_kit -s /var/www/html
	web_kit server /var/www/html

	# Use the default web root
	web_kit server
	web_kit -s

	# Show help
	web_kit help

Notes:
	- All commands accept '--help', '-h', or 'help' for details.
	- This module is intended for use with the config web interface and documentation hosting.
	- Make sure Python 3 is installed and available in your PATH.
	- The server will run in the specified directory and serve files over HTTP on port 8080.
	- Press any key to stop the server after it starts.
	- Keep this help message up to date if commands or usage change.

About:
	This script is part of the Armbian Config V2 toolkit, providing a simple way to serve static files for testing or documentation purposes using Python's built-in HTTP server. It is designed to be lightweight and easy to use, requiring minimal setup.

EOF
}

### START ./web_kit.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	BIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	WEB_ROOT="${WEB_ROOT:-$BIN_ROOT/../html}"
	DOC_ROOT="${DOC_ROOT:-$BIN_ROOT/../doc}"

	# --- Capture and assert help output ---
	help_output="$(web_kit help)"
	echo "$help_output" | grep -q "Usage: web_kit" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---

	web_kit "$@"
fi

### END ./web_kit.sh - Armbian Config V2 test entrypoint

