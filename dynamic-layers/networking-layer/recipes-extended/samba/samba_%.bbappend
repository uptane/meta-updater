FILESEXTRAPATHS:prepend:sota := "${THISDIR}/files:"

SRC_URI:append:sota = " file://samba-common.conf \
                        file://cdtb.conf"

do_install:append:sota() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${nonarch_libdir}/tmpfiles.d
        install -m 0644 ${UNPACKDIR}/samba-common.conf ${D}${nonarch_libdir}/tmpfiles.d/samba-common.conf
        install -m 0644 ${UNPACKDIR}/cdtb.conf ${D}${nonarch_libdir}/tmpfiles.d/cdtb.conf
        # Remove pre-created /var/lib/dhcpcd directory from package
        (cd ${D}${localstatedir}; rmdir -v lib/samba/bind-dns;
              rmdir -v lib/samba/private;
              rmdir -v lib/ctdb/persistent;
              rmdir -v lib/ctdb/state;
              rmdir -v lib/ctdb/volatile;
              rmdir -v lib/ctdb;
              rmdir -v --parents lib/samba;
        )
    fi
}

FILES:${BPN}-common += "${nonarch_libdir}/tmpfiles.d/samba-common.conf"
FILES:ctdb += "${nonarch_libdir}/tmpfiles.d/cdtb.conf"
