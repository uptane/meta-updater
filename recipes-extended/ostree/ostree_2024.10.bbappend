FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " libarchive builtin-grub2-mkconfig"
# gpgme is not required by us, and it brings GPLv3 dependencies
PACKAGECONFIG:remove = "gpgme"
# static requires running as pid1
PACKAGECONFIG:remove = "static"

# Conditional as sdboot support is not yet available upstream
SD_BOOT_PATCHES = " \
    file://0001-Add-support-for-directories-instead-of-symbolic-link.patch \
    file://0002-Add-support-for-systemd-boot-bootloader.patch \
    file://0003-deploy-add-support-for-uki.patch \
"
SRC_URI += "${@bb.utils.contains('OSTREE_BOOTLOADER', 'systemd-boot', '${SD_BOOT_PATCHES}', '', d)}"
