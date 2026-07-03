# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# Licensed on MIT
#
# Based on base-files bbappend from meta-toradex-torizon:
# https://github.com/torizon/meta-toradex-torizon
#
do_install:append:cfs-support () {
	# Remove /dev/root entry from fstab to avoid systemd-remount-fs errors
	# when composefs is managing the root filesystem.
	sed -i -e '\#^ */dev/root#d' ${D}${sysconfdir}/fstab
}
