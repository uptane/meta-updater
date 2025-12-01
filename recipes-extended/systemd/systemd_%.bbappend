do_install:append:sota() {
        # Remove pre-created /var/lib/systemd directory from package
        (cd ${D}${localstatedir}; rmdir -v --parents lib/systemd)
}
