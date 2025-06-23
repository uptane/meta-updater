SUMMARY = "Disable IP reporting in Aktualizr"
DESCRIPTION = "Configures aktualizr to disable IP reporting to the server"
HOMEPAGE = "https://github.com/uptane/aktualizr"
SECTION = "base"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MPL-2.0;md5=815ca599c9df247a0c7f619bab123dad"

inherit allarch

SRC_URI = " \
            file://30-disable-send-ip.toml \
            "

S = "${UNPACKDIR}/sources"

do_install:append () {
    install -m 0700 -d ${D}${libdir}/sota/conf.d
    install -m 0644 ${UNPACKDIR}/30-disable-send-ip.toml ${D}${libdir}/sota/conf.d/30-disable-send-ip.toml
}

FILES:${PN} = " \
                ${libdir}/sota/conf.d/30-disable-send-ip.toml \
                "

# vim:set ts=4 sw=4 sts=4 expandtab:

