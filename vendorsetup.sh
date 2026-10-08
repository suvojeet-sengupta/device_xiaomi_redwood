#
# Copyright (C) 2026 Paranoid Android
#
# SPDX-License-Identifier: Apache-2.0
#

# Apply the source patches redwood needs. Patches in patches/common/ apply
# to both ROMs, the ones in patches/aospa/ and patches/penguinos/ only to
# that ROM. Patches that are already applied are skipped, so this is safe
# to run on every envsetup.

redwood_apply_patches() {
    local top="${T:-$(gettop)}"
    local device="$top/device/xiaomi/redwood"
    local rom patches patch dir

    # PenguinOS keeps its own framework config in custom_config.xml
    if [ -f "$top/frameworks/base/core/res/res/values/custom_config.xml" ]; then
        rom=penguinos
    else
        rom=aospa
    fi

    for patches in "$device/patches/common" "$device/patches/$rom"; do
        [ -d "$patches" ] || continue

        for patch in $(cd "$patches" && find . -name '*.patch' | sort); do
            patch="${patch#./}"
            dir="$top/$(dirname "$patch")"
            [ -d "$dir" ] || continue

            # Already applied
            if git -C "$dir" apply --check --reverse "$patches/$patch" &>/dev/null; then
                continue
            fi

            if git -C "$dir" -c user.name=suvojeet-sengupta -c user.email=suvojitsengupta21@gmail.com \
                    am -q --3way "$patches/$patch" &>/dev/null; then
                echo "redwood: applied $patch" >&2
            else
                git -C "$dir" am --abort &>/dev/null
                echo "redwood: failed to apply $patch" >&2
            fi
        done
    done
}

redwood_apply_patches
unset -f redwood_apply_patches
