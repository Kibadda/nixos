# NixOS configuration

## TODOs
- fonts not working
- flexible font sizes
- cursor

## Installation

### Boot Live USB

### Get git
```console
nix-env -iA nixos.git
```

### Clone repo
```console
git clone https://github.com/Kibadda/dotfiles /tmp/dotfiles
```

### Choose hostname
```console
export HOSTNAME=whatever
```

### Partition
```console
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/dotfiles/machines/$HOSTNAME/disko-config.nix
```

### Generate config
```console
sudo nixos-generate-config --no-filesystems --root /mnt
```

### Copy hardware-configuration.nix
```console
cp /mnt/etc/nixos/hardware-configuration.nix /tmp/dotfiles/machines/$HOSTNAME/hardware-configuration.nix
```

#### hardware-configuration.nix not in version control
```console
# add to index
git -C /tmp/dotfiles add .
```

#### hardware-configuration.nix in version control
```console
# check diff
git -C /tmp/dotfiles diff
```

### Install
```console
sudo nixos-install --flake /tmp/dotfiles#$HOSTNAME
```

### Reboot
```console
sudo reboot now
```

### Add u2f keys
```console
# make sure the yubikey is plugged in
nix-shell -p pam_u2f --run 'mkdir -p $HOME/.config/Yubico && pamu2fcfg > $HOME/.config/Yubico/u2f_keys'
```
