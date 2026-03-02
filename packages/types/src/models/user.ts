import { UserRole } from '../enums';

export interface User {
  id: string;
  phone: string;
  name: string;
  email?: string;
  role: UserRole;
  stationId?: string;
  isActive: boolean;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserWithoutSensitive extends Omit<User, 'pinHash'> {}

export interface LoginCredentials {
  phone: string;
  pin: string;
}

export interface AuthToken {
  token: string;
  user: UserWithoutSensitive;
}
