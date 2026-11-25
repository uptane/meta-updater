FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
	file://ostree \
"

# Composefs support
SRC_URI:append:cfs-support = " \
	file://composefs \
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
	# Composefs init script:
	install -m 0755 ${UNPACKDIR}/composefs ${D}/init.d/94-composefs
	sed -i -e 's/@@CFS_UPGRADE_ENABLE@@/${CFS_UPGRADE_ENABLE}/g' ${D}/init.d/94-composefs

	# prepare-root.conf for initramfs:
	install -d ${D}${nonarch_libdir}/ostree/
	install -m 0644 /dev/null ${D}${nonarch_libdir}/ostree/prepare-root.conf
	write_prepare_root_config ${D}${nonarch_libdir}/ostree/prepare-root.conf
}

require recipes-extended/ostree/gen-cfs-keys.inc

python() {
    cfs_signed_task_setup(d, 'do_install')
}

do_install:append:cfs-signed() {
	install -d ${D}${sysconfdir}/ostree/
	install -m 0644 ${CFS_SIGN_KEYDIR}/${CFS_SIGN_KEYNAME}.pub \
		${D}${sysconfdir}/ostree/initramfs-root-binding.key
}
