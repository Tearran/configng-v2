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
			_index_css        || echo "ERROR: _index_css failed"
			_index_js	   || echo "ERROR:"
			_html_index       || echo "ERROR: _html_index failed"
			cp ../docs/modules_metadata.json ./dist/modules_metadata.json
			_configng_docs
			_html_server      || echo "ERROR: _html_server failed"
			;;
		*)
			_about_media_kit
			;;
	esac
}

_configng_docs(){

	cat <<EOF > "$DIST/docs.html"
<!DOCTYPE html>
<html>
	$(cat ./templates/head.html)
<body>
	$(cat ./templates/nav.html)

<section id="page-info">
  <h1>Armbian Module Metadata</h1>
  <div id="modules-container"><em>Loading modules…</em></div>
</section>
	$(cat ./templates/footer.html)

	<script src="./script.js"></script>
</body>
</html>

EOF

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

_index_js(){

cat <<'EOF' > "$DIST/script.js"
function valueOrNull(val) {
	return val === undefined || val === null || val === ""
		? "<span style='color:#c00'>null</span>"
		: val;
}

// Load logos
fetch("logos.json")
	.then((response) => response.json())
	.then((data) => {
		data.forEach((logo) => {
			let sectionId;
			switch (logo.category) {
				case "armbian":
					sectionId = "armbian-logos";
					break;
				case "armbian-legacy":
					sectionId = "armbian-legacy-logos";
					break;
				case "configng":
					sectionId = "configng-logos";
					break;
				case "configng-legacy":
					sectionId = "configng-legacy-logos";
					break;
				default:
					return;
			}
			const container = document.getElementById(sectionId);
			if (!container) return;
			let div = document.createElement("div");
			let meta = logo.svg_meta || {};
			let metaHtml = `<div class="meta">
        <span><b>Title:</b> ${valueOrNull(meta.title)}</span><br>
        <span><b>Description:</b> ${valueOrNull(meta.desc)}</span>
      </div>`;
			if (
				!logo.pngs ||
				logo.pngs.length === 0 ||
				logo.category.endsWith("legacy")
			) {
				div.innerHTML = `<hr>
          <a href="${logo.svg}" target="_blank">
            <img src="${logo.svg}" alt="${logo.name}" width="64" height="64">
          </a>
          ${metaHtml}
          <p><a href="${logo.svg}" target="_blank">Open SVG / Download</a></p>`;
			} else {
				const pngList = logo.pngs
					.map((p) => `<li><a href="${p.path}">${p.size} PNG</a> – ${p.kb} KB</li>`)
					.join("");
				div.innerHTML = `<hr>
          <a href="${logo.svg}" target="_blank">
            <img src="${logo.svg}" alt="${logo.name}" width="64" height="64">
          </a>
          ${metaHtml}
          <p>${logo.name}:</p>
          <ul>${pngList}</ul>`;
			}
			container.appendChild(div);
		});
	});




// Dark Mode Toggle
const toggle = document.getElementById("dark-mode-toggle");
const body = document.body;

// Initialize from localStorage
if (localStorage.getItem("darkMode") === "true") {
	body.classList.add("dark-mode");
	toggle.textContent = "☀️";
}

toggle.addEventListener("click", () => {
	body.classList.toggle("dark-mode");
	const isDark = body.classList.contains("dark-mode");
	localStorage.setItem("darkMode", isDark);
	toggle.textContent = isDark ? "☀️" : "🌙";
});

// configng docs
const JSON_URL = "https://raw.githubusercontent.com/Tearran/configng-v2/refs/heads/main/media_kit/dist/modules_metadata.json";

fetch(JSON_URL)
  .then(r => r.json())
  .then(data => renderModules(data))
  .catch(err => {
    document.getElementById("modules-container").innerHTML = "<b>Failed to load metadata.</b>";
    console.error(err);
  });

function renderModules(data) {
  const cont = document.getElementById("modules-container");
  cont.innerHTML = "";

  (data.menu || []).forEach(cat => {
    const catDiv = document.createElement("article");
    catDiv.className = "category";
    catDiv.innerHTML = `<h2>${escapeHTML(cat.id)}</h2>
                        ${cat.description ? `<p class="desc">${escapeHTML(cat.description)}</p>` : ""}`;

    (cat.sub || []).forEach(entry => {
      if (entry.sub) {
        const groupDiv = document.createElement("div");
        groupDiv.className = "group";
        groupDiv.innerHTML = `<h3>${escapeHTML(entry.id)}</h3>
                              ${entry.description ? `<p class="desc">${escapeHTML(entry.description)}</p>` : ""}`;

        (entry.sub || []).forEach(mod => groupDiv.appendChild(renderModule(mod)));
        catDiv.appendChild(groupDiv);
      } else {
        catDiv.appendChild(renderModule(entry));
      }
    });
    cont.appendChild(catDiv);
  });
}

function renderModule(mod) {
  const div = document.createElement("div");
  div.className = "module";
  div.innerHTML = `<h4>${escapeHTML(mod.id)}</h4>
                   ${mod.description ? `<p class="desc">${escapeHTML(mod.description)}</p>` : ""}`;
  if (mod.options) {
    const opts = mod.options.split(",").map(o=>o.trim()).filter(Boolean);
    if (opts.length) {
      const spanWrap = opts.map(o=>`<span>${escapeHTML(o)}</span>`).join("");
      div.innerHTML += `<div class="options"><strong>Options:</strong> ${spanWrap}</div>`;
    }
  }
  return div;
}

function escapeHTML(str) {
  return (str||"").replace(/[<>&"']/g, c => ({'<':'&lt;','>':'&gt;','&':'&amp;','"':'&quot;',"'":'&#39;'}[c]));
}

EOF
}

_index_css(){
cat <<'EOF' > "$DIST/style.css"
/* Default Light Mode */
body {
	background: #fff;
	color: #000;
	font-family: sans-serif;
	margin: 0;
}
header {
	background: #23262f;
	color: #fff;
	padding: 0.3rem 1rem;
	display: flex;
	align-items: center;
	min-height: 56px;
}
header .header-logo {
	display: flex;
	gap: 0em;
	padding: 0.1rem;
}
header a {
	display: inline-block;
}
header img {
	vertical-align: middle;
	height: 64px;
	width: auto;
}

footer {
	background: #23262f;
	color: #fff;
	padding: 2rem 1rem;
	font-size: 0.9em;
}
.footer-content {
	display: flex;
	flex-wrap: wrap;
	justify-content: space-between;
	max-width: 1000px;
	margin: 0 auto;
	gap: 2em;
}
.footer-links h4 {
	margin-bottom: 0.5em;
	font-size: 1em;
}
.footer-links ul {
	list-style: none;
	margin: 0;
	padding: 0;
}
.footer-links li {
	margin: 0.3em 0;
}
.footer-links a {
	color: #3ea6ff;
	text-decoration: none;
}
.footer-links a:hover {
	text-decoration: underline;
}
.footer-about {
	flex: 1 1 100%;
	margin-top: 1em;
	text-align: center;
	color: #bbb;
}
.footer-about p {
	margin: 0.3em 0;
}
.footer-legal {
	margin-top: 2em;
	font-size: 0.8em;
	color: #aaa;
	text-align: left;
	max-width: 800px;
	margin-left: auto;
	margin-right: auto;
}
.footer-legal ul {
	list-style: none;
	padding: 0;
	margin: 0.5em 0;
}
.footer-legal li {
	margin: 0.2em 0;
}

/* Nav Bar */
.nav-bar {
	margin-left: auto;
}
.nav-bar ul {
	list-style: none;
	margin: 0;
	padding: 0;
	display: flex;
	gap: 1.2em;
}
.nav-bar li {
	display: inline;
}
.nav-bar a {
	color: #fff;
	text-decoration: none;
	font-weight: 500;
	transition: color 0.2s ease-in-out;
}
.nav-bar a:hover {
	color: #3ea6ff;
}

/* Responsive */
@media (max-width: 768px) {
	header {
		flex-direction: column;
		align-items: flex-start;
		padding: 0.5rem 1rem;
	}
	.nav-bar ul {
		flex-direction: column;
		gap: 0.5em;
		margin-top: 0.5em;
	}
	main {
		grid-template-columns: 1fr;
		grid-template-rows: auto;
	}
}

main {
	padding: 1em;
	display: grid;
	grid-template-columns: 1fr 1fr;
	grid-template-rows: auto auto;
	gap: 1em;
}
.section {
	padding: 1em;
	background: #f0f0f0;
	border-radius: 6px;
}
.section h2 {
	margin-top: 0;
}
img {
	margin: 0.5em;
	vertical-align: middle;
}
.legacy {
	opacity: 0.85;
}
ul {
	list-style-type: none;
	padding-left: 0;
}
ul li {
	margin: 0.2em 0;
}
.meta {
	font-size: 0.95em;
	color: #444;
	margin: 0.25em 0 0.5em 0;
}
.meta span {
	display: inline-block;
	min-width: 70px;
}

/* Dark Mode */
body.dark-mode {
	background: #121212;
	color: #ddd;
}

body.dark-mode .section {
	background: #1e1e1e;
	color: #ddd;
}
body.dark-mode .legacy {
	opacity: 0.7;
}
body.dark-mode a {
	color: #4aa3ff;
}
body.dark-mode .footer-links a {
	color: #4aa3ff;
}
body.dark-mode .footer-about {
	color: #ccc;
}
body.dark-mode .footer-legal {
	color: #888;
}
body.dark-mode hr {
	border-bottom: 1px solid #444;
}
body.dark-mode .meta {
	font-size: 0.95em;
	color: #fff;
	margin: 0.25em 0 0.5em 0;
}

/* Dark mode toggle button */
#dark-mode-toggle {
	margin-left: 1em;
	padding: 0.2em 0.5em;
	font-size: 0.9em;
	cursor: pointer;
	background: #444;
	color: #fff;
	border: none;
	border-radius: 4px;
}
#dark-mode-toggle:hover {
	background: #c3c3c3;
}

/* Page Info Section */
#page-info {
	padding: 1em;
	border-bottom: 1px solid #ddd;
}

#page-info p {
	margin: 0.5em 0 0 0;
	font-size: 1em;
}

   section#page-info { padding: 1em 2em; max-width: 1000px; margin: auto; }
    .category, .group, .module {
      border: 1px solid #ccc;
      border-radius: 6px;
      padding: 1em;
      margin: 1em 0;
      background: #f9f9f9;
    }
    .category h2, .group h3, .module h4 { margin-top: 0; }
    .options { margin-top: .5em; }
    .options span {
      display: inline-block;
      background: #eef;
      border: 1px solid #99c;
      border-radius: 4px;
      padding: .2em .5em;
      margin: .2em;
      font-size: .9em;
    }
    .desc { color: #666; font-style: italic; }

EOF
}


_html_index(){
cat <<EOF > "$DIST/media_kit.html"
<!DOCTYPE html>
<html>
	$(cat ./templates/head.html)
<body>
	$(cat ./templates/nav.html)

	<section id="page-info">
		<h1>Armbian Logos Media Kit</h1>
		<p>We've put together some logos and icons for you to use in your articles and projects.</p>
	</section>

	$(cat ./templates/main.html)
	$(cat ./templates/footer.html)

	<script src="./script.js"></script>

</body>

</html>

EOF


cat <<EOF > "$DIST/index.html"
<!DOCTYPE html>
<html>
	$(cat ./templates/head.html)
<body>
	$(cat ./templates/nav.html)

	<section id="page-info">
		<h1>Welcome to Armbian commnity</h1>
	</section>

	$(cat ./templates/footer.html)

	<script src="./script.js"></script>

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
icon    - Generate a PNG icon set from SVG files in ./images/scalable.
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