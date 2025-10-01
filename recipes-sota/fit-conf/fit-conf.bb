SUMMARY = "FIT image configuration for u-boot to use"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

do_compile() {
	echo -n "fit_conf=" > fit_conf

	if [ -n ${SOTA_MAIN_DTB} ]; then
		echo -n "#conf-${SOTA_MAIN_DTB}" >> fit_conf
	fi

	for ovrl in ${SOTA_DT_OVERLAYS}; do
		echo -n "#conf-overlays_${ovrl}" >> fit_conf
	done

	for conf_frag in ${SOTA_EXTRA_CONF_FRAGS}; do
		echo -n "#${conf_frag}" >> fit_conf
	done
}

do_install() {
	install -d ${D}${libdir}
	install -m 0644 fit_conf ${D}${libdir}
}

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 0644 fit_conf ${DEPLOYDIR}
}

addtask do_deploy before do_build after do_install

FILES:${PN} += "${libdir}/fit_conf"
