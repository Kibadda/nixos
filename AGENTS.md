# Module Development Rules for NixOS Configuration

This document provides rules and patterns for adding new modules to this NixOS configuration project using flakes and home-manager.

## 1. Directory Structure

| Module Type | Location | Purpose |
|-------------|----------|---------|
| Foundation/framework | `modules/base/` | Core system setup (base, desktop, server) |
| Feature bundles | `modules/features/` | Composable features (gnome, vpn, yubikey) |
| Program configs | `modules/programs/` | Individual program setup (git, zsh, neovim) |
| Server services | `modules/services/` | Service definitions (caddy, immich, authelia) |
| Custom packages | `modules/packages/` | Package definitions as flake outputs |
| Host configs | `modules/hosts/` | Per-machine wiring |

## 2. Module Export Naming

```nix
# Home-manager module
flake.homeModules.<name> = { ... };

# NixOS module
flake.nixosModules.<name> = { ... };

# Custom package (use perSystem)
perSystem = { pkgs, ... }: {
  packages.<name> = pkgs.writeShellApplication { ... };
};
```

**File naming:** lowercase with hyphens (e.g., `config-checker.nix`)

## 3. Option Namespacing

All custom options **must** use the `kibadda.*` namespace:

```nix
options.kibadda.<module> = {
  settings = lib.mkOption { type = lib.types.attrs; default = {}; };
  # ...
};
```

## 4. Module Patterns

### Pattern A: Simple wrapper (for single-purpose program configs)

```nix
{
  flake.homeModules.eza = {
    programs.eza = {
      enable = true;
      git = true;
    };
  };
}
```

### Pattern B: With custom options (for extensible configs)

```nix
{
  lib,
  ...
}:
{
  flake.homeModules.git = { config, pkgs, ... }: {
    options.kibadda.git = {
      settings = lib.mkOption { type = lib.types.attrs; default = {}; };
    };

    config.programs.git = lib.recursiveUpdate {
      enable = true;
      # base config...
    } config.kibadda.git.settings;
  };
}
```

### Pattern C: Dual module (when both NixOS and home-manager needed)

```nix
{
  flake.homeModules.zsh = { ... }: { ... };
  flake.nixosModules.zsh = { ... }: { ... };
}
```

## 5. Service Module Pattern

Services **must** register with the service registry in `services/base.nix`:

```nix
{ self, secrets, ... }: {
  flake.nixosModules.myservice = { config, pkgs, ... }: {
    kibadda.services.myservice = {
      subdomain = "myservice";
      host = "127.0.0.1";
      port = 8080;
      auth = "oidc";  # or "forward" or "none"
      backup = {
        paths = [ "/var/lib/myservice" ];
        time = "03:00";
      };
    };

    services.myservice = {
      enable = true;
      # ...
    };
  };
}
```

## 6. Secrets Access

Secrets are passed via `specialArgs` - access them as function parameters:

```nix
{
  secrets,
  ...
}:
{
  flake.nixosModules.foo = {
    # Use secrets.base.username, secrets.home.vpn, etc.
  };
}
```

Available secret files:
- `secrets.base` - username, email, keyid, intelephense license
- `secrets.pi` - domain, IP, authelia secrets, netcup DNS
- `secrets.home` - SSH port, WiFi, VPN config
- `secrets.work` - email, smb config, certificate, ssh hosts

**Never** add secrets to the secret files. Use them as if they were there and instruct the user to add them.

## 7. Custom Packages

Access custom packages via `selfpkgs`:

```nix
flake.homeModules.neovim = { selfpkgs, ... }: {
  home.packages = [ selfpkgs.nvimupdate ];
};
```

## 8. Module Dependencies

Import base modules when extending them:

```nix
{
  self,
  ...
}:
{
  flake.nixosModules.desktop = {
    imports = [ self.nixosModules.base ];
    # ...
  };
}
```

## 9. Host Configuration

Hosts wire modules together - keep them thin:

```nix
nixosConfigurations.hostname = {
  system = "x86_64-linux";
  configuration = { };  # Host-specific NixOS overrides
  home = { };           # Host-specific home-manager overrides
  nixosModules = [
    self.nixosModules.desktop
    self.nixosModules.gnome
    # ...
  ];
  homeModules = [
    self.homeModules.desktop
    self.homeModules.git
    # ...
  ];
  hardware = { /* filesystems, boot, etc. */ };
  disko = { /* disk layout */ };
};
```

## 10. Module Checklist

When adding a new module:

- [ ] Place in correct directory (`programs/`, `features/`, `services/`, etc.)
- [ ] Use `kibadda.*` namespace for custom options
- [ ] Export as `flake.homeModules.<name>` or `flake.nixosModules.<name>`
- [ ] Access secrets via function parameter, not hardcoded
- [ ] For services: register with `kibadda.services.<name>`
- [ ] Import parent modules if extending (e.g., `self.nixosModules.base`)
- [ ] No manual registration needed - `import-tree` auto-discovers modules
- [ ] Add to host's `nixosModules`/`homeModules` list to enable

## 11. Anti-Patterns to Avoid

- Hardcoding values that exist in secrets
- Creating circular dependencies between modules
- Putting host-specific logic in shared modules (use options instead)
- Skipping the service registry for new services
- Using top-level options without `kibadda.*` prefix

## 12. Validation

After changing settings or adding new modules, run:

```sh
nix flake check
```

Don't forget to add new files to the git index before running this command via `git add <file>`.
