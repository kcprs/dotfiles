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
Azure metadata previously lacked limits and capabilities; use exact-ID LiteLLM
inheritance where available. No inference requests are needed.

OpenAI-style catalogs use `data[].id`. LiteLLM metadata uses
`data[].model_name` and `model_info`; the client-visible ID is `model_name`,
not `litellm_params.model`. Report conflicting metadata for duplicate deployments.

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
Map complete request-wide `*_above_<N>k_tokens` prices to `cost.tiers` with
`inputTokensAbove: N * 1000`. Do not mix standard pricing with priority, flex,
batch, or cache-duration variants.

Explicit `supports_{none,minimal,xhigh,max}_reasoning_effort` flags map to
`thinkingLevelMap` keys `off`, `minimal`, `xhigh`, `max`: true uses the respective
provider string (`none` for `off`), false uses `null`; absent means unknown.

Other Pi properties require explicit matching evidence. Generic supported-parameter
lists do not prove compatibility, cache lifetimes, or model capabilities.
`supports_function_calling: false` warrants a tool-workflow warning; do not
invent a Pi configuration field for it.
