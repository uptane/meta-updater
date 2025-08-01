FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://ostree \
    file://0001-Mount-run-with-tmpfs.patch \
"

SRC_URI:append = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'cfs', ' file://composefs', '', d)} \
"

PACKAGES:append = " \
    initramfs-module-ostree \
"

PACKAGES:append = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'cfs', ' initramfs-module-composefs', '', d)} \
"



SUMMARY:initramfs-module-ostree = "initramfs support for ostree based filesystems"
RDEPENDS:initramfs-module-ostree = "${PN}-base ostree-switchroot"
FILES:initramfs-module-ostree = "/init.d/95-ostree"

SUMMARY:initramfs-module-composefs = "initramfs support for booting composefs images"
RDEPENDS:initramfs-module-composefs = "${PN}-base"

RDEPENDS:initramfs-module-composefs:append = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', ' fsverity-utils e2fsprogs-tune2fs', '', d)}"

FILES:initramfs-module-composefs = "\
    /init.d/94-composefs \
    ${nonarch_libdir}/ostree/prepare-root.conf \
"
FILES:initramfs-module-composefs:append = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', ' ${sysconfdir}/ostree/initramfs-root-binding.key', '', d)}"

do_install:append() {
    install -m 0755 ${WORKDIR}/ostree ${D}/init.d/95-ostree
}

CFS_UPGRADE_ENABLE ?= "0"

require recipes-extended/ostree/gen-cfs-keys.inc

generate_cfs_keys[lockfiles] += "${DEPLOY_DIR_IMAGE}/cfskeys.lock"
generate_cfs_keys() {
    gen_cfs_keys
}

CFS_INSTALL_PREFUNCS_COND ?= " generate_cfs_keys"
CFS_INSTALL_PREFUNCS ?= \
     "${@d.getVar('CFS_INSTALL_PREFUNCS_COND') if 'cfs-signed' in d.getVar('DISTRO_FEATURES').split() else ''}"
CFS_INSTALL_DEPENDS_COND ?= "\
     coreutils-native:do_populate_sysroot \
     openssl-native:do_populate_sysroot \
 "
CFS_INSTALL_DEPENDS ?= \
     "${@d.getVar('CFS_INSTALL_DEPENDS_COND') if 'cfs-signed' in d.getVar('DISTRO_FEATURES').split() else ''}"

CFS_INSTALL_FILE_CHECKSUMS ?= "${@cfs_get_key_file_checksums(d)}"

do_install[prefuncs] += "${CFS_INSTALL_PREFUNCS}"
do_install[depends] += "${CFS_INSTALL_DEPENDS}"
do_install[file-checksums] += "${CFS_INSTALL_FILE_CHECKSUMS}"
 

require recipes-extended/ostree/ostree-prepare-root.inc
do_install:append() {

    if echo "${DISTRO_FEATURES}" | grep -q -e " cfs"; then
        # Bundled into initramfs-module-composefs package:
        install -m 0755 ${WORKDIR}/composefs ${D}/init.d/94-composefs
        sed -i -e 's/@@CFS_UPGRADE_ENABLE@@/${CFS_UPGRADE_ENABLE}/g' ${D}/init.d/94-composefs

        install -d ${D}${nonarch_libdir}/ostree/
        install -m 0644 /dev/null ${D}${nonarch_libdir}/ostree/prepare-root.conf
        write_prepare_root_config ${D}${nonarch_libdir}/ostree/prepare-root.conf
        if echo "${DISTRO_FEATURES}" | grep -q -e " cfs-signed"; then
            # Bundled into initramfs-module-composefs package:
            install -d ${D}${sysconfdir}/ostree/
            install -m 0644 ${CFS_SIGN_KEYDIR}/${CFS_SIGN_KEYNAME}.pub \
    	            ${D}${sysconfdir}/ostree/initramfs-root-binding.key
        fi
    fi

}


