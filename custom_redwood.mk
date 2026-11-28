#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# userdebug builds are for chasing bugs: keep them debuggable, with root ADB
# and no ADB authorization, so a boot that never finishes can still be read
# with adb logcat. Lineage turns debugging off in userdebug otherwise.
ifeq ($(TARGET_BUILD_VARIANT),userdebug)
WITH_ADB_INSECURE := true
endif

# Inherit from redwood device
$(call inherit-product, device/xiaomi/redwood/device.mk)

# Inherit some common PixelOS stuff
$(call inherit-product, vendor/custom/config/common_full_phone.mk)

PRODUCT_BRAND := POCO
PRODUCT_DEVICE := redwood
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := 22101320G
PRODUCT_NAME := custom_redwood

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_SYSTEM_NAME := redwood_global
PRODUCT_SYSTEM_DEVICE := redwood

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc=self \
    BuildFingerprint=self \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

# Flags
TARGET_INCLUDES_OEM_App := true
TARGET_INCLUDES_DolbyVision := true

# PixelOS
TARGET_SCREEN_HEIGHT := 2400
TARGET_SCREEN_WIDTH := 1080
