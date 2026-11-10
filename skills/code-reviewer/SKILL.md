---
name: code-reviewer
description: Conducts deep, rigorous, multi-dimensional code reviews for correctness, security, performance, clean architecture, and maintainability. Trigger via /code-reviewer or when asking for a code review.
---

# Code Reviewer Skill

Perform a thorough, expert-level code review on local files, diffs, git branches, or proposed pull requests.

## Trigger Scenarios
- Slash command: `/code-reviewer`
- User requests: "Review this code", "รีวิวโค้ดให้หน่อย", "ตรวจโค้ดนี้มีปัญหาอะไรไหม", "Check pull request diff"

## Review Dimensions

1. **Correctness & Logic Flaws**
   - Off-by-one errors, infinite loops, unhandled edge cases, null/undefined dereferences.
   - Race conditions, concurrency issues, async/await misuses, unhandled Promise rejections.
   - Type safety issues and improper type assertions.

2. **Security & Vulnerabilities**
   - Injection vulnerabilities (SQLi, XSS, Command Injection, SSRF).
   - Authentication, authorization, and permission bypasses.
   - Secret leaks (API keys, passwords, tokens hardcoded in source).
   - Insecure deserialization, path traversal, or weak cryptography.

3. **Performance & Scalability**
   - Unnecessary O(N^2) algorithms, N+1 query patterns, memory leaks.
   - Missing database indexes or redundant network roundtrips.
   - Excessive DOM re-renders or missing memoization in frontend frameworks.

4. **Architecture & Clean Code**
   - SOLID principles, Separation of Concerns, Single Responsibility.
   - Duplicated logic (DRY), magic numbers/strings, poor naming.
   - Error handling consistency and observability (logging, metrics).

## Instructions for the Agent

1. **Analyze Context**:
   - Inspect the modified files using file tools (`view_file`, `git diff`, etc.).
   - Understand the system architecture and the developer's intent.

2. **Structure the Review Output**:
   Format the review into clear, actionable sections:
   - **Executive Summary**: Brief 2-3 sentence overview of overall quality and readiness.
   - **Critical Issues (Blockers)**: Bugs, security risks, or data-loss dangers that MUST be fixed before merge.
   - **Improvements & Suggestions**: Architectural, performance, or readability suggestions.
   - **Positive Highlights**: Good design choices, clean idioms, or robust tests found.
   - **Actionable Code Diffs**: Show before/after code snippets demonstrating exact fixes.

3. **Language Matching**:
   Respond in Thai or English matching the user's inquiry language, with English technical terms preserved.
