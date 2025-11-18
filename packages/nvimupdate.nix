{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "nvimupdate";
  runtimeInputs = [
    pkgs.gnumake
    pkgs.cmake
    pkgs.gettext
  ];
  text = ''
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

      local -i behind=''${ahead_behind[0]}

      if [[ $behind == 0 ]]; then
        info "No changes"
        return 1
      fi

      info "$behind new changes"
      git log --oneline "$upstream...HEAD"

      return 0
    }

    function main() {
      FORCE=0

      while [[ $# -gt 0 ]]; do
        case $1 in
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

      info "Building"
      run make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=~/.local/share/

      info "Installing"
      run make install

      info "Done!"
    }

    main "$@"
  '';
}
