document.addEventListener('DOMContentLoaded', function () {
    const toast = document.querySelector('[data-bs-toggle="toast"]');
    if (toast) {
        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
    }

    const forms = document.querySelectorAll('form[data-ajax="true"]');
    forms.forEach(function(form) {
        form.addEventListener('submit', function (event) {
            event.preventDefault();
            const button = form.querySelector('button[type="submit"]');
            const originalText = button.innerText;
            button.disabled = true;
            button.innerText = 'Processing...';

            setTimeout(function () {
                button.disabled = false;
                button.innerText = originalText;
                alert('Action submitted successfully.');
            }, 500);
        });
    });
});
