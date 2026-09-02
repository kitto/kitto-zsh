load helper

@test "upgrade runs every section when all tools exist" {
   make_stub brew
   make_stub npm
   make_stub bun
   make_stub claude
   make_stub fnm '
case "$1" in
   list) printf "* v22.12.0 default, lts-latest\n" ;;
   exec) echo "v22.12.0" ;;
esac'
   run_zsh 'upgrade'
   [ "$status" -eq 0 ]
   assert_logged "brew update"
   assert_logged "brew upgrade"
   assert_logged "brew doctor"
   assert_logged "brew cleanup"
   assert_logged "fnm install --lts"
   assert_logged "npm i npm -g"
   assert_logged "bun upgrade"
   assert_logged "claude update"
   [[ "$output" == *"All up to date"* ]]
}

@test "upgrade skips or degrades sections whose tool is missing and still finishes" {
   run_zsh 'upgrade'
   [ "$status" -eq 0 ]
   [[ "$output" == *"Homebrew (skipped"* ]]
   [[ "$output" == *"fnm is required"* ]]
   [[ "$output" == *"npm (skipped"* ]]
   [[ "$output" == *"Bun (skipped"* ]]
   [[ "$output" == *"Claude Code (skipped"* ]]
   [[ "$output" == *"All up to date"* ]]
}

@test "the plugin gives KITTO_ZSH_UPGRADE the default step list, but keeps a preset one" {
   run_zsh 'print -r -- "$KITTO_ZSH_UPGRADE"'
   [ "$output" = "brew node npm bun claude" ]
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      KITTO_ZSH_UPGRADE=(bun)
      source \"$PLUGIN\"
      print -r -- \"\$KITTO_ZSH_UPGRADE\"
   "
   [ "$output" = "bun" ]
}

@test "KITTO_ZSH_UPGRADE picks the steps and their order, including user-defined ones" {
   make_stub brew
   make_stub bun
   make_stub rustup
   run_zsh 'upgrade-rust() { rustup update }
KITTO_ZSH_UPGRADE=(rust bun brew)
upgrade'
   [ "$status" -eq 0 ]
   refute_logged "npm"
   [ "$(grep -n . "$KITTO_TEST_LOG" | grep rustup | cut -d: -f1)" -lt "$(grep -n . "$KITTO_TEST_LOG" | grep 'bun upgrade' | cut -d: -f1)" ]
   [ "$(grep -n . "$KITTO_TEST_LOG" | grep 'bun upgrade' | cut -d: -f1)" -lt "$(grep -n . "$KITTO_TEST_LOG" | grep 'brew update' | cut -d: -f1)" ]
   [[ "$output" == *"→ rust"* ]]
}

@test "a user upgrade-<step> function overrides the built-in of the same name" {
   make_stub brew
   run_zsh 'upgrade-brew() { echo CUSTOM-BREW }
KITTO_ZSH_UPGRADE=(brew)
upgrade'
   [ "$status" -eq 0 ]
   [[ "$output" == *"CUSTOM-BREW"* ]]
   refute_logged "brew update"
}

@test "an unknown step is reported with the naming convention and the run continues" {
   make_stub bun
   run_zsh 'KITTO_ZSH_UPGRADE=(nope bun); upgrade'
   [ "$status" -eq 0 ]
   [[ "$output" == *"nope (skipped — no built-in step or upgrade-nope function)"* ]]
   assert_logged "bun upgrade"
   [[ "$output" == *"All up to date"* ]]
}

@test "step names as arguments run just those, ignoring KITTO_ZSH_UPGRADE" {
   make_stub brew
   make_stub npm
   make_stub bun
   run_zsh 'upgrade bun npm'
   [ "$status" -eq 0 ]
   assert_logged "bun upgrade"
   assert_logged "npm i npm -g"
   refute_logged "brew"
}
