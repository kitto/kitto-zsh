load helper

@test "bun up updates, reinstalls from scratch and starts dev" {
   make_stub bun
   mkdir -p "$BATS_TEST_TMPDIR/proj/node_modules"
   touch "$BATS_TEST_TMPDIR/proj/bun.lock"
   run_zsh "cd \"$BATS_TEST_TMPDIR/proj\" && bun up"
   [ "$status" -eq 0 ]
   assert_logged "bun update -i --latest"
   assert_logged "bun i"
   assert_logged "bun dev"
   [ ! -d "$BATS_TEST_TMPDIR/proj/node_modules" ]
   [ ! -f "$BATS_TEST_TMPDIR/proj/bun.lock" ]
}

@test "bun passes everything else through" {
   make_stub bun
   run_zsh 'bun run build'
   [ "$status" -eq 0 ]
   assert_logged "bun run build"
}
