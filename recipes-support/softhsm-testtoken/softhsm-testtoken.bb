SUMMARY = "Mock smartcard for aktualizr"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

S = "${UNPACKDIR}/sources"

RDEPENDS:${PN} = "softhsm libp11 opensc openssl-bin"
DEPENDS:append = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' systemd', '', d)}"


SRC_URI = "file://createtoken.service \
	   file://createtoken.sh"

SYSTEMD_SERVICE:${PN} = "createtoken.service"

do_install() {
  install -d ${D}${systemd_unitdir}/system
  install -m 0644 ${UNPACKDIR}/createtoken.service ${D}${systemd_unitdir}/system/createtoken.service
  install -d ${D}${bindir}
  install -m 0744 ${UNPACKDIR}/createtoken.sh ${D}${bindir}/createtoken.sh
}

FILES:${PN} = "${bindir}/createtoken.sh \
	       ${systemd_unitdir}/system/createtoken.service"

