---
name: refresh-pi-models
description: Discover, update, remove, or add models at configured Pi providers; refresh existing model metadata or optionally verify inference. Ask which actions to run unless the prompt specifies them, then obtain per-model approval for changes.
compatibility: Requires HTTP/JSON tooling and Bash; gum is optional for interactive selection. Optional runtime validation and inference tests require the installed Pi SDK.
---

# Refresh Pi models

The target is **`~/.pi/agent/models.json`**, not a repository-relative copy.
Preserve provider settings and unselected entries; do not edit other
configuration, or commit changes. Use a fresh run directory under project-local
`tmp/pi-model-refresh/` for snapshots, discovery, selections, and evidence.
Read `references/providers.md` for routes, evidence precedence, and field mappings.

## 0. Choose the actions first

Unless the invocation explicitly states which actions to execute, **ask before
provider requests, inference, or edits**, list every option below, and wait:

> Which actions should I run? You can combine them and restrict providers/models.
> 1. **Inspect/audit only:** discover available models and metadata, validate, and report; no configuration changes.
> 2. **Update versions:** propose newer versions of existing models and fetch metadata for approved replacements.
> 3. **Remove models:** propose removing absent or explicitly inactive models.
> 4. **Add models:** propose available models not already configured and fetch metadata for approved additions.
> 5. **Refresh metadata:** update limits, capabilities, reasoning levels, and price estimates without changing model IDs.
> 6. **Verify inference:** run small streaming/tool/reasoning tests, and vision tests where relevant; these may incur charges.
> 7. **Validate only:** check the current configuration locally; no provider or inference requests and no edits.
> 8. **Cancel / do nothing.**

Options 1, 7, and 8 are standalone; options 2–6 can be combined. Clarify
conflicting choices rather than assuming that a read-only request permits edits.

A bare skill invocation or vague "refresh/update my models" requires this menu.
An explicit request such as "refresh metadata only for FhGenie" or "add new
models, do not remove anything" establishes the action scope; do not ask again.
Do not enable unspecified actions. Broad "do everything" still needs confirmation
that paid inference is intended unless the user explicitly authorized it.

Action choice is **not per-model edit approval**: keep the checklist below.
Validation and reporting accompany executed actions. Validate-only skips discovery;
inspect-only produces findings without edits. Verification-only also leaves the
configuration untouched, even if tests suggest corrections.

## 1. Discover

Snapshot the target before changes. Query available models for **each configured
provider in scope**, using metadata requests appropriate to the chosen actions.
Never introduce a new provider. Resolve credentials without exposing them in logs
or artifacts. Discovery is read-only; sanitize saved responses with an allowlist.
For metadata-only work, preserve the complete model list and ordering.

A failed, forbidden, or incomplete response is not evidence of discontinued
support. Flag discovery gaps instead of proposing removals from those responses.

## 2. Select and apply changes

For chosen mutation actions, present one combined interactive checklist across
providers, grouped or labeled. Include only the requested action categories:

- **Update:** replace an existing family member with a newer active version,
  e.g. `GPT-5.6-Sol → GPT-6.1-Sol`. Preserve variant, size, and quantization;
  compare numeric versions and ask about ambiguous successors.
- **Remove:** a configured model is absent from a successfully retrieved complete
  catalog, or explicitly inactive. Describe absence as such, not confirmed retirement.
- **Add:** an active endpoint model is not configured and is not already offered
  as an update target. Do not silently hide new families or variants. Flag models
  unsuitable for the configured Pi API rather than adding them as chat models.
- **Refresh metadata:** keep the existing ID and refresh only supported metadata.
  Show changed fields and sources when known; otherwise mark it as a metadata
  fetch whose resulting differences will be reported.

Every action is **unselected by default**. Each item shows provider and exact IDs.
If an update replaces a missing model, offer that update instead of a redundant
removal, and do not also offer a refresh of the replaced entry. Choices for
different providers are independent. Approval to add/update a model includes
fetching its metadata; refreshing other existing models requires their selection.

Save a manifest mapping opaque `candidate-NNN` keys to actions and exact IDs.
Write `key<TAB>label` rows to a fresh `actions.tsv`; labels must contain no tabs,
newlines, or control characters. Run the bundled picker:

```bash
bash <skill-dir>/scripts/select-candidates.sh <run-dir>/actions.tsv <run-dir>/selected.txt
```

Use an interactive terminal facility. If the agent has no TTY, give the user a
copyable command with absolute paths and wait for them to finish. If gum is
unavailable, ask for selections from the same complete numbered list in chat.
Skip the picker when there are no actions.

Apply only confirmed selections from this run's manifest. Cancellation or a
missing output file grants no approval; a successfully saved empty selection
means no changes. Update names alongside IDs, preserve unrelated settings, and
reassess model-specific overrides rather than carrying obsolete values forward.

## 3. Fetch and apply metadata

After approved ID changes, **query endpoints again** for selected added/updated
models; fetch current metadata for selected refreshes too. Removed and unselected
models need no metadata refresh. Consult the installed Pi schema and fill fields
with reliable evidence: limits, modalities, reasoning levels, pricing/tiers,
input limits, and caching. Compatibility overrides require verified protocol
behavior, not generic capability flags.

Use the evidence hierarchy in `references/providers.md`. Matching LiteLLM
metadata may fill FhGenie gaps even if that ID is unselected under LiteLLM; this
read does not authorize edits to the LiteLLM entry. Record endpoint, inherited,
and catalog-fallback sources separately, and report conflicts.

Do not guess missing values, interpret absent/null capabilities as false, or
invent zero prices. If retrieval fails, keep approved ID changes but do not erase
existing metadata merely because a response omitted it. Reassess old overrides
for replaced models rather than assuming they apply to the successor. For gaps,
report the **effective defaults of the installed Pi version**, especially that
zero displayed estimated cost does not establish free service.

## 4. Optional inference verification

Only run inference when explicitly authorized, including its possible charges.
Read `references/verification.md` first. Limit targets to the approved verification
scope and use bounded, small tests; verification is not a prerequisite for normal
read-only discovery or metadata refresh. Never execute filesystem/network tools
at the model's request. Findings may change only metadata already approved for
add/update/refresh; otherwise report proposed corrections without applying them.

## 5. Validate and report

Validate JSON and the installed Pi schema when available. Also load the target
through Pi's model runtime when available, without loading agent extensions,
executing tools, or issuing inference. Report skipped/unavailable validation.
Check duplicate IDs, preserved provider settings and unselected entries, and
field-level agreement with cited evidence. For metadata-only work, verify IDs
and ordering are unchanged. Check for concurrent target edits before writing;
reconcile rather than overwriting someone else's changes.

Save a sanitized before/after table of changed fields with sources and fallback
status. Summarize approved updates/removals/additions/refreshes, effective defaults,
validation, any authorized test results, and unresolved external blockers. Do not
claim catalog presence, HTTP 200, estimated prices, or one smoke test establish
working deployment behavior, verified billing, maximum budgets, or general
reliability.
