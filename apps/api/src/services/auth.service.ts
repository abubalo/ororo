import { UserRepository } from '../db/queries';
import type { DbClient } from '../db/client';
import { hashPin, verifyPin } from '../utils/hash';
import { generateToken } from '../utils/jwt';
import { ulid } from '../utils/ulid';

export class AuthService {
  constructor(
    private db: DbClient,
    private jwtSecret: string
  ) {}

  async login(phone: string, pin: string) {
    const userRepo = new UserRepository(this.db);
    const user = await userRepo.findByPhone(phone);

    if (!user || !user.isActive) {
      throw new Error('Invalid credentials');
    }

    const isValid = await verifyPin(pin, user.pinHash);
    if (!isValid) {
      throw new Error('Invalid credentials');
    }

    await userRepo.updateLastLogin(user.id);

    const token = await generateToken(user.id, this.jwtSecret);

    return {
      token,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        role: user.role,
        stationId: user.stationId,
      },
    };
  }

  async register(data: {
    phone: string;
    name: string;
    pin: string;
    email?: string;
  }) {
    const userRepo = new UserRepository(this.db);

    const existing = await userRepo.findByPhone(data.phone);
    if (existing) {
      throw new Error('User already exists');
    }

    const pinHash = await hashPin(data.pin);

    const user = await userRepo.create({
      id: ulid(),
      phone: data.phone,
      name: data.name,
      email: data.email,
      role: 'attendant',
      pinHash,
    });

    const token = await generateToken(user.id, this.jwtSecret);

    return {
      token,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        role: user.role,
      },
    };
  }
}
