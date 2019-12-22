#!/usr/bin/sh

. /lib/dracut-crypt-gpg-lib.sh

grep -v "^[[:space:]]*(#|$)" "/etc/crypttab" | while read dst src key opts; do
    gpg_decrypt / root/cryptkey.gpg "initramfs" "$dst" | cryptsetup luksOpen "$src" "$dst" -d -
done 3<&1
kill $(pidof pcscd)
