function renderImg(src, className, alt = '') {
        if (!src) return null;
        const img = document.createElement('img');
        img.src = src;
        img.className = className;
        img.alt = alt;
        return img;
}

fetch('./json/contact-info.json')
        .then(response => response.json())
        .then(data => {
                // Office Hours
                const officeDesc = document.getElementById('office-hours-desc');
                officeDesc.textContent = data.office_hours.description;
                if (data.office_hours.icon) officeDesc.prepend(renderImg(data.office_hours.icon, 'icon'));
                if (data.office_hours.image) officeDesc.prepend(renderImg(data.office_hours.image, 'image'));
                const officeLink = document.getElementById('office-hours-link');
                officeLink.href = data.office_hours.schedule_link;
                officeLink.textContent = "Schedule a Meeting";

                // Business Consultation
                const businessLink = document.getElementById('business-consultation-link');
                businessLink.href = data.business_consultation.link;
                businessLink.textContent = "Schedule Paid Consultation";
                if (data.business_consultation.icon) businessLink.prepend(renderImg(data.business_consultation.icon, 'icon'));
                if (data.business_consultation.image) businessLink.prepend(renderImg(data.business_consultation.image, 'image'));

                // Partners
                const partnersEmail = document.getElementById('partners-email');
                partnersEmail.innerHTML = `Email: <a href="mailto:${data.partners.email}">${data.partners.email}</a>`;
                if (data.partners.icon) partnersEmail.prepend(renderImg(data.partners.icon, 'icon'));
                if (data.partners.image) partnersEmail.prepend(renderImg(data.partners.image, 'image'));
                const partnersPlatinumLink = document.getElementById('partners-platinum-link');
                partnersPlatinumLink.href = data.partners.platinum_form;
                partnersPlatinumLink.textContent = "Platinum Partner Form";

                // Community Chat
                const chatList = document.getElementById('community-chat-list');
                data.community_chat.forEach(chat => {
                        const li = document.createElement('li');
                        if (chat.icon) li.appendChild(renderImg(chat.icon, 'icon'));
                        if (chat.image) li.appendChild(renderImg(chat.image, 'image'));
                        const a = document.createElement('a');
                        a.href = chat.link;
                        a.target = "_blank";
                        a.rel = "noopener noreferrer";
                        a.textContent = chat.name;
                        li.appendChild(a);
                        chatList.appendChild(li);
                });

                // Quick Answer
                const quickDesc = document.getElementById('quick-answer-desc');
                quickDesc.textContent = data.quick_answer.description;
                if (data.quick_answer.icon) quickDesc.prepend(renderImg(data.quick_answer.icon, 'icon'));
                if (data.quick_answer.image) quickDesc.prepend(renderImg(data.quick_answer.image, 'image'));
                const quickLink = document.getElementById('quick-answer-link');
                quickLink.href = data.quick_answer.forum_link;
                quickLink.textContent = "Subscribe to Forum";
        })
        .catch(error => {
                document.getElementById('contact-main').innerHTML = "<p>Unable to load contact information.</p>";
                console.error(error);
        });