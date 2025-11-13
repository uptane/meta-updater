SRC_URI:append:sota = " file://cronie.conf "

do_install:append:sota() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/tmpfiles.d
        install -m 0644 ${WORKDIR}/cronie.conf ${D}${sysconfdir}/tmpfiles.d/cronie.conf
        # Remove pre-created /var directory from package
        (cd ${D}${localstatedir}; rmdir -v --parents spool/cron)
    fi
}
