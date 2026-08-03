load helper

# security stub: logs argv, captures -i batch commands from stdin, serves canned finds
make_security() {
   make_stub security '
case "$1" in
   -i) cat > "'"$STUB_DIR"'/security.stdin" ;;
   find-generic-password) printf "s3cret-value" ;;
   dump-keychain) cat "'"$STUB_DIR"'/dump.txt" 2>/dev/null ;;
esac'
}

@test "vault stores via security -i batch stdin — secret never in argv" {
   make_security
   run_zsh 'vault <<< "s3cret-value
MY_TOKEN"'
   [ "$status" -eq 0 ]
   assert_logged "security -i"
   refute_logged "s3cret-value"
   grep -qxF 'add-generic-password -U -a "kitto-vault" -s "MY_TOKEN" -w "s3cret-value"' "$STUB_DIR/security.stdin"
}

@test "vault escapes quotes and backslashes for the batch command" {
   make_security
   run_zsh 'vault -n <<< "pa\"ss\\word
MY_TOKEN"'
   [ "$status" -eq 0 ]
   grep -qxF 'add-generic-password -U -a "kitto-vault" -s "MY_TOKEN" -w "pa\"ss\\word"' "$STUB_DIR/security.stdin"
}

@test "vault add auto-exports: manifest line, no secret in it, live in current shell" {
   make_security
   run_zsh 'vault <<< "s3cret-value
MY_TOKEN"
print -r -- "live:$MY_TOKEN"'
   [ "$status" -eq 0 ]
   MANIFEST="$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh"
   grep -qxF 'export MY_TOKEN="$(vault MY_TOKEN)"' "$MANIFEST"
   ! grep -q "s3cret-value" "$MANIFEST"
   [[ "$output" == *"live:s3cret-value"* ]]
}

@test "re-adding a name doesn't duplicate its manifest line" {
   make_security
   run_zsh 'vault <<< "s3cret-value
MY_TOKEN"
vault <<< "new-value
MY_TOKEN"'
   [ "$(grep -c '^export MY_TOKEN=' "$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh")" -eq 1 ]
}

@test "vault -n stores without exporting" {
   make_security
   run_zsh 'vault -n <<< "s3cret-value
MY_TOKEN"'
   [ "$status" -eq 0 ]
   [[ "$output" == *"Stored in the keychain"* ]]
   [ ! -f "$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh" ]
}

@test "a name that isn't a valid env var still stores but isn't exported" {
   make_security
   run_zsh 'vault <<< "s3cret-value
my token"'
   [ "$status" -eq 0 ]
   [[ "$output" == *"isn't a valid env var name"* ]]
   grep -qxF 'add-generic-password -U -a "kitto-vault" -s "my token" -w "s3cret-value"' "$STUB_DIR/security.stdin"
   [ ! -f "$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh" ]
}

@test "vault export adds an already-stored secret to the manifest" {
   make_security
   run_zsh 'vault export MY_TOKEN && print -r -- "live:$MY_TOKEN"'
   [ "$status" -eq 0 ]
   grep -qxF 'export MY_TOKEN="$(vault MY_TOKEN)"' "$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh"
   [[ "$output" == *"live:s3cret-value"* ]]
}

@test "vault rm drops the manifest line too" {
   make_security
   run_zsh 'vault <<< "s3cret-value
MY_TOKEN"
vault rm MY_TOKEN'
   [ "$status" -eq 0 ]
   ! grep -q '^export MY_TOKEN=' "$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh"
}

@test "the plugin sources the manifest at startup" {
   make_security
   mkdir -p "$BATS_TEST_TMPDIR/config/kitto-zsh"
   echo 'export MY_TOKEN="$(vault MY_TOKEN)"' > "$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh"
   run_zsh 'print -r -- "boot:$MY_TOKEN"'
   [ "$status" -eq 0 ]
   [[ "$output" == *"boot:s3cret-value"* ]]
}

@test "a manifest is harmless when vault is skipped" {
   make_security
   mkdir -p "$BATS_TEST_TMPDIR/config/kitto-zsh"
   echo 'export MY_TOKEN="$(vault MY_TOKEN)"' > "$BATS_TEST_TMPDIR/config/kitto-zsh/vault.zsh"
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      export XDG_CONFIG_HOME=\"$BATS_TEST_TMPDIR/config\"
      KITTO_ZSH_SKIP=(vault)
      source \"$PLUGIN\"
      print -r -- \"boot:\$MY_TOKEN\"
   "
   [ "$status" -eq 0 ]
   [[ "$output" == *"boot:"* ]]
   [[ "$output" != *"command not found"* ]]
}

@test "vault rejects an empty secret" {
   make_security
   run_zsh 'vault <<< ""'
   [ "$status" -eq 1 ]
   [[ "$output" == *"nothing entered"* ]]
   refute_logged "add-generic-password"
}

@test "vault NAME emits the secret for command substitution when piped" {
   make_security
   run_zsh 'vault MY_TOKEN'
   [ "$status" -eq 0 ]
   [ "$output" = "s3cret-value" ]
   assert_logged "security find-generic-password -a kitto-vault -s MY_TOKEN -w"
}

@test "vault NAME fails clearly for an unknown name" {
   make_stub security 'exit 44'
   run_zsh 'vault NOPE'
   [ "$status" -eq 1 ]
   [[ "$output" == *"no secret called NOPE"* ]]
}

@test "vault list shows stored names" {
   make_security
   cat > "$STUB_DIR/dump.txt" <<'OUT'
keychain: "/Users/x/Library/Keychains/login.keychain-db"
    "acct"<blob>="other-app"
    "svce"<blob>="not-ours"
keychain: "/Users/x/Library/Keychains/login.keychain-db"
    "acct"<blob>="kitto-vault"
    "svce"<blob>="MY_TOKEN"
keychain: "/Users/x/Library/Keychains/login.keychain-db"
    "acct"<blob>="kitto-vault"
    "svce"<blob>="OTHER_KEY"
OUT
   run_zsh 'vault list'
   [ "$status" -eq 0 ]
   [[ "$output" == *"MY_TOKEN"* ]]
   [[ "$output" == *"OTHER_KEY"* ]]
   [[ "$output" != *"not-ours"* ]]
}

@test "vault rm deletes by name" {
   make_security
   run_zsh 'vault rm MY_TOKEN'
   [ "$status" -eq 0 ]
   assert_logged "security delete-generic-password -a kitto-vault -s MY_TOKEN"
   [[ "$output" == *"removed MY_TOKEN"* ]]
}
