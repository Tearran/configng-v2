#!/usr/bin/env bash
set -euo pipefail

web_kit() {

	case "${1:-}" in
		help|-h|--help)
			_about_web_kit
			;;
		server|-s)
			shift 1
			_web_kit_server_py "${1:-${WEB_ROOT:-}}"
			;;
		icons|-i)
			shift 1
			# Usage: web_kit icons [SRC_DIR] [OUT_DIR]
			# Defaults: SRC_DIR="$SVG_LOGO_ROOT", OUT_DIR="$WEB_LOGO_ROOT"
			_web_kit_icon_set "${1:-${SVG_LOGO_ROOT:-}}" "${2:-${WEB_LOGO_ROOT:-}}"
			;;
		json|-j)
			shift 1
			if [[ -n "${1:-}" && -n "${2:-}" ]]; then
				# If arguments are provided, generate only for the provided repo (and optional outfile)
				_web_kit_contributors_json "$@"
			fi

				_web_kit_logo_json


			;;
		pages|-p)
			shift 1
			_web_kit_contrib_page "${1:-$WEB_ROOT/contributors.html}"
			_web_kit_images_page
			;;
		buid|-b)

			# Build all components: icons, contributors JSON, and contrib page
			_web_kit_icon_set "${SVG_LOGO_ROOT:-}" "${WEB_LOGO_ROOT:-}"
			_web_kit_contributors_json "Tearran" "configng-v2"
			_web_kit_contributors_json "armbian" "documentation"
			_web_kit_contributors_json "armbian" "configng"
			_web_kit_contributors_json "armbian" "build"
			_web_kit_contrib_page "${WEB_ROOT}/contributors.html"
			echo "All components built successfully."

			_web_kit_server_py "$WEB_ROOT"
			;;
		*)
			_about_web_kit
			;;
	esac
}
_web_kit_logo_json() {
	local BIN_ROOT
	BIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

	local WEB_ROOT="${WEB_ROOT:-$BIN_ROOT/../public_html}"
	local SVG_SRC_DIR="${SVG_SRC_DIR:-$BIN_ROOT/../assets/images/logos}"   # filesystem source SVGs
	local LOGO_JSON_DIR="${LOGO_JSON_DIR:-$WEB_ROOT/json/images}"          # output directory for per-file JSONs
	local LOGO_IMG_ROOT="${LOGO_IMG_ROOT:-$WEB_ROOT/images}"              # filesystem PNG root
	local LOGO_IMG_WEB="${LOGO_IMG_WEB:-images/logos}"                    # desired web prefix (will be normalized)

	# If WEB_LOGO_ROOT (filesystem) provided and user left LOGO_IMG_WEB default, prefer deriving web prefix from it
	if [[ -n "${WEB_LOGO_ROOT:-}" && "${LOGO_IMG_WEB:-}" == "images/logos" ]]; then
		LOGO_IMG_WEB="${WEB_LOGO_ROOT}"
	fi

	# Normalize LOGO_IMG_WEB: if it's an absolute/filesystem path under WEB_ROOT, convert to web-rel path.
	LOGO_IMG_WEB="${LOGO_IMG_WEB%/}"
	if [[ -n "$WEB_ROOT" && "${LOGO_IMG_WEB#"$WEB_ROOT"/}" != "$LOGO_IMG_WEB" ]]; then
		LOGO_IMG_WEB="${LOGO_IMG_WEB#"$WEB_ROOT"/}"
	fi
	# Remove leading slash or ./ if present
	LOGO_IMG_WEB="${LOGO_IMG_WEB#/}"
	LOGO_IMG_WEB="${LOGO_IMG_WEB#./}"

	# Sizes (override by setting ICON_SIZES as comma-separated list)
	if [ -n "${ICON_SIZES:-}" ]; then
		IFS=',' read -r -a SIZES <<< "${ICON_SIZES}"
	else
		SIZES=(16 32 48 64 96 128 180 192 256 384 512 1024)
	fi

	# Ensure output directory exists
	mkdir -p "$LOGO_JSON_DIR"

	# Collect SVG files
	mapfile -t svg_files < <(find "$SVG_SRC_DIR" -type f -name "*.svg" 2>/dev/null | sort -u)

	# Escape helper for JSON strings
	json_escape() {
		local s="$1"
		s="${s//\\/\\\\}"
		s="${s//\"/\\\"}"
		s="${s//$'\n'/ }"
		printf '%s' "$s"
	}

	# Extract tag content helper
	extract_tag_content() {
		local file="$1"; local primary="$2"; local fallback="$3"; local val
		if val="$(grep -m1 -o "<${primary}>[^<]*</${primary}>" "$file" 2>/dev/null)"; then
			val="$(printf '%s' "$val" | sed 's|<[^>]*>||g')"
			printf '%s' "$val"; return 0
		fi
		if [ -n "$fallback" ]; then
			if val="$(grep -m1 -o "<${fallback}>[^<]*</${fallback}>" "$file" 2>/dev/null)"; then
				val="$(printf '%s' "$val" | sed 's|<[^>]*>||g')"
				printf '%s' "$val"; return 0
			fi
		fi
		printf ''; return 1
	}

	# Generate one JSON file per SVG
	for file in "${svg_files[@]}"; do
		[ -e "$file" ] || continue
		local base name category is_legacy svg_title svg_desc rel_svg_path
		base="$(basename "$file")"
		name="${base%.svg}"

		is_legacy=0
		if [[ "$file" == */legacy/* ]]; then
			if [[ "$name" == armbian_* ]]; then category="armbian-legacy"
			elif [[ "$name" == configng_* ]]; then category="configng-legacy"
			else category="other-legacy"; fi
			is_legacy=1
			rel_svg_path="${LOGO_IMG_WEB}/scalable/legacy/${name}.svg"
		else
			if [[ "$name" == armbian_* ]]; then category="armbian"
			elif [[ "$name" == configng_* ]]; then category="configng"
			else category="other"; fi
			rel_svg_path="${LOGO_IMG_WEB}/scalable/${name}.svg"
		fi

		# metadata
		svg_title="$(extract_tag_content "$file" "dc:title" "title")"
		[ -z "$svg_title" ] && svg_title="$(extract_tag_content "$file" "title" "")"
		svg_desc="$(extract_tag_content "$file" "dc:description" "desc")"
		[ -z "$svg_desc" ] && svg_desc="$(extract_tag_content "$file" "desc" "")"
		svg_title="$(json_escape "$svg_title")"
		svg_desc="$(json_escape "$svg_desc")"

		# Build pngs array entries (if PNG files exist)
		local png_lines=""
		local png_count=0
		local sz img_path full_img_path kb kb_decimal
		for sz in "${SIZES[@]}"; do
			img_path="${LOGO_IMG_WEB}/${sz}x${sz}/${name}.png"
			full_img_path="${LOGO_IMG_ROOT}/${sz}x${sz}/${name}.png"
			if [[ -f "$full_img_path" ]]; then
				kb=$(du -k "$full_img_path" 2>/dev/null | cut -f1 || echo 0)
				if (( kb > 0 )); then
					kb_decimal="$(printf "%.2f" "$kb")"
					# append with comma if needed
					if (( png_count > 0 )); then
						png_lines="${png_lines},\n      { \"path\": \"${img_path}\", \"size\": \"${sz}x${sz}\", \"kb\": ${kb_decimal} }"
					else
						png_lines="      { \"path\": \"${img_path}\", \"size\": \"${sz}x${sz}\", \"kb\": ${kb_decimal} }"
					fi
					((png_count++))
				fi
			fi
		done

		# Write per-file JSON as an array containing the single object
		local OUTFILE="${LOGO_JSON_DIR}/${name}.json"
		mkdir -p "$(dirname "$OUTFILE")"

		{
			printf '[\n'
			printf '  {\n'
			printf '    "name": "%s",\n' "$name"
			printf '    "category": "%s",\n' "$category"
			printf '    "svg": "%s",\n' "$rel_svg_path"
			printf '    "svg_meta": {\n'
			printf '      "title": "%s",\n' "$svg_title"
			printf '      "desc": "%s"\n' "$svg_desc"
			printf '    },\n'
			printf '    "pngs": [\n'
			if [[ -n "$png_lines" ]]; then
				printf '%b\n' "$png_lines"
				printf '    ]\n'
			else
				printf '    ]\n'
			fi
			printf '  }\n'
			printf ']\n'
		} > "$OUTFILE"

		printf 'Wrote: %s\n' "$OUTFILE"
	done

	printf 'Per-image JSON files written to: %s\n' "$LOGO_JSON_DIR"
}

 _web_kit_images_page() {
    local BIN_ROOT
    BIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local WEB_ROOT="${WEB_ROOT:-$BIN_ROOT/../public_html}"
    local WEB_JSON_ROOT="${WEB_JSON_ROOT:-$WEB_ROOT/json}"

    local OUTFILE="${1:-${WEB_ROOT}/images.html}"
    mkdir -p "$(dirname "$OUTFILE")"

    # Write page header and UI (literal here-doc keeps JS template literals intact)
    cat > "$OUTFILE" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Images</title>
<style>
body { font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial; background:#111; color:#eee; margin:0; padding:1rem; }
.header { display:flex; align-items:center; justify-content:space-between; gap:1rem; flex-wrap:wrap; }
h1 { margin:0 0 0.5rem 0; }
.controls { display:flex; gap:0.5rem; align-items:center; }
.grid { margin-top:1rem; display:grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 1rem; }
.card { background:#141414; border-radius:8px; padding:0.75rem; text-align:center; box-shadow: 0 0 0 1px rgba(255,255,255,0.02) inset; }
.card img { max-width:100%; height:100px; object-fit:contain; display:block; margin:0 auto 0.5rem auto; }
.meta { font-size:0.85rem; color:#ddd; word-break:break-word; }
.badge { background:#333; padding:0.25rem 0.5rem; border-radius:6px; font-size:0.75rem; }
.filter { background:#222; color:#fff; border:1px solid #333; padding:0.35rem 0.6rem; border-radius:6px; }
.empty { color:#bbb; padding:1rem 0; text-align:center; }
</style>
</head>
<body>
<div class="header">
  <div>
    <h1>Images</h1>
    <div style="color:#bbb; font-size:0.95rem">All image entries from json/images/*.json</div>
  </div>
  <div class="controls">
    <label class="filter">Category
      <select id="categoryFilter" style="margin-left:0.5rem;">
        <option value="">All</option>
      </select>
    </label>
    <label class="filter">Search
      <input id="search" type="search" placeholder="name or title" style="margin-left:0.5rem;">
    </label>
    <button id="refresh" class="badge" title="Reload data">Refresh</button>
  </div>
</div>

<div id="grid" class="grid"></div>
<div id="empty" class="empty" style="display:none;">No images found.</div>

<!-- blocks array is inserted server-side below -->
HTML

    # Insert the blocks array (server-side) safely
    shopt -s nullglob
    printf '\n<script>\n(async () => {\n  const blocks = [\n' >> "$OUTFILE"
    local f fname title
    for f in "$WEB_JSON_ROOT"/images/*.json; do
        [[ -f "$f" ]] || continue
        fname=$(basename "$f")
        title="${fname%.json}"
        # file path relative to the web root
        printf "    { title: '%s', file: 'json/images/%s' },\n" "$title" "$fname" >> "$OUTFILE"
    done
    printf '  ];\n\n  // helper functions and UI wiring\n  const container = document.getElementById("grid");\n\n  function normalize(s){ return (s||"").toString().toLowerCase(); }\n\n  function buildCategories(items){\n    const set = new Set();\n    items.forEach(i => set.add(i.category || "other"));\n    return Array.from(set).sort();\n  }\n\n  function render(items){\n    const grid = document.getElementById("grid");\n    const empty = document.getElementById("empty");\n    grid.innerHTML = "";\n    if (!items || items.length === 0) { empty.style.display = \"block\"; return; }\n    empty.style.display = \"none\";\n    items.forEach(it => {\n      const div = document.createElement('div');\n      div.className = 'card';\n      const img = document.createElement('img');\n      let src = '';\n      if (it.pngs && it.pngs.length) src = it.pngs[0].path;\n      else if (it.svg) src = it.svg;\n      img.src = src;\n      img.alt = it.name || '';\n      const meta = document.createElement('div');\n      meta.className = 'meta';\n      meta.innerHTML = `<strong>${it.name || \"\"}</strong><div>${(it.svg_meta && it.svg_meta.title) ? it.svg_meta.title : \"\"}</div><div style=\"margin-top:0.5rem\"><span class=\"badge\">${it.category || \"\"}</span></div>`;\n      div.appendChild(img);\n      div.appendChild(meta);\n      grid.appendChild(div);\n    });\n  }\n\n  function populateCategorySelect(items){\n    const sel = document.getElementById('categoryFilter');\n    const cats = buildCategories(items);\n    while (sel.options.length > 1) sel.remove(1);\n    cats.forEach(c => { const opt = document.createElement('option'); opt.value = c; opt.textContent = c; sel.appendChild(opt); });\n  }\n\n  function applyFilters(items){\n    const q = normalize(document.getElementById('search').value);\n    const cat = document.getElementById('categoryFilter').value;\n    const filtered = (items || []).filter(it => {\n      if (cat && (it.category || '') !== cat) return false;\n      if (!q) return true;\n      return normalize(it.name).includes(q) || normalize((it.svg_meta && it.svg_meta.title) || '').includes(q) || normalize((it.svg_meta && it.svg_meta.desc) || '').includes(q);\n    });\n    render(filtered);\n  }\n\n  document.getElementById('refresh').addEventListener('click', async () => {\n    const all = [];\n    for (const b of blocks) {\n      try {\n        const r = await fetch(b.file + '?_=' + Date.now());\n        const data = await r.json();\n        if (Array.isArray(data)) data.forEach(x => all.push(x)); else all.push(data);\n      } catch (e) { console.error('Failed to load ' + b.file, e); }\n    }\n    window._IMAGES_CACHE = all;\n    populateCategorySelect(all);\n    applyFilters(all);\n  });\n\n  document.getElementById('search').addEventListener('input', () => applyFilters(window._IMAGES_CACHE || []));\n  document.getElementById('categoryFilter').addEventListener('change', () => applyFilters(window._IMAGES_CACHE || []));\n\n  // initial load\n  const initial = [];\n  for (const b of blocks) {\n    try {\n      const r = await fetch(b.file);\n      const data = await r.json();\n      if (Array.isArray(data)) data.forEach(x => initial.push(x)); else initial.push(data);\n    } catch(e) { console.error('Failed to load ' + b.file, e); }\n  }\n  window._IMAGES_CACHE = initial;\n  populateCategorySelect(initial);\n  render(initial);\n\n})();\n</script>\n' >> "$OUTFILE"

    shopt -u nullglob

    echo "Images page written to: $OUTFILE"
}


_web_kit_server_py() {

	local root="${1:-${WEB_ROOT:-}}"
	local port="${WEB_PORT:-8080}"

	if ! command -v python3 >/dev/null 2>&1; then
		echo "Python 3 is required to run the server. Please install it."
		exit 1
	fi

	if [[ -z "${root}" ]]; then
		_about_web_kit
		echo "Web root directory is not set. Provide a path or set WEB_ROOT."
		exit 1
	fi

	if [[ ! -d "${root}" ]]; then
		_about_web_kit
		echo "Web root directory ${root} does not exist. Please create it or specify a valid path."
		exit 1
	fi

	cd "${root}"

	echo "Starting Python web server in $(pwd) on port ${port}"
	python3 -m http.server "${port}" --bind 127.0.0.1 &
	PYTHON_PID=$!
	echo "Python web server started with PID ${PYTHON_PID}"
	echo "You can access the server at http://localhost:${port}/"
	echo "Press any key to stop the server..."

	trap 'echo; echo "Stopping the server..."; kill "${PYTHON_PID}" >/dev/null 2>&1 || true; wait "${PYTHON_PID}" 2>/dev/null || true' INT TERM EXIT

	read -r -n 1 -s

	echo
	echo "Stopping the server..."
	kill "${PYTHON_PID}" >/dev/null 2>&1 || true
	wait "${PYTHON_PID}" 2>/dev/null || true
	trap - INT TERM EXIT
	echo "Server stopped."
}

_web_kit_contributors_json() {

	if ! command -v jq >/dev/null 2>&1 || ! command -v wget >/dev/null 2>&1; then
		echo "jq and wget are required to generate the contributors JSON. Please install them."
		exit 1
	fi

	local USER="${1:-Tearran}"
	local REPO="${2:-configng-v2}"
	local MIN_COMMITS=10   # Default minimum commits

	local json_root="${WEB_JSON_ROOT:-${WEB_ROOT:-./}/json}"
	mkdir -p "${json_root}/contributors/"

	local OUTFILE="${3:-${json_root}/contributors/${REPO}.json}"

	echo "Generating contributors JSON for ${USER}/${REPO} (min commits: ${MIN_COMMITS})..."

	local headers=(--header="Accept: application/vnd.github+json")
	local url="https://api.github.com/repos/${USER}/${REPO}/contributors?per_page=100"

	if ! wget -qO- "${headers[@]}" "${url}" \
		| jq --argjson min "$MIN_COMMITS" '[.[] | select(.contributions > $min) | {login, contributions, avatar_url, html_url}]' \
		> "${OUTFILE}"; then
		echo "Failed to generate contributors JSON for ${USER}/${REPO}."
		exit 1
	fi

	echo "Contributors JSON generated at ${OUTFILE}"
}

_web_kit_contrib_page() {
    local OUTFILE="${1:-$WEB_ROOT/contributors.html}"
    mkdir -p "$(dirname "$OUTFILE")"

    cat <<'EOF' > "$OUTFILE"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Armbian Top Contributors</title>
<style>
body { font-family: sans-serif; background:#111; color:#eee; margin:0; padding:1rem; }
h1 { text-align:center; }
.block { margin-bottom:2rem; }
.block h2 { text-align:left; margin:0.5rem 0; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 1rem; }
.contributor { background:#222; border-radius:8px; text-align:center; padding:0.5rem; }
.contributor img { border-radius:50%; width:80px; height:80px; object-fit:cover; }
.small img { width:50px; height:50px; }
.contributor p { margin:0.25rem 0; font-size:0.85rem; }
a { color: inherit; text-decoration: none; }
a:hover { text-decoration: underline; }
</style>

</head>
<main>
	<h1>Armbian Top Contributors</h1>
	<p>Contributors with more than 10 commits to the Armbian projects.</p>
	<!-- Container for contributors -->
	<div id="contributors-container"></div>
</main>
<script>
(async () => {
  const container = document.getElementById('contributors-container');
  const blocks = [
EOF

    # Add each contributors JSON as a block (json/contributors/*.json)
    for f in "$WEB_JSON_ROOT"/contributors/*.json; do
        [[ -f "$f" ]] || continue
        fname=$(basename "$f")
        # Title: strip trailing .json
        title="${fname%.json}"
        # Use smaller icons for particular files (adjust as needed)
        icon_size="false"
        [[ "$fname" == "build-scripts.json" ]] && icon_size="true"
        # JSON file path, relative to the HTML page (WEB_ROOT/contributors.html -> json/contributors/<file>)
        echo "    { title: '$title', file: 'json/contributors/$fname', small: $icon_size }," >> "$OUTFILE"
    done

    cat <<'EOF' >> "$OUTFILE"
  ];

  for (const block of blocks) {
    const divBlock = document.createElement('div');
    divBlock.className = 'block';
    const title = document.createElement('h2');
    title.textContent = block.title;
    divBlock.appendChild(title);

    const grid = document.createElement('div');
    grid.className = 'grid';
    if (block.small) grid.classList.add('small');

    try {
      const resp = await fetch(block.file);
      const data = await resp.json();
      data.forEach(user => {
        const div = document.createElement('div');
        div.className = 'contributor';
        div.innerHTML = `
          <a href="${user.html_url}" target="_blank">
            <img src="${user.avatar_url}" alt="${user.login}">
            <p>${user.login}</p>
            <p>${user.contributions} commits</p>
          </a>
        `;
        grid.appendChild(div);
      });
    } catch(e) {
      console.error("Failed to load " + block.file, e);
    }

    divBlock.appendChild(grid);
    container.appendChild(divBlock);
  }
})();
</script>
</body>
</html>
EOF

    echo "Contributor page written to $OUTFILE"
}

_web_kit_icon_set() {
	local SRC_DIR="${1:-${SVG_LOGO_ROOT:-}}"
	local OUT_DIR_BASE="${2:-${WEB_LOGO_ROOT:-}}"

	[[ -n "${SRC_DIR}" && -d "${SRC_DIR}" ]] || { echo "SVG source not found: ${SRC_DIR}"; return 1; }
	[[ -n "${OUT_DIR_BASE}" ]] || { echo "Output directory not given or empty"; return 1; }

	# Prefer 'magick' if available, else 'convert'
	local IM="convert"
	if command -v magick >/dev/null 2>&1; then
		IM="magick"
	elif ! command -v convert >/dev/null 2>&1; then
		echo "ImageMagick is required ('magick' or 'convert' not found)."
		return 1
	fi

	# Sizes
	local DEFAULT_SIZES="16,32,48,64,96,128,180,192,256,384,512,1024"
	local sizes_csv="${ICON_SIZES:-$DEFAULT_SIZES}"
	IFS=',' read -r -a SIZES <<<"${sizes_csv//[[:space:]]/}"

	# Ensure output structure
	mkdir -p "${OUT_DIR_BASE}/scalable" "${OUT_DIR_BASE}/scalable/legacy"

	# Copy SVGs (non-legacy)
	find "${SRC_DIR}" -maxdepth 1 -type f -name "*.svg" -exec cp -f {} "${OUT_DIR_BASE}/scalable/" \;

	# Copy legacy SVGs if present
	if [[ -d "${SRC_DIR}/legacy" ]]; then
		find "${SRC_DIR}/legacy" -maxdepth 1 -type f -name "*.svg" -exec cp -f {} "${OUT_DIR_BASE}/scalable/legacy/" \;
	fi

	# Render PNGs into <out>/<size>x<size>/<name>.png
	# Iterate both src and optional src/legacy
	shopt -s nullglob
	local svg
	for svg in "${SRC_DIR}"/*.svg "${SRC_DIR}/legacy"/*.svg; do
		[[ -e "$svg" ]] || continue
		local base="$(basename "${svg%.svg}")"
		for size in "${SIZES[@]}"; do
			[[ "$size" =~ ^[0-9]+$ ]] || continue
			local OUT_DIR="${OUT_DIR_BASE}/${size}x${size}"
			mkdir -p "${OUT_DIR}"
			# Transparent background, keep aspect, center and pad to square
			# 'magick' and 'convert' accept the same arguments here.
			$IM -background none -density 384 "$svg" \
				-resize "${size}x${size}" \
				-gravity center -extent "${size}x${size}" \
				"${OUT_DIR}/${base}.png"
		done
	done
	shopt -u nullglob

	# Favicon generation
	# Prefer a specific file if present; fall back to the first available SVG
	local FAVICON_SVG="${SRC_DIR}/armbian_social.svg"
	if [[ ! -f "$FAVICON_SVG" ]]; then
		for svg in "${SRC_DIR}"/*.svg; do
			[[ -f "$svg" ]] || continue
			FAVICON_SVG="$svg"
			break
		done
	fi

	if [[ -f "$FAVICON_SVG" ]]; then
		local tmp16="${WEB_ROOT}/favicon-16.png"
		local tmp32="${WEB_ROOT}/favicon-32.png"
		local tmp48="${WEB_ROOT}/favicon-48.png"
		$IM -background none "$FAVICON_SVG" -resize 16x16 "$tmp16"
		$IM -background none "$FAVICON_SVG" -resize 32x32 "$tmp32"
		$IM -background none "$FAVICON_SVG" -resize 48x48 "$tmp48"
		$IM "$tmp16" "$tmp32" "$tmp48" "${WEB_ROOT}/favicon.ico"
		rm -f "$tmp16" "$tmp32" "$tmp48"
		echo "Favicon generated at ${WEB_ROOT}/favicon.ico"
	else
		echo "No SVG found for favicon in ${SRC_DIR} (looked for armbian_social.svg or any .svg). Skipping favicon."
	fi

	echo "SVGs copied to:       ${OUT_DIR_BASE}/scalable[/legacy]"
	echo "PNG icons generated:  ${OUT_DIR_BASE}/{SIZE}x{SIZE}/name.png"
}


_about_web_kit() {
	cat <<EOF
Usage: web_kit <command> [options]

Commands:
    server,  -s [PATH]         Run a Python 3 simple web server for the specified
                               path, or use the default web root.
    icons,   -i [SRC] [OUT]    Generate icon sets and favicon from SVG sources.
                               Defaults: SRC=\$SVG_LOGO_ROOT, OUT=\$WEB_LOGO_ROOT
    json,    -j                Generate a logos JSON file from all SVGs and PNGs.
    contrib, -c [USER] [REPO]  Generate a contributors JSON file for a GitHub repo.
    build,   -b                Build icons, logos JSON, and contributors JSON.
    help,    -h                Show this help message.

Environment:
    ICON_SIZES                 Comma-separated list of sizes. Default:
                               16,32,48,64,96,128,180,192,256,384,512,1024
    SVG_LOGO_ROOT             (defaults to \$BIN_ROOT/../assets/images/logos)
    WEB_LOGO_ROOT             (defaults to \$WEB_ROOT/images/logos)

Examples:
    # Run server in a specific directory
    web_kit -s ~/public_html
    web_kit server /var/www/html

    # Run server in default web root
    web_kit server
    web_kit -s

    # Generate icons
    web_kit icons
    web_kit -i

    # Generate logos JSON
    web_kit json
    web_kit -j

    # Generate contributors JSON
    web_kit contrib Tearran configng-v2
    web_kit -c Tearran configng-v2

    # Build all
    web_kit build
    web_kit -b

Notes:
    - Requires Python 3, jq, and ImageMagick ('magick' or 'convert') in PATH.
    - Server runs on port 8080 and stops with any key press.
    - Keep this help text updated if commands or usage change.
EOF
}

### START ./web_kit.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	BIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	DOC_ROOT="${DOC_ROOT:-$BIN_ROOT/../doc}"
	SVG_LOGO_ROOT="${SVG_ROOT:-$BIN_ROOT/../assets/images/logos}"

	WEB_ROOT="${WEB_ROOT:-$BIN_ROOT/../public_html}"
	WEB_JSON_ROOT="${WEB_JSON_ROOT:-$WEB_ROOT/json}"
	WEB_DOC_ROOT="${WEB_DOC_ROOT:-$WEB_ROOT/doc}"
	WEB_LOGO_ROOT="${WEB_LOGO_ROOT:-$WEB_ROOT/images/logos}"

	# --- Capture and assert help output ---
	help_output="$(web_kit help)"
	echo "$help_output" | grep -q "Usage: web_kit" || {
		echo "fail: Help output does not contain the expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---

	web_kit "$@"
fi

### END ./web_kit.sh - Armbian Config V2 test entrypoint
