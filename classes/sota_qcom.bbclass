OSTREE_BOOTLOADER ?= "systemd-boot"
EFI_PROVIDER:sota = "${@ 'grub-efi' if d.getVar('OSTREE_BOOTLOADER') == 'grub' else 'systemd-boot' }"
PACKAGECONFIG:append:pn-systemd = " ${@ 'efi' if d.getVar('OSTREE_BOOTLOADER') == 'systemd-boot' else '' }"

# Prepare a flat image directory structure suitable to flash with QDL
IMAGE_CLASSES += "image_types_qcom"
IMAGE_FSTYPES += "ota-esp qcomflash"
IMAGE_TYPEDEP:qcomflash += "ota-ext4 ota-esp"

# Handled by ostree
UKI_CMDLINE = ""
OSTREE_KERNEL_ARGS ?= "console=ttyMSM0,115200 ${OSTREE_KERNEL_ARGS_COMMON}"

# No custom esp image required
QCOM_ESP_IMAGE = ""
QCOM_ESP_FILE = "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.ota-esp"
IMAGE_QCOMFLASH_FS_TYPE = "ota-ext4"

EXTRA_IMAGECMD:ota-esp = "-s 1 -S ${QCOM_VFAT_SECTOR_SIZE}"

IMAGE_CLASSES += "uki"
IMAGE_CLASSES:remove:pn-initramfs-ostree-image = "uki"
