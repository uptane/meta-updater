FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-ostree-pull-set-request-timeout.patch \
            "

PACKAGECONFIG_append = " curl libarchive static builtin-grub2-mkconfig"
PACKAGECONFIG_class-native_append = " curl"
# gpgme is not required by us, and it brings GPLv3 dependencies
PACKAGECONFIG_remove = "soup gpgme"
