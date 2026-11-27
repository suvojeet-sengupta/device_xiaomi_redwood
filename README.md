# redwood PixelOS setup (6.18 kernel)

Scripts to build PixelOS 17 (`seventeen`) for the POCO X5 Pro 5G (redwood)
with the 6.18 kernel prebuilt.

| Path | Repo |
| --- | --- |
| device/xiaomi/redwood | [suvojeet-sengupta/device_xiaomi_redwood](https://github.com/suvojeet-sengupta/device_xiaomi_redwood) `seventeen` |
| device/xiaomi/redwood-kernel-6.18 | [suvojeet-sengupta/device_xiaomi_redwood-kernel-6.18](https://github.com/suvojeet-sengupta/device_xiaomi_redwood-kernel-6.18) `main` |
| vendor/xiaomi/redwood | [suvojeet-sengupta/vendor_xiaomi_redwood_pixelos](https://github.com/suvojeet-sengupta/vendor_xiaomi_redwood_pixelos) `seventeen` |
| vendor/xiaomi/redwood-miuicamera | [genie1997/redwood_miuicamera](https://github.com/genie1997/redwood_miuicamera) `seventeen` |
| hardware/dolby | [suvojeet-sengupta/hardware_dolby](https://github.com/suvojeet-sengupta/hardware_dolby) `moto/dolby-dolbyvision` |
| hardware/redwood-compat | [suvojeet-sengupta/android_hardware_redwood_compat](https://github.com/suvojeet-sengupta/android_hardware_redwood_compat) `seventeen` |
| hardware/xiaomi | [LineageOS/android_hardware_xiaomi](https://github.com/LineageOS/android_hardware_xiaomi) `lineage-24.0` |

## Build

```bash
mkdir pixelos && cd pixelos
repo init -u https://github.com/PixelOS-AOSP/android_manifest.git -b seventeen --git-lfs
repo sync -c -j8 --force-sync --no-tags
git clone -b seventeen-setup https://github.com/suvojeet-sengupta/device_xiaomi_redwood ~/redwood-pixelos-setup
~/redwood-pixelos-setup/setup.sh
~/redwood-pixelos-setup/build.sh -i
```

`build.sh` takes `user`, `userdebug` (default) or `eng`, and `RELEASE` picks
another release config (default `cp2a`). Use `-i` for every build you
publish: an incremental build keeps the old build date.

## Signing

The build signs itself with the release keys: `setup.sh` clones the private
[keys](https://github.com/suvojeet-sengupta/keys) repo to
`vendor/lineage-priv/keys` (set `KEYS_REPO` for another one; git needs
credentials for it), and its `keys.mk` makes `releasekey` the default
certificate. Every APK and APEX, the OTA package and the images come out
signed and tagged `release-keys`, with no re-signing afterwards. `build.sh`
stops if the keys are missing or the build would sign with anything else,
checks that the finished zip carries `releasekey`, and lists any APEX that
has no key in the repo and kept its test key. Recovery only installs a zip
signed with the key of the build it runs, so don't mix release-key and
test-key builds.

The tree root then holds `PixelOS_<version>.zip` for recovery,
`PixelOS_<version>-fastboot.zip` for `fastboot update`, a `.sha256` for each,
and `images/` with boot, vendor_boot and dtbo.

## Root

KernelSU, KernelSU Next and KowSU patch the boot image with their
android17-6.18 module. Pick the KMI `android17-6.18` by hand: the kernel
release (`6.18.33-Suvkernel`) doesn't name it.
