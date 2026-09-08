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

@test "kitto-zsh -v and --version print the version" {
   run zsh "$BIN" -v
   [ "$status" -eq 0 ]
   [[ "$output" == "kitto-zsh "[0-9]*.[0-9]*.[0-9]* ]]
   local short="$output"
   run zsh "$BIN" --version
   [ "$status" -eq 0 ]
   [ "$output" = "$short" ]
}

@test "a tagged commit's version matches its tag" {
   command -v git >/dev/null || skip "git not available"
   cd "$BATS_TEST_DIRNAME/.." || return 1
   local tag
   # only meaningful on a release commit — the bump lands before the tag does,
   # so an untagged HEAD has nothing to compare against
   tag="$(git describe --exact-match --tags HEAD 2>/dev/null)" || skip "HEAD is not tagged"
   run zsh "$BIN" -v
   [ "$output" = "kitto-zsh ${tag#v}" ]
}

@test "usage mentions both subcommands" {
   run zsh "$BIN" nonsense
   [ "$status" -eq 1 ]
   [[ "$output" == *"kitto-zsh init"* ]]
   [[ "$output" == *"--version"* ]]
}
