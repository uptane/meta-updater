FILESEXTRAPATHS:prepend:sota := "${THISDIR}/files:"

SRC_URI:append:sota = " file://shadow.conf"

do_install:append:sota() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${nonarch_libdir}/tmpfiles.d
        install -m 0644 ${UNPACKDIR}/shadow.conf ${D}${nonarch_libdir}/tmpfiles.d/shadow.conf
        # Remove pre-created /var/spool/mail directory from package
        (cd ${D}${localstatedir}; rmdir -v --parents spool/mail)
    fi
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d"
