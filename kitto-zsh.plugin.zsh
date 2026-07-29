# kitto-zsh — a backpack of zsh helpers for Mac JS development
# https://github.com/mattpilott/kitto-zsh

# Standard zero-handling so ${0} is this file's path under any plugin manager
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Set KITTO_ZSH_SKIP=(name ...) before sourcing to opt out of any function
typeset -ga KITTO_ZSH_SKIP

# node and bun shadow real binaries — only take over when their backing tool exists
(( $+commands[fnm] )) || KITTO_ZSH_SKIP+=(node)
(( $+commands[bun] )) || KITTO_ZSH_SKIP+=(bun)

fpath=("${0:A:h}/functions" "${0:A:h}/completions" $fpath)

for _kitto_zsh_fn in "${0:A:h}"/functions/*(N.:t); do
   (( ${KITTO_ZSH_SKIP[(Ie)$_kitto_zsh_fn]} )) && continue
   autoload -Uz "$_kitto_zsh_fn"
done
unset _kitto_zsh_fn
