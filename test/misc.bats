load helper

@test "git-prune deletes only branches whose upstream is gone" {
   make_stub git '
if [ "$1" = "branch" ] && [ "$2" = "-vv" ]; then
cat <<OUT
* main       1234567 [origin/main] latest
  feature-a  2345678 [origin/feature-a: gone] old work
  feature-b  3456789 [origin/feature-b] active
OUT
fi'
   run_zsh 'git-prune'
   [ "$status" -eq 0 ]
   assert_logged "git fetch --prune"
   assert_logged "git branch -d feature-a"
   refute_logged "git branch -d feature-b"
   refute_logged "git branch -d main"
}

@test "mdn queries web-features-cli with baseline sections" {
   make_stub bun
   make_stub bunx
   run_zsh 'mdn dialog'
   [ "$status" -eq 0 ]
   assert_logged "bunx web-features-cli dialog -s baseline -s docs -n 3"
}

@test "mdn without an argument prints usage" {
   make_stub bun
   run_zsh 'mdn'
   [ "$status" -eq 1 ]
   [[ "$output" == *"usage: mdn"* ]]
}

@test "starter-kit degits, certifies, then runs bun up" {
   make_stub bun
   make_stub bunx
   make_stub mkcert
   mkdir -p "$BATS_TEST_TMPDIR/proj"
   run_zsh "cd \"$BATS_TEST_TMPDIR/proj\" && starter-kit </dev/null"
   [ "$status" -eq 0 ]
   assert_logged "bunx degit https://github.com/kitto/starter-kit ."
   assert_logged "mkcert -install"
   assert_logged "mkcert localhost"
   assert_logged "bun update -i --latest"
   assert_logged "bun dev"
}

@test "starter-kit degits via pnpm and skips bun up without bun" {
   make_stub pnpm
   make_stub mkcert
   run_zsh 'starter-kit </dev/null'
   [ "$status" -eq 0 ]
   assert_logged "pnpm dlx degit https://github.com/kitto/starter-kit ."
   assert_logged "mkcert localhost"
   refute_logged "bun update"
   [[ "$output" == *"skipped bun up"* ]]
}

@test "starter-kit degits via npx when only npm exists" {
   make_stub npm
   make_stub npx
   make_stub mkcert
   run_zsh 'starter-kit </dev/null'
   [ "$status" -eq 0 ]
   assert_logged "npx --yes degit https://github.com/kitto/starter-kit ."
}

@test "starter-kit fails clearly with no runner at all" {
   run_zsh 'starter-kit'
   [ "$status" -eq 127 ]
   [[ "$output" == *"bun, pnpm or npm is required"* ]]
}

@test "certify defaults to localhost when the prompt gets no input" {
   make_stub mkcert
   run_zsh 'certify </dev/null'
   assert_logged "mkcert -install"
   assert_logged "mkcert localhost"
}

@test "certify uses the domain typed at the prompt" {
   make_stub mkcert
   run_zsh 'certify <<< "example.com"'
   [ "$status" -eq 0 ]
   assert_logged "mkcert -install"
   assert_logged "mkcert example.com"
}

@test "certify accepts domains as arguments" {
   make_stub mkcert
   run_zsh 'certify example.com "*.example.com"'
   [ "$status" -eq 0 ]
   assert_logged "mkcert example.com *.example.com"
   refute_logged "mkcert localhost"
}

@test "certify installs mkcert and nss via brew when missing" {
   make_stub mkcert
   mv "$STUB_DIR/mkcert" "$STUB_DIR/mkcert.pending"
   make_stub brew '
[ "$1" = "install" ] && [ "$2" = "mkcert" ] && mv "'"$STUB_DIR"'/mkcert.pending" "'"$STUB_DIR"'/mkcert"'
   run_zsh 'certify localhost'
   [ "$status" -eq 0 ]
   assert_logged "brew install mkcert nss"
   assert_logged "mkcert localhost"
}

@test "certify fails clearly with no mkcert and no brew" {
   run_zsh 'certify localhost'
   [ "$status" -eq 127 ]
   [[ "$output" == *"mkcert is required"* ]]
}
