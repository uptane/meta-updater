SUMMARY = "Aktualizr metric collection"
HOMEPAGE = "https://github.com/uptane/aktualizr"
SECTION = "base"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MPL-2.0;md5=815ca599c9df247a0c7f619bab123dad"

RDEPENDS:${PN} = "collectd"

SRC_URI = " file://aktualizr-collectd.conf"

S = "${UNPACKDIR}/sources"

do_install() {
    install -d ${D}${sysconfdir}/collectd.conf.d
    install -m 0644 ${UNPACKDIR}/aktualizr-collectd.conf ${D}${sysconfdir}/collectd.conf.d/aktualizr.conf
}

FILES:${PN} = " \
                ${sysconfdir}/collectd.conf.d \
                ${sysconfdir}/collectd.conf.d/aktualizr.conf \
                "
