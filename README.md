# kitto-zsh

A backpack of zsh helpers for Mac JS development. Companion to [kitto](https://github.com/mattpilott/kitto).

Everything autoloads, so the cost to your shell startup is a single `fpath` append.

## What's inside

| Function | What it does |
|---|---|
| `upgrade` | One command to update everything: brew (update, upgrade, doctor, cleanup) → node → npm → bun. Skips anything you don't have installed. |
| `node upgrade` | Installs the latest LTS and latest node via [fnm](https://github.com/Schniz/fnm), uninstalls every other version, keeps your current default channel. Installs fnm itself (via brew) on first run. |
| `node lts` / `node latest` | Switch your fnm default channel. Everything else passes through to the real `node`. |
| `bun up` | Interactive `bun update -i --latest`, then wipes `node_modules` + `bun.lock`, reinstalls fresh and starts `bun dev`. |
| `kit i` | Scaffold a SvelteKit project in the current directory (`bunx sv create .`). |
| `kit up` | Update `@sveltejs/kit` and `@sveltejs/adapter-auto`. |
| `starter-kit` | Degit [mattpilott/starter-kit](https://github.com/mattpilott/starter-kit) into the current directory, then sort https certs: copies `localhost*.pem` from `$KITTO_ZSH_CERT_PATH` if you've set it, otherwise mints them with [mkcert](https://github.com/FiloSottile/mkcert) (installing mkcert + nss via brew if needed). |
| `mdn <feature>` | Baseline status + MDN docs for a web feature, via [web-features-cli](https://www.npmjs.com/package/web-features-cli). |
| `git-prune` | Delete local branches whose upstream is gone. |

## Install

### Homebrew

```zsh
brew install mattpilott/tap/kitto-zsh
```

Then add to `~/.zshrc`:

```zsh
source $(brew --prefix)/opt/kitto-zsh/kitto-zsh.plugin.zsh
```

### antidote / zinit / sheldon

```zsh
antidote bundle mattpilott/kitto-zsh
```

### oh-my-zsh

```zsh
git clone https://github.com/mattpilott/kitto-zsh $ZSH_CUSTOM/plugins/kitto-zsh
```

```zsh
plugins=(git brew npm kitto-zsh)
```

### No manager

```zsh
git clone https://github.com/mattpilott/kitto-zsh ~/.kitto-zsh
```

```zsh
source ~/.kitto-zsh/kitto-zsh.plugin.zsh
```

## Requirements

macOS with zsh. Each function checks for its own dependencies ([Homebrew](https://brew.sh), [fnm](https://github.com/Schniz/fnm), [bun](https://bun.sh), git) and tells you what's missing rather than erroring cryptically — `upgrade` simply skips sections it can't run.

`node` and `bun` are wrapper functions around the real binaries, and any arguments they don't recognise fall straight through — so plain `node script.js` and `bun test` behave exactly as before. `bun` is only defined when bun itself is installed; `node` is always defined and installs fnm on the first subcommand that needs it.

Heads up that `bun up` is deliberately aggressive: it wipes `node_modules` and `bun.lock` after the update, reinstalls, and starts the dev server. If that's not your workflow, skip it with `KITTO_ZSH_SKIP=(bun)`.

## Opting out

`upgrade` (and `node`/`bun`) are generic names to claim in your shell. Skip any function you don't want by setting this **before** the plugin loads:

```zsh
KITTO_ZSH_SKIP=(upgrade node)
source /path/to/kitto-zsh.plugin.zsh
```

## License

[MIT](LICENSE.md)
