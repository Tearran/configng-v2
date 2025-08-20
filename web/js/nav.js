document.addEventListener('DOMContentLoaded', function () {
        function showSection(sectionId) {
                document.querySelectorAll('main').forEach(main => {
                        main.style.display = 'none';
                });
                const section = document.getElementById(sectionId);
                if (section) {
                        section.style.display = '';
                }
        }

        function handleHashChange() {
                const hash = window.location.hash.replace('#', '');
                if (hash) {
                        showSection(hash);
                } else {
                        showSection('home');
                }
        }

        window.addEventListener('hashchange', handleHashChange);
        handleHashChange();

        document.querySelectorAll('.nav-link').forEach(link => {
                link.addEventListener('click', function (e) {
                        const section = link.getAttribute('data-section');
                        window.location.hash = section;
                });
        });
});