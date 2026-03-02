import { ShiftRepository } from '../db/queries';
import type { DbClient } from '../db/client';
import { ulid } from '../utils/ulid';

export class ShiftService {
  constructor(private db: DbClient) {}

  async startShift(data: {
    attendantId: string;
    stationId: string;
    pumpId?: string;
    openingCash: number;
    openingMeterReading?: number;
  }) {
    const shiftRepo = new ShiftRepository(this.db);

    const activeShift = await shiftRepo.findActiveByAttendant(data.attendantId);
    if (activeShift) {
      throw new Error('You already have an active shift');
    }

    return await shiftRepo.create({
      id: ulid(),
      ...data,
    });
  }

  async closeShift(
    shiftId: string,
    attendantId: string,
    data: {
      closingCash: number;
      closingMeterReading?: number;
      actualCashCounted: number;
      varianceNotes?: string;
    }
  ) {
    const shiftRepo = new ShiftRepository(this.db);

    const shift = await shiftRepo.findById(shiftId);
    if (!shift || shift.attendantId !== attendantId) {
      throw new Error('Shift not found or unauthorized');
    }

    if (shift.status !== 'active') {
      throw new Error('Shift is not active');
    }

    return await shiftRepo.close(shiftId, data);
  }

  async approveShift(shiftId: string, managerId: string) {
    const shiftRepo = new ShiftRepository(this.db);
    return await shiftRepo.approve(shiftId, managerId);
  }

  async rejectShift(shiftId: string, managerId: string, reason: string) {
    const shiftRepo = new ShiftRepository(this.db);
    return await shiftRepo.reject(shiftId, managerId, reason);
  }
}
