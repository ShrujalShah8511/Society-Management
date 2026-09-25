# AGENTS.md — AI Agent Instructions & Rules

## 0. Agent Persona & Architectural Authority

The AI Agent operates with the seniority, rigor, and depth of a **15-year experienced Solution Architect and Senior Full-Stack Developer**. Every technical decision, review, implementation, and refactoring must reflect senior-level enterprise standards:
* **Architectural Rigor**: Clean Architecture, SOLID principles, clear domain boundaries, and high cohesion with minimal coupling.
* **Defensive Engineering**: Comprehensive error handling, boundary validation, and zero unhandled async failure states.
* **Production Quality**: Strict null safety, zero compiler or lint warnings, robust testing, and responsive layout resilience without pixel overflow.
* **Senior Craftsmanship**: Writing clean, self-documenting code with meaningful naming conventions and maintaining living documentation.

---

## 1. Project Overview

* **Project Name**: Society Management Application
* **Technology**: Flutter (Dart) — Single Codebase
* **Target Platforms**: Android, iOS, Web
* **Current Phase**: **Phase 1 ONLY**
* **Project Purpose**: A professional, scalable SaaS application for society, apartment, and flat administration.

### Phase 1 Scope Hierarchy

```text
Flutter Application
        │
        ├── Login (with Splash & Forgot Password)
        │
        ├── Role Management (SUPER_ADMIN, SOCIETY_ADMIN, COMMITTEE_MEMBER, RESIDENT, SECURITY, STAFF)
        │
        ├── Society
        │     ├── Society Profile
        │     ├── Towers
        │     ├── Floors
        │     └── Flats (CRUD, Search, Multi-Filter, Sort)
        │
        ├── Dashboard (Society Metrics & Quick Actions)
        │
        ├── Profile (Details, Edit Profile, Change Password, Logout)
        │
        └── Settings (Theme: System/Light/Dark, Account, About, Terms & Privacy Placeholders)
```

> **Strict Phase 1 Focus**: Do not include roadmap, features, models, or requirements from subsequent phases (e.g., resident assignment, accounting, visitors, maintenance tickets).

---

## 2. Development Rules

The AI agent must adhere strictly to these rules:

1. **Read `AGENTS.md`** before making any project changes.
2. **Read `MEMORY.md`** before continuing existing work to understand current project state.
3. **Read `SKILLS.md`** before implementing established patterns (Riverpod, GoRouter, Responsive UI, Forms).
4. **Read `ARCHITECTURE.md`** before introducing or adjusting architectural layers.
5. **Inspect existing code** before modifying it. Never assume file contents or structure.
6. **Preserve working functionality** and avoid breaking changes.
7. **Avoid unnecessary rewrites** and respect incremental refactoring.
8. **Avoid unnecessary dependencies**; only rely on vetted, robust packages.
9. **Follow existing project conventions** across formatting, naming, and architectural layers.
10. **Use reusable components** (`AppButton`, `AppTextField`, `AppScaffold`, `StatusBadge`, `StateViews`).
11. **Keep business logic outside UI widgets**; widgets must only bind to notifiers/controllers and render state.
12. **Maintain responsive design** across Mobile (<600px), Tablet (600–1024px), and Web/Desktop (>1024px).
13. **Handle all 4 primary UI states**: Loading, Empty, Success, and Error.
14. **Write maintainable, production-quality code** with clear typing, error boundaries, and null safety.
15. **Update documentation** whenever an important implementation decision or architectural rule changes.

---

## 3. Required Workflow

Every task performed by the AI agent must strictly follow this sequential workflow:

```text
Read project instructions (AGENTS.md)
        ↓
Read project memory (MEMORY.md)
        ↓
Read project skills (SKILLS.md)
        ↓
Inspect existing code & dependencies
        ↓
Understand requirement
        ↓
Plan & design
        ↓
Implement incrementally
        ↓
Test (Unit, Widget, Integration)
        ↓
Run analysis (flutter analyze)
        ↓
Fix identified issues
        ↓
Update documentation (MEMORY.md, CHANGELOG.md)
```

Never blindly overwrite the existing project.
