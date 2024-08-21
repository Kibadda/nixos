# NixOS configuration

## TODOs
- chrome/chiaki missing visuals
- neomutt

## Installation

### Boot Live USB

### Get git
```console
nix-env -iA nixos.git
```

### Clone repo
```console
git clone https://github.com/Kibadda/nixos /tmp/nixos
```

### Choose hostname
```console
export HOSTNAME=whatever
```

### Partition
```console
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/nixos/machines/$HOSTNAME/disko-config.nix
```

### Generate config
```console
sudo nixos-generate-config --no-filesystems --root /mnt
```

### Copy hardware-configuration.nix
```console
cp /mnt/etc/nixos/hardware-configuration.nix /tmp/nixos/machines/$HOSTNAME/hardware-configuration.nix
```

#### hardware-configuration.nix not in version control
add index
```console
git -C /tmp/nixos add .
```

#### hardware-configuration.nix in version control
check diff
```console
git -C /tmp/nixos diff
```

### Install
```console
sudo nixos-install --flake /tmp/nixos#$HOSTNAME
```

### Reboot
```console
sudo reboot now
```

### Add u2f keys
make sure the yubikey is plugged in
```console
nix-shell -p pam_u2f --run 'mkdir -p $HOME/.config/Yubico && pamu2fcfg > $HOME/.config/Yubico/u2f_keys'
```
