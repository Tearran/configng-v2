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
			_media_kit_html   || echo "ERROR: _media_kit_html failed"
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

_html_index(){
cat <<'EOF' > "$DIST/index.html"
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title>Armbian Home</title>
	<link rel="icon" href="favicon.ico" type="image/x-icon">
	<style>
		/* Base Styles */
		/* Header */
		header {
			background: #23262f;
			color: #fff;
			padding: 0.5em 1em;
			display: flex;
			align-items: center;
			justify-content: space-between;
			flex-wrap: wrap;
		}

		header .header-logo img {
			height: 64px;
			vertical-align: middle;
		}

		.nav-bar ul {
			list-style: none;
			padding: 0;
			margin: 0;
			display: flex;
			gap: 1em;
		}

		.nav-bar a {
			color: #fff;
			text-decoration: none;
			font-weight: 500;
		}

		.nav-bar a:hover {
			color: #3ea6ff;
		}

		/* Page Info Section */
		#page-info {
			padding: 1em;
			background: #f5f5f5;
			border-bottom: 1px solid #ddd;
		}

		#page-info h1 {
			margin: 0;
			font-size: 1.8em;
			color: #23262f;
		}

		#page-info p {
			margin: 0.5em 0 0 0;
			font-size: 1em;
			color: #444;
		}

		/* Main Content */
		main {
			padding: 1em;
		}

		/* Footer */
	footer { background: #23262f; color: #fff; padding: 2rem 1rem; font-size: 0.9em; }
	.footer-content { display: flex; flex-wrap: wrap; justify-content: space-between; max-width: 1000px; margin: 0 auto; gap: 2em; }
	.footer-links h4 { margin-bottom: 0.5em; font-size: 1em; }
	.footer-links ul { list-style: none; margin: 0; padding: 0; }
	.footer-links li { margin: 0.3em 0; }
	.footer-links a { color: #3ea6ff; text-decoration: none; }
	.footer-links a:hover { text-decoration: underline; }
	.footer-about { flex: 1 1 100%; margin-top: 1em; text-align: center; color: #bbb; }
	.footer-about p { margin: 0.3em 0; }
	.footer-legal { margin-top: 2em; font-size: 0.8em; color: #aaa; text-align: left; max-width: 800px; margin-left: auto; margin-right: auto; }
	.footer-legal ul { list-style: none; padding: 0; margin: 0.5em 0; }
	.footer-legal li { margin: 0.2em 0; }

		/* Dark Mode */
		body.dark-mode {
			background: #121212;
			color: #ddd;
		}

		body.dark-mode #page-info {
			background: #1e1e1e;
			border-bottom: 1px solid #444;
		}

		body.dark-mode a {
			color: #4aa3ff;
		}

		body.dark-mode footer {
			color: #ccc;
		}

		/* Dark mode for Page Info */
		body.dark-mode #page-info {
			background: #1e1e1e;
			/* darker background */
			border-bottom: 1px solid #444;
			/* subtle border */
		}

		body.dark-mode #page-info h1,
		body.dark-mode #page-info p {
			color: #ddd;
			/* lighter text for contrast */
		}

		/* Dark Mode Toggle */
		#dark-mode-toggle {
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
	</style>
</head>

<body>

	<header>
		<span class="header-logo">
			<a href="https://www.armbian.com/" target="_blank" rel="noopener">
				<img src="https://tearran.github.io/configng-v2/media_kit/dist/images/scalable/armbian_social.svg" alt="Armbian Logo">
				<img src="https://tearran.github.io/configng-v2/media_kit/dist/images/scalable/armbian_font.v2.1.svg" alt="Armbian Font">
			</a>
		</span>

		<nav class="nav-bar">
			<ul>
				<li><a href="index.html">Home</a></li>
				<li><a href="media_kit.html">Media kit</a></li>
				<li><a href="docs.html">Documentation</a></li>
				<li><a href="forum.html">Forum</a></li>
			</ul>
		</nav>

		<button id="dark-mode-toggle">🌙 Dark Mode</button>
	</header>

	<!-- Page Info Section -->
	<section id="page-info">
		<h1>Welcome to Armbian</h1>
		<p>This is the home page. Use the navigation above to explore logos, documentation, and community resources.</p>

	</section>

	<main>
		<!-- Main content goes here -->
		<p>Keep this section simple or expand as needed for home page content.</p>

	</main>

<footer>

 <div class="footer-content">
    <div class="footer-links">
      <h4>Resources</h4>
      <ul>
        <li><a href="https://www.armbian.com/" target="_blank" rel="noopener">Home</a></li>
        <li><a href="https://docs.armbian.com/" target="_blank" rel="noopener">Documentation</a></li>
        <li><a href="https://github.com/armbian" target="_blank" rel="noopener">GitHub</a></li>
        <li><a href="https://forum.armbian.com/" target="_blank" rel="noopener">Forum</a></li>
      </ul>
    </div>

    <div class="footer-links">
      <h4>Community</h4>
      <ul>
        <li><a href="https://forum.armbian.com/" target="_blank" rel="noopener">Forum</a></li>
        <li><a href="https://fosstodon.org/@armbian" target="_blank" rel="me noopener">Mastodon</a></li>
        <li><a href="https://discord.gg/armbian" target="_blank" rel="noopener">Discord</a></li>
        <li><a href="https://www.linkedin.com/company/armbian/posts/?feedView=all" target="_blank" rel="noopener">LinkedIn</a></li>
      </ul>
    </div>
   <div class="footer-legal">
    <p><strong>Disclaimer:</strong><br>
      This site and its logos are powered by the Armbian Community™. Please read the following very serious, totally enforceable, absolutely binding guidelines:
    </p>
    <ul>
      <li><b>Do:</b> Share and remix logos responsibly, give credit, and spread the penguin love.</li>
      <li><b>Do:</b> Use logos to show support for Armbian, community projects, or your cat’s Raspberry Pi server.</li>
      <li><b>Don’t:</b> Pretend your project <i>is</i> Armbian, or imply official endorsement when you’re just hacking in your garage.</li>
      <li><b>Don’t:</b> Sell the logos as NFTs, print them on cryptocurrency, or tattoo them on unwilling relatives.</li>
    </ul>
    <p>
      All logos are provided “as-is,” with no warranty except the guarantee that someone will complain about the color scheme.
      By scrolling this far, you acknowledge that you’ve probably read more legal text than most end-user license agreements.
    </p>
  </div>

<div class="footer-about">
      <p>&copy; 2025 Armbian Logos Media Kit</p>
      <p>Powered by the Armbian Community — aligning innovation, coffee, and questionable life choices.</p>
    </div>
</footer>
	<script>
		// Dark Mode Toggle
		const toggle = document.getElementById('dark-mode-toggle');
		const body = document.body;
		if (localStorage.getItem('darkMode') === 'true') {
			body.classList.add('dark-mode');
			toggle.textContent = '☀️ Light Mode';
		}
		toggle.addEventListener('click', () => {
			body.classList.toggle('dark-mode');
			const isDark = body.classList.contains('dark-mode');
			localStorage.setItem('darkMode', isDark);
			toggle.textContent = isDark ? '☀️ Light Mode' : '🌙 Dark Mode';
		});
	</script>

</body>

</html>

EOF

}

_media_kit_html() {
	cat <<'EOF' > "$DIST/media_kit.html"
<!DOCTYPE html>
<html>
<head>
	<meta charset='UTF-8'>
	<link rel="icon" type="image/x-icon" href="favicon.ico">
	<title>Armbian Logos</title>
	<style>
	/* Default Light Mode */
	body { background: #fff; color: #000; font-family: sans-serif; margin: 0; }
	header { background: #23262f; color: #fff; padding: 0.3rem 1rem; display: flex; align-items: center; min-height: 56px; }
	header .header-logo { display: flex; gap: 0em; padding: 0.1rem }
	header a { display: inline-block; }
	header img { vertical-align: middle; height: 64px; width: auto; }

	footer { background: #23262f; color: #fff; padding: 2rem 1rem; font-size: 0.9em; }
	.footer-content { display: flex; flex-wrap: wrap; justify-content: space-between; max-width: 1000px; margin: 0 auto; gap: 2em; }
	.footer-links h4 { margin-bottom: 0.5em; font-size: 1em; }
	.footer-links ul { list-style: none; margin: 0; padding: 0; }
	.footer-links li { margin: 0.3em 0; }
	.footer-links a { color: #3ea6ff; text-decoration: none; }
	.footer-links a:hover { text-decoration: underline; }
	.footer-about { flex: 1 1 100%; margin-top: 1em; text-align: center; color: #bbb; }
	.footer-about p { margin: 0.3em 0; }
	.footer-legal { margin-top: 2em; font-size: 0.8em; color: #aaa; text-align: left; max-width: 800px; margin-left: auto; margin-right: auto; }
	.footer-legal ul { list-style: none; padding: 0; margin: 0.5em 0; }
	.footer-legal li { margin: 0.2em 0; }

	/* Nav Bar */
	.nav-bar { margin-left: auto; }
	.nav-bar ul { list-style: none; margin: 0; padding: 0; display: flex; gap: 1.2em; }
	.nav-bar li { display: inline; }
	.nav-bar a { color: #fff; text-decoration: none; font-weight: 500; transition: color 0.2s ease-in-out; }
	.nav-bar a:hover { color: #3ea6ff; }

	/* Responsive */
	@media (max-width: 768px) {
	  header { flex-direction: column; align-items: flex-start; padding: 0.5rem 1rem; }
	  .nav-bar ul { flex-direction: column; gap: 0.5em; margin-top: 0.5em; }
	  main { grid-template-columns: 1fr; grid-template-rows: auto; }
	}

	main { padding: 1em; display: grid; grid-template-columns: 1fr 1fr; grid-template-rows: auto auto; gap: 1em; }
	.section { padding: 1em; background: #f0f0f0; border-radius: 6px; }
	.section h2 { margin-top: 0; }
	img { margin: 0.5em; vertical-align: middle; }
	.legacy { opacity: 0.85; }
	ul { list-style-type: none; padding-left: 0; }
	ul li { margin: 0.2em 0; }
	.meta { font-size: 0.95em; color: #444; margin: 0.25em 0 0.5em 0; }
	.meta span { display: inline-block; min-width: 70px; }

	/* Dark Mode */
	body.dark-mode { background: #121212; color: #ddd; }

	body.dark-mode .section { background: #1e1e1e; color: #ddd; }
	body.dark-mode .legacy { opacity: 0.7; }
	body.dark-mode a { color: #4aa3ff; }
	body.dark-mode .footer-links a { color: #4aa3ff; }
	body.dark-mode .footer-about { color: #ccc; }
	body.dark-mode .footer-legal { color: #888; }
	body.dark-mode hr { border-bottom: 1px solid #444; }
	body.dark-mode .meta { font-size: 0.95em; color: #fff; margin: 0.25em 0 0.5em 0; }

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
	#dark-mode-toggle:hover { background: #c3c3c3; }

/* Page Info Section */
#page-info {
  padding: 1em;
  border-bottom: 1px solid #ddd;
}

#page-info p {
  margin: 0.5em 0 0 0;
  font-size: 1em;

}


	</style>
</head>
<body>

<header>
  <span class="header-logo">
    <a href="https://www.armbian.com/" target="_blank" rel="noopener">
      <img src="./images/scalable/armbian_social.svg" alt="armbian-tux_v1.5.svg">
      <img src="./images/scalable/armbian_font.v2.1.svg" alt="armbian_font.v2.1.svg">
    </a>
  </span>



  <!-- Navigation -->
  <nav class="nav-bar">
    <ul>
      <li><a href="https://www.armbian.com/">Home</a></li>
      <li><a href="https://forum.armbian.com/">Forum</a></li>
      <li><a href="https://docs.armbian.com/">Documentation</a></li>
    </ul>
  </nav>
    <!-- Dark Mode Toggle -->
  <butt  on id="dark-mode-toggle">🌙 Dark Mode</button>
</header>

<!-- Page Info / Subtitle -->
<section id="page-info">
  <h1>Armbian Logos Media Kit</h1>
  <p>We've put together some logos and icons for you to use in your articles and projects.</p>
</section>


<main>

  <div id="armbian-section" class="section"><h2>Armbian</h2><div id="armbian-logos"></div></div>
  <div id="configng-section" class="section"><h2>ConfigNG</h2><div id="configng-logos"></div></div>
  <div id="armbian-legacy-section" class="section legacy"><h2>Armbian Legacy</h2><div id="armbian-legacy-logos"></div></div>
  <div id="configng-legacy-section" class="section legacy"><h2>ConfigNG Legacy</h2><div id="configng-legacy-logos"></div></div>
</main>


<footer>
<div class="footer-content">
    <div class="footer-links">
      <h4>Resources</h4>
      <ul>
        <li><a href="https://www.armbian.com/" target="_blank" rel="noopener">Home</a></li>
        <li><a href="https://docs.armbian.com/" target="_blank" rel="noopener">Documentation</a></li>
        <li><a href="https://github.com/armbian" target="_blank" rel="noopener">GitHub</a></li>
        <li><a href="https://forum.armbian.com/" target="_blank" rel="noopener">Forum</a></li>
      </ul>
    </div>

    <div class="footer-links">
      <h4>Community</h4>
      <ul>
        <li><a href="https://forum.armbian.com/" target="_blank" rel="noopener">Forum</a></li>
        <li><a href="https://fosstodon.org/@armbian" target="_blank" rel="me noopener">Mastodon</a></li>
        <li><a href="https://discord.gg/armbian" target="_blank" rel="noopener">Discord</a></li>
        <li><a href="https://www.linkedin.com/company/armbian/posts/?feedView=all" target="_blank" rel="noopener">LinkedIn</a></li>
      </ul>
    </div>

    <div class="footer-links">
      <h4>Community</h4>
      <ul>
        <li><a href="https://forum.armbian.com/" target="_blank" rel="noopener">Forum</a></li>
        <li><a href="https://fosstodon.org/@armbian" target="_blank" rel="me noopener">Mastodon</a></li>
        <li><a href="https://discord.gg/armbian" target="_blank" rel="noopener">Discord</a></li>
        <li><a href="https://www.linkedin.com/company/armbian/posts/?feedView=all" target="_blank" rel="noopener">LinkedIn</a></li>
      </ul>
    </div>

<div class="footer-legal">
    <p><strong>Disclaimer:</strong><br>
      This site and its logos are powered by the Armbian Community™. Please read the following very serious, totally enforceable, absolutely binding guidelines:
    </p>
    <ul>
      <li><b>Do:</b> Share and remix logos responsibly, give credit, and spread the penguin love.</li>
      <li><b>Do:</b> Use logos to show support for Armbian, community projects, or your cat’s Raspberry Pi server.</li>
      <li><b>Don’t:</b> Pretend your project <i>is</i> Armbian, or imply official endorsement when you’re just hacking in your garage.</li>
      <li><b>Don’t:</b> Sell the logos as NFTs, print them on cryptocurrency, or tattoo them on unwilling relatives.</li>
    </ul>
    <p>
      All logos are provided “as-is,” with no warranty except the guarantee that someone will complain about the color scheme.
      By scrolling this far, you acknowledge that you’ve probably read more legal text than most end-user license agreements.
    </p>
  </div>

    <div class="footer-about">
      <p>&copy; 2025 Armbian Logos Media Kit</p>
      <p>Powered by the Armbian Community — aligning innovation, coffee, and questionable life choices.</p>
    </div>
  </div>


</footer>


<script>
function valueOrNull(val) {
  return (val === undefined || val === null || val === "") ? "<span style='color:#c00'>null</span>" : val;
}

// Load logos
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
      let metaHtml = `<div class="meta">
        <span><b>Title:</b> ${valueOrNull(meta.title)}</span><br>
        <span><b>Description:</b> ${valueOrNull(meta.desc)}</span>
      </div>`;
      if (!logo.pngs || logo.pngs.length === 0 || logo.category.endsWith('legacy')) {
        div.innerHTML = `<hr>
          <a href="${logo.svg}" target="_blank">
            <img src="${logo.svg}" alt="${logo.name}" width="64" height="64">
          </a>
          ${metaHtml}
          <p><a href="${logo.svg}" target="_blank">Open SVG / Download</a></p>`;
      } else {
        const pngList = logo.pngs.map(p => `<li><a href="${p.path}">${p.size} PNG</a> – ${p.kb} KB</li>`).join('');
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
const toggle = document.getElementById('dark-mode-toggle');
const body = document.body;

// Initialize from localStorage
if (localStorage.getItem('darkMode') === 'true') {
  body.classList.add('dark-mode');
  toggle.textContent = '☀️ Light Mode';
}

toggle.addEventListener('click', () => {
  body.classList.toggle('dark-mode');
  const isDark = body.classList.contains('dark-mode');
  localStorage.setItem('darkMode', isDark);
  toggle.textContent = isDark ? '☀️ Light Mode' : '🌙 Dark Mode';
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