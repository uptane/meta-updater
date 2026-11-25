# Enable composefs (EROFS + overlayfs) kernel support, and optionally
# fs-verity for signed composefs, on kernel recipes that merge .cfg
# fragments from SRC_URI: kernel-yocto based recipes (e.g. linux-yocto,
# linux-intel) and recipes that merge fragments collected via find_cfgs()
# in their own do_configure (e.g. linux-qcom).
#
# This is done from anonymous python so that other linux-* recipes
# (linux-libc-headers, linux-firmware, ...) and non-composefs builds keep
# their task signatures; an inline python expression in SRC_URI would still
# change them, even when it expands to nothing.
COMPOSEFS_KERNEL_FILESDIR := "${THISDIR}/files"

python() {
    overrides = (d.getVar('OVERRIDES') or '').split(':')
    if 'cfs-support' not in overrides or not bb.data.inherits_class('kernel', d):
        return
    d.prependVar('FILESEXTRAPATHS', d.getVar('COMPOSEFS_KERNEL_FILESDIR') + ':')
    d.appendVar('SRC_URI', ' file://composefs.cfg')
    if 'cfs-signed' in overrides:
        d.appendVar('SRC_URI', ' file://composefs-fsverity.cfg')
}
