// ============================================
// COSTEALO - CONFIGURATION
// ============================================

const CONFIG = {
    // API Configuration
    API_BASE_URL: 'https://app-251126163117.azurewebsites.net',

    // Local Storage Keys
    STORAGE_KEYS: {
        TOKEN: 'costealo_token',
        USER: 'costealo_user',
        SUBSCRIPTION: 'costealo_subscription'
    },

    // Subscription Plans
    SUBSCRIPTION_PLANS: {
        FREE: {
            name: 'Gratis',
            maxDatabases: 1,
            maxWorkbooks: 5,
            price: 0
        },
        BASIC: {
            name: 'Básico',
            maxDatabases: 2,
            maxWorkbooks: 10,
            price: 49.99
        },
        STANDARD: {
            name: 'Estándar',
            maxDatabases: 5,
            maxWorkbooks: 25,
            price: 99.99
        },
        PREMIUM: {
            name: 'Premium',
            maxDatabases: -1, // Unlimited
            maxWorkbooks: -1, // Unlimited
            price: 199.99
        }
    },

    // Default values
    DEFAULTS: {
        PROFIT_MARGIN: 0.20, // 20%
        TAX_PERCENTAGE: 0.16, // 16%
        OPERATIONAL_COST_PERCENTAGE: 0.20, // 20%
        PRODUCTION_UNITS: 1
    },

    // File upload
    FILE_UPLOAD: {
        MAX_SIZE: 10 * 1024 * 1024, // 10MB
        ACCEPTED_TYPES: [
            'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'text/csv'
        ]
    },

    // UI Settings
    UI: {
        DEBOUNCE_DELAY: 500, // ms for workbook calculations
        TOAST_DURATION: 3000, // ms
        ANIMATION_DURATION: 300 // ms
    }
};

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
