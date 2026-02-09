# Common settings to enable SOTA
# This can be pulled into a custom distribution, or included in
# local.conf directly with:
#
# require conf/distro/sota.conf.inc

DISTRO_FEATURES:append = " sota usrmerge"
DISTRO_FEATURES_NATIVE:append = " sota"
INHERIT += " sota"

HOSTTOOLS += "sync"
HOSTTOOLS_NONFATAL += "java repo"

# Postinst script in fontcache class will create cache
# at this path during do_rootfs
FONTCONFIG_CACHE_DIR = "${libdir}/cache/fontconfig"
