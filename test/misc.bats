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

@test "starter-kit degits the public template" {
   make_stub bun
   make_stub bunx
   run_zsh 'starter-kit'
   [ "$status" -eq 0 ]
   assert_logged "bunx degit https://github.com/mattpilott/starter-kit ."
}
