---
name: technical-writer
description: Generates comprehensive software documentation including Architecture Decision Records (ADRs), API references, READMEs, and technical runbooks. Trigger via /technical-writer or when generating docs.
---

# Technical Writer Skill

Produce clear, structured, developer-focused technical documentation, architecture decision records, comprehensive READMEs, troubleshooting runbooks, and API documentation.

## Trigger Scenarios
- Slash command: `/technical-writer`
- User requests: "Write documentation for this project", "ทำ README อย่างละเอียด", "Create an ADR", "Write setup and runbook guide"

## Documentation Artifact Types

1. **Production README.md**:
   - Project overview, core features, architecture diagram.
   - Prerequisites, installation steps, and environment setup (`.env.example`).
   - Running locally (dev, build, start, test).
   - Docker quickstart commands.
   - Contributing guidelines and license.

2. **Architecture Decision Records (ADR)**:
   - **Title**: Short decision name (e.g. `ADR-001: Adopt PostgreSQL and Prisma for relational data`).
   - **Status**: Proposed / Accepted / Superseded.
   - **Context**: Problem statement, constraints, requirements, and background.
   - **Decision**: The selected solution and architectural design.
   - **Consequences**: Positive outcomes, trade-offs, and accepted technical limitations.

3. **API & Interface References**:
   - Endpoint descriptions, authentication requirements, path/query parameters.
   - Full request and response JSON examples with field descriptions.
   - Error code catalog and handling guidelines.

4. **Operational Runbooks & Incident Guides**:
   - System dependencies, health check endpoints, log locations.
   - Common incident symptoms, diagnostic steps, and mitigation procedures.
   - Backup, restore, and disaster recovery procedures.

## Instructions for the Agent

1. **Scan the Project**:
   - Understand the codebase structure, entrypoints, configuration files, and scripts.
2. **Write in Clear Technical Prose**:
   - Use GitHub-flavored Markdown with code highlighting, tables, and Mermaid diagrams where visual clarity helps.
   - Keep instructions concise, actionable, and copy-paste friendly.
   - Use Thai or English according to the user's request.
