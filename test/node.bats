load helper

# fnm stub that serves a canned `fnm list` and version lookups
make_fnm() {
   make_stub fnm '
case "$1" in
   list) cat "'"$STUB_DIR"'/fnm.list" ;;
   exec)
      case "$2" in
         --using=lts-latest) echo "v22.12.0" ;;
         --using=latest)     echo "v23.5.0" ;;
      esac ;;
esac'
}

@test "node upgrade prunes old versions and keeps lts + latest" {
   make_fnm
   cat > "$STUB_DIR/fnm.list" <<'OUT'
* v20.10.0
* v22.12.0 default, lts-latest
* v23.5.0 latest
OUT
   run_zsh 'node upgrade'
   [ "$status" -eq 0 ]
   assert_logged "fnm install --lts"
   assert_logged "fnm install --latest"
   assert_logged "fnm uninstall v20.10.0"
   refute_logged "fnm uninstall v22.12.0"
   refute_logged "fnm uninstall v23.5.0"
   assert_logged "fnm default lts-latest"
}

@test "node upgrade keeps a latest-channel default" {
   make_fnm
   cat > "$STUB_DIR/fnm.list" <<'OUT'
* v22.12.0 lts-latest
* v23.5.0 default, latest
OUT
   run_zsh 'node upgrade'
   [ "$status" -eq 0 ]
   assert_logged "fnm default latest"
}

@test "node upgrade defaults to lts when fnm has no default set" {
   make_fnm
   cat > "$STUB_DIR/fnm.list" <<'OUT'
* v23.5.0 latest
OUT
   run_zsh 'node upgrade'
   [ "$status" -eq 0 ]
   assert_logged "fnm default lts-latest"
}

@test "node passes plain args through to the real binary" {
   make_fnm
   make_stub node
   run_zsh 'node --version'
   [ "$status" -eq 0 ]
   assert_logged "node --version"
   refute_logged "fnm"
}

@test "node lts switches the fnm default" {
   make_fnm
   make_stub node
   run_zsh 'node lts'
   [ "$status" -eq 0 ]
   assert_logged "fnm default lts-latest"
   assert_logged "fnm use lts-latest"
   assert_logged "node -v"
}
