FILESEXTRAPATHS:prepend:sota := "${THISDIR}/files:"

SRC_URI:append:sota = " file://dhcpcd.conf"

do_install:append:sota() {
    if [ "${DBDIR}" = "${localstatedir}/lib/${BPN}" ] && \
           ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${nonarch_libdir}/tmpfiles.d
        install -m 0644 ${UNPACKDIR}/dhcpcd.conf ${D}${nonarch_libdir}/tmpfiles.d/dhcpcd.conf
        # Remove pre-created /var/lib/dhcpcd directory from package
        (cd ${D}${localstatedir}; rmdir -v --parents lib/dhcpcd)
    fi
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d"
