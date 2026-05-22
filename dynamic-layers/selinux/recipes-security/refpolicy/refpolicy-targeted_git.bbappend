FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

POLICY_STORE_ROOT:sota = "${sysconfdir}/selinux"

SRC_URI:append:sota = " \
        file://0001-refpolicy-Add-policy-module-for-ostree.patch \
        file://0002-systemd-allow-generator-to-read-symlinks-and-manage-.patch \
        "
