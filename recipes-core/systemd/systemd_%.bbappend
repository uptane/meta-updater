FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:sota = " \
        file://boot.mount-10-no-local-fs-gate.conf \
"

do_install:append:sota() {
        install -d ${D}${systemd_system_unitdir}/boot.mount.d
        install -m 0644 ${UNPACKDIR}/boot.mount-10-no-local-fs-gate.conf \
                ${D}${systemd_system_unitdir}/boot.mount.d/10-no-local-fs-gate.conf
}

FILES:${PN}:append:sota = " ${systemd_system_unitdir}/boot.mount.d/10-no-local-fs-gate.conf"
