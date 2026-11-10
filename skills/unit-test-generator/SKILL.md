---
name: unit-test-generator
description: Generates robust, high-coverage unit and integration test suites covering happy paths, edge cases, error conditions, and mocks. Trigger via /unit-test-generator or when asking to write tests.
---

# Unit Test Generator Skill

Generate high-quality, comprehensive test suites for functions, classes, components, or services in any modern programming language (TypeScript, JavaScript, Python, Go, Java, Rust).

## Trigger Scenarios
- Slash command: `/unit-test-generator`
- User requests: "Write unit tests for this", "เขียน test ให้ไฟล์นี้", "เพิ่ม test coverage", "Generate integration tests"

## Testing Principles

1. **Test Pyramid & Scope**:
   - Focus on fast, reliable unit tests with isolated external dependencies.
   - Use integration tests where multiple components interact (e.g. database, HTTP route handlers).
   - Never write fragile tests that test implementation details instead of observable behavior.

2. **Complete Scenario Coverage**:
   - **Happy Path**: Standard valid inputs with expected outputs.
   - **Boundary & Edge Cases**: Empty arrays, 0, negative values, max limits, unicode, leap years, timezone offsets.
   - **Error & Failure Handling**: Network errors, timeouts, invalid schema, throw exceptions, database disconnects.
   - **Security Edge Cases**: Unauthorized inputs, SQL injection strings, oversized payloads.

3. **Modern Framework Standards**:
   - TypeScript/JS: Vitest, Jest, Playwright, React Testing Library.
   - Python: pytest, unittest.mock, hypothesis.
   - Go: `testing` package, testify (`assert`, `require`), gomock.

## Instructions for the Agent

1. **Analyze the Target Code**:
   - Inspect the file and its exports, types, interfaces, and external dependencies.
   - Identify which testing framework is already configured in the project (`package.json`, `pyproject.toml`, etc.).

2. **Generate Tests following AAA Pattern**:
   - **Arrange**: Setup mock state, test fixtures, and inputs.
   - **Act**: Invoke the function or method under test.
   - **Assert**: Verify return values, side effects, and expected mock calls.

3. **Verify Execution**:
   - If test runners are available locally (e.g. `npm test`, `pytest`, `go test`), run them to verify tests pass and report results.
