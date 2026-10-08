# Redwood Device Tree

Copyright (C) 2025 The LineageOS Project  
Copyright (C) 2026 Paranoid Android

Device configuration for Xiaomi Poco X5 Pro 5G / Redmi Note 12 Pro Speed (redwood).

**Maintainer:** [@suvojeet-sengupta](https://github.com/suvojeet-sengupta)

## Specifications

| Component | Details |
|-----------|---------|
| **Chipset** | Qualcomm Snapdragon 778G 5G (SM7325-2-AB) |
| **CPU** | Kryo 670, Octa-core, up to 2.4 GHz |
| **GPU** | Adreno 642L |
| **RAM** | 6/8 GB LPDDR4X |
| **Storage** | 128/256 GB UFS 2.2 |
| **Display** | 6.67", 2400 × 1080, 120 Hz |
| **Battery** | 5000 mAh (non-removable) |
| **Cameras** | 108 MP (main), 8 MP (wide), 2 MP (macro), 16 MP (front) |
| **OS** | Ships Android 12, supports Android 17 |

![Poco X5 Pro 5G](https://i.blogs.es/98a725/poco-x5-pro/1366_2000.jpeg)

## Building

### Prerequisites

This device tree targets **Paranoid Android** (AOSPA) `calcite` branch. Set up the manifest by adding `.repo/local_manifests/redwood.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <!-- AOSPA Lahaina platform -->
  <project path="vendor/qcom/opensource/audio-hal/primary-hal" name="AOSPA/android_hardware_qcom_audio" remote="aospa" revision="calcite-888" />
  <project path="hardware/qcom/display" name="AOSPA/android_hardware_qcom_display" remote="aospa" revision="calcite-888" />
  <project path="hardware/qcom/gps" name="AOSPA/android_hardware_qcom_gps" remote="aospa" revision="calcite-legacy-component" />
  <project path="hardware/qcom/media" name="AOSPA/android_hardware_qcom_media" remote="aospa" revision="calcite-888" />
  <remove-project name="AOSPA/android_hardware_qcom_thermal" />
  <project path="vendor/qcom/opensource/thermal-hal" name="AOSPA/android_hardware_qcom_thermal" remote="aospa" revision="calcite-legacy" />

  <!-- Device -->
  <project path="device/xiaomi/redwood" name="suvojeet-sengupta/device_xiaomi_redwood" remote="github" revision="clo" />
  <project path="device/xiaomi/redwood-kernel" name="suvojeet-sengupta/device_xiaomi_redwood-kernel" remote="github" revision="clo" clone-depth="1" />
  <project path="vendor/xiaomi/redwood" name="suvojeet-sengupta/vendor_xiaomi_redwood" remote="github" revision="clo" clone-depth="1" />
  <project path="vendor/xiaomi/redwood-miuicamera" name="suvojeet-sengupta/android_vendor_xiaomi_redwood-miuicamera" remote="github" revision="miui-seventeen" clone-depth="1" />
  <project path="packages/apps/ParanoidSense" name="AOSPA/android_packages_apps_ParanoidSense" remote="aospa" revision="calcite" />
  <project path="hardware/xiaomi" name="AOSPA/android_hardware_xiaomi" remote="aospa" revision="calcite" />
  <project path="hardware/dolby" name="suvojeet-sengupta/hardware_dolby" remote="github" revision="moto/dolby-dolbyvision" clone-depth="1" />
</manifest>
```

### Build Steps

1. Sync repositories:
```bash
repo sync --current-branch --no-tags -j4
```

2. Build (test signing):
```bash
./rom-build.sh redwood
```

3. Build with release signing:
```bash
./rom-build.sh redwood -t user -s ~/.android-certs
```

**Note:** Switching between release and test keys requires a factory reset. Switching between `userdebug` and `user` with the same keys does not.

### Extracting Vendor Blobs

Update vendor blobs whenever `proprietary-files.txt` changes:

```bash
cd device/xiaomi/redwood
./extract-files.py /path/to/stock/HyperOS/dump
```

## Features

- **Play Integrity:** PropImitationHooks with runtime controls via `persist.sys.pihooks.*` properties
- **Face Unlock:** ParanoidSense integrated
- **Dolby Vision:** Full support with HDR10 fallback
- **Gestures:** Three-finger swipe to screenshot
- **Security Options:** Ignore secure windows flag available
- **Device Info:** Maintainer name displayed

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
  <project path="packages/apps/ParanoidSense" name="AOSPA/android_packages_apps_ParanoidSense" remote="aospa" revision="calcite" />
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

