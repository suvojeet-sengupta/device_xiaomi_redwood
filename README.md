Copyright (C) 2025 - The LineageOS Project
Copyright (C) 2026 - Paranoid Android

Device configuration for Xiaomi Poco X5 Pro 5G/Redmi Note 12 Pro Speed
==============

The Xiaomi Poco X5 Pro 5G/Redmi Note 12 Pro Speed (codenamed _"redwood"_) is a mid-range smartphone from Xiaomi.

It was released in February 2023.

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
is AOSPA's lahaina platform manifest
(`vendor/aospa/products/platforms/lahaina.xml`).

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <!-- lahaina platform -->
  <project path="vendor/qcom/opensource/audio-hal/primary-hal" name="AOSPA/android_hardware_qcom_audio" remote="aospa" revision="vauxite-888" />
  <project path="hardware/qcom/display" name="AOSPA/android_hardware_qcom_display" remote="aospa" revision="vauxite-888" />
  <project path="hardware/qcom/gps" name="AOSPA/android_hardware_qcom_gps" remote="aospa" revision="vauxite-legacy-component" />
  <project path="hardware/qcom/media" name="AOSPA/android_hardware_qcom_media" remote="aospa" revision="vauxite-888" />
  <remove-project name="AOSPA/android_hardware_qcom_thermal" />
  <project path="vendor/qcom/opensource/thermal-hal" name="AOSPA/android_hardware_qcom_thermal" remote="aospa" revision="vauxite-legacy" />

  <!-- redwood -->
  <project path="device/xiaomi/redwood" name="suvojeet-sengupta/device_xiaomi_redwood" remote="github" revision="clo" />
  <project path="device/xiaomi/redwood-kernel" name="suvojeet-sengupta/device_xiaomi_redwood-kernel" remote="github" revision="clo" clone-depth="1" />
  <project path="vendor/xiaomi/redwood" name="suvojeet-sengupta/vendor_xiaomi_redwood" remote="github" revision="clo" clone-depth="1" />
  <project path="hardware/xiaomi" name="AOSPA/android_hardware_xiaomi" remote="aospa" revision="calcite" />
</manifest>
```

Then sync and build:

```bash
repo sync --current-branch --no-tags -j4
./rom-build.sh redwood
```

`vendor/xiaomi/redwood` must be re-extracted whenever `proprietary-files.txt`
changes, from a dump of the stock HyperOS firmware:

```bash
cd device/xiaomi/redwood && ./extract-files.py /path/to/stock/dump
```

