---
trigger: model_decision
description: Apply when designing or modifying databases, SQL queries, migrations, Supabase, Postgres, Firebase/Firestore security rules, or REST/GraphQL/gRPC APIs.
---

# Database, Supabase, Firebase & Backend API Rules

When working on database schemas, queries, migrations, authentication, or backend APIs:

1. **Cloud Firestore Security Rules (`firestore.rules`)**:
   - **MANDATORY**: Whenever creating, authoring, or modifying `firestore.rules`, always delegate to the `firestore-rules-author` subagent rather than editing `firestore.rules` directly in the main agent.

2. **Supabase & PostgreSQL Best Practices**:
   - Before creating/altering tables, writing SQL migrations, configuring Row-Level Security (RLS), adding indexes, or debugging slow queries in Postgres or Supabase, read and follow:
     - `~/.gemini/config/plugins/supabase/skills/supabase-postgres-best-practices/SKILL.md`
     - `~/.gemini/config/plugins/supabase/skills/supabase/SKILL.md`
   - Ensure every table in `public` has RLS enabled with tested policies, and foreign keys/filter columns are properly indexed.

3. **Schema Design, Mapping & API Architecture**:
   - For relational/NoSQL schema normalization, indexing strategy, and migration planning, consult `~/.gemini/config/skills/database-architect/SKILL.md`.
   - When transforming or mapping payloads between database models and APIs, consult `~/.gemini/config/skills/schema-mapping/SKILL.md`.
   - When designing RESTful endpoints, OpenAPI specs, GraphQL schemas, or gRPC contracts, follow `~/.gemini/config/skills/api-architect/SKILL.md`.

4. **Strict Data Safety Gate**:
   - Follow `~/.gemini/config/skills/accidental-data-loss-prevention/SKILL.md`. Never run destructive SQL (`DROP`, `TRUNCATE`, broad `DELETE`) or destructive migration resets without explicit user approval.
