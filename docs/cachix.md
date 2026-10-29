# Pushing the Raspberry Pi Kernel to Cachix

Oberon runs on a Raspberry Pi 4 and uses the vendor kernel from
`nixos-hardware` (`linux-rpi-*`). That kernel is not available from
`cache.nixos.org`, so Nix has to compile it. Pushing it to Cachix means the
next build can download it instead of recompiling it under QEMU.

You can push it manually from `uranus`, or let the [GitHub Actions
workflow](#github-actions) build it on a native arm64 runner.

## Prerequisites

These apply to manual pushes. The GitHub Actions workflow builds the kernel
itself.

- The kernel build has finished. `cachix push` fails if the store path is not
  valid yet.
- Run the commands on the machine that has the built kernel (normally
  `uranus`).
- The `kibadda` Cachix cache, already configured in
  `modules/base/base.nix`.
- A Cachix auth token from
  <https://app.cachix.org/personal-auth-tokens>.
- Run the commands from a normal `x86_64` shell, not from an `aarch64` `nix
  shell`.

## 1. Get the kernel store paths

From the repository root:

```console
KERNEL=$(nix eval --raw \
  .#nixosConfigurations.oberon.config.boot.kernelPackages.kernel.outPath)
MODULES=$(nix eval --raw \
  .#nixosConfigurations.oberon.config.boot.kernelPackages.kernel.modules.outPath)

echo "$KERNEL"
echo "$MODULES"
```

For the current nixos-hardware revision this is:

```text
/nix/store/kslpi6b1vbizhakjvnnaf0awwhn4c86k-linux-rpi-6.18.50-stable_20260911
/nix/store/y0q2qv1s2rfbha2479v5dcgsmkf4lcjb-linux-rpi-6.18.50-stable_20260911-modules
```

The paths change when `nixos-hardware` or `nixpkgs` is updated, so always use
the `nix eval` commands above rather than copying the paths manually.

## 2. Authenticate

```console
nix run nixpkgs#cachix -- authtoken <token>
```

The token is stored in `~/.config/cachix/cachix.dhall`.

## 3. Push the kernel and modules

```console
nix run nixpkgs#cachix -- push kibadda "$KERNEL" "$MODULES"
```

`cachix push` uploads each path and its runtime closure. Cachix automatically
skips paths that are already available from `cache.nixos.org`, so this mostly
uploads just the Raspberry Pi kernel and its modules.

The `dev` output is not needed for booting and does not have to be pushed.

## 4. Configure Nix to use the cache

Add the cache to `modules/base/base.nix` so all hosts use it:

```nix
nix.settings = {
  extra-substituters = [
    "https://cache.numtide.com"
    "https://kibadda.cachix.org"
  ];
  extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    "kibadda.cachix.org-1:5Hlak2ZLPMRbEbFvPbyuVhBeYdbTTayTrYuuaLLUl/g="
  ];
};
```

The public key is shown by `cachix use kibadda` or in the Cachix dashboard.
Do not use `cachix use` alone on NixOS: it writes to `/etc/nix/nix.conf`, which
is generated from the NixOS configuration and will be overwritten on the next
rebuild.

After updating the module, rebuild the machine that should use the cache:

```console
sudo nixos-rebuild switch --flake .#uranus
```

## 5. Verify

Check that the cache knows about the kernel:

```console
nix path-info --store https://kibadda.cachix.org "$KERNEL"
```

Then run a switch and confirm the kernel is downloaded instead of built:

```console
switch oberon
```

## Optional: cache the whole system

Pushing only the kernel and modules is enough to avoid the expensive compile.
The initrd and other custom paths can be cached by pushing the system
toplevel:

```console
SYSTEM=$(nix eval --raw .#nixosConfigurations.oberon.config.system.build.toplevel.outPath)
nix run nixpkgs#cachix -- push kibadda "$SYSTEM"
```

The full system closure is about 13 GB uncompressed, but Cachix skips
`cache.nixos.org` paths and compresses entries, so the actual usage is much
smaller. Check the storage usage in the Cachix dashboard.

Do **not** push the SD card image. Its closure is about 27 GB.

## Optional: push automatically during builds

`watch-exec` uploads new store paths while a command runs:

```console
nix run nixpkgs#cachix -- watch-exec kibadda -- \
  nixos-rebuild switch --flake .#oberon \
    --target-host oberon \
    --sudo --ask-sudo-password
```

This can upload more than just the kernel, depending on what the build
produces.

## GitHub Actions

`.github/workflows/build-oberon-kernel.yml` builds the kernel and modules on
GitHub's native arm64 runner and pushes them to Cachix. This avoids compiling
under QEMU on `uranus` and is much faster than building on the Pi.

### Setup

1. Add a repository secret named `CACHIX_AUTH_TOKEN` with a Cachix personal
   auth token from <https://app.cachix.org/personal-auth-tokens>.
2. The workflow reuses the existing `GIT_CRYPT_KEY` secret from
   `.github/workflows/nix-flake-check.yml` to unlock the encrypted
   `secrets/*.nix` files.
3. The workflow pushes to the `kibadda` cache, matching
   `modules/base/base.nix`.

The workflow runs manually via **Actions → Build Oberon kernel → Run
workflow**, or on pushes to `main` that change `flake.lock`. Changes to the
kernel wiring (`modules/base/base.nix`, `modules/base/server.nix`,
`modules/hosts/oberon.nix`) or the workflow itself do not trigger it
automatically; run it manually when such a change should refresh the cache.

### Runner and limits

- `ubuntu-24.04-arm` is a native arm64 runner. Public repositories get 4 vCPU,
  16 GB RAM, and 14 GB disk; private repositories currently get 2 vCPU.
- The workflow builds only the kernel and modules, not the full system. The
  14 GB disk is tight for a kernel build, so the workflow removes unused
  preinstalled toolchains first.
- The job has a 180-minute timeout. A native arm64 build should finish well
  within that; an x86_64 runner using QEMU would risk the 6-hour limit.
- The runner builds the committed flake. Commit and push any local changes
  first so the resulting store path matches what `uranus` expects.
- The workflow runs only on manual dispatch and pushes to `main`, not on pull
  requests. This avoids trying to use secrets in pull requests from forks.
- The workflow uses `skipPush: true` and an explicit `cachix push`, so only
  the kernel `out` and `modules` outputs are uploaded, not the whole build
  closure.

### If the git-crypt action fails on arm64

`sliteteam/github-action-git-crypt-unlock` is a Docker action. If it does not
run on the arm64 runner, replace that step with:

```yaml
- name: Unlock git-crypt
  env:
    GIT_CRYPT_KEY: ${{ secrets.GIT_CRYPT_KEY }}
  run: |
    sudo apt-get update
    sudo apt-get install -y git-crypt
    echo "$GIT_CRYPT_KEY" | base64 -d > /tmp/git-crypt.key
    git-crypt unlock /tmp/git-crypt.key
    rm /tmp/git-crypt.key
```

### Manual run

```console
gh workflow run build-oberon-kernel.yml
```

After it finishes, verify the cache from `uranus` with the command in
[Verify](#5-verify).

## Free tier notes

- The free Cachix plan has a 5 GB limit for open source caches.
- Private caches may require a paid plan.
- Entries already present in `cache.nixos.org` are not stored in Cachix by
  default.
- The kernel and modules are about 170 MB uncompressed, well within the free
  tier.
