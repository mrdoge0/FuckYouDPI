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
  touch "${DOTFILEDIR}/TRICK_TARGETS"
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
TPWS_ARGS="--port $(cat "${DOTFILEDIR}/PORT" 2>/dev/null) --hostlist=${DOTFILEDIR}/TRICK_TARGETS"
[ -f "${DOTFILEDIR}/TRICK_HOSTSPELL" ] && TPWS_ARGS="${TPWS_ARGS} --hostspell=hoSt"
[ -f "${DOTFILEDIR}/TRICK_OOB" ] && TPWS_ARGS="${TPWS_ARGS} --oob"
[ -f "${DOTFILEDIR}/TRICK_DISORDER" ] && TPWS_ARGS="${TPWS_ARGS} --disorder"
[ -f "${DOTFILEDIR}/TRICK_HOSTDOT" ] && TPWS_ARGS="${TPWS_ARGS} --hostdot"
[ -f "${DOTFILEDIR}/TRICK_HOSTTAB" ] && TPWS_ARGS="${TPWS_ARGS} --hosttab"
[ -f "${DOTFILEDIR}/TRICK_HOSTNOSPACE" ] && TPWS_ARGS="${TPWS_ARGS} --hostnospace"
[ -f "${DOTFILEDIR}/TRICK_DOMCASE" ] && TPWS_ARGS="${TPWS_ARGS} --domcase"
[ -f "${DOTFILEDIR}/TRICK_METHODSPACE" ] && TPWS_ARGS="${TPWS_ARGS} --methodspace"
[ -f "${DOTFILEDIR}/TRICK_METHODEOL" ] && TPWS_ARGS="${TPWS_ARGS} --methodeol"
[ -f "${DOTFILEDIR}/TRICK_UNIXEOL" ] && TPWS_ARGS="${TPWS_ARGS} --unixeol"
[ -f "${DOTFILEDIR}/TRICK_SPLIT" ] && TPWS_ARGS="${TPWS_ARGS} --split-any-protocol"

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
