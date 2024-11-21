PACKAGECONFIG:append = " curl libarchive static builtin-grub2-mkconfig"
PACKAGECONFIG:class-native:append = " curl"
# gpgme is not required by us, and it brings GPLv3 dependencies
PACKAGECONFIG:remove = "gpgme"
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'ptest', '', 'soup', d)}"
