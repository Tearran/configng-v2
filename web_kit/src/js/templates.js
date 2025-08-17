// Utility: inject HTML fragment into selector
function injectFragment(selector, url) {
        fetch(url)
                .then(r => r.text())
                .then(html => {
                        document.querySelector(selector).innerHTML = html;
                });
}

// Inject shared fragments
document.addEventListener('DOMContentLoaded', () => {
        // Inject nav/header/footer
        injectFragment('#header', './blocks/nav.html');
        injectFragment('#nav', './blocks/nav.html'); // if you want nav separate, or skip if in header
        injectFragment('#footer', './blocks/footer.html');

        // Inject head fragment (special handling, can't use innerHTML for <head>)
        fetch('./blocks/head.html')
                .then(r => r.text())
                .then(html => {
                        const doc = new DOMParser().parseFromString(html, 'text/html');
                        // Append all children from fragment to actual head
                        Array.from(doc.head.children).forEach(node => document.head.appendChild(node));
                });

        // Load main content from JSON and render
        fetch('./json/home.json')
                .then(r => r.json())
                .then(mainContent => {
                        renderFeatures(mainContent.key_features);
                        renderUEFIDevices(mainContent.uefi_devices);
                        renderGettingStarted(mainContent.getting_started);
                });
});

// --- Renderers (same as before!) ---
function renderFeatures(data) {
        const features = [
                {
                        title: data.feature1_title,
                        subtitle: data.feature1_subtitle,
                        link: data.feature1_link,
                        icon: data.feature1_icon
                },
                {
                        title: data.feature2_title,
                        subtitle: data.feature2_subtitle,
                        link: data.feature2_link,
                        icon: data.feature2_icon
                },
                {
                        title: data.feature3_title,
                        subtitle: data.feature3_subtitle,
                        link: data.feature3_link,
                        icon: data.feature3_icon
                }
        ];
        const container = document.getElementById('features-list');
        container.innerHTML = features.map(f => `
            <div class="feature">
                <h3><i class="fa ${f.icon}"></i> <a href="${f.link}" target="_blank">${f.title}</a></h3>
                <p>${f.subtitle}</p>
            </div>
        `).join('');
}

function renderUEFIDevices(data) {
        document.getElementById('uefi-title').textContent = data.title;
        document.getElementById('uefi-note').textContent = data.note;
        const devices = [
                {
                        arch: data.device1_arch,
                        link: data.device1_link,
                        img: data.device1_img,
                        alt: data.device1_img_alt
                },
                {
                        arch: data.device2_arch,
                        link: data.device2_link,
                        img: data.device2_img,
                        alt: data.device2_img_alt
                },
                {
                        arch: data.device3_arch,
                        link: data.device3_link,
                        img: data.device3_img,
                        alt: data.device3_img_alt
                }
        ];
        const container = document.getElementById('uefi-devices-list');
        container.innerHTML = devices.map(d => `
            <div class="uefi-device">
                <a href="${d.link}" target="_blank">
                    <img src="${d.img}" alt="${d.alt}" />
                    <h4>${d.arch}</h4>
                </a>
            </div>
        `).join('');
}

function renderGettingStarted(data) {
        const steps = [
                {
                        title: data.step1_title,
                        content: data.step1_content,
                        link: data.step1_link,
                        docs: data.step1_docs,
                        icon: data.step1_icon
                },
                {
                        title: data.step2_title,
                        content: data.step2_content,
                        docs: data.step2_docs,
                        icon: data.step2_icon
                },
                {
                        title: data.step3_title,
                        content: data.step3_content,
                        docs: data.step3_docs,
                        icon: data.step3_icon
                },
                {
                        title: data.step4_title,
                        content: data.step4_content,
                        docs: data.step4_docs,
                        icon: data.step4_icon
                }
        ];
        const container = document.getElementById('getting-started-steps');
        container.innerHTML = steps.map((s, i) => `
            <div class="step">
                <div class="step-title"><i class="fa ${s.icon}"></i> Step ${i + 1}: ${s.title}</div>
                <p>${s.content}</p>
                ${s.link ? `<p><a href="${s.link}" target="_blank">Download</a></p>` : ""}
                <p><a href="${s.docs}" target="_blank">Documentation</a></p>
            </div>
        `).join('');
}