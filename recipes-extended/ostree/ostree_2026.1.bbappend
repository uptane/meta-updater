FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " libarchive builtin-grub2-mkconfig"
# gpgme is not required by us, and it brings GPLv3 dependencies
PACKAGECONFIG:remove = "gpgme"
# static requires running as pid1
PACKAGECONFIG:remove = "static"

# meta-updater builds ostree without the options its ptest suite needs, so
# disable ptest for sota (meta-updater) configurations. The ':sota' override
# is set by sota.bbclass when 'sota' is in DISTRO_FEATURES.
PTEST_ENABLED:sota = "0"

# Build ostree with composefs support only if override "cfs-support" is set.
PACKAGECONFIG:append:cfs-support = " composefs"

# Ensure ed25519 is available for signing commits.
PACKAGECONFIG:append:cfs-signed = " ed25519-libsodium"

# Conditional as sdboot support is not yet available upstream
SD_BOOT_PATCHES = " \
    file://0001-Add-support-for-directories-instead-of-symbolic-link.patch \
    file://0002-Add-support-for-systemd-boot-bootloader.patch \
    file://0003-deploy-add-support-for-uki.patch \
"
SRC_URI += "${@bb.utils.contains('OSTREE_BOOTLOADER', 'systemd-boot', '${SD_BOOT_PATCHES}', '', d)}"

require ostree-prepare-root.inc

do_install:append:cfs-support:class-target() {
    install -m 0644 /dev/null ${D}${nonarch_libdir}/ostree/prepare-root.conf
    write_prepare_root_config ${D}${nonarch_libdir}/ostree/prepare-root.conf
}
