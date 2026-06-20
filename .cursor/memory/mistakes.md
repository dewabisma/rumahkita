# Project Memory — Mistakes & Corrections

Persistent lessons from user corrections. All agents must read this before feature work and must not repeat listed mistakes.

## Entry format

When appending, use the next `MEM-###` ID and this structure:

```markdown
### MEM-001 — YYYY-MM-DD
- **Category:** e.g. state-management, navigation, styling, workflow
- **Mistake:** What the agent did wrong (one sentence)
- **Do instead:** The correct behavior or pattern
- **Context:** When this applies (feature type, file, stack area)
- **Source:** user | review-loop
```

## Entries

<!-- New entries are appended below. Do not delete past entries unless the user asks. -->

### MEM-001 — 2026-06-19
- **Category:** architecture, state-management, workflow
- **Mistake:** Over-engineered wiring (manual service locator, ChangeNotifier coordinators, heavy layering) when a simpler approach would do.
- **Do instead:** Prefer the simplest solution that works. Use **Riverpod** for dependency injection and app state instead of manual `service_locator.dart` / `ChangeNotifier` glue. Keep layers only where they earn their keep — don't force complicated architecture for its own sake.
- **Context:** All new feature work, refactors, and orchestration prompts; especially connecting UI to data/sync/services.
- **Source:** user

### MEM-002 — 2026-06-20
- **Category:** navigation
- **Mistake:** Navigation left users trapped on screens — e.g. lobby during drafting with no way back to ceremony after `context.go('/lobby')` wiped the stack, or `showBack: true` with no `backFallback` when `canPop()` is false.
- **Do instead:** Never trap users. Use `push`/`pop` to preserve stack where back should work; use `pushReplacement` only when the prior screen should be discarded. Every screen must have a clear exit: back button (`canPop` or `backFallback`), or a forward action to the next valid destination. Bidirectional flows (lobby ↔ ceremony) need buttons both ways. After actions that change phase (e.g. start ceremony), navigate to the appropriate screen.
- **Context:** GoRouter routes, onboarding/ceremony/home flows, `OnboardingScaffold`, any new screen.
- **Source:** user
