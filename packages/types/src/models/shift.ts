import { ShiftStatus } from '../enums';

export interface Shift {
  id: string;
  stationId: string;
  attendantId: string;
  pumpId?: string;
  
  // Timing
  startedAt: Date;
  endedAt?: Date;
  
  // Opening readings
  openingCash: number;
  openingMeterReading?: number;
  
  // Closing readings
  closingCash?: number;
  closingMeterReading?: number;
  actualCashCounted?: number;
  
  // Totals
  totalSales: number;
  totalFuelSales: number;
  totalCarWashSales: number;
  totalStoreSales: number;
  totalCashSales: number;
  totalMomoSales: number;
  totalCardSales: number;
  totalCreditSales: number;
  transactionCount: number;
  fuelDispensed: number;
  
  // Variance
  cashVariance?: number;
  fuelVariance?: number;
  variancePercentage?: number;
  
  // Approval
  status: ShiftStatus;
  varianceNotes?: string;
  approvedBy?: string;
  approvedAt?: Date;
  rejectionReason?: string;
  
  createdAt: Date;
  updatedAt: Date;
}

export interface ShiftSummary {
  shiftId: string;
  attendantName: string;
  startTime: Date;
  endTime?: Date;
  duration?: number; // minutes
  totalSales: number;
  transactionCount: number;
  cashVariance?: number;
  fuelVariance?: number;
  status: ShiftStatus;
}
