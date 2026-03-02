# Database Query Repositories

This directory contains repository classes that provide a clean API for database operations.

## Usage Example

```typescript
import { createDbClient } from '@ororo/db';
import { TransactionRepository, ShiftRepository } from '@ororo/db/queries';

export default {
  async fetch(request, env, ctx) {
    const db = createDbClient(env.DB);
    
    // Initialize repositories
    const transactionRepo = new TransactionRepository(db);
    const shiftRepo = new ShiftRepository(db);
    
    // Use clean methods
    const transactions = await transactionRepo.findByStation('station-123');
    const activeShifts = await shiftRepo.findActiveByStation('station-123');
    
    return Response.json({ transactions, activeShifts });
  }
}

