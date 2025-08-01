FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-mount-Allow-building-when-macro-MOUNT_ATTR_IDMAP-is-.patch \
            file://0002-mount-Allow-building-when-macro-LOOP_CONFIGURE-is-no.patch \
            file://ostree-repo-config.sh \
            file://ostree-repo-config.service \
            "

PACKAGECONFIG:append = " curl libarchive builtin-grub2-mkconfig"
PACKAGECONFIG:class-native:append = " curl"
# gpgme is not required by us, and it brings GPLv3 dependencies
PACKAGECONFIG:remove = "gpgme"
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'ptest', '', 'soup', d)}"

# Build ostree with composefs support only if DISTRO_FEATURES "cfs" is set.
PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs', ' composefs', '', d)}"
PACKAGECONFIG:append:class-native = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs', ' composefs', '', d)}"


# Ensure ed25519 is available for signing commits.
PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', ' ed25519-libsodium', '', d)}"
PACKAGECONFIG:append:class-native = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', ' ed25519-libsodium', '', d)}"


# TODO: Upstream this addition.
PACKAGECONFIG[composefs] = "--with-composefs, --without-composefs"

# TODO: Upstream this addition.
do_configure:prepend() {
    cp ${S}/composefs/libcomposefs/Makefile-lib.am ${S}/composefs/libcomposefs/Makefile-lib.am.inc
}

# Disable PTEST for ostree as it requires options that are not enabled when
# building with meta-updater
PTEST_ENABLED = "0"

# OSTREE_REPO_CFG_...: configurations to be set by "ostree config set <key>"
# executed on the sysroot of the running device - operation performed by the
# service ostree-repo-config.
#
# OSTREE_REPO_CFG_COMPOSEFS: related to key=ex-integrity.composefs (no|yes|maybe).
# OSTREE_REPO_CFG_FSVERITY: related to key=ex-integrity.fsverity (no|yes|maybe).
#
OSTREE_REPO_CFG_COMPOSEFS_DEFAULT = ""
OSTREE_REPO_CFG_COMPOSEFS_DEFAULT = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', 'yes', bb.utils.contains('DISTRO_FEATURES', 'cfs', 'yes', '', d), d)}"
OSTREE_REPO_CFG_COMPOSEFS ?= "${OSTREE_REPO_CFG_COMPOSEFS_DEFAULT}"

OSTREE_REPO_CFG_FSVERITY_DEFAULT = ""

OSTREE_REPO_CFG_FSVERITY_DEFAULT = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', 'yes', bb.utils.contains('DISTRO_FEATURES', 'cfs', 'maybe', '', d), d)}"
OSTREE_REPO_CFG_FSVERITY ?= "${OSTREE_REPO_CFG_FSVERITY_DEFAULT}"

SYSTEMD_SERVICE:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs', ' ostree-repo-config.service', '', d)}"

require ostree-prepare-root.inc

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'cfs', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 /dev/null ${D}${nonarch_libdir}/ostree/prepare-root.conf
        write_prepare_root_config ${D}${nonarch_libdir}/ostree/prepare-root.conf
        install -m 0644 ${WORKDIR}/ostree-repo-config.service ${D}${systemd_system_unitdir}
        install -d ${D}${sbindir}
        install -m 0755 ${WORKDIR}/ostree-repo-config.sh ${D}${sbindir}
        sed -e 's/@@OSTREE_REPO_CFG_COMPOSEFS@@/${OSTREE_REPO_CFG_COMPOSEFS}/' \
            -e 's/@@OSTREE_REPO_CFG_FSVERITY@@/${OSTREE_REPO_CFG_FSVERITY}/' \
            -i ${D}${sbindir}/ostree-repo-config.sh
    fi
}

