FILESEXTRAPATHS:prepend:sota := "${THISDIR}/files:"

SRC_URI:append:sota = " file://libvirt.conf"

do_install:append:sota() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/tmpfiles.d
        install -m 0644 ${UNPACKDIR}/libvirt.conf ${D}${sysconfdir}/tmpfiles.d/libvirt.conf

        (cd ${D}${localstatedir}; rmdir -v lib/libvirt/boot;
                rmdir -v lib/libvirt/ch;
                rmdir -v lib/libvirt/dnsmasq;
                rmdir -v lib/libvirt/filesystems;
                rmdir -v lib/libvirt/images;
                rmdir -v lib/libvirt/lockd/files lib/libvirt/lockd;
                rmdir -v lib/libvirt/lxc;
                rmdir -v lib/libvirt/network;
                rmdir -v lib/libvirt/qemu/channel/target lib/libvirt/qemu/channel;
                rmdir -v lib/libvirt/qemu/checkpoint lib/libvirt/qemu/dump;
                rmdir -v lib/libvirt/qemu/nvram lib/libvirt/qemu/ram;
                rmdir -v lib/libvirt/qemu/save lib/libvirt/qemu/snapshot;
                rmdir -v lib/libvirt/qemu;
                rmdir -v lib/libvirt/swtpm;
                rmdir -v --parents lib/libvirt;
                rmdir -v --parents cache/libvirt/qemu;
        )
    fi
}
