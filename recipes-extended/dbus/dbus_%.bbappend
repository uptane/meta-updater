FILESEXTRAPATHS:prepend:sota := "${THISDIR}/files:"

SRC_URI:append:sota = " file://20-dbus.conf"

do_install:append:sota() {
    if  ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${nonarch_libdir}/tmpfiles.d
        install -m 0644 ${UNPACKDIR}/20-dbus.conf ${D}${nonarch_libdir}/tmpfiles.d/20-dbus.conf
        # Remove pre-created /var/lib/dbus directory from package
        (cd ${D}${localstatedir}; rmdir -v --parents lib/dbus)
    fi
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d"
