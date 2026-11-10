---
name: database-architect
description: Designs normalized/denormalized database schemas, writes migration scripts, optimizes indexes, and tunes SQL/NoSQL queries. Trigger via /database-architect or when designing schemas.
---

# Database Architect Skill

Design database schemas, write idempotent migration scripts, formulate indexing strategies, and optimize complex queries for PostgreSQL, MySQL, SQLite, MongoDB, or Redis.

## Trigger Scenarios
- Slash command: `/database-architect`
- User requests: "ออกแบบ database schema", "Design DB for e-commerce", "Optimize this SQL query", "Write Prisma / Drizzle / Flyway migration"

## Architectural Principles

1. **Schema Design & Normalization**:
   - Apply 3NF (Third Normal Form) for relational models to minimize data duplication and anomalies.
   - Purposeful denormalization only for performance bottlenecks with documented trade-offs.
   - Primary Keys: UUIDv7 (time-ordered, index-friendly) or BIGSERIAL/IDENTITY.
   - Foreign Keys with explicit `ON DELETE` / `ON UPDATE` cascades or restrictions.
   - Timestamps: `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`.
   - Soft deletes vs Hard deletes with audit trails.

2. **Indexing Strategy**:
   - B-Tree indexes on foreign keys, search columns, and filter predicates.
   - Composite indexes following the Leftmost Prefix Rule (`WHERE status = ? AND created_at > ?`).
   - Unique constraints on business keys (e.g. `(tenant_id, email)`).
   - Partial/filtered indexes for sparse conditions (e.g. `WHERE deleted_at IS NULL`).

3. **Query Optimization & Safety**:
   - Prevent N+1 queries using joins or batch fetching.
   - Avoid `SELECT *`, fetch only needed columns.
   - Safe migration rules (e.g. adding columns with `NULL` or non-locking defaults in Postgres).

## Instructions for the Agent

1. **Elicit Entity Relationships**: Identify entities, attributes, relationships (1:1, 1:N, N:M), and cardinality.
2. **Produce Deliverables**:
   - Visual Mermaid ER Diagram (`erDiagram`).
   - Production-ready DDL / Migration scripts (SQL, Prisma, Drizzle, or TypeORM).
   - Recommended indexes and explanation of query patterns supported.
   - Sample seed queries or verification queries.
