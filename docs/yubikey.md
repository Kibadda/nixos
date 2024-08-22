# Yubikey

## renew keys

mount usb

```console
lsblk

sudo cryptsetup luksOpen /dev/sda1 gnupg-secrets

sudo mkdir -p /mnt/encrypted-storage

sudo mount /dev/mapper/gnupg-secrets /mnt/encrypted-storage

sudo mkdir -p /mnt/public

sudo mount /dev/sda2 /mnt/public
```

create directory

```console
export GNUPGHOME=$(mktemp -d -t gnupg-$(date +%Y-%m-%d)-XXXXXXXXXX)

cd $GNUPGHOME

cp -avi /mnt/encrypted-storage/gnupg-*/* $GNUPGHOME
```

```console
gpg -K

export KEYID=$(gpg -k --with-colons "$IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')

export KEYFP=$(gpg -k --with-colons "$IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')

echo $KEYID $KEYFP
```

retrieve password

```console
pass show gpg/pass

export CERTIFY_PASS=ABCD-0123-IJKL-4567-QRST-UVWX
```

```console
export EXPIRATION=2y

gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" --quick-set-expire "$KEYFP" "$EXPIRATION" \
    $(gpg -K --with-colons | awk -f: '/^fpr:/ { print $10 }' | tail -n "+2" | tr "\n" " ")

gpg --armor --export $KEYID | sudo tee /mnt/public/$KEYID-$(date +%F).asc

gpg --import /mnt/public/*.asc

gpg --send-key $KEYID

gpg --keyserver keys.gnupg.net --send-key $KEYID

gpg --keyserver hkps://keyserver.ubuntu.com:443 --send-key $KEYID

gpg --recv $KEYID
```

unmount usb

```console
sudp cp -av $GNUPGHOME /mnt/encrypted-storage

sudo umount /mnt/public

sudo umount /mnt/encrypted-storage

sudo cryptsetup luksClose gnupg-secrets
```
