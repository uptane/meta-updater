do_install:append () {
    # Get rid of the /dev/root entry in fstab to avoid errors from
    # systemd-remount-fs
    if ${@bb.utils.contains('DISTRO_FEATURES', 'cfs', 'true', 'false', d)} ||
       ${@bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', 'true', 'false', d)}; then
        sed -i -e '\#^ */dev/root#d' ${D}${sysconfdir}/fstab
    fi
}
