#!/system/bin/sh
#
# Copyright (C) 2026 Paranoid Android
#
# SPDX-License-Identifier: Apache-2.0
#

# Boot debugging for a boot that hangs or resets.
#
# ramoops doesn't survive the reset on this device, so the kernel log and
# logcat are streamed to /metadata (ext4, data=journal, commit=1) as they
# are produced. Whatever was logged up to a second before the device froze
# or reset is kept. The last 2 boots are kept, boot0 is the newest.
#
# /metadata is small and also holds vold's keys and the OTA snapshot state,
# so every log is capped: about 6 MB per boot, crash buffer included.
#
# Every few seconds the stacks of blocked tasks (sysrq-w) and of the
# running CPUs (sysrq-l) are dumped to the kernel log. Anything that can
# block (ps, getprop) runs in the background so the loop keeps going.

BASE=/metadata/redwood-debug

mkdir -p $BASE
rm -rf $BASE/boot1 $BASE/boot2 $BASE/boot3 $BASE/boot4
[ -d $BASE/boot0 ] && mv $BASE/boot0 $BASE/boot1
DIR=$BASE/boot0
mkdir -p $DIR

echo 1 > /proc/sys/kernel/sysrq
echo on > /proc/sys/kernel/printk_devkmsg

# Kernel log, the whole ring buffer and then everything new, up to 2 MB
(cat /dev/kmsg | head -c 2097152 > $DIR/kmsg.txt) &

# logcat, retried until logd is up. Rotated at 1 MB, 3 files at most.
# The obscura lookups before systemReady and the boot animation flood the
# log, so leave those out.
(
    while true; do
        logcat -b main,system,events -v threadtime -f $DIR/logcat.txt -r 1024 -n 2 \
            SystemServiceRegistry:S am_wtf:S BootAnimation:S
        sleep 1
    done
) &

# Crashes only, small but the most useful
(
    while true; do
        logcat -b crash -v threadtime -f $DIR/crash.txt -r 512 -n 1
        sleep 1
    done
) &

i=0
while [ $i -lt 120 ]; do
    echo "redwood-debug: tick $i" > /dev/kmsg
    echo w > /proc/sysrq-trigger
    echo l > /proc/sysrq-trigger
    (
        timeout 4 ps -A -o PID,PPID,STAT,WCHAN,NAME > $DIR/ps.txt.new 2>&1
        mv $DIR/ps.txt.new $DIR/ps.txt
        grep -E " D | R " $DIR/ps.txt | while read l; do
            echo "redwood-debug: $i $l" > /dev/kmsg
        done
        timeout 4 getprop > $DIR/props.txt.new 2>&1
        mv $DIR/props.txt.new $DIR/props.txt
    ) &
    sleep 5
    i=$((i + 1))
done
