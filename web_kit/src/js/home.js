// Example: Load home.json and render to #features-list, #uefi-devices-list, and #getting-started-steps

fetch('./json/home.json')
        .then(response => response.json())
        .then(data => {
                // Render Key Features
                const features = data.key_features;
                const featuresList = document.getElementById('features-list');
                if (featuresList) {
                        featuresList.innerHTML = `
        <div class="feature">
          <h3><i class="fa ${features.feature1_icon}"></i> ${features.feature1_title}</h3>
          <p>${features.feature1_subtitle}</p>
          <a href="${features.feature1_link}" target="_blank">Learn more</a>
        </div>
        <div class="feature">
          <h3><i class="fa ${features.feature2_icon}"></i> ${features.feature2_title}</h3>
          <p>${features.feature2_subtitle}</p>
          <a href="${features.feature2_link}" target="_blank">Learn more</a>
        </div>
        <div class="feature">
          <h3><i class="fa ${features.feature3_icon}"></i> ${features.feature3_title}</h3>
          <p>${features.feature3_subtitle}</p>
          <a href="${features.feature3_link}" target="_blank">Learn more</a>
        </div>
      `;
                }

                // Render UEFI Devices
                const uefi = data.uefi_devices;
                document.getElementById('uefi-title').textContent = uefi.title;
                document.getElementById('uefi-note').textContent = uefi.note;
                const uefiDevicesList = document.getElementById('uefi-devices-list');
                if (uefiDevicesList) {
                        uefiDevicesList.innerHTML = `
        <div class="uefi-device">
          <img src="${uefi.device1_img}" alt="${uefi.device1_img_alt}">
          <h4>${uefi.device1_arch}</h4>
          <a href="${uefi.device1_link}" target="_blank">View</a>
        </div>
        <div class="uefi-device">
          <img src="${uefi.device2_img}" alt="${uefi.device2_img_alt}">
          <h4>${uefi.device2_arch}</h4>
          <a href="${uefi.device2_link}" target="_blank">View</a>
        </div>
        <div class="uefi-device">
          <img src="${uefi.device3_img}" alt="${uefi.device3_img_alt}">
          <h4>${uefi.device3_arch}</h4>
          <a href="${uefi.device3_link}" target="_blank">View</a>
        </div>
      `;
                }

                // Render Getting Started Steps
                const steps = data.getting_started;
                const stepsList = document.getElementById('getting-started-steps');
                if (stepsList) {
                        stepsList.innerHTML = `
        <div class="step">
          <span class="step-title"><i class="fa ${steps.step1_icon}"></i> ${steps.step1_title}</span>
          <p>${steps.step1_content}</p>
          <a href="${steps.step1_link}" target="_blank">Download</a> |
          <a href="${steps.step1_docs}" target="_blank">Docs</a>
        </div>
        <div class="step">
          <span class="step-title"><i class="fa ${steps.step2_icon}"></i> ${steps.step2_title}</span>
          <p>${steps.step2_content}</p>
          <a href="${steps.step2_docs}" target="_blank">Docs</a>
        </div>
        <div class="step">
          <span class="step-title"><i class="fa ${steps.step3_icon}"></i> ${steps.step3_title}</span>
          <p>${steps.step3_content}</p>
          <a href="${steps.step3_docs}" target="_blank">Docs</a>
        </div>
        <div class="step">
          <span class="step-title"><i class="fa ${steps.step4_icon}"></i> ${steps.step4_title}</span>
          <p>${steps.step4_content}</p>
          <a href="${steps.step4_docs}" target="_blank">Docs</a>
        </div>
      `;
                }
        })
        .catch(error => {
                document.getElementById('features-list').innerHTML = "<p>Unable to load home page features.</p>";
                console.error(error);
        });