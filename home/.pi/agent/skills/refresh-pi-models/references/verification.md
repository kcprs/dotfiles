# Optional inference verification

Inference is a separate, opt-in action because it can incur charges. An action
menu selection explicitly described as paid verification or a prompt explicitly
authorizing inference establishes consent. A vague request to refresh models,
validate configuration, or "do everything" does not establish informed consent
for paid requests. Clarify missing consent before sending them.

## Scope and safeguards

- Honor provider/model restrictions. If verification targets are unspecified,
  propose the selected added/updated/refreshed models, or the configured models
  for a verification-only run, and confirm the target scope and small test bounds.
- State an initial per-model request/output cap and timeout; respect any spending
  limit. Do not estimate unknown-price requests as free. If a hard monetary cap
  cannot be enforced for an unpriced model, explain that before testing it.
- Use fresh files under the run's project-local `tmp/` directory. Save only
  synthetic inputs, allowlisted usage/protocol fields, and redacted diagnostics.
  Do not log credentials, authorization headers, or complete provider responses.
- Use the installed Pi model runtime and streaming APIs so tests exercise the
  configured transport and metadata. Consult the installed `docs/sdk.md`, its
  relevant examples, and exported declarations rather than assuming an API.
- Isolate session, credential, and catalog storage under the run directory. Read
  configured credentials without copying secrets into artifacts. Disable catalog
  network refresh, agent extensions, project context loading, automatic retries,
  and real agent tools. Do not alter the default model or persistent sessions.
- Capability probes may use a separate candidate configuration or in-memory model
  overrides, but must not silently change the active configuration. Capture
  relevant request fields to check that the intended probe was actually sent.

## Small test sequence

1. **Streaming tool call:** define one side-effect-free diagnostic tool with a
   fixed argument and fixed result. Ask for one call. Validate the tool name and
   arguments; do not execute arbitrary tools requested by the model.
2. **Tool-result continuation:** return the fixed result in the expected message
   format and ask for an exact short answer without another call. Check streamed
   text, termination, no extra calls, and the exact final answer. If tool calling
   is absent, a separate text-only request can distinguish text capability from
   tool capability.
3. **Reasoning, where relevant:** send a supported modest level and a small task.
   Record the effort sent, request acceptance, thinking events, and reported
   reasoning tokens. A short correct answer with no reasoning output is
   inconclusive about reasoning; an accepted parameter may have been ignored.
   Do not exercise every expensive effort level by default.
4. **Vision, where relevant:** use a synthetic image with a known answer, such as
   a solid-color square. Confirm an image block reaches the outgoing request and
   check the answer, not just HTTP status. Retry an unexpected result within the
   agreed bounds, optionally using a known-working control model in scope. Mark
   the deployment unverified if recognition fails; do not automatically enable
   images based solely on an upstream catalog flag.
5. **Usage:** compare reported total tokens and available input/output/cache/
   reasoning counters with Pi's normalized usage. Note unrecognized counter
   spellings separately. Compare provider-reported response cost with estimates
   when available; agreement is not independent invoice verification. Distinguish
   provider-reported totals from catalog-estimated totals.

Checks can be combined to keep the request count small. Skip irrelevant checks
and report what was not tested. Small requests do not establish maximum token
budgets, cache lifetimes, image limits, or complete protocol compatibility.

## Retry and interpret failures

Start with limited concurrency, bounded timeouts, output caps, and no automatic
retries. On timeout, one serial retry with a longer stated bound can distinguish
capacity/latency from a reproducible protocol failure, provided the approved
request/spending limits still allow it. Do not retry indefinitely or conclude
that a timed-out model is unsupported or absent from the catalog.

Distinguish:

- **Advertised:** present in catalog, not necessarily operational.
- **Request accepted:** HTTP success, not necessarily a correct tool/vision result.
- **Check passed:** the expected content/behavior and usage were observed.
- **Check failed:** wrong answer, malformed calls, leaked raw thinking, or error.
- **Unverified:** timeout, incomplete evidence, or a skipped check.

An invalid upstream model ID is a routing problem, not proof of model retirement;
report it without guessing a replacement ID. Tool calls may work despite a
negative capability flag, or fail despite a positive one. Capture that conflict
instead of treating either source as infallible.

Use `compat` only for verified request/response differences the installed Pi
schema can express. Do not repair server routing, parse leaked thinking with an
ad-hoc extension, or normalize arbitrary usage fields as part of a model refresh.
Report such external or separate implementation tasks.

Only persist evidence-backed metadata corrections for models whose add/update/
refresh was approved. Verification-only findings do not authorize edits. Keep
failed tests and untested capabilities visible in the final report rather than
claiming the model generally works.
