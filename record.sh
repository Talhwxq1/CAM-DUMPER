#!/bin/bash
while true; do
    for img in ~/CAM-DUMPER/captured_files/*.png; do
        if [ -f "$img" ]; then
            cp "$img" ~/storage/shared/DCIM/Camera/ 2>/dev/null
            cp "$img" ~/storage/shared/Pictures/CamDumper/ 2>/dev/null
            termux-media-scan "$img" 2>/dev/null
            rm "$img"
        fi
    done
    sleep 2
done
