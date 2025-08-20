document.addEventListener("DOMContentLoaded", function () {
        const themeSelect = document.getElementById("theme-select");
        const themeLink = document.getElementById("main-theme");

        // Load saved theme if available
        const savedTheme = localStorage.getItem("theme");
        if (savedTheme) {
                themeLink.setAttribute("href", "./css/" + savedTheme);
                themeSelect.value = savedTheme;
        }

        // Change theme on selection
        themeSelect.addEventListener("change", function () {
                const selectedTheme = themeSelect.value;
                themeLink.setAttribute("href", "./css/" + selectedTheme);
                localStorage.setItem("theme", selectedTheme); // persist choice
        });
});


