OSTREE_BOOTLOADER ?= "grub"
EFI_PROVIDER:sota = "${@ 'grub-efi' if d.getVar('OSTREE_BOOTLOADER') == 'grub' else 'systemd-boot' }"
PACKAGECONFIG:append:sota:pn-systemd = " ${@ 'efi' if d.getVar('OSTREE_BOOTLOADER') == 'systemd-boot' else '' }"

WKS_FILE:sota = "efiimage-sota.wks.in"
IMAGE_BOOT_FILES:sota = ""

IMAGE_FSTYPES:remove:sota = "live hddimg"
OSTREE_KERNEL_ARGS ?= "console=ttyS0,115200 ${OSTREE_KERNEL_ARGS_COMMON}"

PREFERRED_RPROVIDER_network-configuration ?= "connman"
IMAGE_INSTALL:append:sota = " network-configuration "
