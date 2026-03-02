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
