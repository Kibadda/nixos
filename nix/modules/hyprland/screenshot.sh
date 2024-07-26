#!/bin/sh

clip=0
area=0

for arg in "$@" do
  case $arg in
    clip) clip=1 ;;
    area) area=1 ;;
  esac
done

if [ $clip -eq 1 ]; then
  if [ $area -eq 1 ]; then
    grim -g "$(slurp)" - | wl-copy
  else
    grim - | wl-copy
  fi
else
  dir="$HOME/Pictures"
  [[ -d $dir ]] || mkdir $dir

  filename="$dir/$(date +'%Y-%m-%d_%H:%M:%S_grim.png')"

  if [ $area -eq 1]; then
    grim -g "$(slurp)" "$filename"
  else
    grim "$filename"
  fi
fi
