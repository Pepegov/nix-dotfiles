---
name: github-issue-creator
description: Create or update GitHub Issues through GitHub MCP when a user asks to capture a product, design, bug, or engineering task. Use for GitHub only, not GitLab.
---

# GitHub Issue Creator

Create concise, decision-complete GitHub issues without changing the repository unless the user separately requests repository changes.

## Workflow

1. Identify the target repository from an explicit user reference or `git remote -v`. Confirm only if neither identifies one repository.
2. Call `mcp__github__get_me` before any write. For organization-owned repositories, call `mcp__github__list_issue_types`; omit an issue type when it is unsupported.
3. Search for duplicates with `mcp__github__search_issues`. Use the repository qualifier and the core feature terms. If a likely duplicate exists, show it and ask whether to update it instead of creating another issue.
4. Extract the requested outcome, scope, explicit exclusions, user-visible behavior, data or architecture constraints, and acceptance criteria. Inspect the relevant repository files when they clarify the issue, but do not invent implementation details.
5. Create the issue through `mcp__github__issue_write` only after its title and body are decision-complete. Do not assign labels, milestones, assignees, parents, or issue fields unless the user explicitly requests them or the repository convention is known.
6. Return the issue URL and number.

## Issue body

Use only sections that add information:

```markdown
## Goal

## Scope

## Requirements

## Constraints

## Acceptance criteria
```

- State the affected page, module, or flow explicitly. Do not use a generic screen name when the request targets a contextual panel or a specific page.
- Separate in-scope and out-of-scope surfaces when that prevents a likely implementation mistake.
- Keep product requirements distinct from implementation constraints.
- Write acceptance criteria that a reviewer can verify.

## Designs and images

- A screenshot or generated mockup can be used as design evidence. Describe the relevant UI areas in the issue body even when an image is attached.
- `mcp__github__issue_write` supports issue text, not binary image attachments. Do not claim an image was attached unless it is visible in the resulting GitHub issue.
- Do not create a repository file or remote commit solely to host an image unless the user explicitly authorizes that repository change.
- If no supported authenticated attachment path is available, add the textual design requirements and tell the user exactly why the image could not be embedded. Do not add a broken or private link.

## Updates

When a user corrects the issue scope or requirements, update the existing issue with `mcp__github__issue_write` using `method: "update"` and the issue number. Preserve correct existing content and ensure the title matches the corrected scope.

## Safety

- Creating and updating issues changes remote state. Perform only the requested issue operation.
- Never close an issue without an explicit state reason.
- Never create commits, branches, pull requests, labels, projects, or repository files as an incidental part of issue creation.
