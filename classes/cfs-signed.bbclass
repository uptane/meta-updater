# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# Copyright (c) 2023 Toradex AG.
#
# SPDX-License-Identifier: MIT
#
# Based on cfs-signed.bbclass from meta-toradex-torizon:
# https://github.com/torizon/meta-toradex-torizon
#
# This class enables signed composefs support for OSTree deployments.
# It builds on top of cfs-support by adding:
# - ED25519 signing of ostree commits at build time
# - Composefs metadata generation during ostree commit
# - Signature verification enforcement at runtime
# - fs-verity enforcement
#
# Usage: Add to your distro or local.conf:
#   INHERIT += "cfs-signed"
#
# Key configuration:
#   CFS_GENERATE_KEYS: "1" to auto-generate keys, "0" to use existing
#   CFS_SIGN_KEYDIR: Directory for key storage
#   CFS_SIGN_KEYNAME: Base name for key files (.pub and .sec)
#
# Inherit cfs-support so its settings (e.g. the systemd.gpt_auto=0 kernel
# argument keyed on the cfs-support override) are applied to signed builds
# too; this class only layers the signing bits on top.
inherit cfs-support

DISTROOVERRIDES .= ":cfs-signed"

CFS_GENERATE_KEYS ?= "1"
CFS_SIGN_KEYDIR ?= "${TOPDIR}/keys/ostree"
CFS_SIGN_KEYNAME ?= "cfs-dev"
