# Migration: git-crypt to sops-nix

## Overview

Migrate from git-crypt (Nix files with build-time values) to sops-nix (runtime secret files) using age encryption.

**Key insight**: Current secrets mix truly secret values with semi-public config. We'll use a two-tier approach:
- `config.nix` - non-secret build-time values (username, domain, email, sshPort)
- sops YAML files - actual secrets (passwords, API keys, private keys)

## File Structure

```
secrets/
  .sops.yaml              # sops configuration with age keys
  keys/                   # age public keys per host
    oberon.txt
    setebos.txt
    titania.txt
    uranus.txt
  common.yaml             # shared secrets (intelephense license, etc.)
  oberon.yaml             # server secrets (authelia, services, etc.)
  desktop.yaml            # desktop secrets (VPN configs, etc.)
  work.yaml               # work-specific secrets (SMB, SSH keys, cert)
config.nix                # non-secret build-time values (committed to git)
```

## config.nix (Non-Secret Build-Time Values)

```nix
{
  username = "michael";
  name = "Michael";
  email = "email@example.com";
  keyid = "0xBFA6A82102FF1B7A";

  domain = {
    home = "example.com";
    work = "work.example.com";
  };

  sshPort = 22222;

  # Semi-public location (for home-assistant)
  location = {
    lat = "...";
    lon = "...";
    city = "...";
  };
}
```

## Migration Phases

### Phase 1: Setup Infrastructure

1. Add sops-nix to flake inputs
2. Create `config.nix` with extracted build-time values
3. Generate age keys on each host: `age-keygen -o /var/lib/sops-nix/key.txt`
4. Create `.sops.yaml` with host public keys
5. Update `flake.nix` to import config.nix as `cfg`

### Phase 2: Create sops Secret Files

Convert current secrets to YAML format:

**secrets/oberon.yaml:**
```yaml
netcup:
  customer_number: "..."
  api_key: "..."
  api_password: "..."
authelia:
  jwt_secret: "..."
  storage_encryption_key: "..."
  session_secret: "..."
  oidc_hmac_secret: "..."
  oidc_issuer_private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    ...
  users: |
    users:
      michael:
        password: $argon2id$...
  oidc:
    paperless: "$pbkdf2-sha512$..."
    immich: "..."
    # etc.
vaultwarden:
  environment: |
    ADMIN_TOKEN=...
restic:
  repository: "..."
  password: "..."
  environment: |
    AWS_ACCESS_KEY_ID=...
# etc.
```

### Phase 3: Update Modules (by category)

**A. Replace `secrets.base.*` with `cfg.*` (40+ files)**
- `secrets.base.username` → `cfg.username`
- `secrets.base.email` → `cfg.email`
- `secrets.base.name` → `cfg.name`
- `secrets.base.keyid` → `cfg.keyid`

**B. Replace `secrets.*.domain` with `cfg.domain.*`**
- `secrets.pi.domain` → `cfg.domain.home`
- `secrets.work.domain` → `cfg.domain.work`

**C. Replace `secrets.home.sshPort` with `cfg.sshPort`**

**D. Convert service secrets to sops (oberon services)**

Example pattern for services:
```nix
# Before
environment.etc."vaultwarden/env".text = secrets.pi.vaultwarden.environment;

# After
sops.secrets."vaultwarden/environment" = {
  sopsFile = ../secrets/oberon.yaml;
  owner = "vaultwarden";
};
services.vaultwarden.environmentFile = config.sops.secrets."vaultwarden/environment".path;
```

**E. Convert VPN configs (use configFile)**
```nix
# Before
networking.wg-quick.interfaces.home = secrets.home.vpn;

# After
sops.secrets."vpn/home".sopsFile = ../secrets/desktop.yaml;
networking.wg-quick.interfaces.home.configFile = config.sops.secrets."vpn/home".path;
```

**F. Use sops templates for complex interpolation (Caddy)**
```nix
sops.templates."caddy-netcup".content = ''
  acme_dns netcup {
    customer_number ${config.sops.placeholder."netcup/customer_number"}
    api_key ${config.sops.placeholder."netcup/api_key"}
    api_password ${config.sops.placeholder."netcup/api_password"}
  }
'';
```

### Phase 4: Cleanup

1. Remove git-crypt secrets files
2. Remove git-crypt from dependencies
3. Update `.gitattributes`
4. Test all hosts rebuild successfully

## Files to Modify

| File | Changes |
|------|---------|
| `flake.nix` | Add sops-nix input, import config.nix, remove secrets import |
| `modules/base/base.nix` | Replace secrets.base.username with cfg.username |
| `modules/base/nixos.nix` | Replace secrets.base.username with cfg.username |
| `modules/base/desktop.nix` | Replace secrets.base.username with cfg.username |
| `modules/programs/git.nix` | Replace secrets.base.* with cfg.* |
| `modules/programs/zsh.nix` | Replace secrets references |
| `modules/programs/neovim.nix` | Use sops for intelephense license |
| `modules/programs/firefox.nix` | Replace secrets.pi.domain with cfg.domain.home |
| `modules/features/vpn.nix` | Convert to sops configFile pattern |
| `modules/features/yubikey.nix` | Replace secrets.base.keyid with cfg.keyid |
| `modules/features/office.nix` | Convert work secrets to sops |
| `modules/services/caddy.nix` | Use sops templates for netcup |
| `modules/services/authelia.nix` | Convert all secrets to sops |
| `modules/services/*.nix` | Convert service secrets to sops |
| `modules/hosts/*.nix` | Add sops module, update secret references |

## New Files to Create

| File | Purpose |
|------|---------|
| `config.nix` | Non-secret build-time values |
| `secrets/.sops.yaml` | sops configuration |
| `secrets/keys/*.txt` | Host age public keys |
| `secrets/common.yaml` | Shared secrets |
| `secrets/oberon.yaml` | Server secrets |
| `secrets/desktop.yaml` | Desktop secrets |
| `secrets/work.yaml` | Work-specific secrets |

## Verification

1. Generate age keys on test host
2. Create minimal sops secret file
3. Test `nix build .#nixosConfigurations.uranus.config.system.build.toplevel`
4. Deploy to one host, verify services start
5. Gradually migrate remaining hosts

## Commands

```bash
# Generate age key on each host
sudo mkdir -p /var/lib/sops-nix
age-keygen -o /var/lib/sops-nix/key.txt
age-keygen -y /var/lib/sops-nix/key.txt  # Get public key

# Create encrypted secrets file
sops secrets/oberon.yaml

# Edit existing secrets
sops secrets/oberon.yaml

# Rotate keys
sops updatekeys secrets/oberon.yaml
```
