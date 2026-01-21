# Populate font cache in ${libdir} instead of /var/cache.
# Postinst script in fontcache class will create cache
# at this path during do_rootfs. Runtime font cache modification
# will not be possible with ostree.
FONTCONFIG_CACHE_DIR:sota = "${libdir}/cache/fontconfig"
FILES:${PN}:append:sota = " ${libdir}/cache/fontconfig"
