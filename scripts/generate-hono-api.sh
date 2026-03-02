#!/bin/bash

# Create the directory structure
mkdir -p apps/api/src/{middleware,utils,routes}

# ============================================================
# FILE: apps/api/src/index.ts
# Main Hono app entry point
# ============================================================
cat > apps/api/src/index.ts << 'EOF'
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';
import { createDbClient } from '@ororo/db';

// Route imports
import authRoutes from './routes/auth';
import shiftRoutes from './routes/shifts';
import transactionRoutes from './routes/transactions';

// Middleware
import { authMiddleware } from './middleware/auth';
import { errorHandler } from './middleware/error';

type Bindings = {
  DB: D1Database;
  JWT_SECRET: string;
  MTN_MOMO_API_KEY: string;
  AIRTEL_MONEY_API_KEY: string;
};

const app = new Hono<{ Bindings: Bindings }>();

// Global middleware
app.use('*', logger());
app.use('*', prettyJSON());
app.use('*', cors({
  origin: ['http://localhost:5173', 'https://ororo.app'],
  credentials: true,
}));

// Health check
app.get('/health', (c) => {
  return c.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// Public routes (no auth required)
app.route('/auth', authRoutes);

// Protected routes (auth required)
app.use('/api/*', authMiddleware);
app.route('/api/shifts', shiftRoutes);
app.route('/api/transactions', transactionRoutes);

// Error handling
app.onError(errorHandler);

// 404 handler
app.notFound((c) => {
  return c.json({ error: 'Not found', path: c.req.path }, 404);
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/middleware/auth.ts
# JWT authentication middleware
# ============================================================
cat > apps/api/src/middleware/auth.ts << 'EOF'
import { Context, Next } from 'hono';
import { verify } from 'hono/jwt';
import { createDbClient } from '@ororo/db';
import { UserRepository } from '@ororo/db/queries';

export async function authMiddleware(c: Context, next: Next) {
  const authHeader = c.req.header('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized - No token provided' }, 401);
  }

  const token = authHeader.substring(7);
  
  try {
    // Verify JWT
    const payload = await verify(token, c.env.JWT_SECRET);
    
    // Get user from database to ensure still active
    const db = createDbClient(c.env.DB);
    const userRepo = new UserRepository(db);
    const user = await userRepo.findById(payload.sub as string);
    
    if (!user || !user.isActive) {
      return c.json({ error: 'Unauthorized - User not found or inactive' }, 401);
    }
    
    // Attach user to context
    c.set('userId', user.id);
    c.set('userRole', user.role);
    c.set('stationId', user.stationId);
    
    await next();
  } catch (error) {
    return c.json({ error: 'Unauthorized - Invalid token' }, 401);
  }
}

// Role-based access control
export function requireRole(...allowedRoles: string[]) {
  return async (c: Context, next: Next) => {
    const userRole = c.get('userRole');
    
    if (!allowedRoles.includes(userRole)) {
      return c.json({ 
        error: 'Forbidden - Insufficient permissions',
        required: allowedRoles,
        current: userRole,
      }, 403);
    }
    
    await next();
  };
}
EOF

# ============================================================
# FILE: apps/api/src/middleware/error.ts
# Global error handler
# ============================================================
cat > apps/api/src/middleware/error.ts << 'EOF'
import { Context } from 'hono';

export function errorHandler(err: Error, c: Context) {
  console.error('Error:', err);
  
  // Known errors
  if (err.message.includes('not found')) {
    return c.json({ error: err.message }, 404);
  }
  
  if (err.message.includes('already exists')) {
    return c.json({ error: err.message }, 409);
  }
  
  if (err.message.includes('Credit limit exceeded')) {
    return c.json({ error: err.message }, 400);
  }
  
  // Generic server error
  return c.json({ 
    error: 'Internal server error',
    message: err.message,
  }, 500);
}
EOF

# ============================================================
# FILE: apps/api/src/utils/jwt.ts
# JWT helper functions
# ============================================================
cat > apps/api/src/utils/jwt.ts << 'EOF'
import { sign } from 'hono/jwt';

export async function generateToken(
  userId: string,
  secret: string,
  expiresIn: number = 60 * 60 * 12 // 12 hours
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
# FILE: apps/api/src/utils/hash.ts
# Password/PIN hashing utilities
# ============================================================
cat > apps/api/src/utils/hash.ts << 'EOF'
export async function hashPin(pin: string): Promise<string> {
  // In production, use bcrypt or similar
  // For Cloudflare Workers, we can use Web Crypto API
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

// NOTE: For production, use proper bcrypt:
// import bcrypt from 'bcryptjs';
// export const hashPin = (pin: string) => bcrypt.hash(pin, 10);
// export const verifyPin = (pin: string, hash: string) => bcrypt.compare(pin, hash);
EOF

# ============================================================
# FILE: apps/api/src/utils/ulid.ts
# ULID generator for IDs
# ============================================================
cat > apps/api/src/utils/ulid.ts << 'EOF'
import { ulid } from 'ulid';

export { ulid };

// Or use UUID if you prefer:
// export const generateId = () => crypto.randomUUID();
EOF

# ============================================================
# FILE: apps/api/src/routes/auth.ts
# Authentication routes
# ============================================================
cat > apps/api/src/routes/auth.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '@ororo/db';
import { UserRepository } from '@ororo/db/queries';
import { hashPin, verifyPin } from '../utils/hash';
import { generateToken } from '../utils/jwt';
import { ulid } from '../utils/ulid';

const app = new Hono();

// Login schema
const loginSchema = z.object({
  phone: z.string().min(10),
  pin: z.string().length(4),
});

// Login endpoint
app.post('/login', zValidator('json', loginSchema), async (c) => {
  const { phone, pin } = c.req.valid('json');
  
  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);
  
  // Find user by phone
  const user = await userRepo.findByPhone(phone);
  
  if (!user) {
    return c.json({ error: 'Invalid credentials' }, 401);
  }
  
  // Check if user is active
  if (!user.isActive) {
    return c.json({ error: 'Account is inactive' }, 401);
  }
  
  // Verify PIN
  const isValid = await verifyPin(pin, user.pinHash);
  
  if (!isValid) {
    return c.json({ error: 'Invalid credentials' }, 401);
  }
  
  // Update last login
  await userRepo.updateLastLogin(user.id);
  
  // Generate JWT
  const token = await generateToken(user.id, c.env.JWT_SECRET);
  
  return c.json({
    token,
    user: {
      id: user.id,
      phone: user.phone,
      name: user.name,
      role: user.role,
      stationId: user.stationId,
    },
  });
});

// Register endpoint (for creating first user/admin)
const registerSchema = z.object({
  phone: z.string().min(10),
  name: z.string().min(2),
  pin: z.string().length(4),
  email: z.string().email().optional(),
});

app.post('/register', zValidator('json', registerSchema), async (c) => {
  const data = c.req.valid('json');
  
  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);
  
  // Check if user already exists
  const existing = await userRepo.findByPhone(data.phone);
  if (existing) {
    return c.json({ error: 'User already exists' }, 409);
  }
  
  // Hash PIN
  const pinHash = await hashPin(data.pin);
  
  // Create user
  const user = await userRepo.create({
    id: ulid(),
    phone: data.phone,
    name: data.name,
    email: data.email,
    role: 'attendant', // Default role
    pinHash,
  });
  
  // Generate token
  const token = await generateToken(user.id, c.env.JWT_SECRET);
  
  return c.json({
    token,
    user: {
      id: user.id,
      phone: user.phone,
      name: user.name,
      role: user.role,
    },
  }, 201);
});

// Logout endpoint (client-side token deletion, but we can log it)
app.post('/logout', async (c) => {
  // In a real app, you might want to blacklist the token
  // For now, just return success
  return c.json({ message: 'Logged out successfully' });
});

export default app;
EOF

# ============================================================
# FILE: apps/api/src/routes/shifts.ts
# Shift management routes
# ============================================================
cat > apps/api/src/routes/shifts.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '@ororo/db';
import { ShiftRepository } from '@ororo/db/queries';
import { ulid } from '../utils/ulid';
import { requireRole } from '../middleware/auth';

const app = new Hono();

// Start shift
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
  const shiftRepo = new ShiftRepository(db);
  
  // Check if attendant already has an active shift
  const activeShift = await shiftRepo.findActiveByAttendant(attendantId);
  if (activeShift) {
    return c.json({ 
      error: 'You already have an active shift',
      shift: activeShift,
    }, 400);
  }
  
  // Create shift
  const shift = await shiftRepo.create({
    id: ulid(),
    stationId: data.stationId,
    attendantId,
    pumpId: data.pumpId,
    openingCash: data.openingCash,
    openingMeterReading: data.openingMeterReading,
  });
  
  return c.json({ shift }, 201);
});

// Get current shift
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

// Close shift
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
  const shiftRepo = new ShiftRepository(db);
  
  // Verify shift belongs to this attendant
  const shift = await shiftRepo.findById(shiftId);
  if (!shift || shift.attendantId !== attendantId) {
    return c.json({ error: 'Shift not found or unauthorized' }, 404);
  }
  
  if (shift.status !== 'active') {
    return c.json({ error: 'Shift is not active' }, 400);
  }
  
  // Close shift
  const closedShift = await shiftRepo.close(shiftId, data);
  
  return c.json({ shift: closedShift });
});

// Get pending approvals (managers only)
app.get('/pending', requireRole('manager', 'owner'), async (c) => {
  const stationId = c.get('stationId');
  
  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);
  
  const shifts = await shiftRepo.findPendingApproval(stationId);
  
  return c.json({ shifts });
});

// Approve shift (managers only)
app.post('/:id/approve', requireRole('manager', 'owner'), async (c) => {
  const shiftId = c.req.param('id');
  const managerId = c.get('userId');
  
  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);
  
  const shift = await shiftRepo.approve(shiftId, managerId);
  
  return c.json({ shift });
});

// Reject shift (managers only)
const rejectSchema = z.object({
  reason: z.string().min(10),
});

app.post('/:id/reject', 
  requireRole('manager', 'owner'),
  zValidator('json', rejectSchema),
  async (c) => {
    const shiftId = c.req.param('id');
    const { reason } = c.req.valid('json');
    const managerId = c.get('userId');
    
    const db = createDbClient(c.env.DB);
    const shiftRepo = new ShiftRepository(db);
    
    const shift = await shiftRepo.reject(shiftId, managerId, reason);
    
    return c.json({ shift });
  }
);

// Get shift history
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
# Transaction routes (fuel + car wash + store)
# ============================================================
cat > apps/api/src/routes/transactions.ts << 'EOF'
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '@ororo/db';
import {
  TransactionRepository,
  FuelSaleRepository,
  CarWashSaleRepository,
  StoreSaleRepository,
  PaymentRepository,
  ShiftRepository,
  ProductRepository,
} from '@ororo/db/queries';
import { ulid } from '../utils/ulid';

const app = new Hono();

// Create fuel transaction
const createFuelTransactionSchema = z.object({
  shiftId: z.string(),
  pumpId: z.string(),
  fuelType: z.string(),
  litersDispensed: z.number(),
  pricePerLiter: z.number(),
  meterReadingBefore: z.number(),
  meterReadingAfter: z.number(),
  paymentMethod: z.enum(['cash', 'momo_mtn', 'momo_airtel', 'card', 'credit']),
  // Payment details
  amountReceived: z.number().optional(),
  momoPhone: z.string().optional(),
  creditCustomerId: z.string().optional(),
});

app.post('/fuel', zValidator('json', createFuelTransactionSchema), async (c) => {
  const data = c.req.valid('json');
  const attendantId = c.get('userId');
  const stationId = c.get('stationId');
  
  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);
  const fuelSaleRepo = new FuelSaleRepository(db);
  const paymentRepo = new PaymentRepository(db);
  const shiftRepo = new ShiftRepository(db);
  
  const totalAmount = data.litersDispensed * data.pricePerLiter;
  
  // 1. Create transaction
  const transaction = await txnRepo.create({
    id: ulid(),
    receiptNumber: `R-${Date.now()}`,
    stationId,
    shiftId: data.shiftId,
    attendantId,
    type: 'fuel',
    totalAmount,
  });
  
  // 2. Add fuel sale details
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
  
  // 3. Record payment
  const payment = await paymentRepo.create({
    id: ulid(),
    transactionId: transaction.id,
    paymentMethod: data.paymentMethod,
    amount: totalAmount,
    amountReceived: data.amountReceived,
    changeGiven: data.amountReceived ? data.amountReceived - totalAmount : undefined,
    momoPhone: data.momoPhone,
    creditCustomerId: data.creditCustomerId,
  });
  
  // Mark payment completed (in real app, wait for MoMo confirmation)
  await paymentRepo.markCompleted(payment.id);
  
  // 4. Update shift totals
  const shift = await shiftRepo.findById(data.shiftId);
  if (shift) {
    await shiftRepo.updateTotals(data.shiftId, {
      totalSales: (shift.totalSales || 0) + totalAmount,
      totalFuelSales: (shift.totalFuelSales || 0) + totalAmount,
      totalCashSales: data.paymentMethod === 'cash' 
        ? (shift.totalCashSales || 0) + totalAmount 
        : shift.totalCashSales,
      transactionCount: (shift.transactionCount || 0) + 1,
      fuelDispensed: (shift.fuelDispensed || 0) + data.litersDispensed,
    });
  }
  
  return c.json({ transaction, payment }, 201);
});

// Create car wash transaction
const createCarWashSchema = z.object({
  shiftId: z.string(),
  serviceId: z.string().optional(),
  serviceName: z.string(),
  vehicleType: z.string(),
  price: z.number(),
  paymentMethod: z.enum(['cash', 'momo_mtn', 'momo_airtel', 'card', 'credit']),
  amountReceived: z.number().optional(),
  momoPhone: z.string().optional(),
  creditCustomerId: z.string().optional(),
  notes: z.string().optional(),
});

app.post('/car-wash', zValidator('json', createCarWashSchema), async (c) => {
  const data = c.req.valid('json');
  const attendantId = c.get('userId');
  const stationId = c.get('stationId');
  
  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);
  const carWashRepo = new CarWashSaleRepository(db);
  const paymentRepo = new PaymentRepository(db);
  const shiftRepo = new ShiftRepository(db);
  
  // 1. Create transaction
  const transaction = await txnRepo.create({
    id: ulid(),
    receiptNumber: `R-${Date.now()}`,
    stationId,
    shiftId: data.shiftId,
    attendantId,
    type: 'car_wash',
    totalAmount: data.price,
  });
  
  // 2. Add car wash details
  await carWashRepo.create({
    id: ulid(),
    transactionId: transaction.id,
    serviceId: data.serviceId,
    serviceName: data.serviceName,
    vehicleType: data.vehicleType,
    price: data.price,
    notes: data.notes,
  });
  
  // 3. Record payment
  const payment = await paymentRepo.create({
    id: ulid(),
    transactionId: transaction.id,
    paymentMethod: data.paymentMethod,
    amount: data.price,
    amountReceived: data.amountReceived,
    changeGiven: data.amountReceived ? data.amountReceived - data.price : undefined,
    momoPhone: data.momoPhone,
    creditCustomerId: data.creditCustomerId,
  });
  
  await paymentRepo.markCompleted(payment.id);
  
  // 4. Update shift totals
  const shift = await shiftRepo.findById(data.shiftId);
  if (shift) {
    await shiftRepo.updateTotals(data.shiftId, {
      totalSales: (shift.totalSales || 0) + data.price,
      totalCarWashSales: (shift.totalCarWashSales || 0) + data.price,
      totalCashSales: data.paymentMethod === 'cash' 
        ? (shift.totalCashSales || 0) + data.price 
        : shift.totalCashSales,
      transactionCount: (shift.transactionCount || 0) + 1,
    });
  }
  
  return c.json({ transaction, payment }, 201);
});

// Create store transaction
const createStoreSchema = z.object({
  shiftId: z.string(),
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number().min(1),
  })),
  paymentMethod: z.enum(['cash', 'momo_mtn', 'momo_airtel', 'card', 'credit']),
  amountReceived: z.number().optional(),
  momoPhone: z.string().optional(),
  creditCustomerId: z.string().optional(),
});

app.post('/store', zValidator('json', createStoreSchema), async (c) => {
  const data = c.req.valid('json');
  const attendantId = c.get('userId');
  const stationId = c.get('stationId');
  
  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);
  const storeSaleRepo = new StoreSaleRepository(db);
  const paymentRepo = new PaymentRepository(db);
  const shiftRepo = new ShiftRepository(db);
  const productRepo = new ProductRepository(db);
  
  // Calculate total from products
  let totalAmount = 0;
  const items = [];
  
  for (const item of data.items) {
    const product = await productRepo.findById(item.productId);
    if (!product) {
      return c.json({ error: `Product ${item.productId} not found` }, 404);
    }
    
    if (product.currentStock < item.quantity) {
      return c.json({ 
        error: `Insufficient stock for ${product.name}. Available: ${product.currentStock}`,
      }, 400);
    }
    
    const itemTotal = product.sellingPrice * item.quantity;
    totalAmount += itemTotal;
    
    items.push({
      id: ulid(),
      productId: product.id,
      productName: product.name,
      quantity: item.quantity,
      unitPrice: product.sellingPrice,
    });
  }
  
  // 1. Create transaction
  const transaction = await txnRepo.create({
    id: ulid(),
    receiptNumber: `R-${Date.now()}`,
    stationId,
    shiftId: data.shiftId,
    attendantId,
    type: 'store',
    totalAmount,
  });
  
  // 2. Create store sale with items
  await storeSaleRepo.create(
    {
      id: ulid(),
      transactionId: transaction.id,
    },
    items
  );
  
  // 3. Reduce stock for each product
  for (const item of data.items) {
    await productRepo.adjustStock(
      item.productId,
      'sale',
      -item.quantity, // Negative = stock out
      attendantId,
      transaction.receiptNumber,
      undefined,
      transaction.id
    );
  }
  
  // 4. Record payment
  const payment = await paymentRepo.create({
    id: ulid(),
    transactionId: transaction.id,
    paymentMethod: data.paymentMethod,
    amount: totalAmount,
    amountReceived: data.amountReceived,
    changeGiven: data.amountReceived ? data.amountReceived - totalAmount : undefined,
    momoPhone: data.momoPhone,
    creditCustomerId: data.creditCustomerId,
  });
  
  await paymentRepo.markCompleted(payment.id);
  
  // 5. Update shift totals
  const shift = await shiftRepo.findById(data.shiftId);
  if (shift) {
    await shiftRepo.updateTotals(data.shiftId, {
      totalSales: (shift.totalSales || 0) + totalAmount,
      totalStoreSales: (shift.totalStoreSales || 0) + totalAmount,
      totalCashSales: data.paymentMethod === 'cash' 
        ? (shift.totalCashSales || 0) + totalAmount 
        : shift.totalCashSales,
      transactionCount: (shift.transactionCount || 0) + 1,
    });
  }
  
  return c.json({ transaction, payment, items }, 201);
});

// Get transaction by ID
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

// Get transactions by shift
app.get('/shift/:shiftId', async (c) => {
  const shiftId = c.req.param('shiftId');
  
  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);
  
  const transactions = await txnRepo.findByShift(shiftId);
  
  return c.json({ transactions });
});

// Get today's transactions
app.get('/today', async (c) => {
  const stationId = c.get('stationId');
  
  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);
  
  const stats = await txnRepo.getTodayStats(stationId);
  
  return c.json({ stats });
});

export default app;
EOF

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
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "hono": "^4.6.15",
    "@hono/zod-validator": "^0.4.1",
    "zod": "^3.24.1",
    "ulid": "^2.3.0",
    "@ororo/db": "workspace:*"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20250110.0",
    "wrangler": "^3.103.0",
    "typescript": "^5.7.2"
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
  "exclude": ["node_modules", "dist"]
}
EOF

echo "✅ Hono API has been created successfully in apps/api/"
echo ""
echo "Files created:"
echo "  - apps/api/src/index.ts (main app)"
echo "  - apps/api/src/middleware/auth.ts"
echo "  - apps/api/src/middleware/error.ts"
echo "  - apps/api/src/utils/jwt.ts"
echo "  - apps/api/src/utils/hash.ts"
echo "  - apps/api/src/utils/ulid.ts"
echo "  - apps/api/src/routes/auth.ts"
echo "  - apps/api/src/routes/shifts.ts"
echo "  - apps/api/src/routes/transactions.ts"
echo "  - apps/api/package.json"
echo "  - apps/api/wrangler.toml"
echo "  - apps/api/tsconfig.json"
echo ""
echo "Next steps:"
echo "  1. cd apps/api"
echo "  2. npm install"
echo "  3. Update wrangler.toml with your D1 database ID"
echo "  4. Set secrets: wrangler secret put JWT_SECRET"
echo "  5. Run: npm run dev"