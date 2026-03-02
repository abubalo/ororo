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
