export interface Station {
  id: string;
  organizationId: string;
  name: string;
  address?: string;
  city?: string;
  phone?: string;
  operatingHours?: string; // JSON string
  hasFuel: boolean;
  hasCarWash: boolean;
  hasStore: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface OperatingHours {
  open: string; // "06:00"
  close: string; // "22:00"
}
