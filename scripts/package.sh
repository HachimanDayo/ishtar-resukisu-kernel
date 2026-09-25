#!/usr/bin/env bash
# Usage: scripts/package.sh <path/to/Image> <package-name>
# Produces out/AnyKernel3-<name>.zip, out/boot-<name>.img (stock AviumUI boot.img
# with the kernel replaced) and out/SHA256SUMS. Needs GH_TOKEN for gh.
set -euo pipefail

IMAGE=$(realpath "$1")
NAME=$2
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=$ROOT/out
WORK=$(mktemp -d)
mkdir -p "$OUT"

# AnyKernel3
git clone -q --depth=1 https://github.com/osm0sis/AnyKernel3.git "$WORK/ak3"
rm -rf "$WORK"/ak3/{.git,.github,modules,patch,ramdisk,README.md}
cp "$ROOT/anykernel/anykernel.sh" "$WORK/ak3/anykernel.sh"
cp "$IMAGE" "$WORK/ak3/Image"
(cd "$WORK/ak3" && zip -qr9 "$OUT/AnyKernel3-$NAME.zip" . -x '.*')

# Stock boot.img with the new kernel
cd "$WORK"
gh release download -R topjohnwu/Magisk -p 'Magisk-v*.apk' -O magisk.apk
unzip -p magisk.apk lib/x86_64/libmagiskboot.so > magiskboot
chmod +x magiskboot
xz -dc "$ROOT/stock/boot.img.xz" > boot.img
sha256sum boot.img | cut -d' ' -f1 | grep -qx "$(cut -d' ' -f1 "$ROOT/stock/boot.img.sha256")"
./magiskboot unpack boot.img
cp "$IMAGE" kernel
./magiskboot repack boot.img "$OUT/boot-$NAME.img"

cd "$OUT"
sha256sum -- * > SHA256SUMS
cat SHA256SUMS
