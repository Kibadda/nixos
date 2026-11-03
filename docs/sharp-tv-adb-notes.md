# Sharp AQUOS TV — ADB speed-up notes

Date: 2026-11-03

## Device

- Model: `AQUOS_TVE19A` (Sharp), product `tcbrae_a`
- Connection: `10.0.0.21:5555`
- Android 11 (SDK 30), MediaTek `m7322`
- RAM: 1.38 GB total, `ro.config.low_ram=true`
- Display: 1920x1080 @ 60 Hz

## Diagnosis

- Storage is fine: `/data` 4.2 GB, 1.1 GB free (72% used).
- Thermal status 0 — not throttling.
- Load average ~68 is misleading. It comes from ~69 MediaTek TV-driver
  kernel threads (`VMon_Task`, `DMX_Filt_Task`, …) stuck in `D` state.
  Actual CPU was mostly idle.
- Real bottleneck: **RAM**. ~1.30 GB used of 1.38 GB, ~82 MB free,
  248 MB swapped, low-RAM mode enabled. Too many preloaded apps resident.

Top memory users (RSS): TV launcher 245 MB, Play Store ~295 MB (3 processes),
Google Play Services ~167 MB, Netflix 114 MB, `com.cltv.fast` 102 MB,
Assistant 72 MB, TV Settings 63 MB, Prime Video 55 MB,
`tvrecommendations` 54 MB, Play Games 48 MB.

Animations were all at `1.0` (on).

## Changes applied (persist across reboots)

```bash
# Free memory / cache
adb shell am force-stop com.android.vending   # NOTE: first attempt had a typo (com.android vending)
adb shell pm trim-caches 2G

# Animations off
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# Disabled packages
adb shell pm disable-user --user 0 tv.anoki.acr.controller
adb shell pm disable-user --user 0 com.google.android.tvrecommendations
adb shell pm disable-user --user 0 com.google.android.play.games
adb shell pm disable-user --user 0 com.google.android.videos
adb shell pm disable-user --user 0 com.cltv.fast
adb shell pm disable-user --user 0 com.google.android.katniss

adb reboot
```

Also disabled auto-updates in the Play Store UI:
**Settings → Auto-update apps → Don't auto-update apps**.

### What each disabled package is

| Package | What it is | Effect of disabling |
|---|---|---|
| `tv.anoki.acr.controller` | ACR content-recognition tracking | No visible feature lost |
| `com.google.android.tvrecommendations` | Home-screen recommendation row | Recommendations row gone |
| `com.google.android.play.games` | Play Games | Games app/profile |
| `com.google.android.videos` | Google TV movie store | Google movie/TV store |
| `com.cltv.fast` | Iwedia internet/FAST TV app | That app only; antenna/HDMI TV unaffected |
| `com.google.android.katniss` | Google Assistant voice | Voice search/Assistant |

`pm disable-user --user 0` persists across reboots. A factory reset or
firmware update can re-enable everything.

## Undo

```bash
adb shell pm enable tv.anoki.acr.controller
adb shell pm enable com.google.android.tvrecommendations
adb shell pm enable com.google.android.play.games
adb shell pm enable com.google.android.videos
adb shell pm enable com.cltv.fast
adb shell pm enable com.google.android.katniss

# Restore animations
adb shell settings put global window_animation_scale 1
adb shell settings put global transition_animation_scale 1
adb shell settings put global animator_duration_scale 1

adb reboot
```

Re-enable Play Store auto-updates in the Play Store UI if wanted.

List currently disabled packages:

```bash
adb shell pm list packages -d
```

## Useful checks

```bash
adb shell dumpsys meminfo | grep -E "Total RAM|Free RAM|Used RAM|Lost RAM"
adb shell dumpsys cpuinfo | head -20
adb shell df -h /data
adb shell dumpsys thermalservice | grep -i "Thermal Status"
adb shell settings get global window_animation_scale
adb shell pm list packages -d
```

After a reboot, give the TV 2–3 minutes to settle before judging speed;
Play Store and Google services do post-boot work.

## Do not disable

`com.google.android.tvlauncher`, `com.google.android.gms`, `com.android.systemui`,
`com.android.tv.settings`, Gboard, `com.android.bluetooth` (remote may be
Bluetooth), `com.google.android.apps.mediashell` (casting), and the
TV-input/media providers.

## Result after reboot (2026-11-03 20:43, 6 min uptime)

- Used RAM: 1.09 GB -> 1.01 GB (~85 MB freed)
- Reported free RAM: 285 MB -> 362 MB (MemAvailable 322 MB)
- Swap in use: 248 MB -> 180 MB
- `/data` free: 1.1 GB -> 1.9 GB (after `pm trim-caches 2G`)
- Animations persisted at 0; all six packages still disabled

Play Store (~275 MB), Netflix (159 MB) and YouTube TV (94 MB) restarted
after boot, so gains are modest. Re-check after 10-15 minutes idle.

Note: `pm list packages -d` also lists pre-existing disabled packages
(`uk.co.freeview.*`, Talkback) that were not disabled in this session.

## Further gains (optional)

- Disable Play Store entirely (`com.android.vending`): ~275 MB saved,
  but no app installs/updates while disabled.
- Disable Netflix (`com.netflix.ninja`) if unused: ~159 MB.
- Disable YouTube TV (`com.google.android.youtube.tv`) if unused: ~94 MB.
- Disable Prime Video (`com.amazon.amazonvideo.livingroom`) if unused: ~69 MB.

Re-enable any of them with `adb shell pm enable <package>`.

## If it is still slow

1. Keep `/data` above ~1 GB free (uninstall unused apps).
2. Update apps manually every few months, then let the TV idle/charge.
3. Reboot monthly or when it gets sluggish.
4. Avoid "cleaner"/"booster" apps.
5. Last resort: factory reset. Set the TV up in apps-only mode and install
   only what you use.
