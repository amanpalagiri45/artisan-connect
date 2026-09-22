const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1';

export async function api(path, options = {}) {
  const isFormData = options.body instanceof FormData;
  const headers = isFormData ? { ...(options.headers || {}) } : { 'Content-Type': 'application/json', ...(options.headers || {}) };
  const response = await fetch(`${API_BASE}${path}`, { ...options, headers, credentials: 'include' });
  const text = await response.text();
  let body = null;
  try { body = text ? JSON.parse(text) : null; } catch { body = text; }
  if (!response.ok) throw new Error(body?.detail || body || `Request failed (${response.status})`);
  return body;
}

export const endpoints = {
  products: (query = '') => api(`/products/${query ? `?${query}` : ''}`),
  product: (id) => api(`/products/${id}`),
  enhanceProductPhoto: (file) => {
    const form = new FormData();
    form.append('file', file);
    return api('/ai/enhance-product-photo', { method: 'POST', body: form });
  },
};
