# Based on gen-cfs-keys.inc from https://github.com/torizon/meta-toradex-torizon

gen_cfs_keys0() {
    local keydir="${1}"
    local keyname="${2}"

    local pubkey="${keydir}/${keyname}.pub"
    local seckey="${keydir}/${keyname}.sec"

    mkdir -p "${keydir}"

    local pem="$(openssl genpkey -algorithm ed25519 -outform PEM)"
    local pub="$(printf "%s" "${pem}" | openssl pkey -outform DER -pubout | tail -c 32 | base64)"
    local seed="$(printf "%s" "${pem}" | openssl pkey -outform DER | tail -c 32 | base64)"

    # Save secret key (concatenate seed and pub key); see libtest.sh in the ostree code base.
    # Use base64 -w0 to avoid line wrapping which would cause ostree to reject the key.
    (printf "%s" "${seed}" | base64 -d && \
     printf "%s" "${pub}"  | base64 -d) | base64 -w0 > "${seckey}"

    # Save public key:
    printf "%s" "${pub}" > "${pubkey}"
}

gen_cfs_keys() {
    if [ -z "${CFS_SIGN_KEYDIR}" ] || [ -z "${CFS_SIGN_KEYNAME}" ] || [ -z "${CFS_GENERATE_KEYS}" ]; then
        bbfatal "Composefs signing not correctly set up."
    fi

    local pubkey="${CFS_SIGN_KEYDIR}/${CFS_SIGN_KEYNAME}.pub"
    local seckey="${CFS_SIGN_KEYDIR}/${CFS_SIGN_KEYNAME}.sec"

    if [ "${CFS_GENERATE_KEYS}" = "1" ]; then
        if [ -f "${pubkey}" ] && [ -f "${seckey}" ]; then
	    bbnote "Key pair \"${CFS_SIGN_KEYNAME}\" already exists; skipping generation."
	else
	    bbnote "Generating key pair \"${CFS_SIGN_KEYNAME}\" (.pub, .sec)."
	    gen_cfs_keys0 "${CFS_SIGN_KEYDIR}" "${CFS_SIGN_KEYNAME}"
	fi
    fi

    if [ ! -f "${seckey}" ]; then
        bbfatal "Could not find key file \"${seckey}\"."
    fi
}

def cfs_get_key_file_checksums(d):
    if "cfs-signed" not in d.getVar("OVERRIDES").split(":"):
        return ""
    seckey = os.path.join(d.getVar("CFS_SIGN_KEYDIR"),
                          d.getVar("CFS_SIGN_KEYNAME") + ".sec")
    pubkey = os.path.join(d.getVar("CFS_SIGN_KEYDIR"),
                          d.getVar("CFS_SIGN_KEYNAME") + ".pub")
    return " ".join([
        seckey + (":True" if os.path.exists(seckey) else ":False"),
        pubkey + (":True" if os.path.exists(pubkey) else ":False")
    ])

generate_cfs_keys[lockfiles] += "${DEPLOY_DIR_IMAGE}/cfskeys.lock"
generate_cfs_keys() {
    gen_cfs_keys
}

# Set up a task that signs with the composefs key for cfs-signed builds: the
# key pair is generated (if needed) before the task runs, and the task is
# rerun whenever the key files change.
#
# 'nostamp' is only needed when 'cfs-signed' is active, because that feature
# generates cryptographic keys at build time, making the task non-cacheable
# since the keys might change. For projects not using 'cfs-signed', there are
# no keys involved and the task is deterministic, so setting 'nostamp'
# unconditionally would cause taint propagation to all dependent tasks,
# eventually breaking the build.
#
# Due to Yocto bug #13808, it is not possible to use an inline python function
# to set flags conditionally, so call this from an anonymous python function:
#
#   python() {
#       cfs_signed_task_setup(d, 'do_install')
#   }
def cfs_signed_task_setup(d, task):
    if 'cfs-signed' not in (d.getVar('OVERRIDES') or '').split(':'):
        return
    d.appendVarFlag(task, 'prefuncs', ' generate_cfs_keys')
    d.appendVarFlag(task, 'depends', ' coreutils-native:do_populate_sysroot'
                                     ' openssl-native:do_populate_sysroot')
    d.appendVarFlag(task, 'file-checksums', ' ' + cfs_get_key_file_checksums(d))
    d.setVarFlag(task, 'nostamp', '1')
