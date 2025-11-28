// Simple client-side router for vanilla JS SPA
function navigateTo(url) {
    window.location.href = url;
}

// Show/hide elements
function toggleVisibility(elementId) {
    const element = document.getElementById(elementId);
    if (element) {
        element.classList.toggle('hidden');
    }
}

// Utility: Format currency
function formatCurrency(value) {
    return new Intl.NumberFormat('es-BO', {
        style: 'currency',
        currency: 'BOB'
    }).format(value);
}

// Utility: Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('es-BO', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    }).format(date);
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { navigateTo, toggleVisibility, formatCurrency, formatDate };
}
