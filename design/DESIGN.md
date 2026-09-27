# Society Management App — Design Document
**Status:** Design phase | **Platforms:** Android, iOS | **Last updated:** 2026-09-06

## 1. Vision & Goals
**Problem**: Societies manage operations via spreadsheets, WhatsApp, paper registers.
**Vision**: Mobile-first app connecting residents, committees, and staff.

| Goal | Description |
|---|---|
| Clarity | Common tasks (pay dues, complaints, visitors) in <1 min |
| Trust | Transparent records for payments, complaints, visitor logs |
| Accessibility | All age groups; 48dp targets, readable type, regional languages |
| Consistency | Same experience on Android & iOS |

**Success metrics** (TBD): % flats onboarded · monthly active residents · complaint resolution time.

## 2. Users & Personas
| Persona | Role | Primary Needs | Pain Points |
|---|---|---|---|
| Resident | Flat owner/tenant | Pay dues, track complaints, visitor passes, notices | Scattered comms, unclear dues, gate waits |
| Committee | Secretary/treasurer | Collect dues, notices, manage complaints, reports | Manual tracking, no audit trail |
| Security/staff | Gatekeeper, facility | Visitor check-in, delivery logs, amenity access | Paper registers, no resident verification |
| Super admin | Society admin | Onboard, configure blocks/flats, roles, billing | One-time setup complexity |

### Role Permissions
| Role | View | Create/Edit | Approve |
|---|---|---|---|
| Resident | Own flat, notices | Complaints, visitor requests, amenity bookings | — |
| Committee | Society-wide | Notices, events, some settings | Complaints, bookings (TBD) |
| Security | Visitor/delivery log | Check-in/out | — |
| Admin | All | All configuration | All |

## 3. Scope & Features
### Phase 1 (MVP)
| Module | Description | Priority | Notes |
|---|---|---|---|
| Authentication | Phone/email OTP, society code join | P0 | |
| Home dashboard | Notices, quick actions, dues summary | P0 | |
| Maintenance & dues | View bills, payment history, receipts | P0 | Payment gateway TBD |
| Complaints | Raise, track status, attach photos | P0 | |
| Announcements | Society notices, events | P0 | |
| Visitor management | Pre-approve, QR/pass, gate log | P0 | |
| Profile & flat details | Resident info, family, vehicles | P1 | |

### Phase 2+
| Module | Priority |
|---|---|
| Amenity booking (clubhouse, gym, party hall) | P2 |
| Polls & voting (AGM, elections, surveys) | P2 |
| Document vault (bylaws, AGM minutes, NOCs) | P2 |
| Parking management | P2 |
| Accounting & reports | P2 |
| Vendor/staff directory | P3 |

## 4. Information Architecture
### Resident nav
```
Home · Payments (dues/history/receipts) · Complaints (list/new) · Visitors (today/add/history)
Notices (all/events) · Amenities (P2) · More (flat, family, settings, help)
```
### Admin/committee nav
```
Dashboard · Residents & flats · Billing & collections · Complaints · Notices · Visitors · Reports · Settings
```

## 5. Key User Flows
**5.1 Resident onboarding**: App → Join society → Enter society code/scan QR → Flat number → OTP/committee approval → Profile → Dashboard.
*Open*: Self-reg vs committee approval? Multiple flats per user?

**5.2 Pay dues**: Home outstanding → Pay now → Review breakdown → Payment method → Complete → Receipt saved.
*Open*: Partial payments? Late fee rules?

**5.3 Raise complaint**: Complaints → New → Category + description + photos → Submit → Track (Open → In progress → Resolved).

**5.4 Pre-approve visitor**: Visitors → Add → Name/phone/date/time/purpose → Share pass (QR/link) → Security scans → Check-in logged.

**5.5 Security gate check-in**: Security mode → Scan QR or search → Confirm flat + approval → Check-in → (Optional) Check-out.

## 6. Screen Inventory
### Resident
Splash/onboarding · Login/OTP · Join society · Home dashboard · Dues list & detail · Payment checkout · Complaint list · New complaint · Visitor list · Add visitor/pass · Notice detail · Profile & settings *(all: wireframe ☐, hi-fi ☐)*

### Committee/Admin
Admin dashboard · Flat & resident mgmt · Publish notice · Complaint mgmt · Billing config *(all: wireframe ☐, hi-fi ☐)*

## 7. UI/UX Guidelines
**Principles**: Mobile-first · Action-oriented home (3–4 key tasks) · Status visibility (every ticket/payment/visitor) · Low cognitive load.

### Design System (TBD)
| Token | Value |
|---|---|
| Primary color | TBD |
| Secondary color | TBD |
| Error/success/warning | TBD |
| Font family | TBD (min 16sp body) |
| Corner radius | TBD |
| Spacing scale | 4/8/16/24/32 |

### Platform Conventions
| Aspect | Android | iOS |
|---|---|---|
| Navigation | Material bottom nav / top app bar | Tab bar / navigation bar |
| Back | System back + app bar | Swipe + nav bar back |
| Date pickers | Material components | iOS native |
| Haptics | Light feedback on key actions | TBD |

**Accessibility**: 48×48 dp min targets · WCAG AA contrast · screen reader labels · dynamic type support.

## 8. Wireframes & Mockups
Store assets in `design/assets/`. **Figma link**: TBD.

## 9. Content & Copy
- Plain language; no legal jargon in resident screens.
- Amounts: `₹ 1,250.00` | Dates: locale-aware | Errors: what went wrong + next step | Empty states: feature description + first action prompt.

## 10. Technical Considerations
| Topic | Decision | Status |
|---|---|---|
| Cross-platform | Flutter | Decided |
| Offline support | Which screens? | Open |
| Push notifications | Dues, complaint updates, visitor arrival | Planned |
| Multi-society | One app, multiple societies per user? | Open |
| Languages | English first | Open |

## 11. Open Questions
| # | Question |
|---|---|
| 1 | Single app with roles vs separate resident/admin apps? |
| 2 | Payment gateway and merchant account holder? |
| 3 | Visitor pass: QR, OTP, or both? |
| 4 | Tenant vs owner permissions on same flat? |
| 5 | Data residency / compliance requirements? |

## 12. Decision Log
| Date | Decision | Rationale |
|---|---|---|
| 2026-09-06 | Created initial design document | Establish design-phase baseline |

## Glossary
| Term | Definition |
|---|---|
| Society | Housing society / apartment complex / gated community |
| Flat/unit | Individual residence within the society |
| Maintenance | Monthly charges for upkeep ("dues") |
| Committee | Elected resident body managing the society |
| RWA | Residents Welfare Association |
