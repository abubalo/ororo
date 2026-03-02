import type { ApiClient } from '../client';

// Types (temporary until @ororo/types is created)
export interface LoginRequest {
  phone: string;
  pin: string;
}

export interface LoginResponse {
  token: string;
  user: {
    id: string;
    phone: string;
    name: string;
    role: string;
    stationId?: string;
  };
}

export interface RegisterRequest {
  phone: string;
  name: string;
  pin: string;
  email?: string;
}

export interface RegisterResponse {
  token: string;
  user: {
    id: string;
    phone: string;
    name: string;
    role: string;
  };
}

export class AuthEndpoints {
  constructor(private client: ApiClient) {}

  async login(credentials: LoginRequest): Promise<LoginResponse> {
    return this.client.post<LoginResponse>('/auth/login', credentials, false);
  }

  async register(data: RegisterRequest): Promise<RegisterResponse> {
    return this.client.post<RegisterResponse>('/auth/register', data, false);
  }

  async logout(): Promise<void> {
    return this.client.post<void>('/auth/logout');
  }
}
