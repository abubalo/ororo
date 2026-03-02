export interface ApiClientConfig {
  baseUrl: string;
  getToken?: () => string | null;
  onUnauthorized?: () => void;
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public data?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export class ApiClient {
  private baseUrl: string;
  private getToken?: () => string | null;
  private onUnauthorized?: () => void;

  constructor(config: ApiClientConfig) {
    this.baseUrl = config.baseUrl.replace(/\/$/, ''); // Remove trailing slash
    this.getToken = config.getToken;
    this.onUnauthorized = config.onUnauthorized;
  }

  private async request<T>(
    method: string,
    path: string,
    options?: {
      body?: any;
      headers?: Record<string, string>;
      requiresAuth?: boolean;
    }
  ): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...options?.headers,
    };

    // Add auth token if required
    if (options?.requiresAuth !== false) {
      const token = this.getToken?.();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }

    const fetchOptions: RequestInit = {
      method,
      headers,
    };

    if (options?.body) {
      fetchOptions.body = JSON.stringify(options.body);
    }

    try {
      const response = await fetch(url, fetchOptions);

      // Handle 401 Unauthorized
      if (response.status === 401) {
        this.onUnauthorized?.();
        throw new ApiError('Unauthorized', 401);
      }

      // Parse response
      const data = await response.json();

      // Handle error responses
      if (!response.ok) {
        throw new ApiError(
          data.error || 'Request failed',
          response.status,
          data
        );
      }

      return data as T;
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      
      // Network errors
      throw new ApiError(
        'Network error',
        0,
        error
      );
    }
  }

  async get<T>(path: string, requiresAuth = true): Promise<T> {
    return this.request<T>('GET', path, { requiresAuth });
  }

  async post<T>(path: string, body?: any, requiresAuth = true): Promise<T> {
    return this.request<T>('POST', path, { body, requiresAuth });
  }

  async put<T>(path: string, body?: any, requiresAuth = true): Promise<T> {
    return this.request<T>('PUT', path, { body, requiresAuth });
  }

  async delete<T>(path: string, requiresAuth = true): Promise<T> {
    return this.request<T>('DELETE', path, { requiresAuth });
  }
}
