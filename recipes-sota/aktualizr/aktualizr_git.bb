SUMMARY = "Aktualizr SOTA Client"
DESCRIPTION = "SOTA Client application written in C++"
HOMEPAGE = "https://github.com/uptane/aktualizr"
SECTION = "base"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=815ca599c9df247a0c7f619bab123dad"

DEPENDS = "boost curl openssl libarchive libsodium sqlite3 asn1c-native ostree"
DEPENDS:append = "${@bb.utils.contains('PTEST_ENABLED', '1', ' coreutils-native net-tools-native aktualizr-native ', '', d)}"
RDEPENDS:${PN}:class-target = "lshw"
RRECOMMENDS:${PN}_class-target = "${PN}-hwid"

RDEPENDS:${PN}-ptest += "bash cmake curl net-tools python3-core python3-misc python3-modules openssl-bin sqlite3 valgrind"

PRIVATE_LIBS:${PN}-ptest = "libaktualizr.so libaktualizr_secondary.so"

PV = "1.0+git${SRCPV}"
PR = "7"

GARAGE_SIGN_PV = "0.7.4-25-g7cfca74"

SRC_URI = " \
  gitsm://github.com/uptane/aktualizr;branch=${BRANCH};name=aktualizr;protocol=https \
  file://10-resource-control.conf \
  file://aktualizr.service \
  file://aktualizr-secondary.service \
  file://aktualizr-serialcan.service \
  file://aktualizr-tmpfiles.conf \
  file://run-ptest \
  ${@ d.expand("https://tuf-cli-releases.ota.here.com/cli-${GARAGE_SIGN_PV}.tgz;unpack=0;name=garagesign") if not oe.types.boolean(d.getVar('GARAGE_SIGN_AUTOVERSION')) else ''} \
  "

SRC_URI[garagesign.md5sum] = "584cd16aa7824e34b593dae63796466b"
SRC_URI[garagesign.sha256sum] = "c7d5fdceef3e815363e3aa398c38643ca213f9b7f66d50f55c76a66cb74565d2"

SRCREV = "c90723717a4a196cfb9d923dbcd48c5d6031d2c4"
BRANCH ?= "master"

S = "${WORKDIR}/git"

inherit cmake pkgconfig ptest systemd

# disable ptest by default as it slows down builds quite a lot
# can be enabled manually by setting 'PTEST_ENABLED:pn-aktualizr' to '1' in local.conf
PTEST_ENABLED = "0"

SYSTEMD_PACKAGES = "${PN} ${PN}-secondary"
SYSTEMD_SERVICE:${PN} = "aktualizr.service"
SYSTEMD_SERVICE:${PN}-secondary = "aktualizr-secondary.service"

EXTRA_OECMAKE = "-DCMAKE_BUILD_TYPE=Release \
    ${@bb.utils.contains('PTEST_ENABLED', '1', '-DTESTSUITE_VALGRIND=on', '', d)} \
    -DBUILD_OSTREE=ON"

GARAGE_SIGN_OPS = "${@ d.expand('-DGARAGE_SIGN_ARCHIVE=${WORKDIR}/cli-${GARAGE_SIGN_PV}.tgz') if not oe.types.boolean(d.getVar('GARAGE_SIGN_AUTOVERSION')) else ''}"
PKCS11_ENGINE_PATH = "${libdir}/engines-3/pkcs11.so"

PACKAGECONFIG ?= "${@bb.utils.filter('SOTA_CLIENT_FEATURES', 'hsm serialcan ubootenv', d)}"
PACKAGECONFIG:class-native = "sota-tools"
PACKAGECONFIG[warning-as-error] = "-DWARNING_AS_ERROR=ON,-DWARNING_AS_ERROR=OFF,"
PACKAGECONFIG[hsm] = "-DBUILD_P11=ON -DPKCS11_ENGINE_PATH=${PKCS11_ENGINE_PATH},-DBUILD_P11=OFF,libp11,"
PACKAGECONFIG[sota-tools] = "-DBUILD_SOTA_TOOLS=ON ${GARAGE_SIGN_OPS},-DBUILD_SOTA_TOOLS=OFF,glib-2.0,"
PACKAGECONFIG[load-tests] = "-DBUILD_LOAD_TESTS=ON,-DBUILD_LOAD_TESTS=OFF,"
PACKAGECONFIG[serialcan] = ",,,slcand-start"
PACKAGECONFIG[ubootenv] = ",,u-boot-fw-utils,u-boot-fw-utils aktualizr-uboot-env-rollback"

# can be overriden in configuration with `RESOURCE_xxx_pn-aktualizr`
# see `man systemd.resource-control` for details

# can be used to lower aktualizr priority, default is 100
RESOURCE_CPU_WEIGHT = "100"
# will be slowed down when it reaches 'high', killed when it reaches 'max'
RESOURCE_MEMORY_HIGH = "100M"
RESOURCE_MEMORY_MAX = "80%"

do_compile_ptest() {
    cmake_runcmake_build --target build_tests "${PARALLEL_MAKE}"
}

do_install_ptest() {
    # copy the complete source directory (contains build)
    cp -r ${B}/ ${D}/${PTEST_PATH}/build
    cp -r ${S}/ ${D}/${PTEST_PATH}/src

    # remove huge build artifacts
    find ${D}/${PTEST_PATH}/build/src -name "*.a" -delete

    # fix the absolute paths
    find ${D}/${PTEST_PATH}/build -name "CMakeFiles" | xargs rm -rf
    find ${D}/${PTEST_PATH}/build -name "*.cmake" -or -name "DartConfiguration.tcl" -or -name "run-valgrind" | xargs sed -e "s|${S}|${PTEST_PATH}/src|g" -e "s|${B}|${PTEST_PATH}/build|g" -e "s|\"--gtest_output[^\"]*\"||g" -i
}

do_install:append () {
    install -d ${D}${libdir}/sota
    install -m 0644 ${S}/config/sota-shared-cred.toml ${D}/${libdir}/sota/sota-shared-cred.toml
    install -m 0644 ${S}/config/sota-device-cred-hsm.toml ${D}/${libdir}/sota/sota-device-cred-hsm.toml
    install -m 0644 ${S}/config/sota-device-cred.toml ${D}/${libdir}/sota/sota-device-cred.toml
    install -m 0644 ${S}/config/sota-secondary.toml ${D}/${libdir}/sota/sota-secondary.toml
    install -m 0644 ${S}/config/sota-uboot-env.toml ${D}/${libdir}/sota/sota-uboot-env.toml
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/aktualizr-secondary.service ${D}${systemd_unitdir}/system/aktualizr-secondary.service
    install -m 0700 -d ${D}${libdir}/sota/conf.d
    install -m 0700 -d ${D}${sysconfdir}/sota/conf.d
    install -d ${D}${nonarch_libdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/aktualizr-tmpfiles.conf ${D}${nonarch_libdir}/tmpfiles.d/aktualizr.conf

    install -m 0755 -d ${D}${systemd_unitdir}/system
    aktualizr_service=${@bb.utils.contains('SOTA_CLIENT_FEATURES', 'serialcan', '${WORKDIR}/aktualizr-serialcan.service', '${WORKDIR}/aktualizr.service', d)}
    install -m 0644 ${aktualizr_service} ${D}${systemd_unitdir}/system/aktualizr.service

    if ${@bb.utils.contains('PACKAGECONFIG', 'sota-tools', 'true', 'false', d)}; then
        install -m 0755 ${B}/src/sota_tools/garage-sign/bin/* ${D}${bindir}
        install -m 0644 ${B}/src/sota_tools/garage-sign/lib/* ${D}${libdir}
    fi

    # resource control
    install -d ${D}/${systemd_system_unitdir}/aktualizr.service.d
    install -m 0644 ${WORKDIR}/10-resource-control.conf ${D}/${systemd_system_unitdir}/aktualizr.service.d

    sed -i -e 's|@CPU_WEIGHT@|${RESOURCE_CPU_WEIGHT}|g' \
           -e 's|@MEMORY_HIGH@|${RESOURCE_MEMORY_HIGH}|g' \
           -e 's|@MEMORY_MAX@|${RESOURCE_MEMORY_MAX}|g' \
           ${D}${systemd_system_unitdir}/aktualizr.service.d/10-resource-control.conf
}

PACKAGESPLITFUNCS:prepend = "split_hosttools_packages "

python split_hosttools_packages () {
    bindir = d.getVar('bindir')

    # Split all binaries to their own packages.
    do_split_packages(d, bindir, '^(.*)$', '%s', 'Aktualizr tool - %s', extra_depends='', prepend=False)
}

PACKAGES_DYNAMIC = "^aktualizr-.* ^garage-.*"

PACKAGES =+ "${PN}-info ${PN}-lib ${PN}-resource-control ${PN}-configs ${PN}-secondary ${PN}-secondary-lib ${PN}-sotatools-lib"

FILES:${PN} = " \
                ${bindir}/aktualizr \
                ${systemd_unitdir}/system/aktualizr.service \
                "

FILES:${PN}-info = " \
                ${bindir}/aktualizr-info \
                "

FILES:${PN}-lib = " \
                ${libdir}/libaktualizr.so \
                ${nonarch_libdir}/tmpfiles.d/aktualizr.conf \
                "

FILES:${PN}-resource-control = " \
                ${systemd_system_unitdir}/aktualizr.service.d/10-resource-control.conf \
                "

FILES:${PN}-configs = " \
                ${sysconfdir}/sota/* \
                ${libdir}/sota/* \
                "

FILES:${PN}-secondary = " \
                ${bindir}/aktualizr-secondary \
                ${libdir}/sota/sota-secondary.toml \
                ${systemd_unitdir}/system/aktualizr-secondary.service \
                "

FILES:${PN}-secondary-lib = " \
                ${libdir}/libaktualizr_secondary.so \
                "

FILES:${PN}-sotatools-lib = " \
                ${libdir}/libsota_tools.so \
                "

FILES:${PN}-dev = " \
                ${includedir}/lib${PN} \
                ${libdir}/pkgconfig/aktualizr.pc \
                "

BBCLASSEXTEND = "native"

# vim:set ts=4 sw=4 sts=4 expandtab:
