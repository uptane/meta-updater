# Populate font cache in ${libdir} instead of /var/cache.
# Runtime font cache modification will not be possible with ostree.
# package generated fontconfig generated via FONTCONFIG_CACHE_DIR
FILES:${PN}:append = " ${FONTCONFIG_CACHE_DIR}"
