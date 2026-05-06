# General Conventions

---

## Context Management

- Run `/compact` mid-task when finishing a major phase (e.g., after research, before implementation).
- Run `/clear` when switching to a new, unrelated task.
- Avoid spawning subagents for single-step lookups (one file read, one grep). Use direct tools (`Read`, `Bash`) instead. Reserve agents for genuinely multi-step or parallelizable work.

---

## Keeping CLAUDE.md Up to Date

After completing any code change, ask: **"Should any of this be documented in CLAUDE.md?"**

Suggest an update whenever a change involves:
- New or modified data structures, persistence formats, or file layouts
- New modules, clients, or architectural patterns
- New conventions that differ from or extend what's already documented
- Non-obvious decisions or constraints that would help future work
