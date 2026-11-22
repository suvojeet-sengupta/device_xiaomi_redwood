#!/bin/bash
#
# Build PixelOS for redwood with the 6.18 kernel.
#
# Run it from the root of the PixelOS tree, after setup.sh:
#   ~/redwood-pixelos-setup/build.sh [-i] [-t | -S] [userdebug|user|eng]
#
# -i runs an installclean first: use it for every build you publish, since an
# incremental build keeps the old build date. The build type defaults to
# userdebug. Set RELEASE for another release config (default cp2a).
#
# Every build is signed with the release keys in KEYS_DIR (default ~/keys):
# all APKs and APEXes, the OTA package and the images. Without a key
# directory the build stops; -t builds with the AOSP test keys instead.
# A test-key build can't be installed over a release-key one.
# -S skips the build and only signs the last one again.
#
# The flashable zip and the fastboot zip end up in the tree root, boot,
# vendor_boot and dtbo for fastboot in images/.

set -eo pipefail

die() { echo "build: $*" >&2; exit 1; }

clean=
testkeys=
signonly=
variant=userdebug
for arg in "$@"; do
    case "$arg" in
    -i) clean=1 ;;
    -t) testkeys=1 ;;
    -S) signonly=1 ;;
    user | userdebug | eng) variant=$arg ;;
    *) die "unknown argument $arg" ;;
    esac
done
[ -n "$testkeys" ] && [ -n "$signonly" ] && die "-t and -S don't go together"

[ -f build/envsetup.sh ] || die "run this from the root of the ROM tree"
grep -q "redwood-kernel-6.18" device/xiaomi/redwood/BoardConfig.mk ||
    die "device/xiaomi/redwood isn't the 6.18 device tree, run setup.sh first"
[ -f device/xiaomi/redwood-kernel-6.18/Image ] || die "no 6.18 kernel prebuilt, run setup.sh first"

keys=${KEYS_DIR:-$HOME/keys}
if [ -z "$testkeys" ]; then
    [ -f "$keys/releasekey.pk8" ] && [ -f "$keys/platform.pk8" ] ||
        die "no release keys in $keys (set KEYS_DIR, or use -t for a test-key build)"
fi

out=out/target/product/redwood
tf=$out/obj/PACKAGING/target_files_intermediates/custom_redwood-target_files.zip

source build/envsetup.sh
lunch "custom_redwood-${RELEASE:-cp2a}-$variant"

if [ -z "$signonly" ]; then
    [ -n "$clean" ] && m installclean
    rm -f "$tf"
    # the target files zip is what gets signed; m pixelos alone leaves only
    # the unpacked directory
    m pixelos target-files-package
fi

if [ -n "$testkeys" ]; then
    zip=$(ls -t "$out"/PixelOS*redwood*.zip 2>/dev/null | grep -viE "ota|target_files|img|fastboot" | head -n 1 || true)
    [ -n "$zip" ] || die "no PixelOS zip in $out, the build failed"
    name=$(basename "$zip" .zip)
else
    [ -f "$tf" ] || die "no target files in $tf, run the build again without -S"
    # name the signed zips after the build in the target files, not after
    # whatever zip is newest in out/
    name=$(for p in SYSTEM/build.prop SYSTEM/etc/build.prop SYSTEM_EXT/etc/build.prop PRODUCT/etc/build.prop; do
        unzip -p "$tf" "$p" 2>/dev/null; done | sed -n 's/^ro\.custom\.version=//p' | head -n 1)
    [ -n "$name" ] || die "no ro.custom.version in $tf"
fi

if [ -n "$testkeys" ]; then
    echo "build: test-key build, not signed with release keys" >&2
    cp "$zip" .
    mkdir -p images
    for img in boot vendor_boot dtbo; do
        cp "$out/$img.img" images/
    done
else
    signed=$out/$name-signed-target_files.zip
    bin=out/host/linux-x86/bin

    # every APEX that isn't presigned gets the key of the same name
    apex_args=()
    while read -r line; do
        case "$line" in *PRESIGNED*) continue ;; esac
        apex=$(echo "$line" | sed -E 's/^name="([^"]+)".*/\1/')
        key=$keys/${apex%.apex}
        [ -f "$key.pk8" ] && [ -f "$key.pem" ] ||
            die "no key for $apex in $keys (need ${apex%.apex}.pk8, .x509.pem and .pem)"
        apex_args+=(--extra_apks "$apex=$key" --extra_apex_payload_key "$apex=$key.pem")
    done < <(unzip -p "$tf" META/apexkeys.txt)

    echo "build: signing with the keys in $keys"
    "$bin"/sign_target_files_apks -o -d "$keys" "${apex_args[@]}" "$tf" "$signed"
    "$bin"/ota_from_target_files -k "$keys/releasekey" "$signed" "$name.zip"
    "$bin"/img_from_target_files "$signed" "$name-fastboot.zip"

    # the release key must be the one the OTA carries
    want=$(sed -n '/BEGIN/,/END/p' "$keys/releasekey.x509.pem" | sha256sum | cut -d' ' -f1)
    have=$(unzip -p "$name.zip" META-INF/com/android/otacert | sed -n '/BEGIN/,/END/p' | sha256sum | cut -d' ' -f1)
    [ "$want" = "$have" ] || die "$name.zip isn't signed with $keys/releasekey"

    mkdir -p images
    unzip -o -q -j "$signed" IMAGES/boot.img IMAGES/vendor_boot.img IMAGES/dtbo.img -d images
fi

sha256sum "$name.zip" > "$name.zip.sha256"
[ -f "$name-fastboot.zip" ] && sha256sum "$name-fastboot.zip" > "$name-fastboot.zip.sha256"

echo
echo "Kernel:   $(sed -n 's/^release=//p' device/xiaomi/redwood-kernel-6.18/build-info.txt)"
echo "Keys:     $([ -n "$testkeys" ] && echo "AOSP test keys" || echo "$keys")"
echo "ROM:      $(pwd)/$name.zip"
[ -f "$name-fastboot.zip" ] && echo "Fastboot: $(pwd)/$name-fastboot.zip"
echo "Images:   $(pwd)/images/{boot,vendor_boot,dtbo}.img"
