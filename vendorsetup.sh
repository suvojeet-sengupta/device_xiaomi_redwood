#
# Copyright (C) 2026 Paranoid Android
#
# SPDX-License-Identifier: Apache-2.0
#

# Apply the source patches redwood needs on top of PenguinOS, see
# patches/. Patches that are already applied are skipped, so this is
# safe to run on every envsetup.

redwood_apply_patches() {
    local top="${T:-$(gettop)}"
    local patches="$top/device/xiaomi/redwood/patches"
    local patch dir

    [ -d "$patches" ] || return 0

    for patch in $(cd "$patches" && find . -name '*.patch' | sort); do
        patch="${patch#./}"
        dir="$top/$(dirname "$patch")"
        [ -d "$dir" ] || continue

        # Already applied
        if git -C "$dir" apply --check --reverse "$patches/$patch" &>/dev/null; then
            continue
        fi

        if git -C "$dir" -c user.name=redwood -c user.email=redwood@localhost \
                am -q --3way "$patches/$patch" &>/dev/null; then
            echo "redwood: applied $patch" >&2
        else
            git -C "$dir" am --abort &>/dev/null
            echo "redwood: failed to apply $patch" >&2
        fi
    done
}

redwood_apply_patches
unset -f redwood_apply_patches
