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

			_html_index
			;;
		icon)

			_icon_set_from_svg
			;;
		server)

			_html_server
			;;
		all)
			_prepare_dist
			_icon_set_from_svg || echo "ERROR: _icon_set_from_svg failed"
			_index_json       || echo "ERROR: _index_json failed"
			_html_index       || echo "ERROR: _html_index failed"
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
			convert -background white -resize ${size}x${size} "$svg" "$OUT_DIR/${base}.gif"
			convert -background white -resize ${size}x${size} "$svg" "$OUT_DIR/${base}.jpg"
		done
	done

	# Favicon
	FAVICON_SVG="$SRC_DIR/armbian_mascot_v2.1.svg"
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

		# Arrays for PNG, GIF, JPG
		for fmt in png gif jpg; do
			array_name="${fmt}s"
			if [[ "$is_legacy" -eq 1 ]]; then
				echo "    \"$array_name\": []" >> "$OUTPUT"
			else
				echo "    \"$array_name\": [" >> "$OUTPUT"
				for i in "${!SIZES[@]}"; do
					sz="${SIZES[$i]}"
					img_path="images/${sz}x${sz}/${name}.${fmt}"
					if [[ -f "$DIST/$img_path" ]]; then
						kb=$(du -k "$DIST/$img_path" 2>/dev/null | cut -f1 || echo 0)
					else
						kb=0
					fi
					kb_decimal=$(printf "%.2f" "$kb")
					echo -n "      { \"path\": \"$img_path\", \"size\": \"${sz}x${sz}\", \"kb\": ${kb_decimal} }" >> "$OUTPUT"
					[[ $i -lt $((${#SIZES[@]}-1)) ]] && echo "," >> "$OUTPUT"
				done
				echo "" >> "$OUTPUT"
				echo "    ]" >> "$OUTPUT"
			fi
			[[ "$fmt" != "jpg" ]] && echo "," >> "$OUTPUT"
		done

		echo -n "  }" >> "$OUTPUT"
	done

	echo "" >> "$OUTPUT"
	echo "]" >> "$OUTPUT"
	echo "JSON file created: $OUTPUT"
}

_html_index() {
	cat <<'EOF' > "$DIST/index.html"
<!DOCTYPE html>
<html>
<head>
	<meta charset='UTF-8'>
	<link rel="icon" type="image/x-icon" href="favicon.ico">
	<title>Armbian Logos</title>
	<style>
		body { font-family: sans-serif; margin: 0; padding: 0; background: #f8f8f8; }
		header, footer { background: #333; color: #fff; padding: 1em; text-align: center; }
		main {
			padding: 1em;
			display: grid;
			grid-template-columns: 1fr 1fr;
			grid-template-rows: auto auto;
			gap: 1em;
		}
		@media (max-width: 768px) {
			main { grid-template-columns: 1fr; grid-template-rows: auto; }
		}
		.section { padding: 1em; background: #f0f0f0; border-radius: 6px; }
		.section h2 { margin-top: 0; }
		img { margin: 0.5em; vertical-align: middle; }
		.legacy { opacity: 0.85; }
		ul { list-style-type: none; padding-left: 0; }
		ul li { margin: 0.2em 0; }
		.meta { font-size: 0.95em; color: #444; margin: 0.25em 0 0.5em 0; }
		.meta span { display: inline-block; min-width: 70px; }
	</style>
</head>
<body>
	<header>
		<h1>Armbian Logos and Icons</h1>
	</header>

	<main>
		<div id="armbian-section" class="section">
			<h2>Armbian</h2>
			<div id="armbian-logos"></div>
		</div>
		<div id="configng-section" class="section">
			<h2>ConfigNG</h2>
			<div id="configng-logos"></div>
		</div>
		<div id="armbian-legacy-section" class="section legacy">
			<h2>Armbian Legacy</h2>
			<div id="armbian-legacy-logos"></div>
		</div>
		<div id="configng-legacy-section" class="section legacy">
			<h2>ConfigNG Legacy</h2>
			<div id="configng-legacy-logos"></div>
		</div>
	</main>

	<footer>
		<p>For more information, see
			<a href="https://www.armbian.com/brand/" style="color: #fff;">Armbian Brand Guidelines</a>.
		</p>
	</footer>

	<script>
		function valueOrNull(val) {
			// Null, empty string, or undefined become 'null'
			return (val === undefined || val === null || val === "") ? "<span style='color:#c00'>null</span>" : val;
		}

		fetch('logos.json')
			.then(response => response.json())
			.then(data => {
				data.forEach(logo => {
					let sectionId;
					switch (logo.category) {
						case 'armbian': sectionId = 'armbian-logos'; break;
						case 'armbian-legacy': sectionId = 'armbian-legacy-logos'; break;
						case 'configng': sectionId = 'configng-logos'; break;
						case 'configng-legacy': sectionId = 'configng-legacy-logos'; break;
						default: return;
					}
					const container = document.getElementById(sectionId);
					if (!container) return;

					let div = document.createElement('div');

					let meta = logo.svg_meta || {};
					let metaHtml = `
						<div class="meta">
							<span><b>Title:</b> ${valueOrNull(meta.title)}</span><br>
							<span><b>Description:</b> ${valueOrNull(meta.desc)}</span>
						</div>
					`;

					if (!logo.pngs || logo.pngs.length === 0 || logo.category.endsWith('legacy')) {
						div.innerHTML = `
							<hr>
							<a href="${logo.svg}" target="_blank">
								<img src="${logo.svg}" alt="${logo.name}" width="64" height="64">
							</a>
							${metaHtml}
							<p><a href="${logo.svg}" target="_blank">Open SVG / Download</a></p>
						`;
					} else {
						const pngList = logo.pngs.map(p =>
							`<li><a href="${p.path}">${p.size} PNG</a> – ${p.kb} KB</li>`
						).join('');
						const gifList = logo.gifs.map(g =>
							`<li><a href="${g.path}">${g.size} GIF</a> – ${g.kb} KB</li>`
						).join('');
						const jpgList = logo.jpgs.map(j =>
							`<li><a href="${j.path}">${j.size} JPG</a> – ${j.kb} KB</li>`
						).join('');
						div.innerHTML = `
							<hr>
							<a href="${logo.svg}" target="_blank">
								<img src="${logo.svg}" alt="${logo.name}" width="64" height="64">
							</a>
							${metaHtml}
							<p>${logo.name}:</p>
							<ul>
								${pngList}
								${gifList}
								${jpgList}
							</ul>
						`;
					}
					container.appendChild(div);
				});
			});
	</script>
</body>
</html>
EOF
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
icon    - Generate a PNG, JPG, and GIF icon set from SVG files in ./images/scalable.
index   - Generate an HTML media kit index of all SVGs and icons.
server  - Serve the HTML and icon directory using a simple HTTP server.
all     - Run icon generation, HTML index generation and start the server.

Examples:
# Show help
media_kit help

# Generate icons from SVGs
media_kit icon

# Generate the HTML media kit
media_kit index

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
    SIZES=(16 48 512)
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