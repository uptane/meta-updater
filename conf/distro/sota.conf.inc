# Common settings to enable SOTA
# This can be pulled into a custom distribution, or included in
# local.conf directly with:
#
# require conf/distro/sota.conf.inc

DISTRO_FEATURES:append = " sota usrmerge"
DISTRO_FEATURES_NATIVE:append = " sota"
INHERIT += " sota"

export SOURCE_DATE_EPOCH = "0"
REPRODUCIBLE_TIMESTAMP_ROOTFS = "0"

HOSTTOOLS += "sync"
HOSTTOOLS_NONFATAL += "java repo"
