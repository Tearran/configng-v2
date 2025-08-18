// Show/hide main sections on nav click
function showMainSection(sectionId) {
        document.querySelectorAll('main').forEach(main => {
                if (main.id === sectionId) {
                        main.style.display = ''; // Show (let CSS decide grid/block)
                } else {
                        main.style.display = 'none'; // Hide
                }
        });
}
document.addEventListener('DOMContentLoaded', () => {
        document.getElementById('nav').addEventListener('click', function (e) {
                if (e.target.matches('.nav-link')) {
                        const sectionId = e.target.getAttribute('data-section');
                        showMainSection(sectionId);
                        e.preventDefault();
                }
        });
        // Show home by default
        showMainSection('home');
});
