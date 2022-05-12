FILESEXTRAPATHS:prepend:sota := "${THISDIR}/${BPN}:"

SRC_URI:append:sota = " file://tmpfiles.conf"

do_install:append:sota () {
    install -D -m 0644 ${WORKDIR}/tmpfiles.conf ${D}${nonarch_libdir}/tmpfiles.d/nfs-utils.conf
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d/nfs-utils.conf"
