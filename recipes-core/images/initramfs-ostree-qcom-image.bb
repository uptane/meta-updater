DESCRIPTION = "Qcom OS OSTree initramfs image"

PACKAGE_INSTALL = "initramfs-framework-base initramfs-module-udev \
    initramfs-module-rootfs initramfs-module-debug initramfs-module-ostree \
    ${VIRTUAL-RUNTIME_base-utils} base-passwd \
"


PACKAGE_INSTALL:append = "${@bb.utils.contains('DISTRO_FEATURES', 'cfs', ' initramfs-module-composefs', bb.utils.contains('DISTRO_FEATURES', 'cfs-signed', ' initramfs-module-composefs', '', d), d)}"


SYSTEMD_DEFAULT_TARGET = "initrd.target"

IMAGE_NAME_SUFFIX = ""
# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "initramfs-ostree-qcom-image"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES:remove = "wic wic.gz wic.bmap wic.vmdk wic.vdi ext4 ext4.gz teziimg"

IMAGE_CLASSES:remove = "image_repo_manifest license_image qemuboot"

# avoid circular dependencies
EXTRA_IMAGEDEPENDS = ""

inherit core-image nopackages

IMAGE_ROOTFS_SIZE = "8192"

# Users will often ask for extra space in their rootfs by setting this
# globally.  Since this is a initramfs, we don't want to make it bigger
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_OVERHEAD_FACTOR = "1.0"

BAD_RECOMMENDATIONS += "busybox-syslog"
