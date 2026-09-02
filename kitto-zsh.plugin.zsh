# kitto-zsh — a backpack of zsh helpers for Mac JS development
# https://github.com/kitto/kitto-zsh

# Standard zero-handling so ${0} is this file's path under any plugin manager
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Set KITTO_ZSH_SKIP=(name ...) before sourcing to opt out of any function
typeset -ga KITTO_ZSH_SKIP

# Steps `upgrade` runs, in order — read when it runs, so edit or append any time
# (a user upgrade-<step> function adds a step or overrides a built-in)
typeset -ga KITTO_ZSH_UPGRADE
(( $#KITTO_ZSH_UPGRADE )) || KITTO_ZSH_UPGRADE=(brew node npm bun claude)

# bun shadows the real binary — only take over when bun itself exists
# (node is always defined: it installs fnm on first subcommand use and
#  passes everything else through to the real binary)
(( $+commands[bun] )) || KITTO_ZSH_SKIP+=(bun)

# strip our own entries first so re-sourcing (reload) doesn't pile up duplicates
fpath=("${0:A:h}/functions" "${0:A:h}/completions" ${fpath:#${0:A:h}/*})

for _kitto_zsh_fn in "${0:A:h}"/functions/*(N.:t); do
   # skip first: a skipped name may be the user's own function, which must survive
   (( ${KITTO_ZSH_SKIP[(Ie)$_kitto_zsh_fn]} )) && continue
   # drop any already-loaded copy so re-sourcing (reload) picks up new versions
   (( $+functions[$_kitto_zsh_fn] )) && unfunction "$_kitto_zsh_fn"
   autoload -Uz "$_kitto_zsh_fn"
done
unset _kitto_zsh_fn

# vault-managed exports (the file holds names only — values come from the keychain)
if (( $+functions[vault] )) && [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/kitto-zsh/vault.zsh" ]]; then
   source "${XDG_CONFIG_HOME:-$HOME/.config}/kitto-zsh/vault.zsh"
fi
