# Ororo - Gas Station ERP

## Tech Stack
- **Monorepo**: Turborepo + Bun
- **API**: Hono on Cloudflare Workers + D1 (SQLite)
- **Database**: Drizzle ORM
- **Web**: React Router v7 + Tailwind CSS
- **Types**: Shared via `@ororo/types`
- **API Client**: `@ororo/api-client` (type-safe)

## Project Structure
```
ororo/
├── apps/
│   ├── api/          # Hono API (Cloudflare Workers)
│   └── web/          # React Router dashboard
└── packages/
    ├── db/           # Drizzle schemas + repositories
    ├── types/        # Shared TypeScript types
    ├── api-client/   # Type-safe API client
    └── config/       # ESLint + TS configs
```

## Key Concepts

### Database (22 tables)
Core entities: organizations, stations, users, shifts, transactions, payments
- Fuel: tanks, pumps, prices, sales, deliveries
- Car wash: services, sales
- Store: products, categories, stock_movements, sales
- Credit: customers, credit_transactions

### Repository Pattern
```typescript
// Database queries separated from business logic
import { UserRepository } from '@ororo/db/queries';
const userRepo = new UserRepository(db);
const user = await userRepo.findByPhone(phone);
```

### API Structure
```
src/
├── index.ts          # Main Hono app
├── middleware/       # Auth, CORS, error handling
├── routes/           # HTTP endpoints
├── services/         # Business logic
└── utils/            # Helpers
```

### Key Features
- **Offline-first**: Transactions sync when online
- **Multi-tenant**: Organization → Stations → Users
- **Variance tracking**: Cash/fuel variance auto-calculated
- **Flexible payments**: Cash, MoMo (MTN/Airtel), Card, Credit
- **Role-based access**: Attendant, Manager, Owner, Admin

## Common Patterns

### Creating a transaction
```typescript
// 1. Create transaction
const txn = await txnRepo.create({...});

// 2. Add details (fuel/car wash/store)
await fuelSaleRepo.create({...});

// 3. Record payment
const payment = await paymentRepo.create({...});
await paymentRepo.markCompleted(payment.id);

// 4. Update shift totals
await shiftRepo.updateTotals(shiftId, {...});
```

### Type imports
```typescript
import type { User, Transaction } from '@ororo/types/models';
import { UserRole, PaymentMethod } from '@ororo/types';
import type { LoginRequest } from '@ororo/types/api';
```

### API client usage
```typescript
import { OroroApiClient } from '@ororo/api-client';
const api = new OroroApiClient({
  baseUrl: process.env.API_URL,
  getToken: () => localStorage.getItem('token'),
});
const { shift } = await api.shifts.getCurrent();
```

## MVP Scope
✅ Auth (login/register)
✅ Shift management (start/close/approve)
✅ Transactions (fuel + car wash + store)
✅ Payments (cash + MoMo + credit)
✅ Credit customers
✅ Store inventory
✅ Basic reports

❌ NOT in MVP: ATG integration, mobile app, advanced analytics

## Important Rules
- ULIDs for IDs (not auto-increment)
- All timestamps are integers (Unix epoch)
- Variance >2% requires manager approval
- Cash first, mobile money optional
- Rwanda market first (RWF currency)

## Development
```bash
# Install
bun install

# API dev
cd apps/api && bun run dev

# Web dev
cd apps/web && bun run dev

# Type check all
bun run type-check
```

## Database
```bash
# Generate migrations
cd packages/db && bun run generate

# Apply to D1
bun run push

# View in studio
bun run studio
```

## Deployment
- API: Cloudflare Workers (wrangler deploy)
- Database: D1
- Environments: dev, staging, production
- CI/CD: GitHub Actions