FILESEXTRAPATHS:prepend:sota := "${THISDIR}/${BPN}:"

SRC_URI:append:sota = " file://tmpfiles.conf"

do_install:append:sota () {
    install -D -m 0644 ${WORKDIR}/tmpfiles.conf ${D}${nonarch_libdir}/tmpfiles.d/nfs-utils.conf

    rm -v \
        ${D}/var/lib/nfs/etab \
        ${D}/var/lib/nfs/statd/state \
        ${D}/var/lib/nfs/rmtab

    rmdir -v \
        ${D}/var/lib/nfs/statd/sm.bak \
        ${D}/var/lib/nfs/statd/sm \
        ${D}/var/lib/nfs/statd \
        ${D}/var/lib/nfs/v4recovery \
        ${D}/var/lib/nfs
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d/nfs-utils.conf"
