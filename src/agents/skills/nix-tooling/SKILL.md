---
name: nix-tooling
description: >
  Use Nix (flakes) to obtain programs and tools instead of apt, brew, pip install,
  npm -g, or other system-level package managers. Activate this skill whenever a
  command is not found in $PATH, whenever you need to install or obtain a CLI tool,
  compiler, formatter, linter, or runtime, or whenever the user mentions Nix, nixpkgs,
  nix run, nix develop, or flake.nix. Also activate when you're about to reach for
  apt-get, brew, pip install --global, npm install -g, or cargo install — use the
  Nix equivalent instead. This skill applies to Claude Code terminal usage.
---

# Nix Tooling

Use Nix flakes to get any program you need. Never fall back to system package
managers (apt, brew, yum, pacman) or language-level global installs (pip install,
npm -g, cargo install) unless the user explicitly asks for them.

## Core Principle

Nix is your universal package manager. It gives you access to the entire nixpkgs
collection (100,000+ packages) without polluting the system or conflicting with
other tools. Programs obtained via Nix are reproducible, isolated, and disposable.

## When a Program Isn't in $PATH

Before doing anything else, try to run the program with `nix run`. This is the
fastest way to get going.

### One-off commands: `nix run`

Use `nix run` when you just need to execute a tool once or a few times and don't
need it to persist in the shell:

```bash
# Run a program directly from nixpkgs
nix run nixpkgs#jq -- '.name' data.json
nix run nixpkgs#ripgrep -- -r 'TODO' src/
nix run nixpkgs#black -- --check .
nix run nixpkgs#nodePackages.prettier -- --write "**/*.ts"
nix run nixpkgs#ffmpeg -- -i input.mp4 output.gif
```

The pattern is always: `nix run nixpkgs#<package> -- <args>`

The `--` separates nix arguments from the program's arguments. Always include it
when passing arguments to the underlying program.

### Project work: `nix develop` / `nix shell`

When you need multiple tools available in your shell for ongoing work (e.g. a
build toolchain, a language runtime + linter + formatter), use `nix shell` to
get an ad-hoc environment:

```bash
# Get multiple tools at once
nix shell nixpkgs#nodejs nixpkgs#yarn nixpkgs#typescript

# Now node, yarn, and tsc are all available in this shell
node --version
```

If the project already has a `flake.nix` with a `devShells` output, prefer
`nix develop` to enter the project's declared environment:

```bash
# If flake.nix exists in the project root
nix develop
```

## Finding the Right Package Name

If you're not sure of the exact package name in nixpkgs, search for it:

```bash
nix search nixpkgs <query>
```

For example:
```bash
nix search nixpkgs python3     # finds python3, python311, python312, etc.
nix search nixpkgs rust         # finds rustc, cargo, rust-analyzer, etc.
nix search nixpkgs "tree-sitter"
```

Some common mappings where the package name differs from the command name:

| Command    | Nix package                        |
|------------|------------------------------------|
| `python`   | `nixpkgs#python3`                  |
| `node`     | `nixpkgs#nodejs`                   |
| `tsc`      | `nixpkgs#typescript`               |
| `prettier` | `nixpkgs#nodePackages.prettier`    |
| `eslint`   | `nixpkgs#nodePackages.eslint`      |
| `rg`       | `nixpkgs#ripgrep`                  |
| `fd`       | `nixpkgs#fd`                       |
| `bat`      | `nixpkgs#bat`                      |
| `delta`    | `nixpkgs#delta`                    |
| `http`     | `nixpkgs#httpie`                   |
| `convert`  | `nixpkgs#imagemagick`              |

## Decision Checklist

When you need a tool, follow this order:

1. **Is it already in $PATH?** → Just use it.
2. **Quick one-off command?** → `nix run nixpkgs#pkg -- args`
3. **Need it for several commands in a row?** → `nix shell nixpkgs#pkg` then work normally.
4. **Project has a flake.nix with devShell?** → `nix develop`
5. **Can't find the package?** → `nix search nixpkgs <query>` to discover it.

## Things to Avoid

- **Don't use `apt-get install`, `brew install`, or similar.** These modify system
  state and may not even be available. Nix works everywhere.
- **Don't use `pip install`, `npm install -g`, or `cargo install` for CLI tools.**
  Use `nix run` or `nix shell` instead. (Project-local `npm install` or
  `pip install -e .` inside a venv is fine — that's dependency management, not
  tool acquisition.)
- **Don't use `nix-env -i`** (the legacy imperative install). It's the old way
  and creates hidden mutable state. Stick with `nix run` and `nix shell`.
- **Don't use `nix-shell`** (legacy). Use `nix shell` or `nix develop` (flakes
  equivalents) instead.

## Handling Errors

If `nix run` fails with "does not provide attribute", the package name is wrong.
Try `nix search nixpkgs <partial-name>` to find the correct one.

If you see "experimental feature 'flakes' is disabled", Nix flakes aren't
enabled on this system. Add the flag explicitly:

```bash
nix --extra-experimental-features 'nix-command flakes' run nixpkgs#jq -- '.name' file.json
```

Or suggest the user enable flakes permanently in their Nix config:

```
# ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```
