load helper

@test "upgrade runs every section when all tools exist" {
   make_stub brew
   make_stub npm
   make_stub bun
   make_stub fnm '
case "$1" in
   list) printf "* v22.12.0 default, lts-latest\n" ;;
   exec) echo "v22.12.0" ;;
esac'
   run_zsh 'upgrade'
   [ "$status" -eq 0 ]
   assert_logged "brew update"
   assert_logged "brew upgrade"
   assert_logged "brew doctor"
   assert_logged "brew cleanup"
   assert_logged "fnm install --lts"
   assert_logged "npm i npm -g"
   assert_logged "bun upgrade"
   [[ "$output" == *"All up to date"* ]]
}

@test "upgrade skips sections whose tool is missing instead of aborting" {
   run_zsh 'upgrade'
   [ "$status" -eq 0 ]
   [[ "$output" == *"Homebrew (skipped"* ]]
   [[ "$output" == *"Node (skipped"* ]]
   [[ "$output" == *"npm (skipped"* ]]
   [[ "$output" == *"Bun (skipped"* ]]
   [[ "$output" == *"All up to date"* ]]
}
