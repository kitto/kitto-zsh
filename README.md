# kitto-zsh

A backpack of zsh helpers for Mac JS development. Companion to [kitto](https://github.com/kitto/kitto).

Everything autoloads, so shell startup costs a single `fpath` append — plus one keychain lookup per secret you have auto-exported with `vault`.

## What's inside

| Function | What it does |
|---|---|
| `upgrade` | One command to update everything: brew (update, upgrade, doctor, cleanup) → node → npm → bun. Skips anything you don't have installed. |
| `node upgrade` | Installs the latest LTS and latest node via [fnm](https://github.com/Schniz/fnm), uninstalls every other version, keeps your current default channel. Installs fnm itself (via brew) on first run. |
| `node lts` / `node latest` | Switch your fnm default channel. Everything else passes through to the real `node`. |
| `bun up` | Interactive `bun update -i --latest`, then wipes `node_modules` + the lockfile (`bun.lock` or the older `bun.lockb`), reinstalls fresh and starts `bun dev`. Stops early if the update fails or you cancel it. |
| `kit i` | Scaffold a SvelteKit project in the current directory (`bunx sv create .`). |
| `kit up` | Update `@sveltejs/kit` and whichever `@sveltejs/adapter-*` the project already uses (`adapter-auto` if none). |
| `starter-kit` | Degit [kitto/starter-kit](https://github.com/kitto/starter-kit) into the current directory (via bun, pnpm or npm — whichever you have), mint https certs with `certify`, then `bun up`. |
| `certify` | Mint trusted local https certs with [mkcert](https://github.com/FiloSottile/mkcert), installing mkcert + nss via brew if needed. Prompts for a domain (default `localhost`), or pass domains directly: `certify example.com`. |
| `mdn <feature>` | Baseline status + MDN docs for a web feature, via [web-features-cli](https://www.npmjs.com/package/web-features-cli). |
| `git-prune` | Delete local branches whose upstream is gone. Force-deletes (`-D`), because squash-merged branches never look merged to git and a gone upstream is exactly that case. Never touches the current branch or one checked out in a worktree. |
| `vault` | Keep api keys and tokens in the macOS keychain instead of your dotfiles. `vault` prompts for the secret (input hidden) and a name, then exports it automatically — live in the current shell and every new one, so `process.env.NAME` just works. Use `vault -n` to store without exporting, `vault export NAME` to export later, `vault NAME` to grab a value (clipboard at a terminal, raw inside `$(…)`), and `vault list` / `vault rm NAME` to manage. Secrets never appear in argv, shell history, on screen, or in any file — the auto-export manifest holds names only. |

## Install

### Homebrew

```zsh
brew install kitto/tap/kitto-zsh && kitto-zsh init
```

`kitto-zsh init` wires the plugin into your `~/.zshrc` (idempotent — safe to re-run). Prefer doing it yourself? Add:

```zsh
source $(brew --prefix)/opt/kitto-zsh/kitto-zsh.plugin.zsh
```

### antidote / zinit / sheldon

```zsh
antidote bundle kitto/kitto-zsh
```

### oh-my-zsh

```zsh
git clone https://github.com/kitto/kitto-zsh $ZSH_CUSTOM/plugins/kitto-zsh
```

```zsh
plugins=(git brew npm kitto-zsh)
```

### No manager

```zsh
git clone https://github.com/kitto/kitto-zsh ~/.kitto-zsh
```

```zsh
source ~/.kitto-zsh/kitto-zsh.plugin.zsh
```

## Completions

Tab completion for `kit`, `node` and `vault` ships in `completions/`. The plugin adds it to `fpath`, but `compinit` has to run *after* the plugin is sourced for it to take effect. oh-my-zsh and most plugin managers already do this — with the Homebrew or no-manager install, make sure your `compinit` call comes later in `.zshrc`.

## Requirements

macOS with zsh. Each function checks for its own dependencies ([Homebrew](https://brew.sh), [fnm](https://github.com/Schniz/fnm), [bun](https://bun.sh), git) and tells you what's missing rather than erroring cryptically — `upgrade` simply skips sections it can't run.

`node` and `bun` are wrapper functions around the real binaries, and any arguments they don't recognise fall straight through — so plain `node script.js` and `bun test` behave exactly as before. `bun` is only defined when bun is on `PATH` at the moment the plugin is sourced — so source the plugin *after* anything that sets up bun's `PATH` (the same goes for fnm). `node` is always defined and installs fnm on the first subcommand that needs it.

Heads up that `bun up` is deliberately aggressive: it wipes `node_modules` and `bun.lock` after the update, reinstalls, and starts the dev server. If that's not your workflow, skip it with `KITTO_ZSH_SKIP=(bun)`.

## Opting out

`upgrade` (and `node`/`bun`) are generic names to claim in your shell. Skip any function you don't want by setting this **before** the plugin loads:

```zsh
KITTO_ZSH_SKIP=(upgrade node)
source /path/to/kitto-zsh.plugin.zsh
```

## License

[MIT](LICENSE.md)
