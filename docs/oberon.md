# Oberon Notes

## Building Error

```bash
nix build nixpkgs\#{failed-package} --system aarch64-linux --fallback
```

## Services

See [services.md](services.md) for a full reference.

## Cachix

See [cachix.md](cachix.md) for pushing the Raspberry Pi kernel to Cachix.
