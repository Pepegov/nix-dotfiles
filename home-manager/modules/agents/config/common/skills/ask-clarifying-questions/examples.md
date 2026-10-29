# Examples: Ask Clarifying Questions

## Example 1: Correct usage (underspecified request)

User:
"Refactor this Livewire component to be cleaner."

Correct response:
"Before I start, I need to clarify a few things:

1) Scope?
   a) Minimal refactor, keep behaviour identical (recommended)
   b) Improve structure even if internals change
   c) Not sure - use default

2) Target versions?
   a) Current project defaults (recommended)
   b) Must remain compatible with older Laravel / Livewire versions

Reply with: defaults (or e.g. 1a 2a)"

Why this is correct:

- The request is ambiguous
- Questions eliminate major branches of work
- Defaults are clearly offered
- Easy, compact reply format

---

## Example 2: Incorrect usage (over-questioning)

User:
"Add pagination to this table."

Incorrect response:
"Asking about UI preferences, colour themes, testing strategy, performance budgets, and future extensibility."

Why this is wrong:

- Task is standard and well-defined
- Reasonable defaults exist
- Over-questioning slows delivery without reducing risk

---

## Example 3: Proceeding with assumptions (explicit approval)

User:
"Go ahead and make reasonable assumptions."

Correct response:
"I will proceed with these assumptions:

1) Minimal change only
2) Follow existing Flux UI and Tailwind patterns
3) Target current Laravel and Livewire versions
4) Add or update tests only if behaviour changes

If this looks good, I will proceed."

(Wait for confirmation before coding)
