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
