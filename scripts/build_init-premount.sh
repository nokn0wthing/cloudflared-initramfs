#!/usr/bin/env bash
TEMPLATE_FILE="$PWD"/initramfs/init-premount

sed "s/PLACEHOLDER/$TOKEN/" "$TEMPLATE_FILE" > "$INITRAMFS"/scripts/init-premount/cloudflared
chmod 755 "$INITRAMFS"/scripts/init-premount/cloudflared

exit 0