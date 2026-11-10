---
name: api-architect
description: Designs production-grade RESTful APIs, OpenAPI 3.0/Swagger specifications, GraphQL schemas, and gRPC definitions with strict error handling. Trigger via /api-architect or when designing APIs.
---

# API Architect Skill

Architect, design, and specify robust, scalable, developer-friendly APIs adhering to RESTful standards, OpenAPI 3.0, GraphQL, or gRPC specifications.

## Trigger Scenarios
- Slash command: `/api-architect`
- User requests: "Design API for authentication", "ออกแบบ REST API", "Write OpenAPI spec", "Design GraphQL schema"

## API Design Standards

1. **RESTful Resource Modeling**:
   - Nouns for resources, plural form: `/api/v1/users`, `/api/v1/orders/{orderId}/items`.
   - Standard HTTP Methods: `GET` (safe, idempotent), `POST` (create), `PUT` (replace, idempotent), `PATCH` (partial update), `DELETE` (remove, idempotent).
   - Appropriate HTTP Status Codes:
     - `200 OK`, `201 Created`, `204 No Content`
     - `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`, `422 Unprocessable Entity`, `429 Too Many Requests`
     - `500 Internal Server Error`, `502 Bad Gateway`, `503 Service Unavailable`

2. **Predictable Request & Response Envelopes**:
   - Consistent JSON naming convention (camelCase or snake_case, consistent across project).
   - Standardized Error Response Structure (RFC 7807 Problem Details):
     ```json
     {
       "error": {
         "code": "INVALID_INPUT",
         "message": "Human readable summary",
         "details": [{"field": "email", "issue": "Invalid format"}]
       }
     }
     ```
   - Pagination: Cursor-based pagination (`limit`, `cursor`, `nextCursor`) for large datasets, or offset pagination (`page`, `pageSize`, `totalCount`).
   - Idempotency Keys (`Idempotency-Key` header) for critical state-changing actions (payments, checkout).

3. **Versioning & Security**:
   - URI versioning (`/api/v1/...`).
   - Rate limiting headers (`RateLimit-Limit`, `RateLimit-Remaining`).
   - Authorization headers (`Authorization: Bearer <token>`).

## Instructions for the Agent

1. **Define API Contracts**:
   - Provide OpenAPI 3.0 YAML/JSON specification, TypeScript DTO definitions, or GraphQL schemas.
   - Include realistic request bodies, headers, and responses for both success and error cases.
2. **Review Client Ergonomics**:
   - Ensure the API requires minimal round-trips for common user flows.
   - Include sample `curl` requests or frontend fetch examples.
