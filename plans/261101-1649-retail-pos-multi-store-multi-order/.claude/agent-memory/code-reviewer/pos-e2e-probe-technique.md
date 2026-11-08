---
name: pos-e2e-probe-technique
description: How to run modified copies of apps/pos Playwright specs during read-only reviews without touching repo files
metadata:
  type: reference
---

Read-only reviews forbid editing files, but POS e2e mocks often hide defects (e.g. instant mocked responses masked a blank first print).
Probe approach: copy the spec into the session scratchpad `probe/e2e/`, copy `apps/pos/playwright.config.ts` with `cwd: 'D:/Work/parkviet/parkviet/apps/pos'` added to `webServer`, junction `probe/node_modules` -> `apps/pos/node_modules` (`cmd //c mklink /J`), then run `node node_modules/@playwright/test/cli.js test -c playwright.config.ts` from the probe dir with the port the caller allowed (5178; never 5174-5177).
**Why:** adding latency to a mock or emulating print media found real defects the shipped specs passed.
**How to apply:** use for any POS UI timing/print claim; write patch scripts with the Write tool (Bash heredocs containing quotes fail in this environment).
