document.addEventListener('DOMContentLoaded', function () {
        const JSON_URL = "./json/configng.json";
        let data = {};
        let state = { cat: null, group: null, feature: null };

        function escapeHTML(str) {
                return (str || "").replace(/[<>&"']/g, c => ({ "<": "&lt;", ">": "&gt;", "&": "&amp;", '"': "&quot;", "'": "&#39;" }[c]));
        }

        function setBreadcrumbs() {
                const bc = [];
                if (state.cat) bc.push({ label: "Categories", action: () => navTo() });
                if (state.cat && state.group)
                        bc.push({ label: state.cat, action: () => navTo(state.cat) });
                if (state.cat && state.group && state.feature)
                        bc.push({ label: state.group, action: () => navTo(state.cat, state.group) });
                if (state.cat && state.group && state.feature)
                        bc.push({ label: state.feature });
                const el = document.getElementById("breadcrumbs");
                el.innerHTML = bc
                        .map((b) =>
                                b.action
                                        ? `<div tabindex="0" class="breadcrumb" onclick="(${b.action})()" onkeydown="if(event.key==='Enter'){(${b.action})()}">${b.label}</div>`
                                        : `<div class="breadcrumb" style="pointer-events:none;opacity:.7">${b.label}</div>`
                        )
                        .join(' <span style="color:var(--desc)">›</span> ');
        }

        function navTo(cat = null, group = null, feature = null) {
                state.cat = cat;
                state.group = group;
                state.feature = feature;
                setBreadcrumbs();
                renderMenu();
                clearOutput();
        }

        function renderMenu() {
                const menu = document.getElementById("menu");
                let html = "";
                let menuArr = data.menu || [];
                if (!state.cat) {
                        html += "<ul>";
                        for (const cat of menuArr) {
                                html += `<li>
                    <button class="menu-btn" id="menu-btn-${escapeHTML(cat.id.toLowerCase())}" onclick="navTo('${escapeHTML(cat.id)}')">
                        <span>${escapeHTML(cat.id)}</span>
                        ${cat.description ? `<span class="feature-desc">&nbsp;–&nbsp;${escapeHTML(cat.description)}</span>` : ""}
                    </button>
                </li>`;
                        }
                        html += "</ul>";
                } else {
                        const catObj = menuArr.find((c) => c.id === state.cat);
                        if (!catObj) {
                                menu.innerHTML = "<b>Category not found</b>";
                                return;
                        }
                        const entries = catObj.sub || [];
                        if (!state.group && !state.feature) {
                                html += `<h2>Category: ${escapeHTML(catObj.id)}</h2>`;
                                if (catObj.description)
                                        html += `<div class="desc">${escapeHTML(catObj.description)}</div>`;
                                html += "<ul>";
                                for (const entry of entries) {
                                        if ("feature" in entry) {
                                                html += `<li>
                            <button class="feature-btn" onclick="navTo('${escapeHTML(catObj.id)}', null, '${escapeHTML(entry.id)}')">
                                <span class="feature-label">${escapeHTML(entry.id)}</span>
                                <span class="feature-desc">&nbsp;–&nbsp;${escapeHTML(entry.description || "")}</span>
                            </button>
                        </li>`;
                                        } else if ("sub" in entry && Array.isArray(entry.sub)) {
                                                html += `<li>
                            <button class="menu-btn" id="menu-btn-${escapeHTML(entry.id.toLowerCase())}" onclick="navTo('${escapeHTML(catObj.id)}','${escapeHTML(entry.id)}')">
                                <span>${escapeHTML(entry.id)}</span>
                                ${entry.description ? `<span class="feature-desc">&nbsp;–&nbsp;${escapeHTML(entry.description)}</span>` : ""}
                            </button>
                        </li>`;
                                        }
                                }
                                html += "</ul>";
                        } else if (state.group && !state.feature) {
                                const groupObj = entries.find((g) => g.id === state.group);
                                if (!groupObj) {
                                        menu.innerHTML = `<b>Group not found</b>`;
                                        return;
                                }
                                html += `<h2>${escapeHTML(catObj.id)} &gt; ${escapeHTML(groupObj.id)}</h2>`;
                                if (groupObj.description)
                                        html += `<div class="desc">${escapeHTML(groupObj.description)}</div>`;
                                html += "<ul>";
                                for (const mod of groupObj.sub || []) {
                                        html += `<li>
                        <button class="feature-btn" onclick="navTo('${escapeHTML(catObj.id)}','${escapeHTML(groupObj.id)}','${escapeHTML(mod.id)}')">
                            <span class="feature-label">${escapeHTML(mod.id)}</span>
                            <span class="feature-desc">&nbsp;–&nbsp;${escapeHTML(mod.description || "")}</span>
                        </button>
                    </li>`;
                                }
                                html += "</ul>";
                        } else {
                                let mod = null;
                                if (state.group) {
                                        const groupObj = entries.find((g) => g.id === state.group);
                                        if (groupObj && groupObj.sub) {
                                                mod = groupObj.sub.find((m) => m.id === state.feature);
                                        }
                                } else {
                                        mod = entries.find((m) => m.id === state.feature);
                                }
                                if (!mod) {
                                        menu.innerHTML = `<b>Module not found</b>`;
                                        return;
                                }
                                html += `<div class="module-card">`;
                                html += `<h2>${escapeHTML(mod.id)}</h2>`;
                                if (mod.description)
                                        html += `<div class="desc">${escapeHTML(mod.description)}</div>`;
                                if (mod.about)
                                        html += `<div class="desc"><small>${escapeHTML(mod.about)}</small></div>`;
                                if (mod.options) {
                                        html += `<div class="options-block"><b>Options:</b><br>`;
                                        for (const opt of mod.options.split(",")) {
                                                const trimmed = opt.trim();
                                                if (!trimmed) continue;
                                                html += `<button class="option-btn" onclick="sendOption('${escapeHTML(mod.id)}','${escapeHTML(trimmed)}')">${escapeHTML(trimmed)}</button>`;
                                                html += `<div class="option-desc" id="desc-${escapeHTML(trimmed.replace(/[^a-zA-Z0-9_-]/g, "_"))}"></div>`;
                                        }
                                        html += `</div>`;
                                }
                                html += `<details><summary>Raw details</summary><pre>${escapeHTML(JSON.stringify(mod, null, 2))}</pre></details>`;
                                html += `</div>`;
                        }
                }
                menu.innerHTML = html;
        }

        function sendOption(id, option) {
                const out = document.getElementById("command-output");
                out.textContent = `Would send: ${id} ${option}`;
        }

        function clearOutput() {
                document.getElementById("command-output").textContent = "";
        }

        window.navTo = navTo;
        window.sendOption = sendOption;

        // Fetch the JSON
        fetch(JSON_URL)
                .then(response => response.json())
                .then(json => {
                        data = json;
                        navTo();
                })
                .catch((err) => {
                        document.getElementById("menu").innerHTML = "<b>Failed to load menu data.</b>";
                        console.error("Error loading JSON:", err);
                });
});