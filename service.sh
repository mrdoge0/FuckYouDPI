#!/system/bin/sh
# Fuck You DPI!
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0
MODDIR=${0%/*}
DOTFILEDIR="/data/adb/fuckyoudpi.d"

# Debugging options
[ -f "${DOTFILEDIR}/TRICK_DEBUG" ] && set -x
[ -f "${DOTFILEDIR}/TRICK_DEBUG_NOAUTOSTART" ] && [ "$1" != "--manual-start" ] && exit 0

# Enable or disable logging by looking to TRICK_NO_LOG
# (maybe some carriers would detect the module via logs, so I wanna make it togglable)
if [ -f "${DOTFILEDIR}/TRICK_NO_LOG" ]; then
  LOGGING_ENABLED=0
else
  LOGGING_ENABLED=1
fi

# Info logging function
log_inf() {
  [ "${LOGGING_ENABLED}" -eq 1 ] && log -p i -t "FuckYouDPI" "$1"
}

# Warning logging function
log_wrn() {
  [ "${LOGGING_ENABLED}" -eq 1 ] && log -p w -t "FuckYouDPI" "$1"
}

# Error logging function
log_err() {
  [ "${LOGGING_ENABLED}" -eq 1 ] && log -p e -t "FuckYouDPI" "$1"
  [ "$2" == "--fatal" ] && exit 1
}

# Create fuckyoudpi.d if doesn't exist.
if [ ! -d "${DOTFILEDIR}" ]; then
  mkdir "${DOTFILEDIR}"
  # do default settings
  touch "${DOTFILEDIR}/TRICK_HOSTSPELL"
  touch "${DOTFILEDIR}/TRICK_OOB"
  touch "${DOTFILEDIR}/TRICK_DISORDER"
  touch "${DOTFILEDIR}/TRICK_TARGETS"
  log_inf "First time starting."
fi

# Reset to default port if the PORT setting is missing
if [ ! -f "${DOTFILEDIR}/PORT" ] || [ -z "${DOTFILEDIR}/PORT" ]; then
  log_wrn "PORT setting is missing, setting to 3128"
  echo "3128" > "${DOTFILEDIR}/PORT"
fi

# Determine architecture (needed for invoking tpws)
case "$(getprop ro.product.cpu.abi)" in
  arm64-v8a) ARCH="aarch64" ;;
  x86_64) log_wrn "x86_64 support is EXPERIMENTAL"; ARCH="x86_64" ;;
  *) log_err "Architecture is NOT supported!" --fatal ;;
esac

# Determine port
TPWS_PORT="$(cat ${DOTFILEDIR}/PORT 2>/dev/null)"

# Load in settings
TPWS_ARGS="--uid=0:0 --port ${TPWS_PORT} --hostlist=${DOTFILEDIR}/TRICK_TARGETS"
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
log_inf "TPWS arguments are '${TPWS_ARGS}'"

# Check for binary and start TPWS
TPWS_BINARY="${MODDIR}/static-${ARCH}/tpws"
[ ! -f "${TPWS_BINARY}" ] && log_err "[FuckYouDPI] Unable to find TPWS binary for '${ARCH}'!" --fatal
log_inf "Starting static-${ARCH}/tpws"
${TPWS_BINARY} ${TPWS_ARGS} &

# Create kernel rules
log_inf "Adding kernel rules"
ip rule add fwmark 1 lookup 100 2>/dev/null
ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null

# Wait 15 seconds for userland to finish getting ready.
log_inf "Waiting userland to get ready"
sleep 15

# Run workers
for PKG in $(ls "${DOTFILEDIR}" | grep -vE '^TRICK_|^PORT$'); do
  for TARGET_UID in $(dumpsys package ${PKG} | grep uid | cut -d= -f2 | cut -d" " -f1 | uniq); do
      
    # Report start.
    log_inf "Enabling for ${PKG} (UID ${TARGET_UID})"
    
    # Route app to this entire fuckery.
    iptables -t mangle -A OUTPUT -p tcp -m owner --uid-owner "${TARGET_UID}" -j MARK --set-mark 1
    iptables -t mangle -A PREROUTING -p tcp -m mark --mark 1 -j TPROXY --on-port "${TPWS_PORT}" --tproxy-mark 1
    
    # Report finish.
    log_inf "Done enabling for ${PKG} (UID ${TARGET_UID})"
  done
done
