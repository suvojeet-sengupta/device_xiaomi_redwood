Copyright (C) 2025 - The LineageOS Project
Copyright (C) 2026 - Paranoid Android

Device configuration for Xiaomi Poco X5 Pro 5G/Redmi Note 12 Pro Speed
==============

The Xiaomi Poco X5 Pro 5G/Redmi Note 12 Pro Speed (codenamed _"redwood"_) is a mid-range smartphone from Xiaomi.

It was released in February 2023.

Maintained by Suvojeet Sengupta ([@suvojeet-sengupta](https://github.com/suvojeet-sengupta)).

## Device specifications

Basic   | Spec Sheet
-------:|:-------------------------
CPU     | Kryo 670, Up to 2.4 GHz, Octa-core CPU
Chipset | Qualcomm Snapdragon 778G 5G (SM7325-2-AB)
GPU     | Adreno 642L
Memory  | 6/8 GB, LPDDR4X
Storage | 128/256 GB, UFS 2.2
Shipped Android Version | 12
Battery | Non-removable 5000 mAh
Display | 2400 x 1080 pixels, 6.67 inches
Camera  | 108 MP main, 8 MP ultra-wide angle, 2 MP telemacro, 16 MP front

## Device picture

![Poco X5 Pro 5G/Redmi Note 12 Pro Speed](https://i.blogs.es/98a725/poco-x5-pro/1366_2000.jpeg "Poco X5 Pro 5G/Redmi Note 12 Pro Speed")

## Building PenguinOS

This tree targets [PenguinOS](https://github.com/Project-PenguinOS/manifest)
`celerity`, which is based on Paranoid Android `calcite` (CLO). It uses the
AOSPA `device/qcom/common` QTI components, so the blobs those components
already provide are not listed in `proprietary-files.txt`.

Add the following to `.repo/local_manifests/redwood.xml`. The first block
is upstream AOSPA's lahaina platform manifest
(`vendor/aospa/products/platforms/lahaina.xml` on `calcite`); PenguinOS's
copy still points at the older `vauxite` branches, which don't match the
`vendor/qcom/common` blobs.

`device/qcom/common` comes from PenguinOS's own fork, since AOSPA's now
expects a newer CLO QSSI sepolicy than PenguinOS pins and still references
the `hub_app` domain PenguinOS dropped.

redwood also needs a few source patches, kept in `patches/` for both ROMs:

- `vendor/aospa`: AOSPA's `vendor.qti.hardware.perf` HIDL interfaces, which
  the perf component needs.
- `packages/modules/Connectivity`: redwood ships a 5.4 kernel, but Android
  17's network bpf programs require 5.10. The bpfloader refuses to run and
  netd can't find its stats programs, and init reboots the device either way.
- `system/memory/lmkd`: the kernel kills with Simple LMK and has no psi, so
  lmkd has to stay on the in-kernel interface instead of exiting.
- `frameworks/opt/telephony`: the modem never reports EN-DC availability and
  drops the NR secondary cell every few seconds, so on 5G NSA the status bar
  kept falling back to 4G. With `ro.telephony.sticky_nr_anchor` NR stays
  available while camped on the LTE cell it was seen on.
- `frameworks/av`: MIUI Camera sends AF modes and triggers to the fixed focus
  front camera, and the front video pipeline with stabilization stalls on
  each tap to focus. cameraserver keeps AF off for fixed focus cameras, and
  ignores their AE regions on video streams, since tap to meter stalls the
  30 fps stabilized pipeline too.
- `frameworks/base`: QTI's SystemUI shows the LTE anchor's icon for the NR NSA
  override unless the modem reports a QTI NR icon type, which redwood's never
  does. `config_nrNsaIconFromDisplayInfo` shows 5G there instead.
- `vendor/qcom/opensource/power`: ADPF hint sessions boost their threads
  through a WALT node only 5.10 and newer kernels have, every request failed
  and flooded the log. Skip it there, and log the per frame calls only when
  debugging.
- `device/qcom/common`: make `ro.vendor.qspm.enable` overridable. QSPM needs
  `ISnapdragonServices`, which redwood's vendor doesn't have.

`patches-penguinos/` holds the ones only PenguinOS needs:

- `packages/apps/Settings`: About phone > Model lists SoC Model and Total
  RAM, but PenguinOS never added their controllers, so both were blank.
- `frameworks/base`: Google Photos' Pixel XL spoof keeps the device's own
  build fingerprint.

and `patches-aospa/` the ones only AOSPA needs:

- `vendor/google/gms`: AOSPA's GMS ships WebViewGoogle64, which only has 64
  bit libraries but declares multiArch, so Android 17 won't install it on
  redwood, and it overrides the AOSP WebView. With no WebView, Setup Wizard
  and Play Store crashed on a clean flash. Dropping it brings back the AOSP
  WebView, which has 32 and 64 bit libraries, and it's listed first in the
  WebView providers, since WebViewUpdateService only falls back to the
  first available by default one.
- `device/qcom/common`: PenguinOS's copy declares the QSPM HAL attributes,
  which AOSPA's QSSI sepolicy already has, so sepolicy failed to build.
- `system/core`: the health HAL only looked for chargers when it started,
  before the USB power supply reports a USB type, so plugging in a charger
  showed no charging indicator, LED or notification. Look for chargers on
  every update.
- `system/memory/libmeminfo`: the 5.4 kernel has no GPU memory tracepoint, so
  the gpuMem bpf map isn't what libmeminfo expects and system_server aborts
  reading it at boot. PenguinOS already carries this.
- `frameworks/base`, `frameworks/av`: PenguinOS's MIUI Camera support. MIUI
  Camera builds StreamConfigurationMap through constructors AOSP doesn't
  have, so without them it gets no picture sizes and closes.
- `frameworks/base`: PropImitationHooks, which AOSPA dropped, so Play
  Integrity can pass. The overlay ships a default certified build, which
  gives basic integrity. Key attestation isn't blocked, so Play Integrity
  Fix with a Tricky Store keybox gets device and strong integrity without
  any setup. Setting `persist.sys.pihooks.disable.gms_key_attestation_block`
  to false brings the block back, and `persist.sys.pihooks.disable.gms_props`
  turns off the props spoofing.
  Google Photos' Pixel XL spoof keeps the device's own build fingerprint.
- `frameworks/av`: PenguinOS's torch strength extension, which
  `camera/CameraProviderExtension.cpp` plugs into.
- `system/security`, `vendor/aospa`, `packages/apps/Settings`: PenguinOS's
  TEE Simulator. keystore2 serves attestation from an imported keybox for
  the picked apps, set up in More security settings.
- `frameworks/base`, `packages/apps/Settings`, `packages/apps/ParanoidSettings`:
  ignore secure windows (in More security & privacy too), hide applist,
  the maintainer in device info, three finger swipe to screenshot, and the
  face virtual HAL only being used when it's installed.

`vendorsetup.sh` tells the ROMs apart by PenguinOS's
`frameworks/base/core/res/res/values/custom_config.xml` and applies them whenever `build/envsetup.sh` (and so
`rom-build.sh`) runs, skipping the ones that are already applied, so they
survive a `repo sync`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <!-- lahaina platform -->
  <project path="vendor/qcom/opensource/audio-hal/primary-hal" name="AOSPA/android_hardware_qcom_audio" remote="aospa" revision="calcite-888" />
  <project path="hardware/qcom/display" name="AOSPA/android_hardware_qcom_display" remote="aospa" revision="calcite-888" />
  <project path="hardware/qcom/gps" name="AOSPA/android_hardware_qcom_gps" remote="aospa" revision="calcite-legacy-component" />
  <project path="hardware/qcom/media" name="AOSPA/android_hardware_qcom_media" remote="aospa" revision="calcite-888" />
  <remove-project name="AOSPA/android_hardware_qcom_thermal" />
  <project path="vendor/qcom/opensource/thermal-hal" name="AOSPA/android_hardware_qcom_thermal" remote="aospa" revision="calcite-legacy" />

  <!-- PenguinOS qcom common: matches the pinned CLO QSSI sepolicy -->
  <remove-project name="AOSPA/android_device_qcom_common" />
  <project path="device/qcom/common" name="Project-PenguinOS/device_qcom_common" remote="penguin" revision="celerity">
    <linkfile dest="vendor/qcom/build/tasks/generate_extra_images.mk" src="generate_extra_images.mk"/>
  </project>

  <!-- redwood -->
  <project path="device/xiaomi/redwood" name="suvojeet-sengupta/device_xiaomi_redwood" remote="github" revision="clo" />
  <project path="device/xiaomi/redwood-kernel" name="suvojeet-sengupta/device_xiaomi_redwood-kernel" remote="github" revision="clo" clone-depth="1" />
  <project path="vendor/xiaomi/redwood" name="suvojeet-sengupta/vendor_xiaomi_redwood" remote="github" revision="clo" clone-depth="1" />
  <project path="vendor/xiaomi/redwood-miuicamera" name="suvojeet-sengupta/android_vendor_xiaomi_redwood-miuicamera" remote="github" revision="miui-seventeen" clone-depth="1" />
  <project path="hardware/xiaomi" name="AOSPA/android_hardware_xiaomi" remote="aospa" revision="calcite" />
  <project path="hardware/dolby" name="suvojeet-sengupta/hardware_dolby" remote="github" revision="moto/dolby-dolbyvision" clone-depth="1" />
</manifest>
```

Then sync and build:

```bash
repo sync --current-branch --no-tags -j4
./rom-build.sh redwood
```

For a release signed build, pass the folder with the signing keys (releasekey,
platform, shared, media, networkstack, sdk_sandbox, bluetooth, nfc and one key
per APEX, with its payload `.pem`):

```bash
./rom-build.sh redwood -t user -s ~/.android-certs
```

Moving between test keys and release keys needs a data wipe, moving between
`userdebug` and `user` with the same keys doesn't. Keep a copy of the keys off
the build server, a build signed with other keys can't be flashed over it.

`vendor/xiaomi/redwood` must be re-extracted whenever `proprietary-files.txt`
changes, from a dump of the stock HyperOS firmware:

```bash
cd device/xiaomi/redwood && ./extract-files.py /path/to/stock/dump
```

