#!/usr/bin/env bash
set -euo pipefail

# ./html_server.sh - Armbian Config V2 module

html_server() {
	case "${1:-}" in
		help|-h|--help)
			_about_html_server
			;;
		index)
			# Generate an HTML index of SVG files
			_html_server_index
			_html_server_main
			;;
		*)
			_html_server_main
			;;
	esac
}

_html_server_main() {
	# Use a default directory
	local DIR="${1:-.}"
	# Run Python web server for HTTP (CGI dropped for now)
	echo "Starting Python web server"
	python3 -m http.server 8080 &

	PYTHON_PID=$!

	echo "Python web server started with PID $PYTHON_PID"
	echo "You can access the server at http://localhost:8080/$DIR"
	echo "Press any key to stop the server..."
	read -r -n 1 -s
	echo "Stopping the server..."
	if ! kill -0 "$PYTHON_PID" 2>/dev/null; then
		echo "Server is not running or already stopped."
		exit 0
	fi
	kill "$PYTHON_PID" && wait "$PYTHON_PID" 2>/dev/null
	if [[ $? -eq 0 ]]; then
		echo "Server stopped successfully."
	else
		echo "Failed to stop the server."
		exit 1
	fi
	echo "Test complete"
}

_html_server_index() {
	# Directory containing SVGs
	SVG_DIR="./images/scalable"
	# Output HTML file
	OUTPUT="index.html"

	{
	echo "<!DOCTYPE html>"
	echo "<html><head><meta charset='UTF-8'><title>Armbian logos</title></head><body>"
	echo "<img src=\"./images/scalable/armbian-tux_v1.5.svg\" alt=\"armbian-tux_v1.5.svg\" width=\"128\" height=\"128\">"
	echo "<img src=\"./images/scalable/armbian_logo_v2.svg\" alt=\"armbian_logo_v2.svg\" width=\"512\" height=\"128\">"
	echo "<h1>Armbian Logos and Icons</h1>"

	cat <<EOF
	<p>We've put together some logos and icons for you to use in your articles and projects.</p>
EOF
	local SIZES=(16 32 64 128 256 512)
	for file in "$SVG_DIR"/*.svg; do
		[[ -e "$file" ]] || continue
		name=$(basename "$file" .svg)
		echo "<hr>"
		echo "<a href=\"$file\">"
		echo "  <img src=\"$file\" alt=\"$name.svg\" width=\"64\" height=\"64\">"
		echo "</a>"
		echo "<p>Download PNG:</p><ul>"
		for sz in "${SIZES[@]}"; do
		#share/icons/hicolor/
			echo "  <li><a href=\"share/icons/hicolor/${sz}x${sz}/${name}.png\">${sz}x${sz} ${name}.png</a></li>"
		done
		echo "</ul>"
	done

cat <<EOF
	<p>All logos are licensed under the <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a> license.</p>
	<p>For more information, please refer to the <a href="https://www.armbian.com/brand/">Armbian Brand Guidelines</a>.</p>
</body></html>
EOF
	} > "$OUTPUT"

	echo "HTML file created: $OUTPUT"
}

_about_html_server() {
	cat <<EOF
Usage: html_server <command> [options]

Commands:

  	help, -h, --help  Show this help message

Examples:
	# Run the operation
	html_server

	# Show help
	html_server help

Notes:
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}

### START ./html_server.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(html_server help)"
	echo "$help_output" | grep -q "Usage: html_server" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	html_server "$@"
fi

### END ./html_server.sh - Armbian Config V2 test entrypoint