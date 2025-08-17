const toggleBtn = document.getElementById('light-mode-toggle');

toggleBtn.addEventListener('click', function (event) {
        event.preventDefault(); // Prevent anchor navigation
        const lightLink = document.getElementById('light-css');
        if (!document.body.classList.contains('light-mode')) {
                document.body.classList.add('light-mode');
                if (!lightLink) {
                        const link = document.createElement('link');
                        link.rel = 'stylesheet';
                        link.href = './css/light.css';
                        link.id = 'light-css';
                        document.head.appendChild(link);
                }
                toggleBtn.textContent = '🌑'; // Change icon for dark mode
                toggleBtn.title = 'Switch to Dark Mode';
        } else {
                document.body.classList.remove('light-mode');
                if (lightLink) lightLink.remove();
                toggleBtn.textContent = '🌙'; // Change icon for light mode
                toggleBtn.title = 'Switch to Light Mode';
        }
});