{ pkgs }:
pkgs.writeShellApplication {
  name = "ophelia-landscape-toggle";
  runtimeInputs = [
    pkgs.hyprland
    pkgs.jq
  ];
  text = ''
    transform=1
    if [[ $(hyprctl monitors -j | jq ".[].transform") == 1 ]]; then
      transform=0
    fi

    hyprctl keyword "monitor DSI-1,transform,$transform"
    hyprctl keyword "device[synaptics-s3706b]:transform $transform"
  '';
}
