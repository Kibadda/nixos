{ pkgs }:
pkgs.writeShellApplication {
  name = "setup-git-repos";
  text = ''
    function check_and_clone() {
      echo "checking $1"
      if [[ ! -d "$1" ]]; then
        echo "-> creating"
        mkdir -p "$1"
        git clone "git@github.com:Kibadda/$2" "$1" -q
      else
        echo "-> skipping"
      fi
    }

    check_and_clone "$PASSWORD_STORE_DIR" "password-store"
    check_and_clone "$NIXVIM_DIR" "nixvim"
    check_and_clone "$NEOVIM_DIR" "neovim"
  '';
}
