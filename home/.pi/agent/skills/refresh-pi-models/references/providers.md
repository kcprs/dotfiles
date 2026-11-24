# Endpoint reference

Read URLs and credential references from `~/.pi/agent/models.json`. These routes
worked during initial discovery; do not assume they will always be available.

| Provider | Catalog | Metadata | Authentication |
| --- | --- | --- | --- |
| `fhgenie` | Append `/v1/models` to its `/openai` base | `/v1/models/{encoded-id}` | `api-key` |
| `fhgenie-on-prem` | Append `/models` to its `/v1` base | Catalog includes token limits | Bearer token |
| `ame-litellm` | Append `/models` to its `/v1` base | Strip trailing `/v1`, append `/model/info` | Bearer token |

Use bounded timeouts and follow pagination before declaring a catalog complete.
Azure catalogs can include inactive models: inspect status, inference capability,
and lifecycle information. Do not interpret preview status alone as inactive.
LiteLLM `/v2/model/info` previously returned 403; its `/model/info` worked.
Azure metadata may lack limits and capabilities. No inference requests are
needed for discovery; authorized inference verification is a separate action.

OpenAI-style catalogs use `data[].id`. Azure individual-model lookups return a
single object, not necessarily a `data` array. An undated configured alias can
resolve to a dated upstream ID: record that resolution without replacing the
configured ID or treating the alias as absent. Do not infer alias relationships
from similar names alone.

LiteLLM metadata uses `data[].model_name` and `model_info`; the client-visible ID
is `model_name`, not `litellm_params.model`. Report conflicting metadata for
duplicate deployments. An advertised model may still fail inference because its
upstream route is broken; distinguish catalog presence from operational status.

# Evidence precedence

1. Prefer explicit metadata from the configured endpoint. Prefer a published
   combined context window over the conservative input-maximum proxy below.
2. Use exact-ID LiteLLM metadata to fill FhGenie gaps where the matching upstream
   route is confirmed. Fetch it even when the LiteLLM entry is unselected, but do
   not edit that entry. Same IDs do not prove identical billing, deployment
   limits, vision handling, cache retention, or transport compatibility.
3. If endpoint metadata is inadequate, consult the installed Pi upstream catalog
   for a confirmed matching model. Record catalog-derived limits/capabilities and
   complete prices as **fallbacks/estimates**, not verified deployment facts.
   Preserve version, variant, size, and quantization. Do not automatically copy
   the upstream API, URL, authentication, input limits, or compatibility flags.
4. Without adequate evidence, retain applicable existing metadata or leave new
   fields unset. Report missing values and their effective Pi defaults.

Track provenance per field, including whether a value was explicitly reported,
inherited, catalog-derived, or runtime-defaulted. Conflicting endpoint behavior
must not be overridden by a more optimistic catalog claim. Failed optional
verification leaves the capability unverified; it is not automatically proof of
unsupported capability. No inference request is required to use metadata, but
clearly distinguish advertised capabilities from tested ones.

# Pi field mappings

Consult `docs/models-configuration.md` and `schemas/models.schema.json` in the
currently installed Pi package for supported fields and semantics.

| Endpoint field | Pi field |
| --- | --- |
| `max_input_tokens` | `contextWindow` (conservative proxy if combined context is unknown) |
| `max_output_tokens` | `maxTokens` |
| `supports_reasoning` | `reasoning` |
| `supports_vision` | `input`: true → text/image; false → text only |
| `input_cost_per_token` | `cost.input` |
| `output_cost_per_token` | `cost.output` |
| `cache_read_input_token_cost` | `cost.cacheRead` |
| `cache_creation_input_token_cost` | `cost.cacheWrite` |

Never add input and output maxima together or use an ambiguous `max_tokens`
field as the output limit. Convert USD/token to USD/million tokens by multiplying
by 1,000,000. Pi cost objects require all four prices; do not invent missing ones.
Label proxy-advertised, inherited, and upstream-catalog prices as estimates, not
verified billing. Check explicit endpoint rate overrides rather than assuming
catalog prices or proportional markup remain current.
Map complete request-wide `*_above_<N>k_tokens` prices to `cost.tiers` with
`inputTokensAbove: N * 1000`. Do not mix standard pricing with priority, flex,
batch, or cache-duration variants.

Explicit `supports_{none,minimal,xhigh,max}_reasoning_effort` flags map to
`thinkingLevelMap` keys `off`, `minimal`, `xhigh`, `max`: true uses the respective
provider string (`none` for `off`), false uses `null`; absent means unknown.

Only explicit booleans support the capability mappings above; missing/null values
mean unknown. Observed reasoning blocks/tokens and a successful reasoning request
can also establish reasoning support during authorized verification. Successful
parameter acceptance alone does not prove the server honors it or that all
thinking levels behave differently. Explicit server rejection listing allowed
efforts can establish `thinkingLevelMap` support without guessing.

Set `promptCache.short`/`.long` only from verified best-effort endpoint lifetimes
in seconds. Leave unknown lifetimes unset: this prevents warming that tier, not
ordinary server caching. Duration-specific price fields do not establish retention
support. Generic supported-parameter lists do not prove compatibility, cache
lifetimes, or model capabilities.

`supports_function_calling: false` warrants a tool-workflow warning, not an
invented Pi configuration switch. Report contradictions with authorized tool
checks, including raw thinking text leaking into normal answers. Keep metadata
claims, observed behavior, and recommended suitability distinct.

Consult installed Pi defaults when reporting incomplete entries: omitted limits,
reasoning, modalities, and prices still have effective runtime values. In
particular, zero estimated cost for an unpriced model is **not** verified free
service. A catalog refresh such as `pi update --models` does not discover metadata
for these custom endpoint entries.
