export const UserRole = {
  ATTENDANT: "attendant",
  MANAGER: "manager",
  OWNER: "owner",
  ADMIN: "admin",
} as const;

export const FuelType = {
  PETROL: "petrol",
  DIESEL: "diesel",
  KEROSENE: "kerosene",
} as const;

export const TransactionType = {
  FUEL: "fuel",
  CAR_WASH: "car_wash",
  STORE: "store",
  MIXED: "mixed",
} as const;

export const TransactionStatus = {
  PENDING: "pending",
  COMPLETED: "completed",
  CANCELLED: "cancelled",
  REFUNDED: "refunded",
} as const;

export const PaymentMethod = {
  CASH: "cash",
  MOMO_MTN: "momo_mtn",
  MOMO_AIRTEL: "momo_airtel",
  CARD: "card",
  CREDIT: "credit",
} as const;

export const PaymentStatus = {
  PENDING: "pending",
  COMPLETED: "completed",
  FAILED: "failed",
  CANCELLED: "cancelled",
} as const;

export const ShiftStatus = {
  ACTIVE: "active",
  PENDING_APPROVAL: "pending_approval",
  APPROVED: "approved",
  REJECTED: "rejected",
} as const;

export const StockMovementType = {
  PURCHASE: "purchase",
  SALE: "sale",
  ADJUSTMENT: "adjustment",
  RETURN: "return",
  DAMAGE: "damage",
} as const;

export const CreditTransactionType = {
  CHARGE: "charge",
  PAYMENT: "payment",
  ADJUSTMENT: "adjustment",
} as const;

export const VehicleType = {
  SEDAN: "sedan",
  SUV: "suv",
  TRUCK: "truck",
  MOTORCYCLE: "motorcycle",
} as const;

export const CarWashServiceType = {
  BASIC: "basic",
  PREMIUM: "premium",
  FULL: "full",
  CUSTOM: "custom",
} as const;
