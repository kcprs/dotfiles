# Project scaffolding script: open questions and decisions

We will discuss these questions in order. Answers will be recorded under each
question as decisions are made. Suggestions below are not confirmed decisions.

## 1. Script location and name

- Where should the script live, and what should it be called?
- Should it be installed as a command in these dotfiles and always scaffold the
  current working directory?

**Answer:** Place the script and its templates, tests, and requirements in
`.config/scripts/toolup` in this dotfiles repository.
Expose it through a fish abbreviation named `toolup`. The script scaffolds
the current working directory. The chosen script filename is `toolup.sh`.

## 2. Implementation, interaction, and supported platforms

- What implementation and dependencies are acceptable: for example, Bash with
  `gum` for interactive menus, or Python with numbered text prompts?
- Is this macOS-only, or should it also work on Linux?
- Suggestion: Bash with `gum`, if that dependency is acceptable.

**Answer:** Use `gum` for interactive prompts. If `gum` is not installed, stop
with an informative message explaining that it must be installed. Target macOS
only for now. Implement the script in Bash, with gum handling interactive prompts.
Style gum with the terminal's ANSI palette: blue headers, cyan accents, and
subdued bright-black hints. Leave ordinary foreground/background at terminal
defaults; use black on cyan for the selected confirmation button. Preserve
existing `GUM_*` style preferences, including explicitly empty values.

## 3. Default answers and confirmation

- What should the default answers be for C/C++ tools and a Python venv?
- Should the script show a summary and ask for confirmation before writing?
- Suggestion: default to **no** for both optional tool setups and show a final
  confirmation.

**Answer:** Default both C/C++ tools and Python venv setup to **no**. As the final
interactive step, show a summary of the choices and files to create, then ask for
confirmation before writing any files.
Default the final confirmation to **yes**.
Display the final summary with `gum style` in a rounded, padded panel with a
terminal-palette cyan border and ordinary terminal text colors.

## 4. Existing files and policy `none`

- If a target file exists, should the script abort before writing, skip it,
  offer replacement with a backup, or merge its contents?
- Should policy `none` simply omit AI files and leave existing AI files untouched?
- Suggestion: abort before writing any files if a selected target already exists;
  do not delete existing AI files when policy `none` is selected.

**Answer:** Automatically plan replacement of every existing target file with a
backup. Do not ask per-file questions or offer a skip action. List replacements
and backup paths in the final summary; its single confirmation authorizes all
changes and defaults to **yes**. Declining writes neither files nor backups.
Use timestamped sibling backups such as
`.envrc.bak-20261119-143025`, adding a numeric suffix if that name already exists.

Stop before writing if any target is a directory. Back up symlinks themselves,
replace them with regular files, and leave their destinations untouched. Reject
a symlinked `.nono` directory. If backup fails, do not overwrite the original;
stop and report any earlier completed work. If a new target or backup collision
appears after confirmation, stop. If an existing target's contents change, back
up and replace its latest contents.

When AI policy `none` is selected, warn if AI configuration files already exist,
but do not modify those AI configuration files. The user's wording “policy nono”
is interpreted as `none`.

Exception: if C/C++ or Python setup is selected, an existing `.envrc` is still
replaced with a backup after final confirmation, even if replacement removes existing AI
settings. The user confirmed this behavior.

## 5. Missing dependencies and failed commands

- Should the script check only dependencies required by the selected options,
  then abort before writing if a required dependency is missing?
- If a generation command fails, should the script remove files created by this
  run or leave them with an error report?

**Answer:** If generation fails, leave partial results in place. Report what
failed and which files were already written. Do not roll back the run.

Check only dependencies required by the selected options before writing any
files. If any are missing, stop with an informative message. The mandatory `gum`
check and its informative missing-dependency message are already agreed.

## 6. OpenCode version and configuration filename

- Which OpenCode version should this target?
- Is `.opencode.jsonc` intentional, or should the script use the documented
  `opencode.jsonc` or `.opencode/opencode.jsonc` filename?
- Verify the global configuration path and commented MCP example against the
  installed version before implementation.

**Answer:** Target OpenCode v2 and Pi without pinning a minor or patch version.
Use the currently installed versions when specific behavior needs to be verified.
Keep `.opencode.jsonc`: the user has explicitly reconfigured the configuration
filename in nono sandboxes. Write Pi project model settings to `.pi/settings.json`.
Generate `.pi/mcp.json` as valid JSON with a `gitlab-3gpp` server using `npx -y
@zereight/mcp-gitlab`, disabled by default (`"enabled": false`). Reference
`GITLAB_PERSONAL_ACCESS_TOKEN` and `GITLAB_API_URL` with Pi's `${NAME}` syntax;
do not substitute credentials while scaffolding. Missing variables do not
prevent loading a disabled server. Enable it through `/mcp` after credentials
are available, or edit the file and run `/reload`. Treat this file like other
targets for confirmation, backup-and-replace, and safety checks. Policy `none`
leaves it untouched. Keep OpenCode's commented MCP template unchanged.
Every AI-enabled project configures both agents; do not prompt for agent selection.

**Verification before implementation:** Check the global configuration path
and commented MCP template against the installed version and the user's setup.

## 7. Model discovery and selection

- Does “available” mean models from configured/enabled providers, or everything
  the CLI lists?
- Should the menu include only chat models, or image models too?
- Should the current configured model be preselected when available?
- If discovery fails, should the script allow manual entry or abort?
- Suggestion: searchable chat models from configured providers, displaying full
  provider/model IDs and preselecting the configured model when available.

**Answer:** List every model reported by `pi --list-models` and provide gum
search/filter functionality. Select one model for both agents; preserve the full
provider and model ID, including slashes within the model ID. Do not detect or
preselect a configured default. Query `opencode models --standalone` and warn,
but continue, if the selected provider/model ID is not listed. Extra OpenCode
models, including built-ins, are expected and do not constitute a mismatch.
Matching IDs are assumed to use equivalent endpoints and credentials.

Pi discovery supplies dummy values for `FHGENIE_API_KEY`,
`FHGENIE_ONPREM_API_KEY`, and `AME_LITELLM_API_KEY` only in the listing
subprocess. This lets Pi list the statically configured models before `.envrc`
is created and trusted; no real credentials are needed for that listing. The
placeholders are not exported to the caller, passed to OpenCode, or written to
project files. Update this list if another configured provider requires a key.

If either model discovery fails or returns no usable models, stop before writing;
do not offer manual entry. Show a gum spinner for each discovery, preserving
stdout for selection or comparison, displaying stderr separately, and propagating
failures. Write the chosen ID to `.opencode.jsonc` and its provider and model
components to `.pi/settings.json`.

## 8. AI policy behavior and envrc prerequisites

- Do policies only select an envrc file, or should they restrict model choices?
- Are some providers forbidden for confidential projects?
- Must the selected `~/.ai.<policy>.envrc` file exist before generation proceeds?

**Answer:** AI policy selects the corresponding envrc file to source; it
does not restrict models or providers. If the selected `~/.ai.<policy>.envrc`
file does not exist, stop with an error before writing any files. For policy
`confidential`, the agent profiles extend the private local bases
`opencode-confidential` and `pi-confidential`, respectively. For other AI
policies, they extend `opencode` and `pi`. Check that both selected bases
resolve before writing files.

## 9. nono schema, profile, and metadata

The requested sequence assigns two different contents to
`.nono/profile.schema.json`. It also describes the schema command as creating
`.nono/profile.jsonc`, although its output argument names the schema file.

- Is this the intended sequence?
  1. Generate `.nono/profile.schema.json` with `nono profile schema`.
  2. Generate `.nono/profile.jsonc` with `nono profile init --extends opencode`.
  3. Do not write the supplied metadata object as a schema.
- If the metadata object is required, where should it go?
- Should description, author, and license become additional questions?

**Answer:** The original schema/profile instructions contained errors and
typos. Disregard the supplied metadata object; do not ask for description,
author, or license.

1. Create `.nono` if needed and generate `.nono/profile.schema.json` with
   `nono profile schema --output .nono/profile.schema.json`.
2. Generate `.nono/profile.json` with `nono profile init` and no base. This
   shared profile contains project-specific settings and is not used alone.
3. Generate `.nono/agent-pi.jsonc` and `.nono/agent-opencode.jsonc`, each
   extending its selected agent base followed by `profile`. Sibling bases are
   resolved by name; the shared base uses `.json` because sibling `.jsonc` base
   resolution is not supported by the installed version.
4. Add `"$schema": "profile.schema.json"` to all three profiles. Keep private
   network permissions in the local bases, not in the generated project files.
5. Export `NONO_PROFILE=.nono/agent-pi.jsonc` in `.envrc`, with a second,
   commented export for `.nono/agent-opencode.jsonc` for manual switching.
6. Do not detect, warn about, or migrate old setups. Rerunning toolup backs up
   and replaces current targets, including any customized project profile.

## 10. Project naming, template safety, and activation

- Should the project name always come from the current directory, without an
  override prompt?
- May the script normalize the build variable by converting each run of
  non-alphanumeric characters to `_`, uppercasing, prefixing `_` if the result
  starts with a digit, and appending `_BUILD_DIR`?
- May it quote the absolute home path in `source_env`?
- May it quote build-directory expansions and guard `clean` against an unset or
  empty variable?
- Should the CMake command explicitly enable the compilation database with
  `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`?
- Should the script only create files, or also run `direnv allow`?
- Suggestion: leave authorization and environment activation to the user.

**Answer:** All proposed choices are approved:

- Derive the project name from the current directory, without an override prompt.
- Uppercase the name, replace runs of non-alphanumeric characters with `_`,
  prefix `_` if the result starts with a digit, and append `_BUILD_DIR`.
- Quote the resolved absolute home path in `source_env`; do not leave `$HOME`
  in the generated file.
- Quote build-directory expansions and guard `clean` against an unset or empty
  variable.
- Add `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` to the CMake configure command.
- Only create files; do not run `direnv allow` or activate the environment.

## 11. No options selected

- If AI policy is `none` and both C/C++ tools and Python venv setup are declined,
  should the script create nothing?
- Suggestion: report “No files to create,” warn about any existing AI
  configuration, and leave everything untouched.

**Answer:** If AI policy is `none` and both C/C++ tools and Python venv setup
are declined, create nothing. Report “No files to create,” warn about any
existing AI configuration, and leave everything untouched.
