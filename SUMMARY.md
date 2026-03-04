# Ororo - What We're Building

## The Problem
Gas stations in Rwanda/Nigeria operate manually with paper notebooks. This causes:
- 2hrs/day wasted on reconciliation
- 2%+ fuel theft/loss
- 15%+ cash discrepancies
- No real-time visibility
- Manual errors

Existing solutions cost $50k-200k upfront + $2k-5k/month. Too expensive for 80% of stations.

## Our Solution
Mobile-first gas station ERP that replaces paper notebooks. Affordable, offline-capable, prevents theft.

**Target:** Small-medium gas stations (1-5 pumps) operating manually
**Pricing:** $500-1,500/month (50% cheaper than competitors)
**Market:** Rwanda first, then Nigeria

## Core Features (MVP)

### For Attendants
- Start/close shifts with opening/closing readings
- Record fuel sales (pump meter readings auto-calculate variance)
- Car wash sales (cash or credit)
- Store sales (lubricants, drinks, etc.)
- Accept payments: Cash, MTN MoMo, Airtel Money, Credit
- Offline-first (syncs when online)

### For Managers
- Real-time dashboard (sales, shifts, alerts)
- Approve/reject shift closures (variance >2% needs approval)
- Manage inventory (stock levels, low stock alerts)
- Credit customer management
- Daily/weekly reports

### For Owners
- Multi-station view
- Consolidated reports
- Performance by station/attendant

## Technical Approach

### Phase 1 (MVP - 12 weeks)
Manual data entry via tablets/phones. No hardware integration.
- Attendants manually read pump meters
- Manually check tank levels (dipstick)
- Focus: Better than notebook, not automated

### Phase 2 (Future)
Hardware integration: Automated Tank Gauges (ATG), pump sensors
- Premium tier: $2k-3k/month
- Same software, just automated input

## Key Differentiators
1. **Offline-first** - Works without internet (critical in Africa)
2. **Mobile-native** - Attendants use phones, not desktop
3. **Variance tracking** - Auto-detects theft/errors
4. **Credit management** - Track car wash credit (common use case)
5. **Store inventory** - Not just fuel, whole station
6. **Affordable** - 50% cheaper, no upfront hardware cost

## Business Model
- **Manual tier**: $500-1k/month (MVP)
- **Hardware tier**: $2k-3k/month (Phase 2)
- **Module pricing**: Pay for what you use (fuel + car wash + store)
- **Recurring revenue**: SaaS subscription

## Success Metrics
- Fuel variance: 2% → 0.5%
- Reconciliation time: 2hrs/day → 30min/day
- Cash discrepancy: 15% → <5%
- Time to value: <1 week
- Customer ROI: 150-200%

## Go-to-Market
1. **Pilot**: 1 customer (4 stations in Kigali)
2. **Validate**: Prove 0.5% variance in 1 month
3. **Scale**: 10 stations by Q3 2026
4. **Expand**: Nigeria by Q4 2026

## Why This Works
- **Do things that don't scale** - Start manual, prove value
- **Notebook killer** - Not competing with $50k systems
- **Real customer waiting** - Pilot ready to pay
- **Simple problem** - Track transactions, detect theft
- **High ROI** - Customer saves $2k/month, pays $600/month

## What We've Built (So Far)
✅ Complete database schema (22 tables)
✅ Repository layer (11 repositories)
✅ Complete API (Hono + Cloudflare Workers)
✅ Shared types package
✅ Type-safe API client
✅ CI/CD workflows (GitHub Actions)

## What's Next
- [ ] Web dashboard (React Router v7)
- [ ] Deploy API to Cloudflare
- [ ] Test with pilot customer
- [ ] Iterate based on feedback
- [ ] Add 9 more stations

## The Vision
Become the leading gas station management platform in Africa by starting where others won't: the 80% doing everything manually.