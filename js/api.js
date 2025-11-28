// ============================================
// COSTEALO - API CLIENT (Vanilla JS)
// ============================================

const API_BASE_URL = 'https://app-251126163117.azurewebsites.net';

// Token management
const TokenManager = {
    get: () => localStorage.getItem('costealo_token'),
    set: (token) => localStorage.setItem('costealo_token', token),
    remove: () => localStorage.removeItem('costealo_token'),
    isValid: () => {
        const token = TokenManager.get();
        if (!token) return false;
        // TODO: Add JWT expiry validation
        return true;
    }
};

// API Client
class ApiClient {
    constructor(baseURL) {
        this.baseURL = baseURL;
    }

    // Generic request method
    async request(endpoint, options = {}) {
        const url = `${this.baseURL}${endpoint}`;
        const token = TokenManager.get();

        const headers = {
            'Content-Type': 'application/json',
            ...options.headers
        };

        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }

        const config = {
            ...options,
            headers
        };

        try {
            const response = await fetch(url, config);

            // Handle 401 Unauthorized (token expired atau invalid)
            if (response.status === 401) {
                TokenManager.remove();
                window.location.href = '/pages/auth/login.html';
                throw new Error('No autorizado. Por favor inicia sesión.');
            }

            // Handle 403 Forbidden (subscription limits)
            if (response.status === 403) {
                throw new Error('Límite de suscripción alcanzado.');
            }

            // Parse JSON response
            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || 'Error en la solicitud');
            }

            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    // Convenience methods
    get(endpoint) {
        return this.request(endpoint, { method: 'GET' });
    }

    post(endpoint, body) {
        return this.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(body)
        });
    }

    put(endpoint, body) {
        return this.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(body)
        });
    }

    delete(endpoint) {
        return this.request(endpoint, { method: 'DELETE' });
    }

    // File upload
    async upload(endpoint, formData) {
        const url = `${this.baseURL}${endpoint}`;
        const token = TokenManager.get();

        const headers = {};
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }

        try {
            const response = await fetch(url, {
                method: 'POST',
                headers,
                body: formData // FormData sets Content-Type automatically
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || 'Error al subir archivo');
            }

            return data;
        } catch (error) {
            console.error('Upload Error:', error);
            throw error;
        }
    }
}

// Initialize API client
const api = new ApiClient(API_BASE_URL);

// Auth Service
const AuthService = {
    async login(email, password) {
        const data = await api.post('/api/Auth/login', { email, password });
        TokenManager.set(data); // Assuming backend returns token string
        return data;
    },

    async register(name, email, password) {
        const data = await api.post('/api/Users', { name, email, password });
        return data;
    },

    logout() {
        TokenManager.remove();
        window.location.href = '/pages/auth/login.html';
    },

    isAuthenticated() {
        return TokenManager.isValid();
    }
};

// Database Service
const DatabaseService = {
    getAll: () => api.get('/api/PriceDatabase'),
    getById: (id) => api.get(`/api/PriceDatabase/${id}`),
    create: (data) => api.post('/api/PriceDatabase', data),
    update: (id, data) => api.put(`/api/PriceDatabase/${id}`, data),
    delete: (id) => api.delete(`/api/PriceDatabase/${id}`),

    uploadFile: (file, databaseName) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('databaseName', databaseName);
        return api.upload('/api/PriceDatabase/upload', formData);
    },

    importUrl: (name, url) => api.post('/api/PriceDatabase/import-url', { name, url }),
    refresh: (id) => api.put(`/api/PriceDatabase/${id}/refresh`),

    getItems: (id) => api.get(`/api/PriceDatabase/${id}/items`),
    addItem: (id, item) => api.post(`/api/PriceDatabase/${id}/items`, item),
    updateItem: (dbId, itemId, item) => api.put(`/api/PriceDatabase/${dbId}/items/${itemId}`, item),
    deleteItem: (dbId, itemId) => api.delete(`/api/PriceDatabase/${dbId}/items/${itemId}`)
};

// Workbook Service
const WorkbookService = {
    getAll: () => api.get('/api/Workbooks'),
    getById: (id) => api.get(`/api/Workbooks/${id}`),
    create: (data) => api.post('/api/Workbooks', data),
    update: (id, data) => api.put(`/api/Workbooks/${id}`, data),
    delete: (id) => api.delete(`/api/Workbooks/${id}`),
    publish: (id) => api.put(`/api/Workbooks/${id}/publish`),

    addItem: (id, item) => api.post(`/api/Workbooks/${id}/items`, item),
    removeItem: (wbId, itemId) => api.delete(`/api/Workbooks/${wbId}/items/${itemId}`)
};

// Subscription Service
const SubscriptionService = {
    getMine: () => api.get('/api/Subscriptions/me'),
    create: (data) => api.post('/api/Subscriptions', data),
    update: (id, data) => api.put(`/api/Subscriptions/${id}`, data)
};

// Units Service
const UnitsService = {
    getCatalog: () => api.get('/api/Units/catalog'),
    getValid: () => api.get('/api/Units/valid'),
    validate: (unit) => api.get(`/api/Units/validate/${unit}`)
};

// Export services
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        api,
        TokenManager,
        AuthService,
        DatabaseService,
        WorkbookService,
        SubscriptionService,
        UnitsService
    };
}
