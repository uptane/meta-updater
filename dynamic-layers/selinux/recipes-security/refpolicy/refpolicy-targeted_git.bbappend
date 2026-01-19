FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI:append:sota = " \
        file://0001-refpolicy-Add-policy-module-for-ostree.patch \
        "
