# @ororo/types

Shared TypeScript types for the Ororo gas station ERP system.

## Usage

```typescript
// Import enums
import { UserRole, PaymentMethod, TransactionType } from '@ororo/types';

// Import models
import type { User, Transaction, Shift } from '@ororo/types/models';

// Import API types
import type { LoginRequest, LoginResponse } from '@ororo/types/api';

// Import constants
import { VARIANCE_THRESHOLD, CURRENCY } from '@ororo/types/constants';
Structure
enums.ts - Shared enums (UserRole, PaymentMethod, etc.)

models/ - Domain models (User, Transaction, Product, etc.)

api/ - API request/response types

constants.ts - Shared constants
