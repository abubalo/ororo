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
