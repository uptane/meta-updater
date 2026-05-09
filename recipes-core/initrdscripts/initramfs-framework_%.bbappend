FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
	file://ostree \
"

# Composefs support
SRC_URI:append:cfs-support = " \
	file://composefs \
	file://80-composefs.conf \
"

PACKAGES:append = " \
	initramfs-module-ostree \
"

PACKAGES:append:cfs-support = " \
	initramfs-module-composefs \
"

SUMMARY:initramfs-module-ostree = "initramfs support for ostree based filesystems"
RDEPENDS:initramfs-module-ostree = "${PN}-base ostree-switchroot"
FILES:initramfs-module-ostree = "/init.d/98-ostree"

SUMMARY:initramfs-module-composefs = "initramfs support for booting composefs images"
RDEPENDS:initramfs-module-composefs = "${PN}-base"
RDEPENDS:initramfs-module-composefs:append:cfs-signed = " fsverity-utils e2fsprogs-tune2fs"
FILES:initramfs-module-composefs = " \
	/init.d/94-composefs \
	${nonarch_libdir}/ostree/prepare-root.conf \
	${sysconfdir}/modules-load.d/80-composefs.conf \
"
FILES:initramfs-module-composefs:append:cfs-signed = " \
	${sysconfdir}/ostree/initramfs-root-binding.key \
"

require recipes-extended/ostree/ostree-prepare-root.inc

CFS_UPGRADE_ENABLE ?= "0"

do_install:append() {
	install -m 0755 ${UNPACKDIR}/ostree ${D}/init.d/98-ostree
}

do_install:append:cfs-support() {
	# Kernel modules config:
	install -d ${D}/etc/modules-load.d/
	install -m 0644 ${UNPACKDIR}/80-composefs.conf ${D}/etc/modules-load.d/80-composefs.conf

	# Composefs init script:
	install -m 0755 ${UNPACKDIR}/composefs ${D}/init.d/94-composefs
	sed -i -e 's/@@CFS_UPGRADE_ENABLE@@/${CFS_UPGRADE_ENABLE}/g' ${D}/init.d/94-composefs

	# prepare-root.conf for initramfs:
	install -d ${D}${nonarch_libdir}/ostree/
	install -m 0644 /dev/null ${D}${nonarch_libdir}/ostree/prepare-root.conf
	write_prepare_root_config ${D}${nonarch_libdir}/ostree/prepare-root.conf
}

require recipes-extended/ostree/gen-cfs-keys.inc

generate_cfs_keys[lockfiles] += "${DEPLOY_DIR_IMAGE}/cfskeys.lock"
generate_cfs_keys() {
	gen_cfs_keys
}

CFS_INSTALL_PREFUNCS_COND ?= " generate_cfs_keys"
CFS_INSTALL_PREFUNCS ?= \
	"${@d.getVar('CFS_INSTALL_PREFUNCS_COND') if 'cfs-signed' in d.getVar('OVERRIDES').split(':') else ''}"
CFS_INSTALL_DEPENDS_COND ?= "\
	coreutils-native:do_populate_sysroot \
	openssl-native:do_populate_sysroot \
"
CFS_INSTALL_DEPENDS ?= \
	"${@d.getVar('CFS_INSTALL_DEPENDS_COND') if 'cfs-signed' in d.getVar('OVERRIDES').split(':') else ''}"

CFS_INSTALL_FILE_CHECKSUMS ?= "${@cfs_get_key_file_checksums(d)}"

do_install[prefuncs] += "${CFS_INSTALL_PREFUNCS}"
do_install[depends] += "${CFS_INSTALL_DEPENDS}"
do_install[file-checksums] += "${CFS_INSTALL_FILE_CHECKSUMS}"

python() {
    if 'cfs-signed' in (d.getVar('OVERRIDES') or '').split(':'):
        d.setVarFlag('do_install', 'nostamp', '1')
}

do_install:append:cfs-signed() {
	install -d ${D}${sysconfdir}/ostree/
	install -m 0644 ${CFS_SIGN_KEYDIR}/${CFS_SIGN_KEYNAME}.pub \
		${D}${sysconfdir}/ostree/initramfs-root-binding.key
}
