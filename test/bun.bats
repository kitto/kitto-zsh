load helper

@test "bun up runs the interactive update and nothing destructive" {
   make_stub bun
   mkdir -p "$BATS_TEST_TMPDIR/proj/node_modules"
   touch "$BATS_TEST_TMPDIR/proj/bun.lock"
   run_zsh "cd \"$BATS_TEST_TMPDIR/proj\" && bun up"
   [ "$status" -eq 0 ]
   assert_logged "bun update -i --latest"
   refute_logged "bun install"
   [ -d "$BATS_TEST_TMPDIR/proj/node_modules" ]
   [ -f "$BATS_TEST_TMPDIR/proj/bun.lock" ]
}

@test "bun up --clean reinstalls from scratch" {
   make_stub bun
   mkdir -p "$BATS_TEST_TMPDIR/proj/node_modules"
   touch "$BATS_TEST_TMPDIR/proj/bun.lock"
   run_zsh "cd \"$BATS_TEST_TMPDIR/proj\" && bun up --clean"
   [ "$status" -eq 0 ]
   assert_logged "bun update -i --latest"
   assert_logged "bun install"
   [ ! -d "$BATS_TEST_TMPDIR/proj/node_modules" ]
   [ ! -f "$BATS_TEST_TMPDIR/proj/bun.lock" ]
}

@test "bun up never starts a dev server" {
   make_stub bun
   run_zsh 'bun up'
   refute_logged "bun dev"
}

@test "bun passes everything else through" {
   make_stub bun
   run_zsh 'bun run build'
   [ "$status" -eq 0 ]
   assert_logged "bun run build"
}
