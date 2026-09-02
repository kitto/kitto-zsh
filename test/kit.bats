load helper

@test "kit i scaffolds with the current Svelte CLI" {
   make_stub bun
   make_stub bunx
   run_zsh 'kit i'
   [ "$status" -eq 0 ]
   assert_logged "bunx sv create ."
}

@test "kit up falls back to adapter-auto when there is no package.json" {
   make_stub bun
   run_zsh "cd \"$BATS_TEST_TMPDIR\" && kit up"
   [ "$status" -eq 0 ]
   assert_logged "bun install -D @sveltejs/kit @sveltejs/adapter-auto"
}

@test "kit up keeps the adapter the project already uses" {
   make_stub bun
   mkdir -p "$BATS_TEST_TMPDIR/proj"
   cat > "$BATS_TEST_TMPDIR/proj/package.json" <<'JSON'
{ "devDependencies": { "@sveltejs/adapter-node": "^5.0.0", "@sveltejs/kit": "^2.0.0" } }
JSON
   run_zsh "cd \"$BATS_TEST_TMPDIR/proj\" && kit up"
   [ "$status" -eq 0 ]
   assert_logged "bun install -D @sveltejs/kit @sveltejs/adapter-node"
   refute_logged "adapter-auto"
}

@test "kit without a subcommand prints usage" {
   make_stub bun
   run_zsh 'kit'
   [ "$status" -eq 1 ]
   [[ "$output" == *"usage: kit"* ]]
}

@test "kit fails clearly without bun" {
   run_zsh 'kit i'
   [ "$status" -eq 127 ]
   [[ "$output" == *"bun is required"* ]]
}
