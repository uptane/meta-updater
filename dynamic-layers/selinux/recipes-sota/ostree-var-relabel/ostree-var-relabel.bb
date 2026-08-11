SUMMARY = "Relabel /var when the SELinux policy changes across OSTree deployments"
DESCRIPTION = "/var is shared across OSTree deployments and is only labeled \
once by libostree, at deploy time, while the previous deployment's policy is \
still loaded.  This service detects a policy change on boot and relabels /var \
with the policy of the booted deployment, covering updates and rollbacks that \
ship a different SELinux policy."
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MPL-2.0;md5=815ca599c9df247a0c7f619bab123dad"

inherit systemd features_check

REQUIRED_DISTRO_FEATURES = "systemd selinux"

SRC_URI = " \
  file://ostree-var-relabel \
  file://ostree-var-relabel.service \
  "

S = "${UNPACKDIR}"

SYSTEMD_SERVICE:${PN} = "ostree-var-relabel.service"

do_install() {
    install -d ${D}${libexecdir}
    install -m 0755 ${UNPACKDIR}/ostree-var-relabel ${D}${libexecdir}/ostree-var-relabel

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/ostree-var-relabel.service ${D}${systemd_system_unitdir}/ostree-var-relabel.service
    sed -i -e 's,/usr/libexec/,${libexecdir}/,g' ${D}${systemd_system_unitdir}/ostree-var-relabel.service
}

FILES:${PN} = " \
        ${libexecdir}/ostree-var-relabel \
        ${systemd_system_unitdir}/ostree-var-relabel.service \
        "

RDEPENDS:${PN} += "policycoreutils-setfiles"
