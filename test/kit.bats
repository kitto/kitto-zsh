load helper

@test "kit i scaffolds with the current Svelte CLI" {
   make_stub bun
   make_stub bunx
   run_zsh 'kit i'
   [ "$status" -eq 0 ]
   assert_logged "bunx sv create ."
}

@test "kit up updates the SvelteKit packages" {
   make_stub bun
   run_zsh 'kit up'
   [ "$status" -eq 0 ]
   assert_logged "bun install -D @sveltejs/kit @sveltejs/adapter-auto"
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
