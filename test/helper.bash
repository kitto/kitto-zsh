# Shared helpers: run plugin code in a bare zsh with stubbed binaries on PATH.

setup() {
   PLUGIN="$BATS_TEST_DIRNAME/../kitto-zsh.plugin.zsh"
   STUB_DIR="$BATS_TEST_TMPDIR/stubs"
   export KITTO_TEST_LOG="$BATS_TEST_TMPDIR/calls.log"
   mkdir -p "$STUB_DIR"
   : > "$KITTO_TEST_LOG"
}

# make_stub <name> [extra shell body] — logs every invocation to $KITTO_TEST_LOG
make_stub() {
   local name=$1 body=${2:-}
   cat > "$STUB_DIR/$name" <<EOF
#!/bin/sh
echo "$name \$@" >> "\$KITTO_TEST_LOG"
$body
EOF
   chmod +x "$STUB_DIR/$name"
}

# run_zsh <zsh code> — bare zsh, stubs first on PATH, config isolated, plugin sourced
run_zsh() {
   run zsh -f -c "
      PATH=\"$STUB_DIR:/usr/bin:/bin\"
      export XDG_CONFIG_HOME=\"$BATS_TEST_TMPDIR/config\"
      source \"$PLUGIN\"
      $1
   "
}

# security stub: logs argv, captures -i batch commands from stdin, serves canned finds
make_security() {
   make_stub security '
case "$1" in
   -i) cat > "'"$STUB_DIR"'/security.stdin" ;;
   find-generic-password) printf "s3cret-value" ;;
   dump-keychain) cat "'"$STUB_DIR"'/dump.txt" 2>/dev/null ;;
esac'
}

assert_logged() {
   grep -qF "$1" "$KITTO_TEST_LOG" || {
      echo "expected log to contain: $1"
      echo "log was:"; cat "$KITTO_TEST_LOG"
      return 1
   } >&2
}

refute_logged() {
   ! grep -qF "$1" "$KITTO_TEST_LOG" || {
      echo "expected log NOT to contain: $1"
      echo "log was:"; cat "$KITTO_TEST_LOG"
      return 1
   } >&2
}
