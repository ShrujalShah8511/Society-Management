# Society Management App — Design Document
**Platforms:** Android · iOS · Web | **Last updated:** 2026-09-28

## 1. Vision
**Problem**: Societies manage operations via spreadsheets, WhatsApp, paper registers.
**Vision**: Mobile-first app connecting residents, committees, staff, and admins.

## 2. Users & Roles
| Persona | Primary Needs |
|---|---|
| Resident | Pay dues, complaints, visitor passes, notices |
| Committee | Collect dues, notices, manage complaints, reports |
| Security/Staff | Visitor check-in, delivery logs, gate verification |
| Society Admin | Society config, user provisioning, billing |
| Super Admin | Platform-level multi-tenant management, user impersonation |

## 3. Scope

### Phase 1 (Implemented)
| Module | Status |
|---|---|
| Auth (Login, Forgot PW, Force Change PW) | ✅ |
| 6-Role RBAC + permission matrix | ✅ |
| Society Profile (RERA, contact, logo) | ✅ |
| Tower / Floor / Flat CRUD (search, filter, sort) | ✅ |
| Dashboard (KPIs, occupancy bar, quick actions) | ✅ |
| User Management (provision, flat assign, force-PW) | ✅ |
| Notifications (right-drawer, unread badge) | ✅ |
| Multi-tenancy & society isolation | ✅ |
| Super Admin impersonation (login-as) | ✅ |
| Dynamic branding (logo, favicon, title) | ✅ |

### Phase 2+ (Out of Scope for Now)
Resident dues/payments · Complaints · Visitor management · Amenity booking · Polls & voting · Document vault · Parking management · Accounting & reports

## 4. Key User Flows
**Resident onboarding**: App → Join society → Flat number → Committee approval → Profile → Dashboard.

**Super Admin creates society**: Societies → New → Society details + Admin credentials (auto-generated ID, temp PW `Welcome@<mobile>`) → Admin must change PW on first login.

**Super Admin impersonates**: Users → Login As (🔀) → Golden banner shown → Exit Impersonation.

**Pay dues** (Phase 2): Home → Pay Now → Payment method → Receipt saved.

**Raise complaint** (Phase 2): Complaints → New → Category + description + photos → Track status.

## 5. UI/UX Guidelines
- Mobile-first; 48dp min tap targets; WCAG AA contrast.
- Material 3: HSL curated colors, glassmorphic nav, micro-interactions.
- Status visibility: every ticket/payment/visitor shows current state.
- Responsive: Desktop sidebar ↔ Mobile bottom nav; full feature parity.

## 6. Technical Decisions
| Topic | Decision |
|---|---|
| Cross-platform | Flutter (single codebase) |
| Push notifications | Firebase FCM (planned) |
| Multi-society | Super Admin sees all; others scoped to assigned society |
| Offline support | Phase 2 (SQLite/Hive/Isar cache) |
| Languages | English first; regional planned |
| Data residency | Supabase (Postgres + RLS) |

## Glossary
| Term | Definition |
|---|---|
| Society | Housing society / apartment complex / gated community |
| Flat/unit | Individual residence |
| Maintenance | Monthly upkeep charges ("dues") |
| Committee | Elected resident body (RWA) |
