# MySmartAdmin – Execution Phases

---

# Phase 0 – Governance

0.1 CURSOR_RULES.md  
0.2 PROMPT_TEMPLATE.md  
0.3 DEFINITION_OF_DONE.md  
0.4 UI_STYLE_GUIDE.md

---

# Phase 1 – App Foundation

B1 – Flutter baseline  
B2 – Folder structure  
B3 – Routing (5 tabs + Settings)

---

# Phase 2 – UI System

B4 – Design tokens + components  
B4.1 – Dynamic light/dark theme  
B4.2 – Premium theme variants  
B4.2.1 – Dynamic background styles  
B4.3 – UI consistency & depth polish  
B5 – UX microcopy + accessibility polish

Freeze UI before moving to data.

---

# Phase 3 – Information Architecture

B6 – Taxonomy (domains/categories/doc types)  
B7 – Documents entry UX (manual vs scan)

No DB yet.

---

# Phase 4 – Data Foundation

B8 – Drift SQLite schema
- documents
- extracted_fields
- tasks
- alerts

B9 – Domain models + repositories

---

# Phase 5 – Core MVP Features

B10 – Manual entry framework  
B11 – Passport CRUD  
B12 – Driving Licence CRUD  
B13 – Insurance CRUD  
B14 – Mortgage CRUD  
B15 – Credit cards & bank accounts CRUD

B16 – Home dashboard wiring  
B16.1 – TaskBoard module

---

# Phase 6 – Query & Reports

B17 – Deterministic query engine  
B17.1 – Reports foundation

---

# Phase 7 – Secure Files & OCR

B19 – Encrypted file store  
B20 – OCR + extraction + review

---

# Phase 8 – Voice

B18 – Voice-to-text input

---

# Phase 9 – AI Enhancements

Local AI summarisation  
Improved extraction  
Smart reminders

---

# Phase 10 – Open Banking

Secure integration  
Minimal data storage  
Derived summaries only

---

# Rule

Never move to next phase unless:
- flutter run works
- dart analyze clean
- commit completed
- UI remains consistent
