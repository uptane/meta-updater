# Ensure native setfiles is available for OSTree rootfs build-time SELinux labeling.
do_image_ostree[depends] += "policycoreutils-native:do_populate_sysroot"

# Use IMAGE_CMD:ostree:append() so labeling runs right after OSTree layout conversion.
IMAGE_CMD:ostree:append() {
    if [ -f ${OSTREE_ROOTFS}/usr/etc/selinux/config ]; then
        POL_TYPE=$(sed -n -e "s&^SELINUXTYPE[[:space:]]*=[[:space:]]*\([0-9A-Za-z_]\+\)&\1&p" ${OSTREE_ROOTFS}/usr/etc/selinux/config)
        FC_PATH=${OSTREE_ROOTFS}/usr/etc/selinux/${POL_TYPE}/contexts/files/file_contexts

        if [ -n "${POL_TYPE}" ] && [ -f ${FC_PATH} ]; then
            if ! setfiles -m -r ${OSTREE_ROOTFS} ${FC_PATH} ${OSTREE_ROOTFS} -e ${OSTREE_ROOTFS}/usr/etc; then
                bbwarn "Failed to set SELinux contexts on OSTree rootfs staging tree"
            fi
            # /usr/etc/tmpfiles.d is created during OSTree layout conversion (after
            # the earlier rootfs labeling pass) so it carries no xattrs yet.
            # Re-label it explicitly to give systemd-tmpfiles the correct context.
            if [ -d ${OSTREE_ROOTFS}/usr/etc/tmpfiles.d ]; then
                if ! setfiles -m -r ${OSTREE_ROOTFS} ${FC_PATH} ${OSTREE_ROOTFS}/usr/etc/tmpfiles.d; then
                    bbwarn "Failed to set SELinux contexts on ${OSTREE_ROOTFS}/usr/etc/tmpfiles.d"
                fi
            fi
        else
            bbwarn "Missing SELINUXTYPE or file_contexts under ${OSTREE_ROOTFS}/usr/etc/selinux; skipping OSTree build-time labeling"
        fi
    else
        bbwarn "SELinux config not found under ${OSTREE_ROOTFS}, skipping OSTree build-time labeling"
    fi
}
