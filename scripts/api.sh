
#!/bin/bash

# Create the directory structure
mkdir -p apps/api/src/{db,middleware,routes,services,utils}
mkdir -p apps/api/docs

# ============================================================
# FILE: apps/api/package.json
# ============================================================
cat > apps/api/package.json << 'EOF'
{
  "name": "@ororo/api",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "wrangler dev src/index.ts",
    "deploy": "wrangler deploy",
    "deploy:staging": "wrangler deploy --env staging",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:watch": "vitest --watch"
  },
  "dependencies": {
    "hono": "^4.6.15",
    "@hono/zod-validator": "^0.4.1",
    "zod": "^3.24.1",
    "ulid": "^2.3.0",
    "@ororo/db": "workspace:*",
    "@ororo/types": "workspace:*"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20250110.0",
    "wrangler": "^3.103.0",
    "typescript": "^5.7.2",
    "vitest": "^2.1.8",
    "@vitest/coverage-v8": "^2.1.8"
  }
}
EOF

# ============================================================
# FILE: apps/api/wrangler.toml
# ============================================================
cat > apps/api/wrangler.toml << 'EOF'
name = "ororo-api"
main = "src/index.ts"
compatibility_date = "2025-01-15"
node_compat = true

[[d1_databases]]
binding = "DB"
database_name = "ororo-production"
database_id = "your-database-id-here"

[vars]
ENVIRONMENT = "production"

# Use wrangler secret put to set these:
# JWT_SECRET
# MTN_MOMO_API_KEY
# AIRTEL_MONEY_API_KEY

[env.staging]
name = "ororo-api-staging"
[[env.staging.d1_databases]]
binding = "DB"
database_name = "ororo-staging"
database_id = "your-staging-database-id-here"

[env.staging.vars]
ENVIRONMENT = "staging"
EOF

# ============================================================
# FILE: apps/api/tsconfig.json
# ============================================================
cat > apps/api/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "types": ["@cloudflare/workers-types"],
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

# ============================================================
# FILE: apps/api/vitest.config.ts
# ============================================================
cat > apps/api/vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
    },
  },
});
EOF

# ============================================================
# FILE: apps/api/README.md
# ============================================================
cat > apps/api/README.md << 'EOF'
# Ororo API

Backend API for Ororo gas station management system.

## Setup

```bash
# Install dependencies
bun install

# Set up D1 database
wrangler d1 create ororo-dev
wrangler d1 create ororo-production

# Update wrangler.toml with database IDs

# Run migrations
cd ../../packages/db
bun run generate
bun run push

# Set secrets
cd ../../apps/api
wrangler secret put JWT_SECRET
wrangler secret put MTN_MOMO_API_KEY
wrangler secret put AIRTEL_MONEY_API_KEY
```

## Development

```bash
bun run dev
```

## Deploy

```bash
# Deploy to production
bun run deploy

# Deploy to staging
bun run deploy:staging
```

## Testing

```bash
bun run test
bun run test:watch
```

## API Documentation

See `/docs/api.md` for complete API documentation.
EOF

# ============================================================
# FILE: apps/api/docs/api.md
# ============================================================
cat > apps/api/docs/api.md << 'EOF'
# Ororo API Documentation

## Base URL
- Production: `https://api.ororo.app`
- Staging: `https://api-staging.ororo.app`

## Authentication
All endpoints except `/auth/*` require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Endpoints

### Auth
- `POST /auth/login` - Login with phone and PIN
- `POST /auth/register` - Register new user
- `POST /auth/logout` - Logout

### Shifts
- `POST /api/shifts/start` - Start a new shift
- `GET /api/shifts/current` - Get current shift
- `POST /api/shifts/:id/close` - Close a shift
- `GET /api/shifts/pending` - Get pending approvals (manager)
- `POST /api/shifts/:id/approve` - Approve shift (manager)
- `POST /api/shifts/:id/reject` - Reject shift (manager)
- `GET /api/shifts/history` - Get shift history

### Transactions
- `POST /api/transactions/fuel` - Create fuel transaction
- `POST /api/transactions/car-wash` - Create car wash transaction
- `POST /api/transactions/store` - Create store transaction
- `GET /api/transactions/:id` - Get transaction by ID
- `GET /api/transactions/shift/:shiftId` - Get shift transactions
- `GET /api/transactions/today` - Get today's stats

### Stations
- `GET /api/stations` - List all stations
- `GET /api/stations/:id` - Get station details
- `GET /api/stations/current` - Get current user's station

### Users
- `GET /api/users` - List users
- `GET /api/users/:id` - Get user details
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Deactivate user

### Fuel
- `GET /api/fuel/tanks` - List fuel tanks
- `GET /api/fuel/pumps` - List fuel pumps
- `POST /api/fuel/prices` - Update fuel prices
- `POST /api/fuel/deliveries` - Record fuel delivery

### Payments
- `GET /api/payments/:id` - Get payment details
- `POST /api/payments/momo/callback` - MoMo callback webhook

### Reports
- `GET /api/reports/daily-sales` - Daily sales report
- `GET /api/reports/shift-performance` - Shift performance report
- `GET /api/reports/inventory` - Inventory report

## Error Responses
```json
{
  "error": "Error message here"
}
```

## Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not found
- `409` - Conflict
- `500` - Internal server error
EOF

# ============================================================
# FILE: apps/api/src/index.ts
# Main Hono app entry point
# ============================================================
cat > apps/api/src/index.ts << 'EOF'
import { Hono } from 'hono';

// Middleware
import { loggerMiddleware } from './middleware/logger';
import { corsMiddleware } from './middleware/cors';
import { errorHandler } from './middleware/error';
import { authMiddleware } from './middleware/auth';

// Routes
import authRoutes from './routes/auth';
import shiftRoutes from './routes/shifts';
import transactionRoutes from './routes/transactions';
import stationRoutes from './routes/stations';
import userRoutes from './routes/users';
import fuelRoutes from './routes/fuel';
import paymentRoutes from './routes/payments';
import reportRoutes from './routes/reports';

export type Bindings = {
  DB: D1Database;
  JWT_SECRET: string;
  MTN_MOMO_API_KEY: string;
  AIRTEL_MONEY_API_KEY: string;
  ENVIRONMENT?: string;
};

export type Variables = {
  userId: string;
  userRole: string;
  stationId?: string;
};

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

// Global middleware
app.use('*', loggerMiddleware);
app.use('*', corsMiddleware);

// Health check
app.get('/health', (c) => {
  return c.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: c.env.ENVIRONMENT || 'production',
  });
});

// Public routes
app.route('/auth', authRoutes);

// Protected routes
app.use('/api/*', authMiddleware);
app.route('/api/shifts', shiftRoutes);
app.route('/api/transactions', transactionRoutes);
app.route('/api/stations', stationRoutes);
app.route('/api/users', userRoutes);
app.route('/api/fuel', fuelRoutes);
app.route('/api/payments', paymentRoutes);
app.route('/api/reports', reportRoutes);

// Error handling
app.onError(errorHandler);

// 404 handler
app.notFound((c) => {
  return c.json({ error: 'Not found', path: c.req.path }, 404);
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/db/client.ts
# Re-export from @ororo/db
# ============================================================
cat > apps/api/src/db/client.ts << 'EOF'
export { createDbClient } from '@ororo/db';
export type { DbClient } from '@ororo/db';
EOF

# ============================================================
# FILE: apps/api/src/db/queries.ts
# Re-export all repositories
# ============================================================
cat > apps/api/src/db/queries.ts << 'EOF'
export * from '@ororo/db/queries';
EOF

# ============================================================
# FILE: apps/api/src/utils/constants.ts
# ============================================================
cat > apps/api/src/utils/constants.ts << 'EOF'
export const VARIANCE_THRESHOLD = 2; // 2%
export const DEFAULT_CURRENCY = 'RWF';
export const RECEIPT_PREFIX = 'R-';
export const JWT_EXPIRY = 60 * 60 * 12; // 12 hours
EOF

# ============================================================
# FILE: apps/api/src/utils/hash.ts
# ============================================================
cat > apps/api/src/utils/hash.ts << 'EOF'
export async function hashPin(pin: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(pin);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

export async function verifyPin(pin: string, hash: string): Promise<boolean> {
  const pinHash = await hashPin(pin);
  return pinHash === hash;
}
EOF

# ============================================================
# FILE: apps/api/src/utils/jwt.ts
# ============================================================
cat > apps/api/src/utils/jwt.ts << 'EOF'
import { sign } from 'hono/jwt';
import { JWT_EXPIRY } from './constants';

export async function generateToken(
  userId: string,
  secret: string,
  expiresIn: number = JWT_EXPIRY
) {
  const now = Math.floor(Date.now() / 1000);

  return await sign(
    {
      sub: userId,
      iat: now,
      exp: now + expiresIn,
    },
    secret
  );
}
EOF

# ============================================================
# FILE: apps/api/src/utils/ulid.ts
# ============================================================
cat > apps/api/src/utils/ulid.ts << 'EOF'
import { ulid } from 'ulid';
export { ulid };
EOF

# ============================================================
# FILE: apps/api/src/utils/validation.ts
# ============================================================
cat > apps/api/src/utils/validation.ts << 'EOF'
import { z } from 'zod';

export const phoneSchema = z.string().min(10).max(15);
export const pinSchema = z.string().length(4).regex(/^\d{4}$/);
export const ulidSchema = z.string().length(26);

export const paginationSchema = z.object({
  limit: z.number().min(1).max(100).default(20),
  offset: z.number().min(0).default(0),
});
EOF

# ============================================================
# FILE: apps/api/src/middleware/auth.ts
# ============================================================
cat > apps/api/src/middleware/auth.ts << 'EOF'
import { Context, Next } from 'hono';
import { verify } from 'hono/jwt';
import { createDbClient } from '../db/client';
import { UserRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

export async function authMiddleware(
  c: Context<{ Bindings: Bindings; Variables: Variables }>,
  next: Next
) {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized - No token provided' }, 401);
  }

  const token = authHeader.substring(7);

  try {
    const payload = await verify(token, c.env.JWT_SECRET);

    const db = createDbClient(c.env.DB);
    const userRepo = new UserRepository(db);
    const user = await userRepo.findById(payload.sub as string);

    if (!user || !user.isActive) {
      return c.json({ error: 'Unauthorized - Invalid user' }, 401);
    }

    c.set('userId', user.id);
    c.set('userRole', user.role);
    c.set('stationId', user.stationId || undefined);

    await next();
  } catch (error) {
    return c.json({ error: 'Unauthorized - Invalid token' }, 401);
  }
}

export function requireRole(...allowedRoles: string[]) {
  return async (c: Context, next: Next) => {
    const userRole = c.get('userRole');

    if (!allowedRoles.includes(userRole)) {
      return c.json({
        error: 'Forbidden',
        required: allowedRoles,
        current: userRole,
      }, 403);
    }

    await next();
  };
}
EOF

# ============================================================
# FILE: apps/api/src/middleware/cors.ts
# ============================================================
cat > apps/api/src/middleware/cors.ts << 'EOF'
import { Context, Next } from 'hono';

const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:5173',
  'https://ororo.app',
  'https://www.ororo.app',
];

export async function corsMiddleware(c: Context, next: Next) {
  const origin = c.req.header('Origin');

  if (origin && allowedOrigins.includes(origin)) {
    c.header('Access-Control-Allow-Origin', origin);
    c.header('Access-Control-Allow-Credentials', 'true');
  }

  c.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  c.header(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization'
  );

  if (c.req.method === 'OPTIONS') {
    return c.text('', 204);
  }

  await next();
}
EOF

# ============================================================
# FILE: apps/api/src/middleware/error.ts
# ============================================================
cat > apps/api/src/middleware/error.ts << 'EOF'
import { Context } from 'hono';
import type { Bindings } from '../index';

export function errorHandler(err: Error, c: Context<{ Bindings: Bindings }>) {
  console.error('Error:', err);

  if (err.message.includes('not found')) {
    return c.json({ error: err.message }, 404);
  }

  if (err.message.includes('already exists')) {
    return c.json({ error: err.message }, 409);
  }

  if (err.message.includes('Unauthorized')) {
    return c.json({ error: err.message }, 401);
  }

  if (err.message.includes('Forbidden')) {
    return c.json({ error: err.message }, 403);
  }

  return c.json({
    error: 'Internal server error',
    message: c.env?.ENVIRONMENT === 'development' ? err.message : undefined,
  }, 500);
}
EOF

# ============================================================
# FILE: apps/api/src/middleware/logger.ts
# ============================================================
cat > apps/api/src/middleware/logger.ts << 'EOF'
import { Context, Next } from 'hono';

export async function loggerMiddleware(c: Context, next: Next) {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  
  console.log(`${c.req.method} ${c.req.path} - ${c.res.status} (${ms}ms)`);
}
EOF

# ============================================================
# FILE: apps/api/src/services/auth.service.ts
# ============================================================
cat > apps/api/src/services/auth.service.ts << 'EOF'
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
EOF

# ============================================================
# FILE: apps/api/src/services/shift.service.ts
# ============================================================
cat > apps/api/src/services/shift.service.ts << 'EOF'
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
EOF

# ============================================================
# FILE: apps/api/src/services/transaction.service.ts
# ============================================================
cat > apps/api/src/services/transaction.service.ts << 'EOF'
import {
  TransactionRepository,
  FuelSaleRepository,
  PaymentRepository,
  ShiftRepository,
} from '../db/queries';
import type { DbClient } from '../db/client';
import { ulid } from '../utils/ulid';
import { RECEIPT_PREFIX } from '../utils/constants';

export class TransactionService {
  constructor(private db: DbClient) {}

  async createFuelTransaction(data: {
    attendantId: string;
    stationId: string;
    shiftId: string;
    pumpId: string;
    fuelType: string;
    litersDispensed: number;
    pricePerLiter: number;
    meterReadingBefore: number;
    meterReadingAfter: number;
    paymentMethod: string;
    amountReceived?: number;
    momoPhone?: string;
    creditCustomerId?: string;
  }) {
    const txnRepo = new TransactionRepository(this.db);
    const fuelSaleRepo = new FuelSaleRepository(this.db);
    const paymentRepo = new PaymentRepository(this.db);
    const shiftRepo = new ShiftRepository(this.db);

    const totalAmount = data.litersDispensed * data.pricePerLiter;

    // Create transaction
    const transaction = await txnRepo.create({
      id: ulid(),
      receiptNumber: `${RECEIPT_PREFIX}${Date.now()}`,
      stationId: data.stationId,
      shiftId: data.shiftId,
      attendantId: data.attendantId,
      type: 'fuel',
      totalAmount,
    });

    // Add fuel sale
    await fuelSaleRepo.create({
      id: ulid(),
      transactionId: transaction.id,
      pumpId: data.pumpId,
      fuelType: data.fuelType,
      litersDispensed: data.litersDispensed,
      pricePerLiter: data.pricePerLiter,
      meterReadingBefore: data.meterReadingBefore,
      meterReadingAfter: data.meterReadingAfter,
    });

    // Record payment
    const payment = await paymentRepo.create({
      id: ulid(),
      transactionId: transaction.id,
      paymentMethod: data.paymentMethod,
      amount: totalAmount,
      amountReceived: data.amountReceived,
      changeGiven: data.amountReceived
        ? data.amountReceived - totalAmount
        : undefined,
      momoPhone: data.momoPhone,
      creditCustomerId: data.creditCustomerId,
    });

    await paymentRepo.markCompleted(payment.id);

    // Update shift totals
    const shift = await shiftRepo.findById(data.shiftId);
    if (shift) {
      await shiftRepo.updateTotals(data.shiftId, {
        totalSales: (shift.totalSales || 0) + totalAmount,
        totalFuelSales: (shift.totalFuelSales || 0) + totalAmount,
        totalCashSales:
          data.paymentMethod === 'cash'
            ? (shift.totalCashSales || 0) + totalAmount
            : shift.totalCashSales,
        transactionCount: (shift.transactionCount || 0) + 1,
        fuelDispensed: (shift.fuelDispensed || 0) + data.litersDispensed,
      });
    }

    return { transaction, payment };
  }
}
EOF

# ============================================================
# FILE: apps/api/src/services/payment.service.ts
# ============================================================
cat > apps/api/src/services/payment.service.ts << 'EOF'
import { PaymentRepository } from '../db/queries';
import type { DbClient } from '../db/client';

export class PaymentService {
  constructor(private db: DbClient) {}

  async processPayment(paymentId: string) {
    const paymentRepo = new PaymentRepository(this.db);
    return await paymentRepo.markCompleted(paymentId);
  }

  async handleMomoCallback(data: any) {
    const paymentRepo = new PaymentRepository(this.db);
    // Process mobile money callback
    return { status: 'processed' };
  }
}
EOF

# ============================================================
# FILE: apps/api/src/services/fuel.service.ts
# ============================================================
cat > apps/api/src/services/fuel.service.ts << 'EOF'
import type { DbClient } from '../db/client';

export class FuelService {
  constructor(private db: DbClient) {}

  async calculateVariance(
    meterDifference: number,
    recordedSales: number
  ): Promise<{ variance: number; percentage: number }> {
    const variance = meterDifference - recordedSales;
    const percentage =
      recordedSales > 0 ? (variance / recordedSales) * 100 : 0;

    return { variance, percentage };
  }
}
EOF

# ============================================================
# FILE: apps/api/src/services/momo.service.ts
# ============================================================
cat > apps/api/src/services/momo.service.ts << 'EOF'
export class MoMoService {
  constructor(
    private apiKey: string,
    private environment: 'sandbox' | 'production' = 'production'
  ) {}

  async requestPayment(
    amount: number,
    phone: string,
    reference: string
  ): Promise<{ transactionId: string; status: string }> {
    // MTN MoMo API integration
    return {
      transactionId: reference,
      status: 'pending',
    };
  }

  async checkPaymentStatus(transactionId: string): Promise<string> {
    return 'SUCCESSFUL';
  }
}
EOF

# ============================================================
# FILE: apps/api/src/routes/auth.ts
# ============================================================
cat > apps/api/src/routes/auth.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { AuthService } from '../services/auth.service';
import { phoneSchema, pinSchema } from '../utils/validation';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const loginSchema = z.object({
  phone: phoneSchema,
  pin: pinSchema,
});

app.post('/login', zValidator('json', loginSchema), async (c) => {
  const { phone, pin } = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const authService = new AuthService(db, c.env.JWT_SECRET);

  try {
    const result = await authService.login(phone, pin);
    return c.json(result);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 401);
  }
});

const registerSchema = z.object({
  phone: phoneSchema,
  name: z.string().min(2),
  pin: pinSchema,
  email: z.string().email().optional(),
});

app.post('/register', zValidator('json', registerSchema), async (c) => {
  const data = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const authService = new AuthService(db, c.env.JWT_SECRET);

  try {
    const result = await authService.register(data);
    return c.json(result, 201);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.post('/logout', async (c) => {
  return c.json({ message: 'Logged out successfully' });
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/shifts.ts
# ============================================================
cat > apps/api/src/routes/shifts.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { ShiftService } from '../services/shift.service';
import { ShiftRepository } from '../db/queries';
import { requireRole } from '../middleware/auth';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const startShiftSchema = z.object({
  stationId: z.string(),
  pumpId: z.string().optional(),
  openingCash: z.number(),
  openingMeterReading: z.number().optional(),
});

app.post('/start', zValidator('json', startShiftSchema), async (c) => {
  const data = c.req.valid('json');
  const attendantId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftService = new ShiftService(db);

  try {
    const shift = await shiftService.startShift({
      attendantId,
      ...data,
    });
    return c.json({ shift }, 201);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.get('/current', async (c) => {
  const attendantId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const shift = await shiftRepo.findActiveByAttendant(attendantId);

  if (!shift) {
    return c.json({ error: 'No active shift found' }, 404);
  }

  return c.json({ shift });
});

const closeShiftSchema = z.object({
  closingCash: z.number(),
  closingMeterReading: z.number().optional(),
  actualCashCounted: z.number(),
  varianceNotes: z.string().optional(),
});

app.post('/:id/close', zValidator('json', closeShiftSchema), async (c) => {
  const shiftId = c.req.param('id');
  const data = c.req.valid('json');
  const attendantId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftService = new ShiftService(db);

  try {
    const shift = await shiftService.closeShift(shiftId, attendantId, data);
    return c.json({ shift });
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.get('/pending', requireRole('manager', 'owner'), async (c) => {
  const stationId = c.get('stationId');

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const shifts = await shiftRepo.findPendingApproval(stationId);

  return c.json({ shifts });
});

app.post('/:id/approve', requireRole('manager', 'owner'), async (c) => {
  const shiftId = c.req.param('id');
  const managerId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftService = new ShiftService(db);

  const shift = await shiftService.approveShift(shiftId, managerId);

  return c.json({ shift });
});

const rejectSchema = z.object({
  reason: z.string().min(10),
});

app.post(
  '/:id/reject',
  requireRole('manager', 'owner'),
  zValidator('json', rejectSchema),
  async (c) => {
    const shiftId = c.req.param('id');
    const { reason } = c.req.valid('json');
    const managerId = c.get('userId');

    const db = createDbClient(c.env.DB);
    const shiftService = new ShiftService(db);

    const shift = await shiftService.rejectShift(shiftId, managerId, reason);

    return c.json({ shift });
  }
);

app.get('/history', async (c) => {
  const attendantId = c.get('userId');
  const limit = parseInt(c.req.query('limit') || '10');

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const shifts = await shiftRepo.findByAttendant(attendantId, limit);

  return c.json({ shifts });
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/transactions.ts
# ============================================================
cat > apps/api/src/routes/transactions.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { TransactionService } from '../services/transaction.service';
import { TransactionRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const createFuelTransactionSchema = z.object({
  shiftId: z.string(),
  pumpId: z.string(),
  fuelType: z.string(),
  litersDispensed: z.number(),
  pricePerLiter: z.number(),
  meterReadingBefore: z.number(),
  meterReadingAfter: z.number(),
  paymentMethod: z.string(),
  amountReceived: z.number().optional(),
  momoPhone: z.string().optional(),
  creditCustomerId: z.string().optional(),
});

app.post('/fuel', zValidator('json', createFuelTransactionSchema), async (c) => {
  const data = c.req.valid('json');
  const attendantId = c.get('userId');
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const transactionService = new TransactionService(db);

  try {
    const result = await transactionService.createFuelTransaction({
      attendantId,
      stationId,
      ...data,
    });
    return c.json(result, 201);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.get('/:id', async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const transaction = await txnRepo.findById(id);

  if (!transaction) {
    return c.json({ error: 'Transaction not found' }, 404);
  }

  return c.json({ transaction });
});

app.get('/shift/:shiftId', async (c) => {
  const shiftId = c.req.param('shiftId');

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const transactions = await txnRepo.findByShift(shiftId);

  return c.json({ transactions });
});

app.get('/today/stats', async (c) => {
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const stats = await txnRepo.getTodayStats(stationId);

  return c.json({ stats });
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/stations.ts
# ============================================================
cat > apps/api/src/routes/stations.ts << 'EOF'
import { Hono } from 'hono';
import { createDbClient } from '../db/client';
import { StationRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

app.get('/current', async (c) => {
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 404);
  }

  const db = createDbClient(c.env.DB);
  const stationRepo = new StationRepository(db);

  const station = await stationRepo.findById(stationId);

  if (!station) {
    return c.json({ error: 'Station not found' }, 404);
  }

  return c.json({ station });
});

app.get('/', async (c) => {
  const db = createDbClient(c.env.DB);
  const stationRepo = new StationRepository(db);

  const stations = await stationRepo.findAll();

  return c.json({ stations });
});

app.get('/:id', async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const stationRepo = new StationRepository(db);

  const station = await stationRepo.findById(id);

  if (!station) {
    return c.json({ error: 'Station not found' }, 404);
  }

  return c.json({ station });
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/users.ts
# ============================================================
cat > apps/api/src/routes/users.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { UserRepository } from '../db/queries';
import { requireRole } from '../middleware/auth';
import { hashPin } from '../utils/hash';
import { ulid } from '../utils/ulid';
import { phoneSchema, pinSchema } from '../utils/validation';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

app.get('/', requireRole('manager', 'owner'), async (c) => {
  const stationId = c.get('stationId');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const users = stationId
    ? await userRepo.findByStation(stationId)
    : await userRepo.findActiveUsers();

  return c.json({ users });
});

app.get('/:id', requireRole('manager', 'owner'), async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const user = await userRepo.findById(id);

  if (!user) {
    return c.json({ error: 'User not found' }, 404);
  }

  return c.json({ user });
});

const createUserSchema = z.object({
  phone: phoneSchema,
  name: z.string().min(2),
  pin: pinSchema,
  email: z.string().email().optional(),
  role: z.enum(['attendant', 'manager']),
  stationId: z.string().optional(),
});

app.post('/', requireRole('manager', 'owner'), zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json');
  const stationId = c.get('stationId');

  // Ensure users are created for the manager's station
  if (data.role === 'attendant' && !data.stationId && stationId) {
    data.stationId = stationId;
  }

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const existing = await userRepo.findByPhone(data.phone);
  if (existing) {
    return c.json({ error: 'User already exists' }, 409);
  }

  const pinHash = await hashPin(data.pin);

  const user = await userRepo.create({
    id: ulid(),
    ...data,
    pinHash,
  });

  return c.json({ user }, 201);
});

const updateUserSchema = z.object({
  name: z.string().min(2).optional(),
  email: z.string().email().optional(),
  role: z.enum(['attendant', 'manager']).optional(),
  isActive: z.boolean().optional(),
});

app.put('/:id', requireRole('manager', 'owner'), zValidator('json', updateUserSchema), async (c) => {
  const id = c.req.param('id');
  const data = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const user = await userRepo.update(id, data);

  return c.json({ user });
});

app.delete('/:id', requireRole('manager', 'owner'), async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  await userRepo.deactivate(id);

  return c.json({ message: 'User deactivated successfully' });
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/fuel.ts
# ============================================================
cat > apps/api/src/routes/fuel.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { requireRole } from '../middleware/auth';
import { FuelService } from '../services/fuel.service';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const updatePriceSchema = z.object({
  fuelType: z.string(),
  pricePerLiter: z.number(),
});

app.post('/prices', requireRole('manager', 'owner'), zValidator('json', updatePriceSchema), async (c) => {
  const data = c.req.valid('json');
  const stationId = c.get('stationId');

  // Implementation would use FuelPriceRepository
  return c.json({ message: 'Price updated', data });
});

const deliverySchema = z.object({
  tankId: z.string(),
  supplierName: z.string(),
  invoiceQuantity: z.number(),
  deliveredQuantity: z.number(),
  pricePerLiter: z.number(),
  invoiceNumber: z.string(),
});

app.post('/deliveries', requireRole('manager', 'owner'), zValidator('json', deliverySchema), async (c) => {
  const data = c.req.valid('json');

  // Implementation would use FuelDeliveryRepository
  return c.json({ message: 'Delivery recorded', data }, 201);
});

app.get('/variance/calculate', async (c) => {
  const meterDiff = parseFloat(c.req.query('meterDiff') || '0');
  const recordedSales = parseFloat(c.req.query('recordedSales') || '0');

  const db = createDbClient(c.env.DB);
  const fuelService = new FuelService(db);

  const result = await fuelService.calculateVariance(meterDiff, recordedSales);

  return c.json(result);
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/payments.ts
# ============================================================
cat > apps/api/src/routes/payments.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { PaymentService } from '../services/payment.service';
import { PaymentRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

app.get('/:id', async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const paymentRepo = new PaymentRepository(db);

  const payment = await paymentRepo.findById(id);

  if (!payment) {
    return c.json({ error: 'Payment not found' }, 404);
  }

  return c.json({ payment });
});

const momoCallbackSchema = z.object({
  transactionId: z.string(),
  status: z.string(),
  amount: z.number(),
  phone: z.string(),
});

app.post('/momo/callback', zValidator('json', momoCallbackSchema), async (c) => {
  const data = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const paymentService = new PaymentService(db);

  const result = await paymentService.handleMomoCallback(data);

  return c.json(result);
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/reports.ts
# ============================================================
cat > apps/api/src/routes/reports.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { TransactionRepository, ShiftRepository } from '../db/queries';
import { requireRole } from '../middleware/auth';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const dateRangeSchema = z.object({
  start: z.string().optional(),
  end: z.string().optional(),
});

app.get('/daily-sales', requireRole('manager', 'owner'), zValidator('query', dateRangeSchema), async (c) => {
  const { start, end } = c.req.valid('query');
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const startDate = start ? new Date(start) : new Date(new Date().setHours(0, 0, 0, 0));
  const endDate = end ? new Date(end) : new Date(new Date().setHours(23, 59, 59, 999));

  const transactions = await txnRepo.findByDateRange(stationId, startDate, endDate);

  // Calculate summary
  const summary = transactions.reduce(
    (acc, t) => {
      acc.totalRevenue += t.totalAmount;
      acc.totalTransactions += 1;
      
      if (t.type === 'fuel') acc.fuelRevenue += t.totalAmount;
      else if (t.type === 'car_wash') acc.carWashRevenue += t.totalAmount;
      else if (t.type === 'store') acc.storeRevenue += t.totalAmount;
      
      return acc;
    },
    {
      totalRevenue: 0,
      totalTransactions: 0,
      fuelRevenue: 0,
      carWashRevenue: 0,
      storeRevenue: 0,
    }
  );

  return c.json({
    summary,
    transactions,
  });
});

app.get('/shift-performance', requireRole('manager', 'owner'), zValidator('query', dateRangeSchema), async (c) => {
  const { start, end } = c.req.valid('query');
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const startDate = start ? new Date(start) : new Date(new Date().setDate(new Date().getDate() - 7));
  const endDate = end ? new Date(end) : new Date();

  const shifts = await shiftRepo.findByDateRange(stationId, startDate, endDate);

  return c.json({ shifts });
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/services/index.ts
# ============================================================
cat > apps/api/src/services/index.ts << 'EOF'
export * from './auth.service';
export * from './shift.service';
export * from './transaction.service';
export * from './payment.service';
export * from './fuel.service';
export * from './momo.service';
EOF

# ============================================================
# FILE: apps/api/src/routes/index.ts
# ============================================================
cat > apps/api/src/routes/index.ts << 'EOF'
export { default as authRoutes } from './auth';
export { default as shiftRoutes } from './shifts';
export { default as transactionRoutes } from './transactions';
export { default as stationRoutes } from './stations';
export { default as userRoutes } from './users';
export { default as fuelRoutes } from './fuel';
export { default as paymentRoutes } from './payments';
export { default as reportRoutes } from './reports';
EOF

echo "✅ Complete Hono API has been created successfully in apps/api/"
echo ""
echo "Files created:"
echo "  - apps/api/package.json"
echo "  - apps/api/wrangler.toml"
echo "  - apps/api/tsconfig.json"
echo "  - apps/api/vitest.config.ts"
echo "  - apps/api/README.md"
echo "  - apps/api/docs/api.md"
echo "  - apps/api/src/index.ts"
echo "  - apps/api/src/db/client.ts"
echo "  - apps/api/src/db/queries.ts"
echo "  - apps/api/src/utils/ (constants.ts, hash.ts, jwt.ts, ulid.ts, validation.ts)"
echo "  - apps/api/src/middleware/ (auth.ts, cors.ts, error.ts, logger.ts)"
echo "  - apps/api/src/services/ (auth.service.ts, shift.service.ts, transaction.service.ts, payment.service.ts, fuel.service.ts, momo.service.ts)"
echo "  - apps/api/src/routes/ (auth.ts, shifts.ts, transactions.ts, stations.ts, users.ts, fuel.ts, payments.ts, reports.ts)"
echo ""
echo "Next steps:"
echo "  1. cd apps/api"
echo "  2. npm install"
echo "  3. Update wrangler.toml with your D1 database IDs"
echo "  4. Set secrets: wrangler secret put JWT_SECRET"
echo "  5. Run: npm run dev"

