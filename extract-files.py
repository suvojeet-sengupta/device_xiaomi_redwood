#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2025 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'hardware/qcom/display',
    'hardware/qcom/display/gralloc',
    'hardware/qcom/display/libdebug',
    'hardware/qcom/wlan/qcwcn',
    'hardware/xiaomi',
    'vendor/qcom/common/vendor/adreno/r',
    'vendor/qcom/common/vendor/display/5.4',
    'vendor/qcom/common/vendor/gps-legacy',
    'vendor/qcom/common/vendor/media/5.4',
]


def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'com.qualcomm.qti.dpm.api@1.0',
        'com.qualcomm.qti.imscmservice@2.0',
        'com.qualcomm.qti.imscmservice@2.1',
        'com.qualcomm.qti.imscmservice@2.2',
        'com.qualcomm.qti.uceservice@2.0',
        'com.qualcomm.qti.uceservice@2.1',
        'com.qualcomm.qti.uceservice@2.2',
        'com.qualcomm.qti.uceservice@2.3',
        'libmmosal',
        'vendor.qti.data.factory@2.0',
        'vendor.qti.data.factory@2.1',
        'vendor.qti.data.factory@2.2',
        'vendor.qti.data.factory@2.3',
        'vendor.qti.data.mwqem@1.0',
        'vendor.qti.data.slm@1.0',
        'vendor.qti.diaghal@1.0',
        'vendor.qti.hardware.data.cne.internal.api@1.0',
        'vendor.qti.hardware.data.cne.internal.constants@1.0',
        'vendor.qti.hardware.data.cne.internal.server@1.0',
        'vendor.qti.hardware.data.connection@1.0',
        'vendor.qti.hardware.data.connection@1.1',
        'vendor.qti.hardware.data.dynamicdds@1.0',
        'vendor.qti.hardware.data.iwlan@1.0',
        'vendor.qti.hardware.data.latency@1.0',
        'vendor.qti.hardware.data.lce@1.0',
        'vendor.qti.hardware.data.qmi@1.0',
        'vendor.qti.hardware.mwqemadapter@1.0',
        'vendor.qti.hardware.radio.am@1.0',
        'vendor.qti.hardware.radio.ims@1.0',
        'vendor.qti.hardware.radio.ims@1.1',
        'vendor.qti.hardware.radio.ims@1.2',
        'vendor.qti.hardware.radio.ims@1.3',
        'vendor.qti.hardware.radio.ims@1.4',
        'vendor.qti.hardware.radio.ims@1.5',
        'vendor.qti.hardware.radio.ims@1.6',
        'vendor.qti.hardware.radio.ims@1.7',
        'vendor.qti.hardware.radio.internal.deviceinfo@1.0',
        'vendor.qti.hardware.radio.lpa@1.0',
        'vendor.qti.hardware.radio.lpa@1.1',
        'vendor.qti.hardware.radio.qcrilhook@1.0',
        'vendor.qti.hardware.radio.qtiradio@1.0',
        'vendor.qti.hardware.radio.qtiradio@2.0',
        'vendor.qti.hardware.radio.qtiradio@2.1',
        'vendor.qti.hardware.radio.qtiradio@2.2',
        'vendor.qti.hardware.radio.qtiradio@2.3',
        'vendor.qti.hardware.radio.qtiradio@2.4',
        'vendor.qti.hardware.radio.qtiradio@2.5',
        'vendor.qti.hardware.radio.qtiradio@2.6',
        'vendor.qti.hardware.radio.uim@1.0',
        'vendor.qti.hardware.radio.uim@1.1',
        'vendor.qti.hardware.radio.uim@1.2',
        'vendor.qti.hardware.radio.uim_remote_client@1.0',
        'vendor.qti.hardware.radio.uim_remote_client@1.1',
        'vendor.qti.hardware.radio.uim_remote_client@1.2',
        'vendor.qti.hardware.radio.uim_remote_server@1.0',
        'vendor.qti.hardware.slmadapter@1.0',
        'vendor.qti.hardware.wifidisplaysession@1.0',
        'vendor.qti.ims.callcapability@1.0',
        'vendor.qti.ims.callinfo@1.0',
        'vendor.qti.ims.factory@1.0',
        'vendor.qti.ims.factory@1.1',
        'vendor.qti.ims.rcsconfig@1.0',
        'vendor.qti.ims.rcsconfig@1.1',
        'vendor.qti.ims.rcsconfig@2.0',
        'vendor.qti.ims.rcsconfig@2.1',
        'vendor.qti.imsrtpservice@3.0',
        'vendor.qti.latency@2.0',
        'vendor.qti.latency@2.1',
    ): lib_fixup_vendor_suffix,
}

blob_fixups: blob_fixups_user_type = {
    ('vendor/etc/camera/pureShot_parameter.xml', 'vendor/etc/camera/pureView_parameter.xml'): blob_fixup()
        .regex_replace(r'=(\d+)>', r'="\1">'),
    'vendor/lib64/hw/camera.qcom.so': blob_fixup()
        .binary_regex_replace(b'\x73\x74\x5F\x6C\x69\x63\x65\x6E\x73\x65\x2E\x6C\x69\x63', b'\x63\x61\x6D\x65\x72\x61\x5F\x63\x6E\x66\x2E\x74\x78\x74')
        .add_needed('libprocessgroup_shim.so')
        .replace_needed('libtinyxml2.so', 'libtinyxml2-v34.so'),
    'vendor/lib64/hw/camera.xiaomi.so': blob_fixup()
        .sig_replace('29 07 00 94', '1F 20 03 D5'),
    'vendor/lib64/hw/com.qti.chi.override.so': blob_fixup()
        .add_needed('libprocessgroup_shim.so'),
    ('vendor/etc/media_lahaina/video_system_specs.json', 'vendor/etc/media_yupik_v1/video_system_specs.json'): blob_fixup()
        .regex_replace('"max_retry_alloc_output_timeout": 10000,', '"max_retry_alloc_output_timeout": 0,'),
    'vendor/etc/msm_irqbalance.conf': blob_fixup()
        .regex_replace('IGNORED_IRQ=27,23,38$', 'IGNORED_IRQ=27,23,38,115,332'),
    ('vendor/lib64/mediadrm/libwvdrmengine.so', 'vendor/lib64/libwvhidl.so'): blob_fixup()
        .add_needed('libcrypto_shim.so'),
    'vendor/lib64/android.hardware.secure_element@1.0-impl.so': blob_fixup()
        .remove_needed('android.hidl.base@1.0.so'),
    'vendor/lib64/libmialgoengine.so' : blob_fixup()
        .remove_needed('android.hardware.graphics.allocator@3.0.so')
        .remove_needed('vendor.qti.hardware.display.allocator@3.0.so'),
    'vendor/lib64/libmialgo_rfs.so': blob_fixup()
        .clear_symbol_version('remote_handle64_close')
        .clear_symbol_version('remote_handle64_invoke')
        .clear_symbol_version('remote_handle64_open')
        .clear_symbol_version('remote_register_buf_attr')
        .clear_symbol_version('remote_session_control'),
    'vendor/lib64/libmisight.so' : blob_fixup()
        .add_needed('libjsoncpp_shim.so')
        .add_needed('libmisightjson_shim.so'),
    ('vendor/lib64/libalAILDC.so', 'vendor/lib64/libalLDC.so', 'vendor/lib64/libalhLDC.so'): blob_fixup()
        .clear_symbol_version('AHardwareBuffer_allocate')
        .clear_symbol_version('AHardwareBuffer_describe')
        .clear_symbol_version('AHardwareBuffer_lock')
        .clear_symbol_version('AHardwareBuffer_release')
        .clear_symbol_version('AHardwareBuffer_unlock'),
    'vendor/lib64/libarcsoft_hdrplus_hvx_stub.so': blob_fixup()
        .clear_symbol_version('remote_handle_close')
        .clear_symbol_version('remote_handle_invoke')
        .clear_symbol_version('remote_handle_open'),
    'vendor/lib64/libsensor_cal_v2.so': blob_fixup()
        .add_needed('libjsoncpp_shim.so'),
    ('vendor/lib/hw/audio.primary.lahaina.so', 'vendor/lib/hw/sound_trigger.primary.lahaina.so', 'vendor/lib/libaudioroute_ext.so'): blob_fixup()
        .replace_needed('libaudioroute.so', 'libaudioroute-v34.so'),
    'vendor/lib64/libaudiocloudctrl.so': blob_fixup()
        .replace_needed('libtinyxml2.so', 'libtinyxml2-v34.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'redwood',
    'xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
