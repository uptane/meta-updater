FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:sota = " \
    file://10-use-prebuilt-ldconfig-cache.conf \
    file://ostree-ldconfig-update \
"

do_install:append:sota() {
    install -d ${D}${systemd_system_unitdir}/ldconfig.service.d
    install -d ${D}${libexecdir}

    install -m 0644 \
        ${UNPACKDIR}/10-use-prebuilt-ldconfig-cache.conf \
        ${D}${systemd_system_unitdir}/ldconfig.service.d/

    sed -i \
        -e 's|@LIBEXECDIR@|${libexecdir}|g' \
        ${D}${systemd_system_unitdir}/ldconfig.service.d/10-use-prebuilt-ldconfig-cache.conf

    install -m 0755 \
        ${UNPACKDIR}/ostree-ldconfig-update \
        ${D}${libexecdir}/
}

FILES:${PN}:append:sota = " \
    ${systemd_system_unitdir}/ldconfig.service.d/10-use-prebuilt-ldconfig-cache.conf \
    ${libexecdir}/ostree-ldconfig-update \
"

RDEPENDS:${PN}:append:sota = " coreutils"

