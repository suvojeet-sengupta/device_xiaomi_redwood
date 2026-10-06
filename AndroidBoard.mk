#
# Copyright (C) 2026 Paranoid Android
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

# The kernel is built from TARGET_KERNEL_SOURCE by QTI's kernel_definitions.mk,
# which the ROM links into vendor/qcom/build/tasks. Don't include it here: it
# has to come after generate_extra_images.mk, which only defines the DTBO
# image rule while TARGET_PREBUILT_KERNEL is still unset, and after the core
# Makefile, so its dtb.img rule wins over the one for prebuilt DTBs.
