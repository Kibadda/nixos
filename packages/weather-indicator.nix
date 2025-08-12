{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "weather-indicator";
  runtimeInputs = [
    pkgs.curl
    pkgs.toybox
  ];
  text = ''
    for _ in {1..5}
    do
      if ! text=$(curl -s "https://wttr.in/Ulm+Germany?format=1");
      then
        text=$(echo "$text" | sed -E "s/\s+/ /g")
        echo "$text"
        exit
      fi
      sleep 2
    done
    echo ""
  '';
}
