do_install:append:sota() {
    if  ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        # Remove pre-created /var/lib/dbus directory from package
        (cd ${D}${localstatedir}; rmdir -v --parents lib/dbus)
    fi
}
