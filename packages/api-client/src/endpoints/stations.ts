import type { ApiClient } from '../client';

export interface Station {
  id: string;
  organizationId: string;
  name: string;
  address?: string;
  city?: string;
  phone?: string;
  operatingHours?: string;
  hasFuel: boolean;
  hasCarWash: boolean;
  hasStore: boolean;
  createdAt: string;
  updatedAt: string;
}

export class StationEndpoints {
  constructor(private client: ApiClient) {}

  async getCurrent(): Promise<{ station: Station }> {
    return this.client.get<{ station: Station }>('/api/stations/current');
  }

  async getAll(): Promise<{ stations: Station[] }> {
    return this.client.get<{ stations: Station[] }>('/api/stations');
  }
}
