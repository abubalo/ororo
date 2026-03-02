import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { users } from '../schema';

export function createAuthQueries(db: DbClient) {
  return {
    /**
     * Find user by phone number
     */
    async findUserByPhone(phone: string) {
      const result = await db
        .select()
        .from(users)
        .where(eq(users.phone, phone))
        .limit(1);
      
      return result[0] || null;
    },

    /**
     * Find user by ID
     */
    async findUserById(id: string) {
      const result = await db
        .select()
        .from(users)
        .where(eq(users.id, id))
        .limit(1);
      
      return result[0] || null;
    },

    /**
     * Create new user
     */
    async createUser(data: {
      id: string;
      phone: string;
      name: string;
      email?: string;
      role: 'attendant' | 'manager' | 'owner' | 'admin';
      pinHash: string;
      stationId?: string;
    }) {
      const now = new Date();
      
      await db.insert(users).values({
        ...data,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      });

      return this.findUserById(data.id);
    },

    /**
     * Update last login timestamp
     */
    async updateLastLogin(userId: string) {
      await db
        .update(users)
        .set({ 
          lastLoginAt: new Date(),
          updatedAt: new Date(),
        })
        .where(eq(users.id, userId));
    },

    /**
     * Update user PIN
     */
    async updateUserPin(userId: string, newPinHash: string) {
      await db
        .update(users)
        .set({ 
          pinHash: newPinHash,
          updatedAt: new Date(),
        })
        .where(eq(users.id, userId));
    },

    /**
     * Deactivate user (soft delete)
     */
    async deactivateUser(userId: string) {
      await db
        .update(users)
        .set({ 
          isActive: false,
          updatedAt: new Date(),
        })
        .where(eq(users.id, userId));
    },
  };
}

export type AuthQueries = ReturnType<typeof createAuthQueries>;
