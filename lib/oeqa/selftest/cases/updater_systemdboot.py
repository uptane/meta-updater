# SPDX-License-Identifier: MIT

"""Metadata checks for the initial systemd-boot menu configuration."""

from oeqa.selftest.case import OESelftestTestCase
from oeqa.utils.commands import bitbake, get_bb_var, get_bb_vars


class SystemdBootTimeoutTests(OESelftestTestCase):
    config = '''\
MACHINE = "qemux86-64"
SOTA_MACHINE = "intel"
OSTREE_BOOTLOADER = "systemd-boot"
IMAGE_FSTYPES = "ota-esp wic"
'''

    def test_default_timeout(self):
        self.write_config(self.config)
        self.assertEqual(get_bb_var('OSTREE_SYSTEMD_BOOT_TIMEOUT',
                                    'core-image-minimal'), '')

    def test_timeout_values_and_wic_export(self):
        for timeout in ('', '0', '5', '0005', '4294967293',
                        'menu-hidden', 'menu-force', 'menu-disabled'):
            with self.subTest(timeout=timeout):
                self.write_config(self.config +
                                  'OSTREE_SYSTEMD_BOOT_TIMEOUT = "%s"\n' % timeout)
                variables = get_bb_vars(['OSTREE_SYSTEMD_BOOT_TIMEOUT', 'WICVARS'],
                                        'core-image-minimal')
                self.assertEqual(variables['OSTREE_SYSTEMD_BOOT_TIMEOUT'] or '',
                                 timeout)
                self.assertIn('OSTREE_SYSTEMD_BOOT_TIMEOUT',
                              variables['WICVARS'].split())

    def test_invalid_timeout(self):
        for timeout in ('-1', '1.5', 'menu-disable', '5 editor no',
                        ' 5', '5 ', '4294967294', '4294967295', '4294967296'):
            with self.subTest(timeout=timeout):
                self.write_config(self.config +
                                  'OSTREE_SYSTEMD_BOOT_TIMEOUT = "%s"\n' % timeout)
                result = bitbake('-e core-image-minimal', ignore_status=True)
                self.assertNotEqual(result.status, 0)
                self.assertIn('OSTREE_SYSTEMD_BOOT_TIMEOUT must be', result.output)

    def test_timeout_is_specific_to_systemd_boot(self):
        self.write_config(self.config + '''\
OSTREE_BOOTLOADER = "grub"
OSTREE_SYSTEMD_BOOT_TIMEOUT = "not-a-systemd-boot-timeout"
''')
        self.assertEqual(get_bb_var('OSTREE_BOOTLOADER', 'core-image-minimal'),
                         'grub')
