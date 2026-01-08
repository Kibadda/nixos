{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "work";
  runtimeInputs = [
    pkgs.sshfs
    pkgs.sftpman
  ];
  text = ''
    work_vpn() {
      if [ "$1" == "up" ]; then
        sudo systemctl start wg-quick-work.service
      elif [ "$1" == "down" ]; then
        sudo systemctl stop wg-quick-work.service
      fi
    }

    work_sshfs() {
      if [ "$1" == "up" ]; then
        sftpman mount studies
        sftpman mount in
      elif [ "$1" == "down" ]; then
        sftpman umount studies
        sftpman umount in
      fi
    }

    work_smb() {
      if [ "$1" == "up" ]; then
        sudo mount -t cifs -o credentials=~/.smbcredentials,uid=1000,gid=1000 //192.168.22.3/team /mnt/team
        sudo mount -t cifs -o credentials=~/.smbcredentials,uid=1000,gid=1000 //192.168.22.3/temp /mnt/temp
      elif [ "$1" == "down" ]; then
        sudo umount /mnt/team
        sudo umount /mnt/temp
      fi
    }

    if [ "$1" == "up" ]; then
      work_vpn up
      work_sshfs up
      work_smb up
    elif [ "$1" == "down" ]; then
      work_smb down
      work_sshfs down
      work_vpn down
    elif [ "$1" == "vpn" ]; then
      work_vpn "$2"
    elif [ "$1" == "sshfs" ]; then
      work_sshfs "$2"
    elif [ "$1" == "smb" ]; then
      work_smb "$2"
    fi
  '';
}
