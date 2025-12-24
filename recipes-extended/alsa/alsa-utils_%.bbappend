do_install:append:sota() {
        # Remove pre-created /var/lib/alsa directory from package
        (cd "${D}" && rmdir -v --parents "var/lib/alsa")
}
