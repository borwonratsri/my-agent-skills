---
name: security-auditor
description: Audits codebases for security vulnerabilities, OWASP Top 10 flaws, hardcoded credentials, insecure dependencies, and injection risks. Trigger via /security-auditor or when asking for a security audit.
---

# Security Auditor Skill

Perform in-depth security assessments and vulnerability scans on source code, configurations, infrastructure files, and dependencies based on OWASP Top 10, CWE, and NIST standards.

## Trigger Scenarios
- Slash command: `/security-auditor`
- User requests: "Audit security of this project", "ตรวจช่องโหว่ความปลอดภัย", "Check for secret leaks", "OWASP top 10 review"

## Core Audit Checklists

1. **Injection & Input Validation (A03:2021)**:
   - SQL Injection (raw queries, string interpolation vs parameterized queries).
   - Cross-Site Scripting (XSS) (dangerous HTML sinks like `dangerouslySetInnerHTML`, `innerHTML`, unescaped template tags).
   - Command Injection (`child_process.exec`, `os.system` with untrusted inputs).
   - SSRF (Server-Side Request Forgery) in outbound fetch/HTTP requests.
   - Path Traversal (`../../` in file read/write operations).

2. **Broken Authentication & Access Control (A01:2021 & A07:2021)**:
   - Missing authentication middleware on private routes.
   - Broken Object Level Authorization (BOLA / IDOR): Can user A view/edit user B's resources by changing `id` in URL?
   - Weak JWT verification (ignoring algorithm, expired tokens, missing signature check).
   - Insecure Session Cookies (missing `HttpOnly`, `Secure`, `SameSite=Strict/Lax`).

3. **Cryptographic & Secret Failures (A02:2021)**:
   - Hardcoded API keys, JWT secrets, private keys, database passwords in git.
   - Weak hashing algorithms (MD5, SHA1 for passwords instead of bcrypt, argon2, or PBKDF2).
   - Hardcoded random number generators (`Math.random()` used for cryptographic tokens instead of `crypto.randomBytes()`).

4. **Security Misconfiguration & Dependency Risks (A05:2021 & A06:2021)**:
   - CORS misconfiguration (`Access-Control-Allow-Origin: *` with credentials).
   - Leaking stack traces or internal server errors to clients in production.
   - Outdated dependencies with known CVEs (`npm audit`, `pip-audit`, `snyk`).

## Instructions for the Agent

1. **Perform Static Analysis**:
   - Inspect source code, environment files, router handlers, and configuration.
2. **Generate Severity-Ranked Report**:
   - **Critical / High**: Immediate exploit potential, remote code execution, secret leaks, unauthorized data access.
   - **Medium**: Missing rate limiting, improper CORS, clickjacking risks.
   - **Low / Informational**: Best practices, security headers (`Helmet`, CSP, HSTS).
3. **Provide Remediation Diffs**:
   - Give exact before/after code patches showing how to fix each vulnerability securely.
