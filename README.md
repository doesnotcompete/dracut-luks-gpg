# dracut-luks-gpg

`dracut-luks-gpg` adds support for decrypting LUKS devices with GPG-encrypted keyfiles (including OpenPGP smartcard support) at bootup for systems using the `dracut` initramfs infrastructure with `systemd`. It uses the `crypt-gpg` library included with `dracut`.

Unfortunately `systemd-cryptsetup` does not currently support usage of GPG-encrypted keyfiles for LUKS devices. Therefore this module bypasses `systemd-cryptsetup-generator` and opens your crypt devices using the included `systemd` units at bootup. Specify `luks=no` as a kernel argument in your bootloader to disable the interfering `systemd` cryptsetup support.

`91crypt-luks-gpg` contains the `dracut` module for inclusion in the initramfs. Copy to `/lib/dracut/modules.d` and add the module to your initramfs with the `add_dracutmodules` option in the `dracut` configuration. For instance, add a file `gpg.conf` with the following content to `/etc/dracut.conf.d`:

```
add_dracutmodules+="crypt-gpg crypt-luks-gpg"
install_items+="/sbin/cryptsetup"
```

Regenerate your initramfs with `dracut -f`.

Copy `luks-gpg` to `/usr/bin`, and install `luks-gpg.service` as a system service if you wish to open additional local LUKS devices specified in `/etc/crypttab` after switch root.

_NOTE: If you wish to automatically open and mount additional crypt devices apart from the root drive at bootup, the corresponding service unit `luks-gpg.service` expects an unencrypted keyfile for those drives to be present at `/etc/keys/cryptkey`. With the privileges set with the commands above this file will only be readable by root, and as your root drive is assumed to be encrypted, your key will be secure until your root drive is opened subsequent to providing your GPG key at bootup. However, please be aware that an adversary with access to this file could use it to decrypt your disks._

## Preparations
1. Export your public key, and import it into the root users keychain: `gpg --export --armor {KEYID} > crypt-public-key.gpg` and `sudo mv crypt-public-key.gpg /etc/dracut.conf.d`, and as root: `gpg --import /etc/dracut.conf.d/crypt-public-key.gpg`. The `dracut` module will copy this public key to the initramfs, so that the included `gpg` can correctly identify the key to be used for decrypting your LUKS keyfile.
2. Generate a keyfile to encrypt your disks:
```
mkdir -m 700 /etc/keys
dd if=/dev/random bs=1 count=256 > /etc/keys/cryptkey
gpg -e -o /etc/keys/cryptkey.gpg -r {KEYID}
```
3. Now add corresponding keyslots to your LUKS devices: `cryptsetup luksAddKey /dev/{CRYPTDEVICE} /etc/keys/cryptkey`.
