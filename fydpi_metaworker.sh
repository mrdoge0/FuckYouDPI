#!/system/bin/sh
# Fuck You DPI!
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0
MODDIR="/data/adb/modules/fuckyoudpi"
DOTFILEDIR="/data/adb/fuckyoudpi.d"

# Run workers.
for pkg in $(ls "${DOTFILEDIR}" | grep -vE '^TRICK_|^PORT$'); do
  "${MODDIR}/fydpi_worker.sh" "$pkg" &
done
