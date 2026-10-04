#!/system/bin/sh
#
# Copyright (C) 2026 Paranoid Android
#
# SPDX-License-Identifier: Apache-2.0
#

# Boot debugging for a boot that hangs.
#
# Every few seconds, dump the stacks of blocked tasks and the process list
# to the kernel log, which ends up in ramoops and survives a warm reboot
# even if storage is stuck. Logs are also snapshotted to /metadata in the
# background, so a blocked write doesn't stop the kernel log dumps.

DIR=/metadata/redwood-debug

echo 1 > /proc/sys/kernel/sysrq

snapshot() {
    mkdir -p $DIR/$1
    dmesg > $DIR/$1/dmesg.txt 2>&1
    logcat -d -b all -v threadtime -t 30000 > $DIR/$1/logcat.txt 2>&1
    getprop > $DIR/$1/props.txt 2>&1
    ps -A -o PID,PPID,STAT,WCHAN,NAME > $DIR/$1/ps.txt 2>&1
}

i=0
while [ $i -lt 60 ]; do
    echo "redwood-debug: tick $i" > /dev/kmsg
    ps -A -o PID,STAT,WCHAN,NAME | grep -E " D | R " | while read l; do
        echo "redwood-debug: $l" > /dev/kmsg
    done
    echo w > /proc/sysrq-trigger
    snapshot $i &
    sleep 10
    i=$((i + 1))
done
