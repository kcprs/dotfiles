# Toolup project scaffolding requirements

Toolup scaffolds the current working directory with the selected AI configuration
and optional language/tool setup. The following sections specify its required
behavior.

## Generated files

Toolup manages the following project-relative targets. Only targets selected by
the conditions below participate in validation, confirmation, backup, and
replacement.

| Target | Included when |
|---|---|
| `.envrc` | AI policy is not `none`, or Rust, Python, or C/C++ setup is selected |
| `.justfile`, `.clang-tidy` | C/C++ setup is selected |
| `.opencode.json` | AI policy is not `none` |
| `.pi/settings.json`, `.pi/mcp.json` | AI policy is not `none` |
| `.nono/profile.schema.json`, `.nono/profile.json` | AI policy is not `none` |
| `.nono/agent-pi.json`, `.nono/agent-opencode.json` | AI policy is not `none` |
| `.fdignore` | AI policy is not `none` |

Toolup creates `.pi/` and `.nono/` as needed for their selected targets.
Language/tool setup does not create additional scaffold files beyond those
listed above.

The migration manifest is a conditional post-run artifact, described in
section 13, rather than a scaffold target.

## 1. Script location and name

Place the script and its templates, tests, and requirements in
`home/.config/scripts/toolup` in this dotfiles repository.
Expose it through a fish abbreviation named `toolup`. The script scaffolds
the current working directory. The chosen script filename is `toolup.sh`.

## 2. Implementation, interaction, and supported platforms

Use `gum` for interactive prompts. If `gum` is not installed, stop
with an informative message explaining that it must be installed. Target macOS
only for now. Implement the script in Bash, with gum handling interactive prompts.
Style gum with the terminal's ANSI palette: blue headers, cyan accents, and
subdued bright-black hints. Leave ordinary foreground/background at terminal
defaults; use black on cyan for the selected confirmation button. Preserve
existing `GUM_*` style preferences, including explicitly empty values.

## 3. User choices, defaults, and confirmation

Present interactive prompts in this order:

1. **AI policy:** choose `none`, `confidential`, `restricted`, or `public`.
   Default to `restricted`. Policy `none` omits AI configuration; the other
   policies enable AI configuration as described in section 6.
2. **AI model:** when AI policy is not `none`, select one model for both
   agents using the discovery and selection rules in section 4. Do not detect
   or preselect a configured default.
3. **Rust tools:** default to **no**.
4. **C/C++ tools:** default to **no**.
5. **Python venv:** default to **no**.
6. **Final confirmation:** show a summary of the choices and selected targets,
   including creation or replacement actions and backup paths, then ask for
   confirmation before writing any files. Default to **yes**. If no targets
   are selected, follow section 12 instead.

Display the final summary with `gum style` in a rounded, padded panel.
Default the border to terminal ANSI palette index 6 (cyan), preserving any
existing `BORDER_FOREGROUND` override, including an explicitly empty value.
Leave ordinary text foreground and background at terminal defaults.

Collect nonfatal setup warnings and display them together in a separate
**Warnings** panel below the final summary, before confirmation. Use a rounded,
padded panel with terminal ANSI palette index 3 (yellow) for the border. Omit
the panel when there are no warnings. This includes model compatibility,
normalized profile names, and policy-`none` warnings. When no targets are
selected, display the same panel below “No files to create,” without asking for
confirmation. Fatal errors and command diagnostics remain immediate; failures
after writing begins are reported then.

## 4. Model discovery and selection

List every model reported by `pi --list-models`, displaying full provider/model
IDs and providing gum search/filter functionality. Select one model for both
agents; preserve the full provider and model ID, including slashes within the
model ID. Do not detect or preselect a configured default. Query `opencode models --standalone` and warn,
but continue, if the selected provider/model ID is not listed. Extra OpenCode
models, including built-ins, are expected and do not constitute a mismatch.
Matching IDs are assumed to use equivalent endpoints and credentials.

Pi discovery supplies dummy values for `FHGENIE_API_KEY`,
`FHGENIE_ONPREM_API_KEY`, and `AME_LITELLM_API_KEY` only in the listing
subprocess. This lets Pi list the statically configured models before `.envrc`
is created and trusted; no real credentials are needed for that listing. The
placeholders are not exported to the caller, passed to OpenCode, or written to
project files. Update this list if another configured provider requires a key.

If Pi model discovery or OpenCode model discovery fails or returns no usable
models, stop before writing; do not offer manual entry. Show a gum spinner for each discovery, preserving
stdout for selection or comparison, displaying stderr separately, and propagating
failures. Write the chosen ID to `.opencode.json` and its provider and model
components to `.pi/settings.json`, using jq's sorted-key output for generated
objects.

## 5. Project naming, template safety, and activation

### Language/tool setup

Language/tool choices are independent of AI policy and of each other. Each
selected option adds its corresponding section to `.envrc`:

- **Rust:** set and export project-local `CARGO_HOME` as specified in section 6.
  Do not install a Rust toolchain or run Cargo during scaffolding.
- **Python:** add `layout python3`. Direnv creates and activates the virtual
  environment when the user authorizes and activates `.envrc`; toolup does not
  create it during scaffolding.
- **C/C++:** export the project-derived build-directory variable with the value
  `_build`. Generate `.justfile` from `toolup-templates/justfile`, substituting
  that variable's name for `__BUILD_DIR_VAR__`. Copy
  `toolup-templates/clang-tidy` literally to `.clang-tidy`.

The generated `.justfile` must provide:

- A default recipe that runs `build`.
- A `build` recipe that configures CMake in the selected build directory, relying
  on the globally exported `CMAKE_EXPORT_COMPILE_COMMANDS` environment variable
  for compilation-database generation, copies `compile_commands.json` to the
  project root, and builds the project.
- A `clean` recipe that removes the selected build directory, refusing to run
  if the build-directory variable is unset or empty.

The `.clang-tidy` template defines the initial analysis checks. Toolup does not
run CMake, build or clean the project, or run clang-tidy during scaffolding.

### Project naming, safety, and activation

- Derive the project name from the current directory, without an override prompt.
- Derive the build-directory variable name by uppercasing the project name,
  replacing runs of non-alphanumeric characters with `_`, prefixing `_` if
  the result starts with a digit, and appending `_BUILD_DIR`. Do not change
  the project name itself.
- Explicitly quote the resolved absolute home path in `source_env`, including
  paths without spaces. Escape shell-special characters so the path remains
  literal at activation; do not leave `$HOME` in the generated file.
- Quote build-directory expansions and guard both `build` and `clean` against
  an unset or empty variable, using `<build_dir_env_var_name> not defined` as
  the error message, with the actual build-directory variable name substituted.
- Write the selected configuration files, create their required directories,
  and perform the backups specified in section 10. Do not run `direnv allow`
  or activate the environment; leave authorization and activation to the user.

## 6. AI policy behavior and envrc prerequisites

AI policy selects the corresponding envrc file to source; it
does not restrict models or providers. If the selected `~/.ai.<policy>.envrc`
file does not exist, stop with an error before writing any files. For policy
`confidential`, the agent profiles extend the private local bases
`opencode-confidential` and `pi-confidential`, respectively. For other AI
policies, they extend `opencode` and `pi`. Check that both selected bases
resolve before writing files.

When Rust tools are selected, include the following in the generated `.envrc`
to keep Cargo dependency-cache writes inside the writable project, regardless of
AI policy:

```sh
CARGO_HOME="$(expand_path .cargo-home)"
export CARGO_HOME
```

Use direnv's `expand_path` at environment activation, not during scaffolding.
Direnv evaluates `.envrc` from its containing directory, so the resulting
absolute path stays anchored to the project root when commands run from
subdirectories and adapts when the checkout moves. Do not hard-code the checkout
path. Assign and export separately to avoid masking the command's exit status
and to satisfy ShellCheck SC2155.

Do not add `CARGO_HOME` based on AI policy alone, or when Rust tools are declined.
Ignore `.cargo-home/` through the dotfiles' global Git ignore list at
`home/.config/git/ignore`; toolup does not need to modify a project's `.gitignore`.

Format the generated `.envrc` as clearly separated sections, in this order:
**AI Tools**, **Rust**, **Python**, and **C/C++**. Include only sections selected
for the project. Each section has a centered title between divider lines made of
exactly 100 `#` characters; the divider lines contain no spaces or other
characters. Center titles within that 100-column width, and separate adjacent
sections with a blank line.

## 7. OpenCode version and configuration filename

Target OpenCode v2 and Pi without pinning a minor or patch version.
Use the currently installed versions when specific behavior needs to be verified.
Write strict JSON to `.opencode.json` so jq can generate it with explicitly
sorted keys. Write Pi project model settings to `.pi/settings.json`.
Generate `.pi/mcp.json` as valid JSON with a `gitlab-3gpp` server using `npx -y
@zereight/mcp-gitlab`, disabled by default (`"enabled": false`). Reference
`GITLAB_PERSONAL_ACCESS_TOKEN` and `GITLAB_API_URL` with Pi's `${NAME}` syntax;
do not substitute credentials while scaffolding. Missing variables do not
prevent loading a disabled server. Enable it through `/mcp` after credentials
are available, or edit the file and run `/reload`. Treat this file like other
targets for confirmation, backup-and-replace, and safety checks. Policy `none`
leaves it untouched. Every AI-enabled project configures both agents; do not
prompt for agent selection.

**Verification prerequisite:** Before implementing or updating AI configuration
generation, verify configuration paths, generated JSON, and MCP behavior against
the locally installed OpenCode and Pi versions and the user's setup. Record the
versions used when reporting verification results.

## 8. nono schema and profiles

Generate the schema and profiles as follows. Do not generate a separate metadata
object or ask for description, author, or license.

1. Create `.nono` if needed and generate `.nono/profile.schema.json` with
   `nono profile schema --output .nono/profile.schema.json`.
2. Generate `.nono/profile.json` with `nono profile init` and no base. This
   shared profile contains project-specific settings and is not used alone.
3. Generate `.nono/agent-pi.json` and `.nono/agent-opencode.json`, each
   extending its selected agent base followed by `profile`. Resolve the shared
   project base by sibling name and generate it as `.json`, not `.jsonc`.
4. Add `"$schema": "profile.schema.json"` to all three profiles. Keep private
   network permissions in the local bases, not in the generated project files.
5. Export `NONO_PROFILE=.nono/agent-pi.json` in `.envrc`, with a second,
   commented export for `.nono/agent-opencode.json` for manual switching.
6. Toolup itself does not migrate legacy configurations or search for legacy
   paths beyond the policy-`none` warning checks specified in section 10.
   The migration skill handles user-approved legacy discovery and migration
   as described in section 13. Rerunning toolup backs up and replaces selected
   current targets, including any customized project profile.

**Compatibility rationale:** The shared base uses `.json` to support sibling
base resolution. Before changing this format or the inheritance structure,
verify sibling-base resolution with the locally installed nono version.

## 9. Project-local fd ignore template

Make the normally Git-ignored `SESSION.md` discoverable by `fd` in projects
scaffolded with an AI policy other than `none`. This fd configuration is for use
in Pi, which is not used with policy `none`.

- Add `toolup-templates/fdignore` beside the existing templates and copy it to
  `.fdignore` in the current project root. Copy the template literally; do not
  interpolate it or read the dotfiles repository's root `.fdignore` at runtime.
- The initial template contains exactly `!/SESSION.md` followed by a newline.
  The leading slash limits the exception to the project-root file; do not also
  unignore nested `SESSION.md` files or other Git-ignored files. This changes
  fd's ignore behavior, not Git's tracking behavior.
- Include `.fdignore` only when AI policy is `confidential`, `restricted`, or
  `public`, independently of language/tool setup. Do not add a separate prompt
  or require `fd` to be installed: toolup only installs the configuration.
- With policy `none`, do not create, back up, replace, or validate an existing
  `.fdignore`, and do not require its template, even when Rust, C/C++, or Python
  setup is selected. Warn about its presence as specified in section 10, without
  inspecting its contents. Section 12's “No files to create” behavior remains
  unchanged when all tools are declined.
- Treat `.fdignore` like other managed targets under sections 3, 10–11, and 13:
  validate its template before writing, list creation or replacement and its
  backup path in the final summary, and write only after confirmation. An
  existing file is backed up and replaced, not merged or appended to; a
  replacement participates in the migration handoff. Apply the same directory,
  symlink, backup-collision, and post-confirmation safety checks.
- Do not create `SESSION.md`, modify project or global Git ignore files, or
  change global fd configuration as part of this feature.

## 10. Existing files and policy `none`

Automatically plan replacement of every existing target file with a
backup. Do not ask per-file questions or offer a skip action. List replacements
and backup paths in the final summary; its single confirmation authorizes all
changes and defaults to **yes**. Declining writes neither files nor backups.
Use timestamped sibling backups such as
`.envrc.bak-20261119-143025`, adding a numeric suffix if that name already exists.

Stop before writing if any target is a directory. Back up symlinks themselves,
replace them with regular files, and leave their destinations untouched. Reject
symlinked `.nono` and `.pi` directories, or those paths existing as non-directories,
when AI setup is selected. Check these parent directories both before confirmation
and again immediately afterward, before any backups or writes. These are
best-effort safety checks, not protection against concurrent filesystem changes.
If backup fails, do not overwrite the original; stop and report any earlier
completed work. If a new target or backup collision
appears after confirmation, stop. If an existing target's contents change, back
up and replace its latest contents.

When AI policy `none` is selected, check the following project-relative paths
and warn for each existing path that it will be left untouched. Include current
and legacy AI configuration paths, as well as the AI-associated fd configuration:

| Configuration | Paths to check |
|---|---|
| OpenCode | `.opencode.json`, `.opencode.jsonc`, `opencode.json`, `opencode.jsonc`, `.opencode/opencode.json`, `.opencode/opencode.jsonc` |
| Pi | `.pi/settings.json`, `.pi/mcp.json` |
| nono | `.nono/profile.schema.json`, `.nono/profile.json`, `.nono/profile.jsonc`, `.nono/agent-pi.json`, `.nono/agent-pi.jsonc`, `.nono/agent-opencode.json`, `.nono/agent-opencode.jsonc` |
| fd | `.fdignore` |

These existence checks do not select the paths for generation, validate their
contents, or authorize modification. Do not modify any of these paths under
policy `none`.

Also warn if an existing `.envrc` contains a `source_env` reference to an `.ai.`
policy file or a `NONO_PROFILE` setting. This warning must distinguish leaving
`.envrc` untouched when no language/tool setup is selected from replacing it
with a backup after confirmation when language/tool setup is selected, removing
its existing AI settings. Present these warnings together as specified in section 3.

Exception: if C/C++, Python, or Rust setup is selected, an existing `.envrc` is
still replaced with a backup after final confirmation, even if replacement removes
existing AI settings.

## 11. Missing dependencies and failed commands

If generation fails, leave partial results in place. Report what
failed and which files were already written. Do not roll back the run.

Check only dependencies required by the selected options before writing any
files. If any are missing, stop with an informative message. Always check for
`gum`, as required by section 2.

In addition to `gum`, require `direnv` whenever any target is selected.
AI setup requires `opencode`, `pi`, `nono`, and `jq`; C/C++ setup requires
`cmake` and `just`; Python setup requires `python3`. Rust setup does not
require a Rust toolchain during scaffolding. Use `jq` for deterministic JSON
generation and schema insertion.

## 12. No options selected

If AI policy is `none` and C/C++, Python, and Rust setup are all
declined, create nothing. Report “No files to create,” warn about any existing
AI configuration, and leave everything untouched.

## 13. Migration handoff and skill

After a successful run that replaced at least one existing target, but without
asking another confirmation question, create a temporary manifest under the
project's `tmp/` directory and print a short migration hint. Put the exact Pi
skill command on its own line so it can be copied and run from the project root.
Do not create a manifest or print the hint when the run only creates files or
fails partway through.

If scaffolding completes but manifest creation or writing fails, leave generated
files and backups in place and exit nonzero. Report the cause and a short message
that scaffolding completed but migration handoff failed; do not print the normal
success message or migration hint, and do not ask another confirmation question.

The manifest is versioned tab-separated text: a `toolup-migration-manifest-v1`
header followed by one target-path and backup-path pair per replaced file. Use
the arrays recorded during the run; do not infer pairs from timestamps. The
manifest contains paths only, not file contents or credentials.

The user-level Pi skill lives at `~/.pi/agent/skills/toolup-migrate/SKILL.md`.
It processes manifest pairs and also checks for plausible legacy configs of
tools managed by toolup. It must present such candidates and let the user choose
whether to include each one. Toolup itself performs only the policy-`none`
warning checks specified in section 10; it does not discover additional legacy
migration candidates. The skill applies only user-approved changes to new
targets, then lists exact old source files and asks whether to delete them. It
deletes only after explicit confirmation and never deletes generated targets or
unselected candidates.
