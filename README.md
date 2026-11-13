Copyright (C) 2025 - The LineageOS Project

Device configuration for Xiaomi Poco X5 Pro 5G/Redmi Note 12 Pro Speed
==============

The Xiaomi Poco X5 Pro 5G/Redmi Note 12 Pro Speed (codenamed _"redwood"_) is a mid-range smartphone from Xiaomi.

It was released in February 2023.

## PixelOS (seventeen) with the 6.18 kernel

This branch builds PixelOS 17 (`custom_redwood`) and LineageOS
(`lineage_redwood`) on the 6.18 kernel prebuilt
([device_xiaomi_redwood-kernel-6.18](https://github.com/suvojeet-sengupta/device_xiaomi_redwood-kernel-6.18)).

`.repo/local_manifests/redwood.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="redwood" fetch="https://github.com" />
  <project name="suvojeet-sengupta/android_device_xiaomi_redwood_pixelos" path="device/xiaomi/redwood" remote="redwood" revision="seventeen" />
  <project name="suvojeet-sengupta/device_xiaomi_redwood-kernel-6.18" path="device/xiaomi/redwood-kernel-6.18" remote="redwood" revision="main" />
  <project name="BlueHeart01/android_vendor_xiaomi_redwood" path="vendor/xiaomi/redwood" remote="redwood" revision="17" clone-depth="1" />
  <project name="BlueHeart01/redwood_hardware_dolby" path="hardware/dolby" remote="redwood" revision="moto-1.0" />
  <project name="LineageOS/android_hardware_xiaomi" path="hardware/xiaomi" remote="redwood" revision="lineage-24.0" />
</manifest>
```

```bash
repo init -u https://github.com/PixelOS-AOSP/android_manifest.git -b seventeen --git-lfs
repo sync -c -j8 --force-sync --no-tags
source build/envsetup.sh
lunch custom_redwood-cp2a-userdebug
m pixelos
```

KernelSU, KernelSU Next and KowSU patch the boot image with their
android17-6.18 module (KMI android17-6.18, chosen by hand).

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