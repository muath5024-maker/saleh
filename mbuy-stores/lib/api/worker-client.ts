/**
 * Worker API Client
 * All API calls go through Worker, not directly to Supabase
 */

import axios, { AxiosInstance } from 'axios';

const WORKER_API_URL = process.env.NEXT_PUBLIC_WORKER_API_URL || 'https://misty-mode-b68b.baharista1.workers.dev';

class WorkerClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: WORKER_API_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  /**
   * Set authorization token
   */
  setAuthToken(token: string) {
    this.client.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }

  /**
   * Clear authorization token
   */
  clearAuthToken() {
    delete this.client.defaults.headers.common['Authorization'];
  }

  /**
   * Get store by slug
   * GET /public/store/{slug}
   */
  async getStoreBySlug(slug: string) {
    const response = await this.client.get(`/public/store/${slug}`);
    return response.data;
  }

  /**
   * Get store theme
   * GET /public/store/{slug}/theme
   */
  async getStoreTheme(slug: string) {
    const response = await this.client.get(`/public/store/${slug}/theme`);
    return response.data;
  }

  /**
   * Get store branding
   * GET /public/store/{slug}/branding
   */
  async getStoreBranding(slug: string) {
    const response = await this.client.get(`/public/store/${slug}/branding`);
    return response.data;
  }

  /**
   * Get store products
   * GET /store-site/{slug}/products
   */
  async getStoreProducts(slug: string, params?: { limit?: number; offset?: number; category_id?: string }) {
    const response = await this.client.get(`/store-site/${slug}/products`, { params });
    return response.data;
  }

  /**
   * Check slug availability
   * GET /secure/store/check-slug?slug={slug}
   */
  async checkSlugAvailability(slug: string, token: string) {
    this.setAuthToken(token);
    const response = await this.client.get(`/secure/store/check-slug`, {
      params: { slug },
    });
    return response.data;
  }

  /**
   * Create store (onboarding)
   * POST /secure/store/create
   */
  async createStore(data: {
    name: string;
    slug: string;
    description?: string;
    city?: string;
  }, token: string) {
    this.setAuthToken(token);
    const response = await this.client.post(`/secure/store/create`, data);
    return response.data;
  }

  /**
   * Update store branding
   * PUT /secure/store/{id}/branding
   */
  async updateStoreBranding(
    storeId: string,
    data: {
      logo_url?: string;
      cover_image_url?: string;
      primary_color?: string;
      secondary_color?: string;
      theme_id?: string;
    },
    token: string
  ) {
    this.setAuthToken(token);
    const response = await this.client.put(`/secure/store/${storeId}/branding`, data);
    return response.data;
  }

  /**
   * Get AI suggestions for store
   * POST /secure/store/{id}/ai-suggestions
   */
  async getAISuggestions(
    storeId: string,
    data: {
      store_name: string;
      description?: string;
      answers?: Record<string, any>;
    },
    token: string
  ) {
    this.setAuthToken(token);
    const response = await this.client.post(`/secure/store/${storeId}/ai-suggestions`, data);
    return response.data;
  }
}

export const workerClient = new WorkerClient();
