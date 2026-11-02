load helper

@test "plugin loads in a bare shell and registers functions" {
   run_zsh 'whence -w upgrade node kit starter-kit mdn git-prune'
   [ "$status" -eq 0 ]
   [[ "$output" == *"upgrade: function"* ]]
   [[ "$output" == *"node: function"* ]]
   [[ "$output" == *"kit: function"* ]]
   [[ "$output" == *"starter-kit: function"* ]]
   [[ "$output" == *"mdn: function"* ]]
   [[ "$output" == *"git-prune: function"* ]]
}

@test "KITTO_ZSH_SKIP opts out of individual functions" {
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      KITTO_ZSH_SKIP=(upgrade node)
      source \"$PLUGIN\"
      whence -w upgrade; whence -w node; whence -w mdn
   "
   [[ "$output" != *"upgrade: function"* ]]
   [[ "$output" != *"node: function"* ]]
   [[ "$output" == *"mdn: function"* ]]
}

@test "node without fnm still runs the real binary" {
   make_stub node
   run_zsh 'node --version'
   [ "$status" -eq 0 ]
   assert_logged "node --version"
   refute_logged "fnm"
}

@test "bun is not shadowed when bun is absent" {
   run_zsh 'whence -w bun || true'
   [[ "$output" != *"bun: function"* ]]
}

@test "re-sourcing the plugin replaces stale loaded functions" {
   make_security
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      export XDG_CONFIG_HOME=\"$BATS_TEST_TMPDIR/config\"
      vault() { echo OLD-IMPLEMENTATION }
      source \"$PLUGIN\"
      vault MY_TOKEN
   "
   [ "$status" -eq 0 ]
   [[ "$output" == "s3cret-value" ]]
   [[ "$output" != *"OLD-IMPLEMENTATION"* ]]
}

@test "bun is shadowed when it exists" {
   make_stub bun
   run_zsh 'whence -w bun'
   [ "$status" -eq 0 ]
   [[ "$output" == *"bun: function"* ]]
}

@test "KITTO_ZSH_SKIP leaves a user's own function of that name intact" {
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      upgrade() { echo MY-OWN-UPGRADE }
      KITTO_ZSH_SKIP=(upgrade)
      source \"$PLUGIN\"
      upgrade
   "
   [ "$status" -eq 0 ]
   [[ "$output" == *"MY-OWN-UPGRADE"* ]]
}

@test "re-sourcing the plugin doesn't duplicate fpath entries" {
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      source \"$PLUGIN\"; source \"$PLUGIN\"
      print -l \$fpath | grep -c kitto-zsh
   "
   [ "$output" -eq 2 ]
}

@test "functions still load once our fpath entries are gone" {
   make_stub node
   run_zsh 'fpath=(${fpath:#*kitto-zsh*}); node --version'
   [ "$status" -eq 0 ]
   assert_logged "node --version"
}
