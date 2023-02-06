FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-ostree-fetcher-curl-set-a-timeout-for-an-overall-req.patch \
            "

PACKAGECONFIG:append = " curl libarchive static builtin-grub2-mkconfig"
PACKAGECONFIG:class-native:append = " curl"
# gpgme is not required by us, and it brings GPLv3 dependencies
PACKAGECONFIG:remove = "soup gpgme"
