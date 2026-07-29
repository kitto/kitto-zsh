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

@test "starter-kit copies certs from KITTO_ZSH_CERT_PATH" {
   make_stub bun
   make_stub bunx
   mkdir -p "$BATS_TEST_TMPDIR/certs" "$BATS_TEST_TMPDIR/proj"
   touch "$BATS_TEST_TMPDIR/certs/localhost.pem" "$BATS_TEST_TMPDIR/certs/localhost-key.pem"
   run_zsh "cd \"$BATS_TEST_TMPDIR/proj\"
      export KITTO_ZSH_CERT_PATH=\"$BATS_TEST_TMPDIR/certs\"
      starter-kit"
   [ "$status" -eq 0 ]
   assert_logged "bunx degit https://github.com/mattpilott/starter-kit ."
   [ -f "$BATS_TEST_TMPDIR/proj/localhost.pem" ]
   [ -f "$BATS_TEST_TMPDIR/proj/localhost-key.pem" ]
   refute_logged "mkcert"
}

@test "starter-kit mints certs with mkcert when no cert path is set" {
   make_stub bun
   make_stub bunx
   make_stub mkcert
   run_zsh 'starter-kit'
   [ "$status" -eq 0 ]
   assert_logged "mkcert -install"
   assert_logged "mkcert localhost"
}

@test "starter-kit installs mkcert via brew when missing" {
   make_stub bun
   make_stub bunx
   make_stub mkcert
   mv "$STUB_DIR/mkcert" "$STUB_DIR/mkcert.pending"
   make_stub brew '
[ "$1" = "install" ] && [ "$2" = "mkcert" ] && mv "'"$STUB_DIR"'/mkcert.pending" "'"$STUB_DIR"'/mkcert"'
   run_zsh 'starter-kit'
   [ "$status" -eq 0 ]
   assert_logged "brew install mkcert nss"
   assert_logged "mkcert localhost"
}

@test "starter-kit skips certs gracefully with no mkcert and no brew" {
   make_stub bun
   make_stub bunx
   run_zsh 'starter-kit'
   [ "$status" -eq 0 ]
   [[ "$output" == *"skipped https certs"* ]]
}
