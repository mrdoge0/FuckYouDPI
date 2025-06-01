#!/system/bin/sh
# Fuck You DPI!
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0
MODDIR=${0%/*}
DOTFILEDIR="/data/adb/fuckyoudpi.d"

# Create fuckyoudpi.d if doesn't exist.
if [ ! -d "${DOTFILEDIR}" ]; then
  mkdir "${DOTFILEDIR}"
  # do default settings
  touch "${DOTFILEDIR}/TRICK_HOSTSPELL"
  touch "${DOTFILEDIR}/TRICK_OOB"
  touch "${DOTFILEDIR}/TRICK_DISORDER"
  echo "1080" > "${DOTFILEDIR}/PORT"
  echo "[FuckYouDPI] First time starting."
fi

# Determine architecture (needed for invoking tpws)
case "$(getprop ro.product.cpu.abi)" in
  arm64-v8a) ARCH="aarch64" ;;
  armeabi-v7a) ARCH="armv7eabi" ;;
  x86_64) ARCH="x86_64" ;;
  x86) ARCH="i686" ;;
  *) echo "[FuckYouDPI] Architecture is NOT supported!"; exit 1 ;;
esac

# Load in settings.
TPWS_TARGET_PORT=$(cat "${DOTFILEDIR}/PORT")
TPWS_ARGS=""
[ -f "${DOTFILEDIR}/TRICK_HOSTSPELL" ] && TPWS_ARGS="${TPWS_ARGS} --hostspell=hoSt"
[ -f "${DOTFILEDIR}/TRICK_OOB" ] && TPWS_ARGS="${TPWS_ARGS} --oob"
[ -f "${DOTFILEDIR}/TRICK_DISORDER" ] && TPWS_ARGS="${TPWS_ARGS} --disorder"

# Check for binary and start TPWS.
TPWS_BINARY="${MODDIR}/static-${ARCH}/tpws"
[ ! -f "${TPWS_BINARY}" ] && echo "[FuckYouDPI] Unable to find TPWS binary for '${ARCH}'!"; exit 1
${TPWS_BINARY} --port ${TPWS_TARGET_PORT} ${TPWS_ARGS} &

# Run workers.
for pkg in $(ls "${DOTFILEDIR}" | grep -vE '^TRICK_|^PORT$'); do
  ./fydpi_worker.sh "$pkg" &
done
