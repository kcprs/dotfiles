---
name: rust
description: Best practices and guidelines for working with Rust code.
---

## Workflow

As the last step after making changes to Rust code, run cargo commands listed below in the order
given. At each step, react to any errors or warnings before proceeding to the next step. Note that
project-local instructions for AI agents may mention additional flags and arguments to use with
these commands.

- `cargo check --workspace`
- `cargo test --workspace`
- `cargo clippy --workspace`
- `cargo fmt`

## Documentation

- Always put documentation comments above any attributes (e.g. `#[derive(...)]`).

## Dependencies

When adding dependencies to Rust projects, use `cargo add` instead or editing `Cargo.toml` directly.

## Error handling

- Prefer `expect()` over `unwrap()`. The `expect` message should be very concise, and should explain
  why that expect call cannot fail.
- In code that uses `eyre` or `anyhow` `Result`s, consistently use `.context()` prior to every
  error-propagation with `?`. Context messages in `.context` should be simple present tense, such as
  to complete the sentence "while attempting to ...".

## API design

- When designing `pub` or crate-wide Rust APIs, consult the checklist in
  <https://rust-lang.github.io/api-guidelines/checklist.html>.

## Debugging

- For ad-hoc debugging, create a temporary Rust example in `examples/` and run it with `cargo run
  --example <name>`. Remove the example after use.
