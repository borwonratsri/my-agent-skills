---
name: refactoring-clean-code
description: Refactors complex, tightly-coupled, or legacy code into clean, modular, SOLID-compliant code without breaking existing functionality. Trigger via /refactoring-clean-code or when cleaning up code.
---

# Refactoring & Clean Code Skill

Transform bloated, complex, hard-to-read, or legacy code into clean, elegant, modular, and maintainable software while preserving exact external behavior and backwards compatibility.

## Trigger Scenarios
- Slash command: `/refactoring-clean-code`
- User requests: "Refactor this function", "Clean up this messy file", "แก้โค้ดให้อ่านง่ายขึ้น", "Reduce cyclomatic complexity"

## Refactoring Targets & Techniques

1. **Code Smells to Eliminate**:
   - **Long Method / God Object**: Decompose into small, focused, single-purpose functions.
   - **Deep Nesting (Pyramid of Doom)**: Use Guard Clauses, early returns, and pattern matching.
   - **Duplicated Logic (DRY)**: Extract reusable helper utilities and abstractions.
   - **Feature Envy**: Move logic closer to the data it operates on.
   - **Magic Numbers & Strings**: Replace with named constants, enums, or configuration objects.
   - **Primitive Obsession**: Wrap primitive combinations into domain value objects or types.

2. **SOLID & Clean Architecture**:
   - **Single Responsibility (SRP)**: Each module or function has only one reason to change.
   - **Open/Closed (OCP)**: Extend behavior through polymorphism, composition, or strategy pattern rather than modifying core logic.
   - **Dependency Inversion (DIP)**: Depend on abstractions/interfaces rather than concrete implementations.
   - **Composition over Inheritance**: Favor lightweight composed objects over deep class hierarchies.

3. **Safe Refactoring Workflow**:
   - Ensure existing tests pass before touching code.
   - Make small, incremental transformations.
   - Re-run tests after each transformation to verify zero regressions.

## Instructions for the Agent

1. **Analyze Current Complexity**:
   - Read the file using `view_file`. Identify code smells, cognitive complexity, and responsibilities.
2. **Execute Clean Refactoring**:
   - Use clean, modern language idioms (e.g. optional chaining, destructuring, immutability, pattern matching).
   - Maintain descriptive, intention-revealing names for variables, types, and functions.
   - Preserve all existing public API interfaces, parameter signatures, and return values so callers never break.
3. **Present Diff & Explanation**:
   - Show the clean before-and-after comparison.
   - Highlight the specific architectural improvements made.
