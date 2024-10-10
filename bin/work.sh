work_vpn() {
  if [ "$1" == "up" ]; then
    sudo systemctl start wg-quick-work.service
  elif [ "$1" == "down" ]; then
    sudo systemctl stop wg-quick-work.service
  fi
}

work_sshfs() {
  if [ "$1" == "up" ]; then
    sshfs -o Ciphers=aes256-ctr,compression=no,auto_cache,reconnect,uid=1000,gid=1000 work-studies:/opt/studiesbeta /mnt/studiesbeta
  elif [ "$1" == "down" ]; then
    fusermount3 -u /mnt/studiesbeta
  fi
}

if [ "$1" == "up" ]; then
  work_vpn up
  work_sshfs up
elif [ "$1" == "down" ]; then
  work_sshfs down
  work_vpn down
elif [ "$1" == "vpn" ]; then
  work_vpn "$2"
elif [ "$1" == "sshfs" ]; then
  work_sshfs "$2"
fi
