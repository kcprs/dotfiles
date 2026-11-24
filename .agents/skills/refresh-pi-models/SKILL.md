---
name: refresh-pi-models
description: Discover active models at configured Pi providers, let the user select updates/removals/additions in one interactive checklist, then fetch metadata for approved models.
compatibility: Requires HTTP/JSON tooling, Bash, and gum for interactive selection.
---

# Refresh Pi models

The target is **`~/.pi/agent/models.json`**, not a repository-relative copy.
Preserve provider settings and unselected entries; do not edit other
configuration, or commit changes. Temporary discovery and selection artifacts
may be created under project-local `tmp/pi-model-refresh/`.
Read `references/providers.md` for routes and field mappings.

## 1. Discover

Read the configuration and query currently available, active models for **each
provider already configured**. Resolve its credentials without exposing them
in logs or artifacts. Use read-only requests and sanitize saved responses.

A failed, forbidden, or incomplete response is not evidence of discontinued
support. Flag discovery gaps instead of proposing removals from those responses.

## 2. Select and apply changes

Present one combined interactive checklist across providers, grouped or labeled:

- **Update:** replace an existing family member with a newer active version,
  e.g. `GPT-5.6-Sol → GPT-6.1-Sol`. Preserve variant, size, and quantization;
  compare numeric versions and ask about ambiguous successors.
- **Remove:** a configured model is absent from a successfully retrieved complete
  catalog, or explicitly inactive. Describe absence as such, not confirmed retirement.
- **Add:** an active endpoint model is not configured and is not already offered
  as an update target. Do not silently hide new families or variants. Flag models
  unsuitable for the configured Pi API rather than adding them as chat models.

Every update, removal, and addition is **unselected by default**. Each item shows
provider and exact IDs. If an update replaces a missing model, offer that update
instead of a redundant removal. Choices for different providers are independent.

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

## 3. Fetch metadata and verify

After applying approved changes, **query endpoints again** for the selected
added/updated models. Removed and unselected models need no metadata refresh.
Fill every field supported by the installed Pi models schema for which the
endpoint supplies reliable evidence: token limits, modalities, reasoning levels,
pricing and tiers, input limits, caching, or compatibility where explicitly stated.

FhGenie and LiteLLM models with the **same ID** are assumed to share upstream
model metadata. Fetch matching LiteLLM metadata when FhGenie lacks it, even if
that ID is not selected under LiteLLM. Prefer explicit provider-specific limits;
report conflicts. Copied pricing remains an estimate, not verified billing.

Do not guess missing values, treat absent capabilities as false, or missing
prices as zero. If metadata retrieval fails, keep the approved model change,
leave unsupported fields unset, and report the gap.

Validate JSON and, when tooling is available, the installed Pi schema. Check
for duplicate IDs, unintended edits, and agreement with fetched metadata.
Summarize applied updates/removals/additions and unresolved metadata gaps.
