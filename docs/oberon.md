# Oberon

## First Installation

```diff
diff --git a/machines/oberon/gitea.nix b/machines/oberon/gitea.nix
index bbb6632..8fa7ec3 100644
--- a/machines/oberon/gitea.nix
+++ b/machines/oberon/gitea.nix
@@ -8,7 +8,7 @@
     nginx.virtualHosts."${meta.pi.gitea.domain}" = {
       enableACME = true;
       forceSSL = true;
-      # extraConfig = meta.pi.ip-whitelist;
+      extraConfig = meta.pi.ip-whitelist;
       locations."/".proxyPass = "http://localhost:3000";
     };
 
@@ -20,7 +20,7 @@
           DOMAIN = meta.pi.gitea.domain;
           ROOT_URL = "https://${meta.pi.gitea.domain}/";
         };
-        service.DISABLE_REGISTRATION = true;
+        service.DISABLE_REGISTRATION = false;
       };
       database = {
         type = "postgres";
diff --git a/machines/oberon/immich.nix b/machines/oberon/immich.nix
index 376c3c2..e694375 100644
--- a/machines/oberon/immich.nix
+++ b/machines/oberon/immich.nix
@@ -7,7 +7,7 @@
     nginx.virtualHosts."${meta.pi.immich.domain}" = {
       enableACME = true;
       forceSSL = true;
-      # extraConfig = meta.pi.ip-whitelist;
+      extraConfig = meta.pi.ip-whitelist;
       locations."/".proxyPass = "http://localhost:2283";
     };
 
diff --git a/machines/oberon/mealie.nix b/machines/oberon/mealie.nix
index cfaa24b..724c5a4 100644
--- a/machines/oberon/mealie.nix
+++ b/machines/oberon/mealie.nix
@@ -7,7 +7,7 @@
     nginx.virtualHosts."${meta.pi.mealie.domain}" = {
       enableACME = true;
       forceSSL = true;
-      # extraConfig = meta.pi.ip-whitelist;
+      extraConfig = meta.pi.ip-whitelist;
       locations."/".proxyPass = "http://localhost:9000";
     };
 
```

```bash
# on uranus
buildoberon
scp result/sd-image/nixos-image.img.zst titania:

# on titania
unzstd nixos-image.img.zst
sudo dd bs=4096 conv=fsync status=progress of=/dev/mmcblk0 if=nixos-image.img
```

## Setup

- [ ] create gitea admin login
- [ ] create immich admin login
- [ ] create mealie admin login

## Remove diffs

```bash
# on uranus
git restore .
switchoberon
```
