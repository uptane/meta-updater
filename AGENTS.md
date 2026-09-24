# AGENTS.md

Yocto layer providing OTA updates with OSTree and Aktualizr.

It supports GRUB, systemd-boot and U-Boot, UKI deployments and SELinux
build-time labeling. The supported Yocto release is whatever
`LAYERSERIES_COMPAT_sota` in `conf/layer.conf` says; `master` builds against
the `master` branches of oe-core, bitbake and meta-openembedded (see
`kas/base.yml`).

## Where to look

- `README.adoc`: overview, dependencies, links to the full documentation.
- `CONTRIBUTING.adoc`: branches, DCO and the contributor checklist.
- `classes/`: core logic (`sota.bbclass`, `image_types_ostree.bbclass`, `sota_<platform>.bbclass` for platform support).
- `recipes-*/`: recipes, grouped by area.
- `kas/`: kas configurations for supported machines.
- `lib/oeqa/selftest/cases/`: oe-selftest tests (`updater_*.py`).
- `scripts/`: `run-qemu-ota` (boots images for the selftests) and `ci/` (GitLab CI).

## Build environment

Build inside `kas-container`, which bundles the build environment, so no
build dependencies are installed on the host. You need:

1. `kas-container` on `PATH`, or `KAS_CONTAINER=/abs/path/to/kas-container`
   (from [kas](https://github.com/siemens/kas/blob/master/kas-container)).
2. A container runtime that `kas-container` can use.
3. Work directories outside the repository for build output and shared caches.

`kas-container` uses Docker when it is installed and falls back to Podman
otherwise (set `KAS_CONTAINER_ENGINE` to override), so check the engine it
will pick:

```sh
docker run --rm hello-world    # or, on a Podman-only host: podman run --rm hello-world
```

Do not use `sudo` unless the host setup requires it, and do not create or
modify user groups as part of this workflow.

If `KAS_WORK_DIR`, `KAS_BUILD_DIR`, `DL_DIR` and `SSTATE_DIR` are already set
in the environment, use them as they are. Only set defaults when they are
absent:

```sh
export KAS_WORK_DIR="${KAS_WORK_DIR:-/path/to/kas-work}"   # outside the checkout
export DL_DIR="${DL_DIR:-/path/to/shared-cache/downloads}"
export SSTATE_DIR="${SSTATE_DIR:-/path/to/shared-cache/sstate-cache}"
mkdir -p "${DL_DIR}" "${SSTATE_DIR}" "${KAS_WORK_DIR}"
```

`kas-container` mounts the checkout as `/repo`, `KAS_WORK_DIR` as `/work`,
and `DL_DIR` / `SSTATE_DIR` when set, so the caches persist between builds.
The layer clones (`oe-core`, `bitbake`, `meta-openembedded`, ...) live in
`KAS_WORK_DIR`, and the build directory is `${KAS_WORK_DIR}/build` unless
`KAS_BUILD_DIR` is set. Because `/repo` is the live checkout, do not switch
branches or rebase while a build is running from it.

## Building

| Config                 | Description                                     |
|------------------------|-------------------------------------------------|
| `intel-corei7-64.yml`  | Intel x86-64 (EFI, GRUB)                        |
| `raspberrypi4-64.yml`  | Raspberry Pi 4 (64-bit)                         |
| `rb3gen2-core-kit.yml` | Qualcomm RB3 Gen2                               |
| `selinux.yml`          | SELinux fragment; combine with a machine config |

`base.yml`, `common-qcom.yml` and `common-rpi.yml` are only included by the
others. Combine fragments with `:`, e.g. `kas/intel-corei7-64.yml:kas/selinux.yml`.

```sh
"${KAS_CONTAINER:-kas-container}" build kas/intel-corei7-64.yml

# Run a command in the build environment, without re-fetching the layers:
"${KAS_CONTAINER:-kas-container}" shell --skip repos_checkout kas/intel-corei7-64.yml \
  -c "bitbake core-image-base"

# Re-run a single task:
"${KAS_CONTAINER:-kas-container}" shell --skip repos_checkout kas/intel-corei7-64.yml \
  -c "bitbake core-image-base -c image_ota_ext4 -f"
```

### Keeping the layers current

kas clones the layers once and does not move existing clones afterwards.
Because `master` follows the upstream `master` branches, a stale
`KAS_WORK_DIR` stops parsing as soon as a versioned bbappend no longer
matches the recipe in the old meta-openembedded clone:

```text
ERROR: No recipes in default available for:
  /build/../repo/recipes-extended/ostree/ostree_2026.4.bbappend
```

After rebasing on upstream `master`, or whenever that error shows up,
refresh the clones with `--update` instead of `--skip repos_checkout`:

```sh
"${KAS_CONTAINER:-kas-container}" shell --update kas/intel-corei7-64.yml \
  -c "bitbake core-image-base"
```

`--update` resets the kas-managed clones to the tip of their branch, so
check that they carry no local work first. When upstream bumps a recipe
that a versioned bbappend tracks, rename the bbappend in the commit that
needs it and check that the carried patches still apply
(`bitbake <recipe> -c patch -f`).

### Disk space

A `core-image-base` build from a cold sstate cache needs on the order of
100 GB in `tmp/`, plus what it adds to `SSTATE_DIR`, and updating the layers
invalidates most of the cache. The kas-generated `local.conf` sets no
`BB_DISKMON_DIRS`, so bitbake runs the disk full instead of stopping. Check
the free space before a build; on a constrained host, add a temporary
`conf/auto.conf` to the build directory (kas does not manage it, so remove it
again afterwards):

```sh
cat > "${KAS_BUILD_DIR:-${KAS_WORK_DIR}/build}/conf/auto.conf" <<'EOF'
INHERIT += "rm_work"
BB_DISKMON_DIRS = "STOPTASKS,${TMPDIR},10G,100K STOPTASKS,${SSTATE_DIR},10G,100K HALT,${TMPDIR},5G,50K"
EOF
```

Never delete build output, sstate or download directories to make room
without asking the user first, even when the content can be regenerated.

## Booting in QEMU

Boot-test changes to OSTree, the image types and the boot flow in QEMU.
`runqemu` needs KVM; `kas-container --kvm` (kas 5.5 or later) passes
`/dev/kvm` into the container and gives the build user access to it:

```sh
"${KAS_CONTAINER:-kas-container}" --kvm shell \
  --skip repos_checkout kas/intel-corei7-64.yml
# then, inside the shell:
runqemu core-image-base wic nographic slirp serial ovmf qemuparams="-m 1024 -no-reboot"
```

Without KVM, or for more control over the machine and the serial log, run
the native QEMU from the build directory on the host. QEMU then falls back
to TCG emulation, which is slower but enough for boot tests; do not run a
build at the same time.

```sh
BUILD_DIR="${KAS_BUILD_DIR:-${KAS_WORK_DIR}/build}"
DEPLOY_DIR="${BUILD_DIR}/tmp/deploy/images/intel-corei7-64"
COMPONENTS="${BUILD_DIR}/tmp/sysroots-components/x86_64"
UNINATIVE="${BUILD_DIR}/tmp/sysroots-uninative/x86_64-linux"
QEMU="${COMPONENTS}/qemu-system-native/usr/bin/qemu-system-x86_64"
LIB_PATH="$(ls -d "${COMPONENTS}"/*/usr/lib | tr '\n' ':')${UNINATIVE}/lib:${UNINATIVE}/usr/lib"

cp "${DEPLOY_DIR}/ovmf.vars.qcow2" /tmp/ovmf.vars.qcow2   # one copy per VM

"${UNINATIVE}/lib/ld-linux-x86-64.so.2" --library-path "${LIB_PATH}" "${QEMU}" \
  -L "${COMPONENTS}/qemu-system-native/usr/share/qemu" \
  -drive if=pflash,format=qcow2,readonly=on,file="${DEPLOY_DIR}/ovmf.code.qcow2" \
  -drive if=pflash,format=qcow2,file=/tmp/ovmf.vars.qcow2 \
  -drive file="${DEPLOY_DIR}/core-image-base-intel-corei7-64.rootfs.wic",format=raw,snapshot=on \
  -cpu IvyBridge -m 1024 -nographic -no-reboot \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -chardev file,id=char0,path=/tmp/qemu-serial.log -serial chardev:char0
```

- The native binary cannot be run directly: its ELF interpreter is the
  in-container path `/build/tmp/sysroots-uninative/...`, so the shell reports
  `cannot execute: required file not found`. Run it through the uninative
  loader as above, with libraries from `sysroots-components` (an image's
  `recipe-sysroot-native` is deleted by `rm_work`).
- Intel images need `-cpu IvyBridge` or newer: the kernel is built for
  corei7, and the default `qemu64` CPU fails with invalid opcode faults.
- `snapshot=on` keeps the image in the deploy directory unchanged.

A login prompt alone does not show much. To check the booted system, use
`-serial stdio`, log in as `root` (the kas configs allow an empty password)
and look at `ostree admin status`, `/proc/mounts`,
`systemctl is-system-running` and `journalctl -b -p err`. The image is
BusyBox based: use `head -n N` rather than `head -N`, and there is no
`findmnt`.

## Testing

- Go through the contributor checklist in `CONTRIBUTING.adoc` before submitting.
- List in the PR description which checks were run and which were not; never claim a check that was not run.

Run the selftests inside `kas-container`:

```sh
"${KAS_CONTAINER:-kas-container}" shell --skip repos_checkout kas/intel-corei7-64.yml \
  -c "oe-selftest -r updater"

# A single module or class:
"${KAS_CONTAINER:-kas-container}" shell --skip repos_checkout kas/intel-corei7-64.yml \
  -c "oe-selftest -r updater_qemux86_64.GeneralTests"
```

The test cases set the `MACHINE` they need (mostly `qemux86-64`) themselves,
so the kas machine config only provides the environment. The GitLab CI
pipeline runs the same tests through the `repo` and Docker based flow in
`scripts/ci/`, not through kas.

## Commits and PRs

- Target `master`; backports go to the release branches.
- Every commit needs `Signed-off-by:` (`git commit -s`).
- AI-assisted commits use `Assisted-by: AGENT_NAME:MODEL_VERSION`, not `Co-Authored-By:`.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `No recipes in default available for: .../ostree_<version>.bbappend` | Stale layer clones in `KAS_WORK_DIR`, or upstream bumped the recipe | Re-run with `--update`; if upstream moved on, rename the bbappend and check the carried patches |
| `do_patch` fails after a recipe version bump | A carried patch was merged upstream | Check the patch's `Upstream-Status`; if the fix is in the new release, drop the patch instead of refreshing it |
| `OSError: [Errno 28] No space left on device` during a build | No disk monitor in the kas `local.conf` | Ask the user to free space, then resume with `rm_work` and `BB_DISKMON_DIRS` (see "Disk space") |
| `qemu-system-x86_64: cannot execute: required file not found` on the host | The ELF interpreter is the in-container `/build/tmp/...` path | Run QEMU through the uninative loader (see "Booting in QEMU") |
| QEMU "invalid opcode" crash | The default `qemu64` CPU lacks SSE4 | Use `-cpu IvyBridge` |
| Build warns that `var/lib` is not preserved | OSTree deployments do not carry `/var`; only `/usr` and `/etc` come from the commit | Move the data under `/usr`, or ignore the warning |
