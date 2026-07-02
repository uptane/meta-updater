FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " libarchive builtin-grub2-mkconfig"
# gpgme is not required by us, and it brings GPLv3 dependencies
PACKAGECONFIG:remove = "gpgme"
# static requires running as pid1
PACKAGECONFIG:remove = "static"

# Build ostree with composefs support only if override "cfs-support" is set.
PACKAGECONFIG:append:cfs-support = " composefs"

# With composefs "/" (and /usr) are overlays with no backing block device;
# expose the physical root via /run/systemd/volatile-root so systemd's
# partition discovery keeps working (ESP automount on /boot, needed by
# bootctl, systemd-bless-boot and ostree admin).
SRC_URI:append:cfs-support = " file://0001-prepare-root-create-run-systemd-volatile-root-for-co.patch"

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
