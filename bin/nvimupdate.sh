set -e

function info() {
  local blue="\033[0;34m"
  local nc="\033[0m"
  echo -e "$blue$1$nc"
}

function run() {
  echo "-> $*"
  "$@" >> "$NEOVIM_DIR.log" || cat "$NEOVIM_DIR.log"
}

function changes() {
  local upstream
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}")

  local ahead_behind
  read -ra ahead_behind <<< "$(git rev-list --left-right --count "$upstream...HEAD")"

  local -i behind=${ahead_behind[0]}

  if [[ $behind == 0 ]]; then
    info "No changes"
    return 1
  fi

  info "$behind new changes"
  git log --oneline "$upstream...HEAD"

  return 0
}

function patch() {
  local patchfile="$NEOVIM_DIR/snippet.patch"
  cat <<'EOF' > "$patchfile"
diff --git a/runtime/lua/vim/snippet.lua b/runtime/lua/vim/snippet.lua
index a880bf019..396956d15 100644
--- a/runtime/lua/vim/snippet.lua
+++ b/runtime/lua/vim/snippet.lua
@@ -2,8 +2,8 @@ local G = vim.lsp._snippet_grammar
 local snippet_group = vim.api.nvim_create_augroup('vim/snippet', {})
 local snippet_ns = vim.api.nvim_create_namespace('vim/snippet')
 local hl_group = 'SnippetTabstop'
-local jump_forward_key = '<tab>'
-local jump_backward_key = '<s-tab>'
+local jump_forward_key = '<c-l>'
+local jump_backward_key = '<c-h>'
 
 --- Returns the 0-based cursor position.
 ---
EOF

  git apply "$patchfile"
  rm -f "$patchfile"
}

function install() {
  info "Installing"
  run sudo make CMAKE_BUILD_TYPE=RelWithDebInfo install
}

function main() {
  ASAN=0
  FORCE=0

  while [[ $# -gt 0 ]]; do
    case $1 in
      -a) ASAN=1 ;;
      -f) FORCE=1 ;;
    esac
    shift
  done

  run rm -f "$NEOVIM_DIR.log"

  if [[ ! -d "$NEOVIM_DIR/.git" ]]; then
    run rm -rf "$NEOVIM_DIR"
    info "Cloning neovim"
    run git clone https://github.com/neovim/neovim --depth 1 --quiet "$NEOVIM_DIR"
    FORCE=1
  fi

  run cd "$NEOVIM_DIR"

  if ! git diff --exit-code; then
    info "Local changes!"
    exit
  fi

  info "Fetching updates"
  run git fetch

  if ((!FORCE)) && ! changes; then
    info "Done!"
    exit
  fi

  info "Rebasing"
  run git rebase

  info "Cleaning workspace"
  run make distclean

  info "Applying snippet patch"
  run patch

  if ((ASAN)); then
    info "Building (ASAN enabled)"
    run make CMAKE_EXTRA_FLAGS="-DCMAKE_C_COMPILER=clang -DENABLE_ASAN_UBSAN=1"
  else
    info "Building"
    run make CMAKE_BUILD_TYPE=RelWithDebInfo
  fi

  info "Installing"
  run sudo make CMAKE_BUILD_TYPE=RelWithDebInfo install

  info "Removing patched changes"
  git checkout .

  info "Done!"
}

main "$@"
