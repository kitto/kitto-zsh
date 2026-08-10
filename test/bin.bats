load helper

BIN="$BATS_TEST_DIRNAME/../bin/kitto-zsh"

@test "kitto-zsh init appends the source line to .zshrc" {
   ZDOTDIR="$BATS_TEST_TMPDIR" run zsh "$BIN" init
   [ "$status" -eq 0 ]
   grep -qF 'source "$(brew --prefix)/opt/kitto-zsh/kitto-zsh.plugin.zsh"' "$BATS_TEST_TMPDIR/.zshrc"
}

@test "kitto-zsh init is idempotent" {
   ZDOTDIR="$BATS_TEST_TMPDIR" zsh "$BIN" init
   ZDOTDIR="$BATS_TEST_TMPDIR" run zsh "$BIN" init
   [ "$status" -eq 0 ]
   [[ "$output" == *"already wired"* ]]
   [ "$(grep -c 'kitto-zsh.plugin.zsh' "$BATS_TEST_TMPDIR/.zshrc")" -eq 1 ]
}

@test "kitto-zsh with no subcommand prints usage" {
   run zsh "$BIN"
   [ "$status" -eq 1 ]
   [[ "$output" == *"usage: kitto-zsh init"* ]]
}
