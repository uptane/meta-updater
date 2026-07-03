# Enable composefs (EROFS + overlayfs) kernel support, and optionally
# fs-verity for signed composefs, on any linux kernel recipe.
#
# The .cfg fragments are merged both by kernel-yocto based recipes
# (e.g. linux-yocto, linux-intel) and by recipes that merge fragments
# collected via find_cfgs() in their own do_configure (e.g. linux-qcom),
# so no recipe-family specific handling is required here.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:cfs-support = " file://composefs.cfg"
SRC_URI:append:cfs-signed = " file://composefs-fsverity.cfg"
