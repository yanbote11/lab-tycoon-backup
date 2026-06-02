# AI Rules

Before making changes:

1. Read all AI documentation files.
2. Connect to Roblox Studio MCP.
3. Inspect current project structure.
4. Summarize findings.
5. Wait for approval before major edits.

---

## Do Not

- Rewrite large systems
- Replace working systems
- Add unnecessary polling loops
- Add unnecessary RenderStepped loops
- Rebuild large UI lists repeatedly
- Change save data schema without approval

---

## Performance First

Prioritize:

- FPS
- Memory usage
- Mobile performance

Prefer:

- Event-driven systems
- Incremental updates

Avoid:

- Constant updates
- Full refreshes
- Excessive animations

---

## Development Style

Make small changes.

Explain changes before implementing.

Preserve working functionality.
