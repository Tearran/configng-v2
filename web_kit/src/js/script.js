function valueOrNull(val) {
  return val === undefined || val === null || val === ""
    ? "<span style='color:#c00'>null</span>"
    : val;
}

// Load logos
fetch("./json/logos.json")
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
    const opts = mod.options.split(",").map(o => o.trim()).filter(Boolean);
    if (opts.length) {
      const spanWrap = opts.map(o => `<span>${escapeHTML(o)}</span>`).join("");
      div.innerHTML += `<div class="options"><strong>Options:</strong> ${spanWrap}</div>`;
    }
  }
  return div;
}

function escapeHTML(str) {
  return (str || "").replace(/[<>&"']/g, c => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;', "'": '&#39;' }[c]));
}

