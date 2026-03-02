#!/bin/bash

# Ororo Monorepo Structure Setup Script
# This script removes default Turbo apps and creates the Ororo structure

set -e  # Exit on any error

echo "🚀 Setting up Ororo monorepo structure..."
echo ""

# Step 1: Remove default Turbo apps
echo "📦 Cleaning up default Turbo structure..."
rm -rf apps/docs
rm -rf apps/web

# Step 2: Remove default packages (we'll create our own)
rm -rf packages/ui
rm -rf packages/eslint-config
rm -rf packages/typescript-config

echo "✅ Cleanup complete!"
echo ""

# Step 3: Create new app directories
echo "📱 Creating app directories..."

# Mobile app structure
mkdir -p apps/mobile/src/components
mkdir -p apps/mobile/src/screens/auth
mkdir -p apps/mobile/src/screens/home
mkdir -p apps/mobile/src/screens/sale
mkdir -p apps/mobile/src/screens/shift
mkdir -p apps/mobile/src/screens/sales
mkdir -p apps/mobile/src/screens/more
mkdir -p apps/mobile/src/navigation
mkdir -p apps/mobile/src/store
mkdir -p apps/mobile/src/db/models
mkdir -p apps/mobile/src/services
mkdir -p apps/mobile/src/utils
mkdir -p apps/mobile/src/hooks
mkdir -p apps/mobile/assets

# Web app structure
mkdir -p apps/web/app/routes/dashboard
mkdir -p apps/web/app/routes/owner
mkdir -p apps/web/app/components/ui
mkdir -p apps/web/app/components/layout
mkdir -p apps/web/app/components/dashboard
mkdir -p apps/web/app/components/sales
mkdir -p apps/web/app/components/fuel
mkdir -p apps/web/app/components/shifts
mkdir -p apps/web/app/lib
mkdir -p apps/web/app/hooks
mkdir -p apps/web/app/store
mkdir -p apps/web/app/styles
mkdir -p apps/web/public

# API structure
mkdir -p apps/api/src/routes
mkdir -p apps/api/src/middleware
mkdir -p apps/api/src/services
mkdir -p apps/api/src/db
mkdir -p apps/api/src/utils

echo "✅ App directories created!"
echo ""

# Step 4: Create package directories
echo "📦 Creating package directories..."

# DB package
mkdir -p packages/db/src/schema
mkdir -p packages/db/src/migrations

# Types package
mkdir -p packages/types/src/api
mkdir -p packages/types/src/models

# API Client package
mkdir -p packages/api-client/src/endpoints

# UI package (optional)
mkdir -p packages/ui/src/components

# Config package
mkdir -p packages/config/eslint
mkdir -p packages/config/typescript

echo "✅ Package directories created!"
echo ""

# Step 5: Create other directories
echo "📜 Creating additional directories..."
mkdir -p scripts
mkdir -p .github/workflows
mkdir -p .vscode

echo "✅ Additional directories created!"
echo ""

# Step 6: Create empty files for mobile app
echo "📱 Creating mobile app files..."

# Root mobile files
touch apps/mobile/app.json
touch apps/mobile/babel.config.js
touch apps/mobile/package.json
touch apps/mobile/tsconfig.json
touch apps/mobile/README.md
touch apps/mobile/src/App.tsx

# Components
touch apps/mobile/src/components/Button.tsx
touch apps/mobile/src/components/Input.tsx
touch apps/mobile/src/components/Card.tsx
touch apps/mobile/src/components/LoadingSpinner.tsx
touch apps/mobile/src/components/index.ts

# Auth screens
touch apps/mobile/src/screens/auth/LoginScreen.tsx
touch apps/mobile/src/screens/auth/PinSetupScreen.tsx

# Home screen
touch apps/mobile/src/screens/home/HomeScreen.tsx

# Sale screens
touch apps/mobile/src/screens/sale/NewSaleScreen.tsx
touch apps/mobile/src/screens/sale/FuelTypeScreen.tsx
touch apps/mobile/src/screens/sale/MeterReadingScreen.tsx
touch apps/mobile/src/screens/sale/PaymentScreen.tsx
touch apps/mobile/src/screens/sale/SaleCompleteScreen.tsx

# Shift screens
touch apps/mobile/src/screens/shift/ShiftStartScreen.tsx
touch apps/mobile/src/screens/shift/ShiftSummaryScreen.tsx
touch apps/mobile/src/screens/shift/ShiftCloseScreen.tsx

# Sales screens
touch apps/mobile/src/screens/sales/SalesHistoryScreen.tsx
touch apps/mobile/src/screens/sales/SaleDetailScreen.tsx

# More screen
touch apps/mobile/src/screens/more/MoreScreen.tsx

# Navigation
touch apps/mobile/src/navigation/RootNavigator.tsx
touch apps/mobile/src/navigation/AuthNavigator.tsx
touch apps/mobile/src/navigation/MainNavigator.tsx

# Store
touch apps/mobile/src/store/authStore.ts
touch apps/mobile/src/store/shiftStore.ts
touch apps/mobile/src/store/salesStore.ts
touch apps/mobile/src/store/syncStore.ts

# Database
touch apps/mobile/src/db/schema.ts
touch apps/mobile/src/db/sync.ts
touch apps/mobile/src/db/models/Transaction.ts
touch apps/mobile/src/db/models/Shift.ts
touch apps/mobile/src/db/models/Payment.ts

# Services
touch apps/mobile/src/services/api.ts
touch apps/mobile/src/services/auth.ts
touch apps/mobile/src/services/transactions.ts
touch apps/mobile/src/services/shifts.ts
touch apps/mobile/src/services/sync.ts

# Utils
touch apps/mobile/src/utils/format.ts
touch apps/mobile/src/utils/validation.ts
touch apps/mobile/src/utils/storage.ts
touch apps/mobile/src/utils/constants.ts

# Hooks
touch apps/mobile/src/hooks/useAuth.ts
touch apps/mobile/src/hooks/useShift.ts
touch apps/mobile/src/hooks/useOnlineStatus.ts
touch apps/mobile/src/hooks/useSync.ts

echo "✅ Mobile app files created!"
echo ""

# Step 7: Create empty files for web app
echo "🌐 Creating web app files..."

# Root web files
touch apps/web/package.json
touch apps/web/tsconfig.json
touch apps/web/tailwind.config.ts
touch apps/web/postcss.config.js
touch apps/web/vite.config.ts
touch apps/web/README.md

# App files
touch apps/web/app/root.tsx
touch apps/web/app/entry.client.tsx

# Routes
touch apps/web/app/routes/_index.tsx
touch apps/web/app/routes/login.tsx
touch apps/web/app/routes/dashboard/_layout.tsx
touch apps/web/app/routes/dashboard/_index.tsx
touch apps/web/app/routes/dashboard/sales.tsx
touch apps/web/app/routes/dashboard/fuel.tsx
touch apps/web/app/routes/dashboard/shifts.tsx
touch apps/web/app/routes/dashboard/reports.tsx
touch apps/web/app/routes/dashboard/settings.tsx
touch apps/web/app/routes/owner/_layout.tsx
touch apps/web/app/routes/owner/_index.tsx

# UI Components
touch apps/web/app/components/ui/button.tsx
touch apps/web/app/components/ui/card.tsx
touch apps/web/app/components/ui/table.tsx
touch apps/web/app/components/ui/dialog.tsx
touch apps/web/app/components/ui/input.tsx
touch apps/web/app/components/ui/select.tsx
touch apps/web/app/components/ui/badge.tsx

# Layout Components
touch apps/web/app/components/layout/Sidebar.tsx
touch apps/web/app/components/layout/TopBar.tsx
touch apps/web/app/components/layout/Layout.tsx

# Dashboard Components
touch apps/web/app/components/dashboard/MetricCard.tsx
touch apps/web/app/components/dashboard/TransactionFeed.tsx
touch apps/web/app/components/dashboard/AlertPanel.tsx
touch apps/web/app/components/dashboard/QuickStats.tsx

# Sales Components
touch apps/web/app/components/sales/TransactionTable.tsx
touch apps/web/app/components/sales/TransactionDetail.tsx
touch apps/web/app/components/sales/SalesChart.tsx

# Fuel Components
touch apps/web/app/components/fuel/TankGauge.tsx
touch apps/web/app/components/fuel/TankList.tsx
touch apps/web/app/components/fuel/VarianceAlert.tsx

# Shifts Components
touch apps/web/app/components/shifts/ShiftCard.tsx
touch apps/web/app/components/shifts/ShiftApproval.tsx
touch apps/web/app/components/shifts/ShiftHistory.tsx

# Lib
touch apps/web/app/lib/api.ts
touch apps/web/app/lib/auth.ts
touch apps/web/app/lib/format.ts
touch apps/web/app/lib/utils.ts

# Hooks
touch apps/web/app/hooks/useAuth.ts
touch apps/web/app/hooks/useRealtime.ts
touch apps/web/app/hooks/useStations.ts

# Store
touch apps/web/app/store/authStore.ts
touch apps/web/app/store/stationStore.ts

# Styles
touch apps/web/app/styles/globals.css

echo "✅ Web app files created!"
echo ""

# Step 8: Create empty files for API
echo "🔌 Creating API files..."

# Root API files
touch apps/api/package.json
touch apps/api/tsconfig.json
touch apps/api/wrangler.toml
touch apps/api/vitest.config.ts
touch apps/api/README.md

# Main file
touch apps/api/src/index.ts

# Routes
touch apps/api/src/routes/auth.ts
touch apps/api/src/routes/transactions.ts
touch apps/api/src/routes/shifts.ts
touch apps/api/src/routes/payments.ts
touch apps/api/src/routes/fuel.ts
touch apps/api/src/routes/reports.ts
touch apps/api/src/routes/stations.ts
touch apps/api/src/routes/users.ts

# Middleware
touch apps/api/src/middleware/auth.ts
touch apps/api/src/middleware/cors.ts
touch apps/api/src/middleware/logger.ts
touch apps/api/src/middleware/error.ts

# Services
touch apps/api/src/services/auth.service.ts
touch apps/api/src/services/transaction.service.ts
touch apps/api/src/services/shift.service.ts
touch apps/api/src/services/payment.service.ts
touch apps/api/src/services/fuel.service.ts
touch apps/api/src/services/momo.service.ts

# Database
touch apps/api/src/db/client.ts
touch apps/api/src/db/queries.ts

# Utils
touch apps/api/src/utils/jwt.ts
touch apps/api/src/utils/hash.ts
touch apps/api/src/utils/validation.ts
touch apps/api/src/utils/constants.ts

echo "✅ API files created!"
echo ""

# Step 9: Create empty files for packages
echo "📦 Creating package files..."

# DB package
touch packages/db/package.json
touch packages/db/tsconfig.json
touch packages/db/drizzle.config.ts
touch packages/db/README.md
touch packages/db/src/index.ts
touch packages/db/src/client.ts
touch packages/db/src/schema/organizations.ts
touch packages/db/src/schema/stations.ts
touch packages/db/src/schema/users.ts
touch packages/db/src/schema/transactions.ts
touch packages/db/src/schema/fuel-sales.ts
touch packages/db/src/schema/car-wash-sales.ts
touch packages/db/src/schema/payments.ts
touch packages/db/src/schema/shifts.ts
touch packages/db/src/schema/fuel-tanks.ts
touch packages/db/src/schema/fuel-pumps.ts
touch packages/db/src/schema/credit-customers.ts
touch packages/db/src/schema/index.ts

# Types package
touch packages/types/package.json
touch packages/types/tsconfig.json
touch packages/types/README.md
touch packages/types/src/index.ts
touch packages/types/src/enums.ts
touch packages/types/src/constants.ts
touch packages/types/src/api/auth.ts
touch packages/types/src/api/transactions.ts
touch packages/types/src/api/shifts.ts
touch packages/types/src/api/payments.ts
touch packages/types/src/api/index.ts
touch packages/types/src/models/user.ts
touch packages/types/src/models/station.ts
touch packages/types/src/models/transaction.ts
touch packages/types/src/models/shift.ts
touch packages/types/src/models/payment.ts
touch packages/types/src/models/index.ts

# API Client package
touch packages/api-client/package.json
touch packages/api-client/tsconfig.json
touch packages/api-client/README.md
touch packages/api-client/src/index.ts
touch packages/api-client/src/client.ts
touch packages/api-client/src/endpoints/auth.ts
touch packages/api-client/src/endpoints/transactions.ts
touch packages/api-client/src/endpoints/shifts.ts
touch packages/api-client/src/endpoints/payments.ts
touch packages/api-client/src/endpoints/fuel.ts
touch packages/api-client/src/endpoints/reports.ts

# UI package (optional)
touch packages/ui/package.json
touch packages/ui/tsconfig.json
touch packages/ui/README.md
touch packages/ui/src/index.ts
touch packages/ui/src/components/Button.tsx
touch packages/ui/src/components/Input.tsx
touch packages/ui/src/components/Card.tsx

# Config package
touch packages/config/package.json
touch packages/config/README.md
touch packages/config/eslint/base.js
touch packages/config/eslint/react.js
touch packages/config/eslint/node.js
touch packages/config/typescript/base.json
touch packages/config/typescript/react.json
touch packages/config/typescript/node.json

echo "✅ Package files created!"
echo ""

# Step 10: Create root config files
echo "⚙️  Creating root config files..."
touch .env.example
touch .env.local
touch .gitignore
touch .npmrc

# VS Code config
touch .vscode/settings.json
touch .vscode/extensions.json
touch .vscode/launch.json

# GitHub workflows
touch .github/workflows/ci.yml
touch .github/workflows/deploy.yml

echo "✅ Root config files created!"
echo ""

# Step 11: Create scripts
echo "📜 Creating scripts..."
touch scripts/migrate.ts
touch scripts/seed.ts
touch scripts/deploy.sh
chmod +x scripts/deploy.sh

echo "✅ Scripts created!"
echo ""

# Step 12: Update root README
echo "📝 Updating README..."
cat > README.md << 'EOF'
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
EOF

echo "✅ README updated!"
echo ""

# Step 13: Print directory tree
echo "📁 Final structure:"
echo ""
tree -L 3 -I 'node_modules|.git' || find . -maxdepth 3 -type d | grep -v node_modules | sort

echo ""
echo "✅ Ororo monorepo structure created successfully!"
echo ""
echo "🎯 Next steps:"
echo "   1. Install dependencies: bun install"
echo "   2. Set up environment: cp .env.example .env.local"
echo "   3. Review package.json files and add dependencies"
echo "   4. Start building!"
echo ""