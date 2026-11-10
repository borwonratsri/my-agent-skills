---
name: schema-mapping
description: Guides the process of analyzing, mapping, and documenting transformations between different data schemas, models, database tables, and API payloads.
---

# Schema Mapping & Data Transformation Skill

Analyze, design, and implement field-level data transformations between disparate data models (Source Schema to Target Schema), supporting JSON/REST payloads, database records, CSV/XML formats, and third-party API integrations.

## Trigger Scenarios
- Slash command: `/schema-mapping`
- User requests: "Map this schema to our target API", "ทำ Data Mapping ระหว่าง 2 ระบบ", "Transform source JSON to target schema", "Write schema mapping specification"

## Core Mapping Methodology

1. **Schema Ingestion & Structure Discovery**:
   - Inspect Source Schema: Field names, data types, nullability, nested arrays/objects, formats (e.g. ISO-8601 vs epoch).
   - Inspect Target Schema: Destination contracts, required validation constraints, default values.

2. **Field-Level Mapping Rules**:
   - **Direct (1:1)**: Simple copy with identical semantics (e.g. `source.email -> target.user_email`).
   - **Transformational (Formula / Lookup)**:
     - Date/Time conversions (e.g. `YYYY-MM-DD` to `DD/MM/YYYY` or epoch ms).
     - String formatting (e.g. concatenation `first_name + " " + last_name -> fullName`, trimming, uppercase).
     - Enumeration / Code mapping (e.g. `1 -> "ACTIVE"`, `0 -> "INACTIVE"`).
   - **Aggregation (N:1)**: Summing line items, calculating totals, or flattening nested objects.
   - **Splitting (1:N)**: Decomposing compound strings (e.g. `address_line` into street, district, province, postal code).

3. **Edge Case & Validation Handling**:
   - Null and undefined handling: Coalescing (`?? defaultValue`), optional chaining.
   - Type coercion safety: Parsing numbers (`parseInt`, `parseFloat`), booleans (`"true"` vs `true`).
   - Boundary checks and validation error logging.

## Instructions for the Agent
1. Output a clear **Markdown Mapping Matrix**:
   | Source Field | Source Type | Target Field | Target Type | Transformation Rule / Logic | Notes |
2. Provide executable conversion code:
   - TypeScript/JavaScript transformer function, Python dictionary transformation, or JSONata expression.
3. Include unit tests asserting correct output across standard and edge-case test payloads.
