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

