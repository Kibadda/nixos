if playerctl -p spotify status 1>/dev/null 2>/dev/null; then
  status=""

  if [ $(playerctl -p spotify status) == "Paused" ]; then
    status=""
  fi

  song=$(playerctl -p spotify metadata --format "{{ artist }} - {{ title }}")
  time=$(playerctl -p spotify metadata --format "{{ duration(position) }} / {{ duration(mpris:length) }}")

  echo "  $song  $status  $time"
else
  echo "  spotify not running"
fi
