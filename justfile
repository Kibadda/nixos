set positional-arguments

hostname := `hostname -s`
ssh_port := `nix eval --raw --impure --expr 'toString (import ./secrets/home.nix).sshPort'`

default:
  @just --list

check:
  nix flake check

switch host=hostname:
  nixos-rebuild switch --flake ".#{{host}}" --sudo

deploy host:
  NIX_SSHOPTS='-p {{ssh_port}}' nixos-rebuild switch --flake ".#{{host}}" --target-host "{{host}}" --sudo --ask-sudo-password

sdbuild host:
  nixos-rebuild build-image --image-variant sd-card --flake ".#{{host}}"
