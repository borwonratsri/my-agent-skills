---
name: chrome-devtools
description: "Master Chrome DevTools MCP skill for web debugging, browser automation, performance optimization (LCP/CWV), memory leak diagnostics, accessibility (a11y) audits, and cookie/session state management."
---

# Chrome DevTools Master Skill & MCP Guide

Comprehensive, all-in-one skill for interacting with, automating, and debugging web applications in Chrome via the Model Context Protocol (MCP).

## When to Use This Skill
- Slash command: `/chrome-devtools`
- User requests: "Debug this website", "ทดสอบหน้าเว็บบนเบราว์เซอร์", "Check Core Web Vitals / LCP", "Inspect cookies and session", "Find memory leaks", "Audit accessibility (a11y)"

---

## ⚙️ MCP Server Configuration

To enable Chrome DevTools tools in your environment, ensure `chrome-devtools-mcp` is registered in your client configuration:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--categoryExtensions", "--memoryDebugging"]
    }
  }
}
```

---

## 🌐 1. Core Browser Automation & Interaction

- **Lifecycle**: Browser starts automatically on the first tool call using a persistent profile.
- **Page Targeting**: Call `list_pages` to get `pageId` (e.g. `pageId: 1`), or use the ID returned by `new_page`.
- **Navigation & Inspection**:
  1. `navigate_page`: Load target URL.
  2. `take_snapshot`: Get full DOM accessibility tree with element `uid`s (faster and more robust than raw screenshots).
  3. `click` / `fill`: Interact with elements using their `uid`.
  4. `take_screenshot`: Capture visual state for user verification.
  5. `evaluate_script`: Run JavaScript directly inside page context for custom inspection.

---

## ⚡ 2. Performance & Core Web Vitals (LCP)

- **Identify LCP Element**: Locate the largest visual element in the viewport (hero image, heading, video poster).
- **Sub-part Breakdown**:
  - **TTFB (Time to First Byte)**: Server response and redirect latency.
  - **Resource Load Delay**: Time between TTFB and when the browser starts fetching the LCP resource (optimize via `<link rel="preload" as="image">`).
  - **Resource Load Duration**: Image/asset transfer time (optimize via WebP/AVIF, responsive `srcset`, CDN caching).
  - **Element Render Delay**: Time from asset download finish until pixel painting (eliminate render-blocking CSS/JS).

---

## ♿ 3. Accessibility (a11y) Auditing

- Inspect DOM snapshots for proper semantic HTML landmarks (`<main>`, `<nav>`, `<header>`).
- Verify keyboard focus states (`outline`, `tabindex`, skip links).
- Audit color contrast ratios (WCAG AA: minimum 4.5:1 for normal text, 3:1 for large text).
- Check ARIA attributes: Ensure `aria-label`, `aria-expanded`, and `aria-hidden` are used correctly without breaking screen readers.

---

## 🍪 4. Cookies, Session State & Security Headers

- Diagnose 401/403 authentication redirects and session expiration.
- Check security flags: `HttpOnly` (prevent XSS token theft), `Secure` (HTTPS only), and `SameSite=Lax/Strict`.
- Verify Third-Party cookie phaseout readiness and Partitioned Cookie headers (`CHIPS`).

---

## 🧠 5. Memory Leak & Heap Diagnostics

- Capture heap snapshots to compare object counts before and after running repetitive actions.
- Identify detached DOM trees (elements removed from DOM but retained by JS event listeners).
- Spot unbounded closures, uncleaned `setInterval` timers, and global caches.

---

## 🛠️ Instructions for the Agent
1. Determine the specific debugging goal (Navigation, Speed/LCP, Accessibility, Cookies, or Memory).
2. Execute tool calls in logical sequence: `navigate` -> `wait_for` -> `take_snapshot` / `evaluate` -> `interact` -> `report`.
3. Provide actionable, pinpointed code fixes for any issues detected.
