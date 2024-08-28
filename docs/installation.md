# Desktop

```console
nix-env -iA nixos.git

git clone https://github.com/Kibadda/nixos /tmp/nixos
```

```console
export HOSTNAME=uranus
```

```console
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/nixos/machines/$HOSTNAME/disko-config.nix
```

optionally generate hardware-configuration.nix

```console
sudo nixos-generate-config --no-filesystems --root /mnt

cp /mnt/etc/nixos/hardware-configuration.nix /tmp/nixos/machines/$HOSTNAME/hardware-configuration.nix
```

```console
sudo nixos-install --flake /tmp/nixos#$HOSTNAME

sudo reboot now
```

```console
nix-shell -p pam_u2f --run 'mkdir -p $HOME/.config/Yubico && pamu2fcfg > $HOME/.config/Yubico/u2f_keys'
```

# Pi

```console
sudo nix build .#nixosConfigurations.pi.config.system.build.sdImage

sudo dd if=TODO of=/dev/sdX bs=4096 conv=fsync status=progress
```
