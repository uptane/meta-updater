# SPDX-License-Identifier: GPL-2.0-only

"""Run with the wic Python package on PYTHONPATH."""

import importlib.util
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
import unittest
from unittest.mock import patch


plugin_path = (Path(__file__).resolve().parents[1] /
               "lib/wic/plugins/source/bootimg_sota_efi.py")
spec = importlib.util.spec_from_file_location("bootimg_sota_efi", plugin_path)
plugin = importlib.util.module_from_spec(spec)
spec.loader.exec_module(plugin)


class SystemdBootConfigTests(unittest.TestCase):
    def setUp(self):
        self.directory = TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.source = Path(self.directory.name) / "ota-boot"
        self.work = Path(self.directory.name) / "wic"
        self.config = self.source / "boot/loader/loader.conf"
        self.config.parent.mkdir(parents=True)
        self.part = SimpleNamespace(rootfs_dir=str(self.source))
        self.creator = SimpleNamespace(
            ks=SimpleNamespace(bootloader=SimpleNamespace(timeout=5)))
        self.bitbake_vars = {}
        self.enterContext(patch.object(plugin, "get_bitbake_var",
                                      side_effect=self.bitbake_vars.get))

    def configure(self):
        plugin.BootimgSotaEFIPlugin.do_configure_systemdboot(
            self.part, self.creator, str(self.work))
        return self.work / "hdd/boot/loader/loader.conf"

    def test_empty_timeout_uses_wks(self):
        self.bitbake_vars["OSTREE_SYSTEMD_BOOT_TIMEOUT"] = ""
        self.assertEqual(self.configure().read_text(), "timeout 5\n")

    def test_explicit_timeout_overrides_wks(self):
        for timeout in ("0", "3", "menu-hidden", "menu-force", "menu-disabled"):
            with self.subTest(timeout=timeout):
                original = "timeout 10\neditor no\n"
                self.config.write_text(original)
                self.bitbake_vars["OSTREE_SYSTEMD_BOOT_TIMEOUT"] = timeout
                output = self.configure()
                self.assertEqual(output.read_text(), "timeout %s\n" % timeout)

    def test_clearing_timeout_restores_wks(self):
        self.bitbake_vars["OSTREE_SYSTEMD_BOOT_TIMEOUT"] = "menu-disabled"
        self.assertEqual(self.configure().read_text(), "timeout menu-disabled\n")
        self.bitbake_vars["OSTREE_SYSTEMD_BOOT_TIMEOUT"] = ""
        self.assertEqual(self.configure().read_text(), "timeout 5\n")


if __name__ == "__main__":
    unittest.main()
