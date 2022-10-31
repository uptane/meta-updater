SUMMARY = "Aktualizr hwid configuration"
HOMEPAGE = "https://github.com/uptane/aktualizr"
SECTION = "base"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MPL-2.0;md5=815ca599c9df247a0c7f619bab123dad"

INHIBIT_DEFAULT_DEPS = "1"

# Because of the dependency on MACHINE.
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install() {
    if [ -n "${SOTA_HARDWARE_ID}" ]; then
        install -m 0700 -d ${D}${libdir}/sota/conf.d
        printf "[provision]\nprimary_ecu_hardware_id = \"${SOTA_HARDWARE_ID}\"\n" \
		> ${D}${libdir}/sota/conf.d/40-hardware-id.toml
    fi
}

FILES:${PN} = "${libdir}/sota/conf.d/40-hardware-id.toml"
ALLOW_EMPTY:${PN} = "1"
