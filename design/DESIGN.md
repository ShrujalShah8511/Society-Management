# Society Management App — Design Document

> **Status:** Design phase  
> **Platforms:** Android, iOS  
> **Last updated:** 2026-09-06

This document is the single source of truth for product and UX design during the design phase. Update it as decisions are made, wireframes are added, and scope is refined.

---

## 1. Vision & Goals

### Problem statement

_Housing societies and apartment complexes need a simple way to manage day-to-day operations—maintenance, communication, security, and community engagement—without relying on spreadsheets, WhatsApp groups, and paper registers._

### Product vision

_A mobile-first society management app that connects residents, management committees, and staff in one place._

### Design goals

| Goal | Description |
|------|-------------|
| **Clarity** | Residents should complete common tasks (pay dues, raise complaints, register visitors) in under a minute |
| **Trust** | Transparent records for payments, complaints, and visitor logs |
| **Accessibility** | Usable by all age groups; large touch targets, readable type, support for regional languages |
| **Consistency** | Same experience and branding on Android and iOS |

### Success metrics (to refine)

- [ ] _Define adoption target (e.g. % of flats onboarded)_
- [ ] _Define engagement target (e.g. monthly active residents)_
- [ ] _Define operational targets (e.g. complaint resolution time)_

---

## 2. Target Users & Personas

### Primary personas

| Persona | Role | Primary needs | Pain points |
|---------|------|---------------|-------------|
| **Resident** | Flat owner / tenant | Pay maintenance, track complaints, visitor passes, announcements | Scattered communication, unclear dues, long wait at gate |
| **Committee member** | Secretary, treasurer, etc. | Collect dues, publish notices, manage complaints, reports | Manual tracking, payment reconciliation, no audit trail |
| **Security / staff** | Gatekeeper, facility staff | Visitor check-in, delivery logs, amenity access | Paper registers, no resident verification |
| **Super admin** | Society admin / builder handover | Onboard society, configure blocks/flats, roles, billing rules | One-time setup complexity |

### User roles & permissions (draft)

| Role | Can view | Can create/edit | Can approve |
|------|----------|-----------------|-------------|
| Resident | Own flat, society notices | Complaints, visitor requests, amenity bookings | — |
| Committee | Society-wide data | Notices, events, some settings | Complaints, bookings (TBD) |
| Security | Visitor log, delivery log | Check-in / check-out | — |
| Admin | All | All configuration | All |

---

## 3. Scope & Features

### MVP (Phase 1)

| Module | Description | Priority | Notes |
|--------|-------------|----------|-------|
| **Authentication** | Phone/email OTP, society code join | P0 | |
| **Home dashboard** | Notices, quick actions, dues summary | P0 | |
| **Maintenance & dues** | View bills, payment history, receipts | P0 | Payment gateway TBD |
| **Complaints** | Raise, track status, attach photos | P0 | |
| **Announcements** | Society notices, events | P0 | |
| **Visitor management** | Pre-approve visitors, QR/pass, gate log | P0 | |
| **Profile & flat details** | Resident info, family members, vehicles | P1 | |

### Phase 2+

| Module | Description | Priority |
|--------|-------------|----------|
| Amenity booking | Clubhouse, gym, party hall slots | P2 |
| Polls & voting | AGM, elections, surveys | P2 |
| Document vault | Bylaws, AGM minutes, NOCs | P2 |
| Parking management | Slot assignment, guest parking | P2 |
| Vendor / staff directory | Plumber, electrician contacts | P3 |
| Accounting & reports | Ledger, expense reports (committee) | P2 |

### Out of scope (for now)

- _List features explicitly excluded to avoid scope creep_

---

## 4. Information Architecture

### App navigation (draft)

```
├── Home (dashboard)
├── Payments
│   ├── Current dues
│   ├── Payment history
│   └── Receipts
├── Complaints
│   ├── My complaints
│   └── New complaint
├── Visitors
│   ├── Expected today
│   ├── Add visitor
│   └── History
├── Notices
│   ├── All notices
│   └── Events
├── Amenities (Phase 2)
├── More / Profile
│   ├── My flat
│   ├── Family members
│   ├── Settings
│   └── Help & support
```

### Committee / admin navigation (draft)

```
├── Dashboard (overview)
├── Residents & flats
├── Billing & collections
├── Complaints (manage)
├── Notices (publish)
├── Visitors (society log)
├── Reports
└── Settings
```

---

## 5. Key User Flows

_Use this section to document flows before wireframing. Link to wireframes when available._

### 5.1 Resident onboarding

1. Download app → Select "Join society"
2. Enter society code or scan invite QR
3. Enter flat number → Verify via OTP / committee approval
4. Complete profile → Land on home dashboard

**Open questions:**
- [ ] Self-registration vs committee approval?
- [ ] Support for multiple flats per user?

### 5.2 Pay maintenance dues

1. Home shows outstanding amount → Tap "Pay now"
2. Review bill breakdown → Select payment method
3. Complete payment → Receipt saved in history

**Open questions:**
- [ ] Partial payments allowed?
- [ ] Late fee rules?

### 5.3 Raise a complaint

1. Complaints → "New complaint"
2. Select category, describe issue, attach photos
3. Submit → Track status (Open → In progress → Resolved)

### 5.4 Pre-approve a visitor

1. Visitors → "Add visitor"
2. Enter name, phone, date/time, purpose
3. Share pass (QR/link) with visitor
4. Security scans at gate → Check-in logged

### 5.5 Security gate check-in

1. Security mode → Scan QR or search visitor
2. Confirm flat and resident approval
3. Check-in → Optional check-out on exit

---

## 6. Screen Inventory

_Check off as wireframes / high-fidelity designs are completed._

### Resident app

| Screen | Wireframe | Hi-fi | Platform notes |
|--------|-----------|-------|----------------|
| Splash / onboarding | ☐ | ☐ | |
| Login / OTP | ☐ | ☐ | |
| Join society | ☐ | ☐ | |
| Home dashboard | ☐ | ☐ | |
| Dues list & detail | ☐ | ☐ | |
| Payment checkout | ☐ | ☐ | |
| Complaint list | ☐ | ☐ | |
| New complaint | ☐ | ☐ | |
| Visitor list | ☐ | ☐ | |
| Add visitor / pass | ☐ | ☐ | |
| Notice detail | ☐ | ☐ | |
| Profile & settings | ☐ | ☐ | |

### Committee / admin app (or role-based views)

| Screen | Wireframe | Hi-fi | Notes |
|--------|-----------|-------|-------|
| Admin dashboard | ☐ | ☐ | Same app, different role? |
| Flat & resident management | ☐ | ☐ | |
| Publish notice | ☐ | ☐ | |
| Complaint management | ☐ | ☐ | |
| Billing configuration | ☐ | ☐ | |

---

## 7. UI / UX Guidelines

### Design principles

1. **Mobile-first** — Primary use on phones; tablet layouts optional later
2. **Action-oriented home** — Surface the 3–4 most common tasks immediately
3. **Status visibility** — Every ticket, payment, and visitor request shows clear status
4. **Low cognitive load** — Short forms, sensible defaults, progressive disclosure

### Design system (to define)

| Token | Value | Notes |
|-------|-------|-------|
| Primary color | _TBD_ | Brand / trust |
| Secondary color | _TBD_ | |
| Error / success / warning | _TBD_ | |
| Font family | _TBD_ | System fonts vs custom |
| Base font size | _TBD_ | Min 16sp for body |
| Corner radius | _TBD_ | |
| Spacing scale | _TBD_ | e.g. 4, 8, 16, 24, 32 |

### Platform conventions

| Aspect | Android | iOS |
|--------|---------|-----|
| Navigation | Material bottom nav / top app bar | Tab bar / navigation bar |
| Back behavior | System back + app bar | Swipe + nav bar back |
| Date/time pickers | Material components | iOS native pickers |
| Haptics | Light feedback on key actions | TBD |

### Accessibility

- [ ] Minimum touch target: 48×48 dp/pt
- [ ] Color contrast WCAG AA
- [ ] Screen reader labels for all interactive elements
- [ ] Support for dynamic type / font scaling

---

## 8. Wireframes & Mockups

_Store file references here. Add assets under `design/assets/`._

| Asset | Path | Description | Date |
|-------|------|-------------|------|
| _Example_ | `design/assets/wireframes/home.png` | Home dashboard v1 | — |

**Design tools:** _Figma / Adobe XD / Sketch — link project here_

**Figma link:** _TBD_

---

## 9. Content & Copy Guidelines

- Use plain language; avoid legal jargon in resident-facing screens
- Amounts: currency symbol + two decimal places (e.g. ₹ 1,250.00)
- Dates: locale-aware formatting
- Error messages: state what went wrong and what to do next
- Empty states: explain the feature and prompt the first action

---

## 10. Technical Design Considerations (for alignment)

_Keep high-level during design phase; detail in separate technical docs later._

| Topic | Decision | Status |
|-------|----------|--------|
| Cross-platform approach | _React Native / Flutter / native_ | Open |
| Offline support | _Which screens work offline?_ | Open |
| Push notifications | Dues reminders, complaint updates, visitor arrival | Planned |
| Multi-society | One app, multiple societies per user? | Open |
| Languages | English first; _list others_ | Open |

---

## 11. Open Questions

| # | Question | Owner | Resolution |
|---|----------|-------|------------|
| 1 | Single app with roles vs separate resident/admin apps? | | Open |
| 2 | Payment gateway and who holds merchant account? | | Open |
| 3 | Visitor pass: QR, OTP, or both? | | Open |
| 4 | Tenant vs owner permissions on same flat? | | Open |
| 5 | Data residency / compliance requirements? | | Open |

---

## 12. Design Decision Log

_Record significant decisions with date and rationale._

| Date | Decision | Rationale | Alternatives considered |
|------|----------|-----------|-------------------------|
| 2026-09-06 | Created initial design document | Establish design-phase baseline | — |

---

## 13. References & Inspiration

- _Competitor / reference apps_
- _Regulatory or RWA guidelines_
- _User research notes (link or path)_

---

## Appendix: Glossary

| Term | Definition |
|------|------------|
| **Society** | Housing society / apartment complex / gated community |
| **Flat / unit** | Individual residence within the society |
| **Maintenance** | Monthly charges for upkeep, often called "dues" |
| **Committee** | Elected resident body managing the society |
| **RWA** | Residents Welfare Association |
