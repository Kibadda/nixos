# Desktop

This pretends that git, git-crypt and disko are installed on the live usb.

1. export key
```bash
git-crypt export-key EXPORTED_KEY.gpg
```

2. use psitransfer to transfer exported key to new host

3. clone github repository
```bash
git clone https://github.com/Kibadda/nixos /tmp/nixos
```

4. unlock git-crypt
```bash
git unlock EXPORTED_KEY.gpg
```

5. export hostname
```bash
export HOST=hostname
```

6. disko
```bash
disko --mode destroy,format,mount --flake /tmp/nixos#$HOST
```

7. generate hardware-config and update in host
```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

8. nixos install
```bash
sudo nixos-install --flake /tmp/nixos#$HOST
```

9. reboot
```bash
reboot now
```

10. generate u2f keys
```bash
nix-shell -p pam_u2f --run 'mkdir -p $HOME/.config/Yubico && pamu2fcfg > $HOME/.config/Yubico/u2f_keys'
```

# Pi

```console
nix build .#nixosConfigurations.pi.config.system.build.sdImage

sudo dd if=TODO of=/dev/sdX bs=4096 conv=fsync status=progress
```
