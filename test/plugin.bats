load helper

@test "plugin loads in a bare shell and registers functions" {
   run_zsh 'whence -w upgrade kit starter-kit mdn git-prune'
   [ "$status" -eq 0 ]
   [[ "$output" == *"upgrade: function"* ]]
   [[ "$output" == *"kit: function"* ]]
   [[ "$output" == *"starter-kit: function"* ]]
   [[ "$output" == *"mdn: function"* ]]
   [[ "$output" == *"git-prune: function"* ]]
}

@test "KITTO_ZSH_SKIP opts out of individual functions" {
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      KITTO_ZSH_SKIP=(upgrade kit)
      source \"$PLUGIN\"
      whence -w upgrade; whence -w kit; whence -w mdn
   "
   [[ "$output" != *"upgrade: function"* ]]
   [[ "$output" != *"kit: function"* ]]
   [[ "$output" == *"mdn: function"* ]]
}

@test "node is not shadowed when fnm is absent" {
   run_zsh 'whence -w node || true'
   [[ "$output" != *"node: function"* ]]
}

@test "bun is not shadowed when bun is absent" {
   run_zsh 'whence -w bun || true'
   [[ "$output" != *"bun: function"* ]]
}

@test "node and bun are shadowed when their tools exist" {
   make_stub fnm
   make_stub bun
   run_zsh 'whence -w node bun'
   [ "$status" -eq 0 ]
   [[ "$output" == *"node: function"* ]]
   [[ "$output" == *"bun: function"* ]]
}
