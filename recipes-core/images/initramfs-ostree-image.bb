# Netboot initramfs image.
DESCRIPTION = "OSTree initramfs image"

# Install the full OSTree package into the initramfs.
# This is needed to support using the non-static version of
# ostree-prepare-root. The problem with ostree-prepare-root-static is that
# expects to run as PID 1 and not as part of an initrd.
PACKAGE_INSTALL = "ostree ostree-initrd busybox base-passwd ${ROOTFS_BOOTSTRAP_INSTALL}"

SYSTEMD_DEFAULT_TARGET = "initrd.target"

IMAGE_NAME_SUFFIX = ""
# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

export IMAGE_BASENAME = "initramfs-ostree-image"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_CLASSES:remove = "image_repo_manifest qemuboot"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

# Avoid circular dependencies
EXTRA_IMAGEDEPENDS = ""

inherit core-image nopackages

IMAGE_ROOTFS_SIZE = "8192"

# Users will often ask for extra space in their rootfs by setting this
# globally.  Since this is a initramfs, we don't want to make it bigger
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_OVERHEAD_FACTOR = "1.0"

BAD_RECOMMENDATIONS += "busybox-syslog"
