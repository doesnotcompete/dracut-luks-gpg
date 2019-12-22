#!/usr/bin/bash

# called by dracut
check() {
    if ! dracut_module_included "crypt-gpg"; then
        derror "dracut-luks-gpg needs crypt-gpg in the initramfs"
    fi

    return 0
}

# called by dracut
depends() {
    echo crypt-gpg
    return 0
}

# called by dracut
install() {
    inst_script "$moddir/luks-gpg.sh" "/bin/luks-gpg"
    inst_multiple pcscd
    inst_simple "$moddir/dracut-luks-gpg.service" "$systemdsystemunitdir/dracut-luks-gpg.service"
    ln_r "$systemdsystemunitdir/dracut-luks-gpg.service" "$systemdsystemunitdir/sysinit.target.wants/dracut-luks-gpg.service"
	cp "/etc/keys/cryptkey.gpg" "${initdir}/root/"
}
