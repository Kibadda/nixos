# Oberon

```bash
# on uranus
build oberon
scp result/sd-image/nixos-image.img.zst titania:

# on titania
unzstd nixos-image.img.zst
sudo dd bs=4096 conv=fsync status=progress of=/dev/mmcblk0 if=nixos-image.img
```
