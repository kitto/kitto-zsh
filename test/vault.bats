load helper

# security stub: logs argv, captures stdin, serves canned finds
make_security() {
   make_stub security '
cat > "'"$STUB_DIR"'/security.stdin"
case "$1" in
   find-generic-password) printf "s3cret-value" ;;
   dump-keychain) cat "'"$STUB_DIR"'/dump.txt" 2>/dev/null ;;
esac'
}

@test "vault stores via stdin — secret never in argv" {
   make_security
   run_zsh 'vault <<< "s3cret-value
MY_TOKEN"'
   [ "$status" -eq 0 ]
   assert_logged "security add-generic-password -U -a kitto-vault -s MY_TOKEN -w"
   refute_logged "s3cret-value"
   grep -q "s3cret-value" "$STUB_DIR/security.stdin"
}

@test "vault confirms the secret twice on stdin for security's retype prompt" {
   make_security
   run_zsh 'vault <<< "s3cret-value
MY_TOKEN"'
   [ "$(grep -c "s3cret-value" "$STUB_DIR/security.stdin")" -eq 2 ]
}

@test "vault prints copiable usage after storing" {
   make_security
   run_zsh 'vault <<< "s3cret-value
MY_TOKEN"'
   [[ "$output" == *'$(vault MY_TOKEN)'* ]]
   [[ "$output" == *'export MY_TOKEN='* ]]
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
