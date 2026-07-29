# kitto-zsh

A backpack of zsh helpers for Mac JS development. Companion to [kitto](https://github.com/mattpilott/kitto).

Everything autoloads, so the cost to your shell startup is a single `fpath` append.

## What's inside

| Function | What it does |
|---|---|
| `upgrade` | One command to update everything: brew (update, upgrade, doctor, cleanup) → node → npm → bun. Skips anything you don't have installed. |
| `node upgrade` | Installs the latest LTS and latest node via [fnm](https://github.com/Schniz/fnm), uninstalls every other version, keeps your current default channel. |
| `node lts` / `node latest` | Switch your fnm default channel. Everything else passes through to the real `node`. |
| `bun up` | Interactive `bun update -i --latest`. Add `--clean` to also wipe `node_modules` + `bun.lock` and reinstall from scratch. |
| `kit i` | Scaffold a SvelteKit project in the current directory (`bunx sv create .`). |
| `kit up` | Update `@sveltejs/kit` and `@sveltejs/adapter-auto`. |
| `starter-kit` | Degit [mattpilott/starter-kit](https://github.com/mattpilott/starter-kit) into the current directory. |
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

`node` and `bun` are wrapper functions around the real binaries. They only get defined when their backing tool exists (`node` requires fnm), and any arguments they don't recognise fall straight through — so plain `node script.js` and `bun test` behave exactly as before.

## Opting out

`upgrade` (and `node`/`bun`) are generic names to claim in your shell. Skip any function you don't want by setting this **before** the plugin loads:

```zsh
KITTO_ZSH_SKIP=(upgrade node)
source /path/to/kitto-zsh.plugin.zsh
```

## License

[MIT](LICENSE.md)
