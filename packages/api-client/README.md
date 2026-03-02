# @ororo/api-client

Type-safe API client for Ororo.

## Usage

### Web App (React)

```typescript
import { OroroApiClient, ApiError } from '@ororo/api-client';

// Initialize client
const apiClient = new OroroApiClient({
  baseUrl: 'https://api.ororo.app',
  getToken: () => localStorage.getItem('token'),
  onUnauthorized: () => {
    // Redirect to login
    window.location.href = '/login';
  },
});

// Use in component
async function login(phone: string, pin: string) {
  try {
    const { token, user } = await apiClient.auth.login({ phone, pin });
    localStorage.setItem('token', token);
    return user;
  } catch (error) {
    if (error instanceof ApiError) {
      console.error(error.message, error.status);
    }
  }
}

// Get current shift
const { shift } = await apiClient.shifts.getCurrent();

// Create fuel transaction
const result = await apiClient.transactions.createFuelTransaction({
  shiftId: shift.id,
  pumpId: 'pump-123',
  fuelType: 'petrol',
  litersDispensed: 45.5,
  pricePerLiter: 1099,
  meterReadingBefore: 125678.5,
  meterReadingAfter: 125724.0,
  paymentMethod: 'cash',
  amountReceived: 50000,
});
