#!/usr/bin/env bash
set -euo pipefail

# Armbian Media Kit V2 module

DIST="dist"
SRC_DIR="${SRC_DIR:-./brand}"
SIZES=(16 48 512)
SVG_DIR="$SRC_DIR"

media_kit() {
	case "${1:-}" in
		help|-h|--help)
			_about_media_kit
			;;
		index)
			_html_json
			;;
		icon)
			_icon_set_from_svg
			;;
		server)
			_html_server "${@:-}"
			;;
		contributors|-c)
			# Set your repository here (format: owner/repo)
			echo "Contributors JSON generate"
			USER="Tearran"
			REPO="configng-v2"

			echo "Contributors $REPO JSON generate"
			#wget -O contributors.json "https://api.github.com/repos/${USER:-Tearran}/${REPO:-configng}/contributors"
			wget -O- "https://api.github.com/repos/${USER:-Tearran}/${REPO:-configng}/contributors" | jq '[.[] | {login, contributions, avatar_url, html_url}]' > ./contributors.json
			echo "Contributors JSON generated in contributors.json"

			;;
		all)
			_prepare_dist
			_icon_set_from_svg || echo "ERROR: _icon_set_from_svg failed"
			_index_json       || echo "ERROR: _index_json failed"
			cp ../docs/modules_metadata.json ./dist/modules_metadata.json
			cp ./contributors.json ./dist/contributors.json || echo "run -c first"
			_html_server      || echo "ERROR: _html_server failed"
			;;
		*)

			_about_media_kit
			;;
	esac
}

_prepare_dist() {
	if [ -d "$DIST" ]; then
		rm -rf "$DIST"
	fi
	mkdir -p "$DIST"
}

_icon_set_from_svg() {
	mkdir -p "$DIST/images/scalable"
	mkdir -p "$DIST/images/scalable/legacy"
	# Copy SVGs to dist/images/scalable/ (non-legacy)
	find "$SRC_DIR" -maxdepth 1 -type f -name "*.svg" -exec cp {} "$DIST/images/scalable/" \;
	# Copy legacy SVGs
	if [ -d "$SRC_DIR/legacy" ]; then
		find "$SRC_DIR/legacy" -maxdepth 1 -type f -name "*.svg" -exec cp {} "$DIST/images/scalable/legacy/" \;
	fi

	for svg in "$SRC_DIR"/*.svg "$SRC_DIR/legacy"/*.svg; do
		[ -e "$svg" ] || continue
		base=$(basename "$svg" .svg)
		for size in "${SIZES[@]}"; do
			OUT_DIR="$DIST/images/${size}x${size}"
			mkdir -p "$OUT_DIR"
			convert -background none -resize ${size}x${size} "$svg" "$OUT_DIR/${base}.png"
		done
	done

	# Favicon
	FAVICON_SVG="$SRC_DIR/armbian_social.svg"
	if [[ -f "$FAVICON_SVG" ]]; then
		convert -background none "$FAVICON_SVG" -resize 16x16 "$DIST/favicon-16.png"
		convert -background none "$FAVICON_SVG" -resize 32x32 "$DIST/favicon-32.png"
		convert -background none "$FAVICON_SVG" -resize 48x48 "$DIST/favicon-48.png"
		convert "$DIST/favicon-16.png" "$DIST/favicon-32.png" "$DIST/favicon-48.png" "$DIST/favicon.ico"
		rm "$DIST/favicon-16.png" "$DIST/favicon-32.png" "$DIST/favicon-48.png"
	fi
}



_index_json() {
	OUTPUT="$DIST/logos.json"
	mapfile -t svg_files < <(find "$SRC_DIR" "$SRC_DIR/legacy" -type f -name "*.svg" | sort -u)

	echo "[" > "$OUTPUT"
	first=1

	for file in "${svg_files[@]}"; do
		[[ -e "$file" ]] || continue
		name=$(basename "$file" .svg)

		# Determine category and SVG path for HTML
		if [[ "$file" == */legacy/* ]]; then
			if [[ "$name" == armbian_* ]]; then category="armbian-legacy"
			elif [[ "$name" == configng_* ]]; then category="configng-legacy"
			else category="other-legacy"; fi
			is_legacy=1
			rel_svg_path="images/scalable/legacy/$name.svg"
		else
			if [[ "$name" == armbian_* ]]; then category="armbian"
			elif [[ "$name" == configng_* ]]; then category="configng"
			else category="other"; fi
			is_legacy=0
			rel_svg_path="images/scalable/$name.svg"
		fi

		# Metadata extraction
		svg_title=$(grep -oP '<title>(.*?)</title>' "$file" | head -n1 | sed 's/<title>\(.*\)<\/title>/\1/')
		if [[ -z "$svg_title" ]]; then
			svg_title=$(grep -oP '<dc:title>(.*?)</dc:title>' "$file" | head -n1 | sed 's/<dc:title>\(.*\)<\/dc:title>/\1/')
		fi

		svg_desc=$(grep -oP '<desc>(.*?)</desc>' "$file" | head -n1 | sed 's/<desc>\(.*\)<\/desc>/\1/')
		if [[ -z "$svg_desc" ]]; then
			svg_desc=$(grep -oP '<dc:description>(.*?)</dc:description>' "$file" | head -n1 | sed 's/<dc:description>\(.*\)<\/dc:description>/\1/')
		fi

		[[ $first -eq 0 ]] && echo "," >> "$OUTPUT"
		first=0

		echo "  {" >> "$OUTPUT"
		echo "    \"name\": \"$name\"," >> "$OUTPUT"
		echo "    \"category\": \"$category\"," >> "$OUTPUT"
		echo "    \"svg\": \"$rel_svg_path\"," >> "$OUTPUT"
		echo "    \"svg_meta\": {" >> "$OUTPUT"
		echo "      \"title\": \"$svg_title\"," >> "$OUTPUT"
		echo "      \"desc\": \"$svg_desc\"" >> "$OUTPUT"
		echo "    }," >> "$OUTPUT"

		# Array for PNG only, include only files that exist and are > 0KB
		array_name="pngs"
		if [[ "$is_legacy" -eq 1 ]]; then
			echo "    \"$array_name\": []" >> "$OUTPUT"
		else
			echo "    \"$array_name\": [" >> "$OUTPUT"
			png_count=0
			for i in "${!SIZES[@]}"; do
				sz="${SIZES[$i]}"
				img_path="images/${sz}x${sz}/${name}.png"
				full_img_path="$DIST/$img_path"
				if [[ -f "$full_img_path" ]]; then
					kb=$(du -k "$full_img_path" 2>/dev/null | cut -f1 || echo 0)
					if (( kb > 0 )); then
						kb_decimal=$(printf "%.2f" "$kb")
						[[ $png_count -gt 0 ]] && echo "," >> "$OUTPUT"
						echo -n "      { \"path\": \"$img_path\", \"size\": \"${sz}x${sz}\", \"kb\": ${kb_decimal} }" >> "$OUTPUT"
						((png_count++))
					fi
				fi
			done
			echo "" >> "$OUTPUT"
			echo "    ]" >> "$OUTPUT"
		fi

		echo -n "  }" >> "$OUTPUT"
	done

	echo "" >> "$OUTPUT"
	echo "]" >> "$OUTPUT"
	echo "JSON file created: $OUTPUT"
}

_html_server() {
	cd "$DIST"
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
	cd ..
}

_about_media_kit() {
	cat <<EOF
Usage: media_kit <command> [options]

Commands:
help    - Show this help message.
icon    - Generate a PNG icon set from SVG files in ./images/scalable.
index   - Generate an HTML media kit index of all SVGs and icons.
server  - Serve the HTML and icon directory using a simple HTTP server.
all     - Run icon generation, HTML index generation and start the server.

Examples:
# Show help
media_kit help

# Generate icons from SVGs
media_kit icon

# Generate the HTML and start the server
media_kit index serve

# Start the server (serves current directory by default)
media_kit server [directory]

Notes:
- All commands accept '--help', '-h', or 'help' for details, if implemented.
- This tool is intended for use with the Armbian Config V2 menu and for scripting.
- Please keep this help message up to date if commands or behavior change.
- SVGs should be placed in ./images/scalable for indexing and icon generation.

EOF
}

### START ./media_kit.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SIZES=(16 32 48 512)
    SVG_DIR="./brand"

    help_output="$(media_kit help)"
    if ! echo "$help_output" | grep -q "Usage: media_kit"; then
        echo "Warning: Help output does not contain expected usage string"
        echo "test complete"
	exit 1
        # Do NOT exit here, continue with main command!
    fi
    media_kit "$@"
fi

### END ./media_kit.sh - Armbian Config V2 test entrypoint