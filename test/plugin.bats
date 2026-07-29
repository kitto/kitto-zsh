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

@test "bun is shadowed when it exists" {
   make_stub bun
   run_zsh 'whence -w bun'
   [ "$status" -eq 0 ]
   [[ "$output" == *"bun: function"* ]]
}
