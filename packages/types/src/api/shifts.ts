export interface StartShiftRequest {
  stationId: string;
  pumpId?: string;
  openingCash: number;
  openingMeterReading?: number;
}

export interface StartShiftResponse {
  shift: {
    id: string;
    stationId: string;
    attendantId: string;
    pumpId?: string;
    startedAt: Date;
    openingCash: number;
    openingMeterReading?: number;
    status: string;
  };
}

export interface CloseShiftRequest {
  closingCash: number;
  closingMeterReading?: number;
  actualCashCounted: number;
  varianceNotes?: string;
}

export interface CloseShiftResponse {
  shift: {
    id: string;
    endedAt: Date;
    cashVariance?: number;
    fuelVariance?: number;
    variancePercentage?: number;
    status: string;
  };
}

export interface ApproveShiftRequest {
  shiftId: string;
}

export interface RejectShiftRequest {
  shiftId: string;
  reason: string;
}
