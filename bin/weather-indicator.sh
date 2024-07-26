for i in {1..5}
do
  text=$(curl -s "https://wttr.in/Ulm+Germany?format=1")
  if [[ $? == 0 ]];
  then
    text=$(echo "$text" | sed -E "s/\s+/ /g")
    echo "$text"
    exit
  fi
  sleep 2
done
echo ""
