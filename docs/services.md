# Oberon Services

## Table of Contents

- [Adblocker](#adguardhome)
- [SSO](#authelia)
- [Monitoring](#beszel)
- [Dashboard](#dashboard)
- [Home](#home-assistant)
- [Fotos](#immich)
- [IT Tools](#it-tools)
- [Joggen](#marathon-tracker)
- [Essen](#mealie)
- [GTD](#mindwtr-app)
- [GTD Cloud](#mindwtr-cloud)
- [Cloud](#nextcloud)
- [PDF](#stirling)
- [Urlaub](#trek)
- [Notizen](#trilium)
- [Tresor](#vaultwarden)

## adguardhome

| Key | Value |
|-----|-------|
| Name | adguardhome |
| Description | Adblocker |
| Subdomain | ad |
| URL | https://ad.kibadda.de |
| Open |  |
| Auth | none |
| Port | :3000 |
| Section | Monitoring |
| Backup | — |

## authelia

| Key | Value |
|-----|-------|
| Name | authelia |
| Description | SSO |
| Subdomain | sso |
| URL | https://sso.kibadda.de |
| Open | ✓ |
| Auth | none |
| Port | :9091 |
| Section | Apps |
| Backup | — |

## beszel

| Key | Value |
|-----|-------|
| Name | beszel |
| Description | Monitoring |
| Subdomain | monitoring |
| URL | https://monitoring.kibadda.de |
| Open |  |
| Auth | none |
| Port | :8090 |
| Section | Monitoring |
| Backup | — |

## dashboard

| Key | Value |
|-----|-------|
| Name | dashboard |
| Description | Dashboard |
| Subdomain | dashboard |
| URL | https://dashboard.kibadda.de |
| Open | ✓ |
| Auth | forward |
| Port | :8082 |
| Section |  |
| Backup | — |

## home-assistant

| Key | Value |
|-----|-------|
| Name | home-assistant |
| Description | Home |
| Subdomain | home |
| URL | https://home.kibadda.de |
| Open | ✓ |
| Auth | none |
| Port | :8123 |
| Section | Apps |
| Backup | — |

## immich

| Key | Value |
|-----|-------|
| Name | immich |
| Description | Fotos |
| Subdomain | pics |
| URL | https://pics.kibadda.de |
| Open | ✓ |
| Auth | oidc |
| Port | :2283 |
| Section | Apps |
| Backup | archive:<br>/mnt/immich/backups<br>sync:<br>/mnt/immich/library<br>/mnt/immich/upload<br>/mnt/immich/profile |

## it-tools

| Key | Value |
|-----|-------|
| Name | it-tools |
| Description | IT Tools |
| Subdomain | tools |
| URL | https://tools.kibadda.de |
| Open | ✓ |
| Auth | none |
| Port | socket |
| Section | Tools |
| Backup | — |

## marathon-tracker

| Key | Value |
|-----|-------|
| Name | marathon-tracker |
| Description | Joggen |
| Subdomain | joggen |
| URL | https://joggen.kibadda.de |
| Open |  |
| Auth | oidc |
| Port | socket |
| Section | Apps |
| Backup | archive:<br>/mnt/marathon-tracker/database/database.sqlite |

## mealie

| Key | Value |
|-----|-------|
| Name | mealie |
| Description | Essen |
| Subdomain | food |
| URL | https://food.kibadda.de |
| Open |  |
| Auth | oidc |
| Port | :9000 |
| Section | Apps |
| Backup | archive:<br>/var/lib/private/mealie |

## mindwtr-app

| Key | Value |
|-----|-------|
| Name | mindwtr-app |
| Description | GTD |
| Subdomain | gtd |
| URL | https://gtd.kibadda.de |
| Open |  |
| Auth | none |
| Port | :5173 |
| Section | Apps |
| Backup | — |

## mindwtr-cloud

| Key | Value |
|-----|-------|
| Name | mindwtr-cloud |
| Description | GTD Cloud |
| Subdomain | gtd-cloud |
| URL | https://gtd-cloud.kibadda.de |
| Open |  |
| Auth | none |
| Port | :8787 |
| Section |  |
| Backup | — |

## nextcloud

| Key | Value |
|-----|-------|
| Name | nextcloud |
| Description | Cloud |
| Subdomain | cloud |
| URL | https://cloud.kibadda.de |
| Open | ✓ |
| Auth | oidc |
| Port | socket |
| Section | Apps |
| Backup | archive:<br>/mnt/nextcloud/data/nextcloud.db<br>sync:<br>/mnt/nextcloud/data/michael |

## stirling

| Key | Value |
|-----|-------|
| Name | stirling |
| Description | PDF |
| Subdomain | pdf |
| URL | https://pdf.kibadda.de |
| Open |  |
| Auth | none |
| Port | :8079 |
| Section | Tools |
| Backup | — |

## trek

| Key | Value |
|-----|-------|
| Name | trek |
| Description | Urlaub |
| Subdomain | urlaub |
| URL | https://urlaub.kibadda.de |
| Open |  |
| Auth | oidc |
| Port | :5926 |
| Section | Apps |
| Backup | archive:<br>/mnt/trek/data/travel.db |

## trilium

| Key | Value |
|-----|-------|
| Name | trilium |
| Description | Notizen |
| Subdomain | notes |
| URL | https://notes.kibadda.de |
| Open | ✓ |
| Auth | oidc |
| Port | :8084 |
| Section | Apps |
| Backup | archive:<br>/mnt/trilium/document.db |

## vaultwarden

| Key | Value |
|-----|-------|
| Name | vaultwarden |
| Description | Tresor |
| Subdomain | pass |
| URL | https://pass.kibadda.de |
| Open |  |
| Auth | none |
| Port | :8222 |
| Section | Apps |
| Backup | archive:<br>/var/backup/vaultwarden |

