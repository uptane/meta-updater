FILESEXTRAPATHS:prepend:sota := "${THISDIR}/files:"

SRC_URI:append:sota = " file://alsa.conf"

do_install:append:sota () {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${nonarch_libdir}/tmpfiles.d
        install -m 0644 ${UNPACKDIR}/alsa.conf ${D}${nonarch_libdir}/tmpfiles.d/alsa.conf
        rm -f "${D}${localstatedir}/lib/alsa/asound.state"
        (cd "${D}" && rmdir -v --parents "var/lib/alsa")
    fi
}

FILES:alsa-states:append:sota = " ${nonarch_libdir}/tmpfiles.d"
