# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# Copyright (c) 2023 Toradex AG.
#
# SPDX-License-Identifier: MIT
#
# Based on cfs-signed.bbclass from meta-toradex-torizon:
# https://github.com/torizon/meta-toradex-torizon
#
# This class enables composefs support for OSTree deployments.
#
# When inherited, the system will:
# - Build ostree with composefs support
# - Configure ostree-prepare-root to use composefs
# - Include composefs modules in the initramfs
# - Add required kernel configuration
#
# Usage: Add to your distro or local.conf:
#   INHERIT += "cfs-support"
#
DISTROOVERRIDES .= ":cfs-support"

# When composefs is enabled, disable systemd-gpt-auto-generator to avoid
# mount warnings with the composefs overlay.
OSTREE_KERNEL_ARGS:append:cfs-support = " systemd.gpt_auto=0"
