# Ororo - Gas Station Management System

Modern, mobile-first ERP for African gas stations.

## Structure

```
ororo/
├── apps/
│   ├── mobile/     # React Native (Expo) - Attendant App
│   ├── web/        # React Router v7 - Manager Dashboard
│   └── api/        # Hono API on Cloudflare Workers
└── packages/
    ├── db/         # Drizzle database schema
    ├── types/      # Shared TypeScript types
    ├── api-client/ # Shared API client
    ├── ui/         # Shared UI components
    └── config/     # ESLint, TypeScript configs
```

## Getting Started

```bash
# Install dependencies
bun install

# Set up environment
cp .env.example .env.local

# Set up database
bun run db:generate
bun run db:migrate

# Start development
bun run dev
```

## Development

```bash
# Start all apps
bun run dev

# Build all apps
bun run build

# Type check all apps
bun run type-check

# Lint all apps
bun run lint
```

## Apps

### Mobile (`apps/mobile`)
React Native app for fuel attendants. Record sales, manage shifts, work offline.

### Web (`apps/web`)
React Router dashboard for managers and owners. Real-time monitoring, reports, approvals.

### API (`apps/api`)
Hono API running on Cloudflare Workers with D1 database.

## Packages

### Database (`packages/db`)
Drizzle ORM schema and migrations for D1.

### Types (`packages/types`)
Shared TypeScript types for API contracts and domain models.

### API Client (`packages/api-client`)
Type-safe API client used by mobile and web apps.

## Deploy

```bash
# Deploy API
cd apps/api && wrangler deploy

# Build web
cd apps/web && npm run build
```

## License

MIT
