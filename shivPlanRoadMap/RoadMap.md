# MySmartAdmin (Working Name)
Offline-First Personal Life Management Platform

---

# 1. Vision

MySmartAdmin is a mobile-first, privacy-first life administration platform.

It helps users:
- Store and manage important documents
- Track expiries and renewals
- Organise insurance, finance, property, and vehicle data
- Generate reports
- Query their own data
- Maintain full control of their information

Core principle:
> The device is the system of record.

No mandatory cloud storage.
GDPR-safe by default.
User controls everything.

---

# 2. Core Principles

## 2.1 Product Principles
- Mobile-first (Flutter)
- Offline-first architecture
- Privacy-first (no data stored online by default)
- Manual entry + scan/upload always supported
- Review & confirm before saving extracted data
- Deterministic logic before AI
- Clean, premium UI/UX

## 2.2 Technical Principles
- SQLite (Drift) for structured storage
- JSON for flexible data fields
- Future FTS (Full-Text Search) support
- Local encrypted file store
- No Firebase for core data
- Open Banking optional and isolated

---

# 3. Feature Domains (Complete Inventory)

## 3.1 Identity & Legal
- Passport
- Driving Licence
- Visa / Residence Permit (future)
- Birth/Marriage certificates (future)
- Expiry tracking
- Renewal reminders
- Query: “When does my passport expire?”

---

## 3.2 Property & Home
- Mortgage / Rent
- Council Tax
- Gas / Electricity / Water
- Broadband / TV Licence
- Home Insurance (Buildings / Contents)
- Maintenance items (boiler service, EPC, gas safety)
- Home assets inventory
    - Appliances
    - Warranties
    - Service history

---

## 3.3 Vehicle Management
- Car Insurance history
- MOT
- Road Tax
- PCP / HP / Lease
- Breakdown cover
- Service history
- Repairs
- Warranty tracking
- Spend history

---

## 3.4 Insurance & Protection
- Life Insurance
- Critical Illness
- Income Protection
- Travel Insurance
- Health/Dental
- Pet Insurance
- Renewal reminders
- Claim history (future)

---

## 3.5 Banking & Credit
- Bank accounts
- Credit cards (limit, APR, statement date)
- Loans (personal/car)
- Mortgage links
- Masked sensitive display
- Credit reminders (future)

---

## 3.6 Subscriptions & Lifestyle
- Mobile contracts
- Streaming services
- Gym memberships
- Kids activities (future)
- Price rise alerts (future)
- Unused detection (future)

---

## 3.7 Documents Hub (Core Differentiator)
- Store contracts, policies, invoices
- Attach files to records
- Categorised by domain
- Tagging & metadata
- Timeline view (future)

---

## 3.8 Tasks & Reminders
- User-created tasks
- System-generated renewal tasks
- Expiry alerts
- Filters: Today / Upcoming / Overdue / Completed
- Home dashboard summary

---

## 3.9 Query System (Deterministic First)
- Text queries:
    - “When does my passport expire?”
    - “Show upcoming renewals”
    - “List my insurance policies”
- Intent parsing via rules
- No hallucination

---

## 3.10 Reports
- Monthly spending summary
- Insurance cost history
- Mortgage overview
- Category-level reports
- Exportable summaries (future)

---

## 3.11 Scan & OCR
- Scan/upload document
- On-device OCR
- Extract key fields
- Review & confirm required
- Store raw OCR + structured fields

---

## 3.12 Voice
- On-device speech-to-text
- Deterministic query execution
- Privacy messaging

---

## 3.13 Open Banking (Optional Module)
- UK-first
- Secure token handling
- Minimal data retention
- Derived summaries stored locally
- Fully optional

---

# 4. UI/UX Principles

- Premium, calm, professional feel
- Layered surfaces (background → surface → card)
- No flat white screens
- Light + Dark mode
- Multiple premium theme variants
- Customizable background styles (solid + gradient)
- Clear empty states
- Privacy reassurance messaging
- Accessibility-first

---

# 5. Future (Phase 2+)

- Receipt line-item parsing
- Smart AI summaries
- Solar/energy optimisation
- Property portfolio
- Net worth dashboard
- Multi-country support
