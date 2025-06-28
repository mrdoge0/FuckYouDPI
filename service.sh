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
  x86_64) ARCH="x86_64" ;;
  *) echo "[FuckYouDPI] Architecture is NOT supported!"; exit 1 ;;
esac

# Load in settings.
TPWS_TARGET_PORT=$(cat "${DOTFILEDIR}/PORT" 2>/dev/null)
TPWS_ARGS="--port ${TPWS_TARGET_PORT}"
[ -f "${DOTFILEDIR}/TRICK_HOSTSPELL" ] && TPWS_ARGS="${TPWS_ARGS} --hostspell=hoSt"
[ -f "${DOTFILEDIR}/TRICK_OOB" ] && TPWS_ARGS="${TPWS_ARGS} --oob"
[ -f "${DOTFILEDIR}/TRICK_DISORDER" ] && TPWS_ARGS="${TPWS_ARGS} --disorder"

# Check for binary and start TPWS.
TPWS_BINARY="${MODDIR}/static-${ARCH}/tpws"
[ ! -f "${TPWS_BINARY}" ] && echo "[FuckYouDPI] Unable to find TPWS binary for '${ARCH}'!"
echo "[FuckYouDPI] starting static-${ARCH}/tpws"
${TPWS_BINARY} ${TPWS_ARGS} &

# Create kernel rules.
ip rule add fwmark 1 lookup 100 2>/dev/null
ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null

# Done.
exit 0
