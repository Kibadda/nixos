{ pkgs }:
pkgs.writeShellApplication {
  name = "home";
  text = ''
    if [ "$1" == "up" ]; then
      sudo systemctl start wg-quick-home.service
    elif [ "$1" == "down" ]; then
      sudo systemctl stop wg-quick-home.service
    fi
  '';
}
