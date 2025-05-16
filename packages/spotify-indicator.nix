{ pkgs }:
pkgs.writeShellApplication {
  name = "spotify-indicator";
  runtimeInputs = [
    pkgs.playerctl
    pkgs.toybox
  ];
  text = ''
    if playerctl -p spotify status 1>/dev/null 2>/dev/null; then
      status=""

      if [ "$(playerctl -p spotify status)" == "Paused" ]; then
        status=""
      fi

      artist=$(playerctl -p spotify metadata --format "{{ artist }}")
      song=$(playerctl -p spotify metadata --format "{{ title }}")
      time=$(playerctl -p spotify metadata --format "{{ duration(position) }} / {{ duration(mpris:length) }}")

      echo "  $artist - ''${song:0:25}  $status  $time"
    else
      echo "  spotify not running"
    fi
  '';
}
