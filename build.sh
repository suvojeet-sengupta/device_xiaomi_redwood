#!/bin/bash
#
# Build PixelOS for redwood with the 6.18 kernel.
#
# Run it from the root of the PixelOS tree, after setup.sh:
#   ~/redwood-pixelos-setup/build.sh [-i] [userdebug|user|eng]
#
# -i runs an installclean first: use it for every build you publish, since an
# incremental build keeps the old build date. The build type defaults to
# userdebug. Set RELEASE for another release config (default cp2a).
#
# The build signs itself with the release keys in vendor/lineage-priv/keys
# (setup.sh clones them): every APK and APEX, the OTA package and the images
# come out signed, with no re-signing step afterwards. Without the keys the
# build stops.
#
# The flashable zip and the fastboot zip end up in the tree root, boot,
# vendor_boot and dtbo for fastboot in images/.

set -eo pipefail

die() { echo "build: $*" >&2; exit 1; }

clean=
variant=userdebug
for arg in "$@"; do
    case "$arg" in
    -i) clean=1 ;;
    user | userdebug | eng) variant=$arg ;;
    *) die "unknown argument $arg" ;;
    esac
done

[ -f build/envsetup.sh ] || die "run this from the root of the ROM tree"
grep -q "redwood-kernel-6.18" device/xiaomi/redwood/BoardConfig.mk ||
    die "device/xiaomi/redwood isn't the 6.18 device tree, run setup.sh first"
[ -f device/xiaomi/redwood-kernel-6.18/Image ] || die "no 6.18 kernel prebuilt, run setup.sh first"

keys=vendor/lineage-priv/keys
for f in keys.mk releasekey.pk8 releasekey.x509.pem platform.pk8; do
    [ -f "$keys/$f" ] || die "no $keys/$f, run setup.sh first"
done

out=out/target/product/redwood
tf=$out/obj/PACKAGING/target_files_intermediates/custom_redwood-target_files.zip

source build/envsetup.sh
lunch "custom_redwood-${RELEASE:-cp2a}-$variant"

cert=$(get_build_var DEFAULT_SYSTEM_DEV_CERTIFICATE)
[ "$cert" = "$keys/releasekey" ] ||
    die "the build would sign with $cert, not $keys/releasekey"

[ -n "$clean" ] && m installclean
rm -f "$tf"
# pixelos builds the OTA zip, the target files zip is for the fastboot zip
m pixelos target-files-package

zip=$(ls -t "$out"/PixelOS_*.zip 2>/dev/null | head -n 1 || true)
[ -n "$zip" ] || die "no PixelOS zip in $out, the build failed"
[ -f "$tf" ] || die "no target files in $tf, the build failed"
name=$(basename "$zip" .zip)

# the release key must be the one the OTA carries
want=$(sed -n '/BEGIN/,/END/p' "$keys/releasekey.x509.pem" | sha256sum | cut -d' ' -f1)
have=$(unzip -p "$zip" META-INF/com/android/otacert | sed -n '/BEGIN/,/END/p' | sha256sum | cut -d' ' -f1)
[ "$want" = "$have" ] || die "$zip isn't signed with $keys/releasekey"
tags=$(unzip -p "$tf" SYSTEM/build.prop | sed -n 's/^ro\.build\.tags=//p')
[ "$tags" = release-keys ] || die "the build is tagged $tags, not release-keys"

# APEXes whose payload key isn't in the key directory keep their test key
unzip -p "$tf" META/apexkeys.txt | grep -v PRESIGNED | grep -v "private_key=\"$keys/" |
    sed -E 's/^name="([^"]+)".*/    \1/' > /tmp/redwood-testkey-apexes.$$ || true
if [ -s /tmp/redwood-testkey-apexes.$$ ]; then
    echo "build: these APEXes have no key in $keys and kept their test key:" >&2
    cat /tmp/redwood-testkey-apexes.$$ >&2
fi
rm -f /tmp/redwood-testkey-apexes.$$

cp "$zip" "$name.zip"
out/host/linux-x86/bin/img_from_target_files "$tf" "$name-fastboot.zip"
mkdir -p images
unzip -o -q -j "$tf" IMAGES/boot.img IMAGES/vendor_boot.img IMAGES/dtbo.img -d images

sha256sum "$name.zip" > "$name.zip.sha256"
sha256sum "$name-fastboot.zip" > "$name-fastboot.zip.sha256"

echo
echo "Kernel:   $(sed -n 's/^release=//p' device/xiaomi/redwood-kernel-6.18/build-info.txt)"
echo "Keys:     $keys"
echo "ROM:      $(pwd)/$name.zip"
echo "Fastboot: $(pwd)/$name-fastboot.zip"
echo "Images:   $(pwd)/images/{boot,vendor_boot,dtbo}.img"
