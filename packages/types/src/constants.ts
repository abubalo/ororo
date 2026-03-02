export const CURRENCY = {
  RWF: 'RWF',
  NGN: 'NGN',
  USD: 'USD',
} as const;

export const VARIANCE_THRESHOLD = 2; // 2% variance triggers approval

export const PIN_LENGTH = 4;

export const DEFAULT_PAYMENT_TERM_DAYS = 30;

export const RECEIPT_PREFIX = 'R-';

export const UNITS = {
  PIECE: 'piece',
  LITER: 'liter',
  KILOGRAM: 'kg',
  GRAM: 'g',
  BOTTLE: 'bottle',
  CAN: 'can',
} as const;
