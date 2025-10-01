FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
	file://ostree \
"

PACKAGES:append = " \
	initramfs-module-ostree \
"

SUMMARY:initramfs-module-ostree = "initramfs support for ostree based filesystems"
RDEPENDS:initramfs-module-ostree = "${PN}-base ostree-switchroot"
FILES:initramfs-module-ostree = "/init.d/98-ostree"

do_install:append() {
	install -m 0755 ${UNPACKDIR}/ostree ${D}/init.d/98-ostree
}
