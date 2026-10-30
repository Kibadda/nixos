# AGENTS.md — NixOS flake configuration

Single flake (flake-parts + import-tree, nixpkgs `nixos-26.05`, home-manager, disko)
that builds NixOS configurations for 5 hosts: `oberon` (aarch64 RPi server),
`ophelia` (aarch64 mobile-nixos phone), `titania`/`setebos`/`uranus` (x86_64 desktops).

## Validation

```sh
git add <new files>          # flakes only see git-tracked files — this step is required
nix flake check              # what CI runs (.github/workflows/nix-flake-check.yml)
```

There is no formatter, linter, or test suite — `nix flake check` is the whole
verification step. It evaluates every host, so it is slow. Faster targeted checks:

```sh
# Evaluate a single host without building
nix eval .#nixosConfigurations.titania.config.system.build.toplevel.drvPath

# Dump the service registry of a host
nix eval .#nixosConfigurations.oberon.config.kibadda.services --json
```

Known non-local failure: evaluating `oberon` can fail with `immich-2.7.5 … marked as
insecure` (a nixpkgs-side known-vulnerability flag, not something you broke). Do not
chase it as a regression from your change.

## Secrets are git-crypt encrypted

`secrets/**` is encrypted with git-crypt (`.gitattributes`). Evaluation only works on
an unlocked checkout — on a fresh clone run `git-crypt unlock` (alias: `git unlock`)
first; CI unlocks with `GIT_CRYPT_KEY`. If evaluation dies with nonsense syntax
errors inside `secrets/*.nix`, the checkout is locked, not broken.

Secrets are injected as flake-parts `specialArgs` (`flake.nix`) as
`secrets.{base,pi,home,work}`. **Only the outer file function can take
`{ secrets, ... }` as a parameter** — inner NixOS/home-manager modules are
evaluated with `specialArgs = { selfpkgs }` only, so they reference `secrets`
through lexical closure from the enclosing outer function (see
`modules/services/immich.nix`). Never hardcode values that exist in secrets.

**Never write secrets into `secrets/*.nix` yourself.** Reference them as if they
existed and tell the user to add the value.

`docs/sops-nix-migration.md` is a *planned* migration, not the current state — the
repo still uses git-crypt.

## Module development

Layout under `modules/`:

| Dir | Holds |
|-----|-------|
| `base/` | foundation layers: `base`, `desktop`, `server` (+ flake wiring) |
| `features/` | composable features (gnome, vpn, yubikey, nvidia, …) |
| `programs/` | single-program configs (git, zsh, neovim, …) |
| `services/` | NixOS services + the service registry (`services/base.nix`) |
| `packages/` | custom packages exposed via `perSystem` |
| `hosts/` | per-machine wiring — keep thin |

Two-layer structure: the *outer* file is a flake-parts module that exports

```nix
flake.homeModules.<name> = { ... }: { ... };   # home-manager module
flake.nixosModules.<name> = { ... }: { ... };  # NixOS module
perSystem = { pkgs, ... }: { packages.<name> = ...; };  # custom packages
```

and the *inner* function is the actual module. File names: lowercase-with-hyphens.

Gotchas that are easy to miss:

- **import-tree auto-imports every `.nix` under `modules/`** (default: only paths
  containing `/_` are skipped, so `_helpers.nix` stays private). There is no import
  list to update — but every imported file must be a valid flake-parts module; a
  broken or non-module `.nix` file breaks the whole flake.
- **A module exists only once added to a host's `nixosModules`/`homeModules` list**
  in `modules/hosts/*.nix` (or via `imports = [ self.nixosModules.x ]` from another
  module). Exporting it does nothing by itself.
- All custom options live under the **`kibadda.*` namespace** — no bare top-level
  options.
- Custom packages are consumed through the `selfpkgs` specialArg
  (e.g. `home.packages = [ selfpkgs.gitdirty ]`).
- Common pattern: defaults + user override via
  `lib.recursiveUpdate { ...base config... } config.kibadda.<name>.settings`
  (see `modules/programs/git.nix`).

### Host schema (non-standard — read `modules/base/nixos.nix` first)

Hosts do not call `nixosSystem` directly; they fill an option set:

```nix
nixosConfigurations.<host> = {
  system = "x86_64-linux";
  configuration = { };            # NixOS overrides
  home = { };                     # home-manager overrides
  nixosModules = [ self.nixosModules.desktop ... ];
  homeModules  = [ self.homeModules.desktop ... ];
  hardware = { }; disko = { };    # optional
  nixpkgs = inputs.<...>;         # optional, defaults to main nixpkgs
};
```

`nixpkgs.hostPlatform`, hostname, home-manager user wiring, and `stateVersion`
are applied centrally — don't repeat them per host.

### Service modules must register in the service registry

New services set `kibadda.services.<name>` (defined in `modules/services/base.nix`);
caddy, authelia, backups, and the dashboard all consume `builtins.attrValues
config.kibadda.services`, so an unregistered service gets no proxy/auth/backup.

```nix
kibadda.services.myservice = {
  description = "Short human name";   # required, no default
  subdomain = "myservice";            # → <subdomain>.<secrets.pi.domain>
  host = "127.0.0.1"; port = 8080;    # both optional (defaults: "localhost"/null).
                                      # port = null → no reverse_proxy emitted,
                                      # proxy yourself via `extra` (see freshrss)
  auth = "oidc";                      # required: "none" | "oidc" | "forward"
  open = false;                       # false → caddy IP-allowlists the vhost to
                                      # secrets.pi.ip; true → reachable anywhere
  policy = "one_factor";              # only for auth = "forward" (default one_factor)
  backup = {
    archive = [ "/var/lib/myservice" ];  # tar.gz → S3 (restorable)
    sync = [ "/mnt/data" ];              # aws s3 sync (live data)
  };
  section = "Apps";                   # optional: "Monitoring" | "Tools" | "Apps"
  oidc = { redirect_uris = [ ... ]; method = "post"; };  # required when auth = "oidc"
};
```

- `auth = "forward"` → caddy runs forward_auth against authelia, gated by `policy`.
- `auth = "oidc"` → the app does OIDC login itself; authelia auto-registers a
  client using `secrets.pi.authelia.oidc.<name>` — **that secret must already
  exist**, so a new OIDC service needs the user to add it.
- `url`/`hostname` are read-only derived values — reference
  `config.kibadda.services.<name>.url` instead of building URLs by hand.

## Generated docs & git hook

`docs/services.md` is **generated, never hand-edit it** — from
`nix eval .#nixosConfigurations.oberon.config.kibadda.services` via
`scripts/generate-oberon-services.sh` (needs `nix` + `jq`; skips gracefully if absent).

`.githooks/pre-commit` regenerates and stages it whenever staged changes touch
`modules/services/**` or `modules/hosts/oberon.nix`. Hooks are **not active by
default** — enable once per clone:

```sh
git config core.hooksPath .githooks
```

If you change service modules without the hook, run the script manually and commit
`docs/services.md` together with your change.

## Conventions

- Commit messages: conventional commits scoped to the module or host
  (`feat(oberon): …`, `fix(zsh): …`, `chore: flake update`).
- `.envrc` runs `use flake . -Lv` (direnv auto-loads the devshell).
- `opencode.json` wires up the `mcp-nixos` MCP server — use it for nixpkgs/NixOS
  option lookups instead of guessing option names.
