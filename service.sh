#!/system/bin/sh
# Fuck You DPI!
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0
MODDIR=${0%/*}
source "${MODDIR}/common-func.sh"

# Debugging options
[ -f "${DOTFILEDIR}/TRICK_DEBUG_NOAUTOSTART" ] && [ "$1" != "--manual-start" ] && exit 0

# Remount data to remove nosuid option
# (it potentially can create security issues but nosuid is problematic AF in this purpose)
log_inf "Remounting data without nosuid"
mount -o remount,suid,dev /data
SUID_EXIT=$?
case "${SUID_EXIT}" in
  0) log_wrn "Remounted data without nosuid. This can potentially cause security issues but this is required for FuckYouDPI to run (at least for now).";;
  *) log_err "Cannot remount data without nosuid!!! (mount command exit code: ${SUID_EXIT})";;
esac

# Create fuckyoudpi.d if doesn't exist
if [ ! -d "${DOTFILEDIR}" ]; then
  mkdir "${DOTFILEDIR}"
  for F in "HOSTSPELL" "OOB" "DISORDER" "TARGETS"; do
    touch "${DOTFILEDIR}/TRICK_${F}"
  done
  log_inf "First time starting."
fi

# Reset to default port if the PORT setting is missing
if [ ! -f "${DOTFILEDIR}/PORT" ] || [ -z "$(cat ${DOTFILEDIR}/PORT)" ]; then
  log_wrn "PORT setting is missing, setting to 3128"
  echo "3128" > "${DOTFILEDIR}/PORT"
fi

# Same thing as up, but for nfqws
if [ ! -f "${DOTFILEDIR}/TRICK_NFQWS_PORT" ] || [ -z "$(cat ${DOTFILEDIR}/TRICK_NFQWS_PORT)" ]; then
  log_wrn "PORT setting for NFQWS is missing, setting to 3129"
  echo "3129" > "${DOTFILEDIR}/TRICK_NFQWS_PORT"
fi

# Determine architecture (needed for invoking tpws and nfqws)
case "$(getprop ro.product.cpu.abi)" in
  arm64-v8a) ARCH="aarch64" ;;
  x86_64) log_wrn "x86_64 support is EXPERIMENTAL"; ARCH="x86_64" ;;
  *) log_err "Architecture is NOT supported!" --fatal ;;
esac

# Determine ports
TPWS_PORT="$(cat ${DOTFILEDIR}/PORT 2>/dev/null)"
NFQWS_PORT="$(cat ${DOTFILEDIR}/TRICK_NFQWS_PORT 2>/dev/null)"

# Load in settings
TPWS_ARGS="--uid=0:0 --port ${TPWS_PORT} --hostlist=${DOTFILEDIR}/TRICK_TARGETS"
NFQWS_ARGS="--uid=0:0 --port ${NFQWS_PORT} --hostlist=${DOTFILEDIR}/TRICK_TARGETS"
[ -f "${DOTFILEDIR}/TRICK_SPLIT" ] && TPWS_ARGS="${TPWS_ARGS} --split-any-protocol" && NFQWS_ARGS="${NFQWS_ARGS} --split-any-protocol"
[ -f "${DOTFILEDIR}/TRICK_HOSTSPELL" ] && TPWS_ARGS="${TPWS_ARGS} --hostspell=hoSt" && NFQWS_ARGS="${NFQWS_ARGS} --hostspell=hoSt"
for T in "oob" "disorder" "hostdot" "hosttab" "hostnospace" "domcase" "methodspace" "methodeol" "unixeol"; do
  TX="$(echo ${T} | tr '[:lower:]' '[:upper:]')"
  [ -f "${DOTFILEDIR}/TRICK_${TX}" ] && TPWS_ARGS="${TPWS_ARGS} --${T}" && NFQWS_ARGS="${NFQWS_ARGS} --${T}"
done
log_inf "TPWS arguments are '${TPWS_ARGS}'"
log_inf "NFQWS arguments are '${NFQWS_ARGS}'"

# Check for TPWS binary
TPWS_BINARY="${MODDIR}/static-${ARCH}/tpws"
[ ! -f "${TPWS_BINARY}" ] && log_err "Unable to find TPWS binary for '${ARCH}'!" --fatal

# Check for NFQWS binary
NFQWS_BINARY="${MODDIR}/static-${ARCH}/nfqws"
if [ -f "${DOTFILEDIR}/TRICK_NFQWS" ] && [ -f "${NFQWS_BINARY}" ]; then
  log_inf "NFQWS will start"
  log_wrn "NFQWS support is HIGHLY EXPERIMENTAL!!!"
  NFQWS_USABLE_AND_ENABLED=1
elif [ -f "${DOTFILEDIR}/TRICK_NFQWS" ] && [ ! -f "${NFQWS_BINARY}" ]; then
  log_err "Unable to find NFQWS binary for '${ARCH}'!"
  log_wrn "NFQWS won't start despite it being enabled"
  NFQWS_USABLE_AND_ENABLED=0
else
  log_inf "NFQWS won't start because it isn't enabled"
  NFQWS_USABLE_AND_ENABLED=0
fi

# Wait rest of the 15 seconds for userland to finish getting ready.
log_inf "Waiting userland to get ready"
sleep 15

# Create kernel rules
log_inf "Adding kernel rules"
ip rule add fwmark 1 lookup 100 2>/dev/null
ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null

# Grant network capabilities
log_inf "Granting network capabilites to TPWS"
setcap 'cap_net_admin,cap_net_raw,cap_net_bind_service=eip' ${TPWS_BINARY}

# Invoke daemon and wait a fucking sec
log_inf "Invoking fydpid"
${MODDIR}/fydpid.sh &
sleep 1

# Start TPWS
log_inf "Starting static-${ARCH}/tpws"
${TPWS_BINARY} ${TPWS_ARGS} &

# Start NFQWS, if it's enabled and usable
if [ ${NFQWS_USABLE_AND_ENABLED} -eq 1 ]; then
  log_inf "Granting network capabilites to NFQWS"
  setcap 'cap_net_admin,cap_net_raw,cap_net_bind_service=eip' ${NFQWS_BINARY}
  log_inf "Starting static-${ARCH}/nfqws"
  ${NFQWS_BINARY} ${NFQWS_ARGS} &
fi

# Run workers
for PKG in $(ls "${DOTFILEDIR}" | grep -vE '^TRICK_|^PORT$'); do
  for TARGET_UID in $(dumpsys package ${PKG} | grep uid | cut -d= -f2 | cut -d" " -f1 | uniq); do      
    # Report start
    log_inf "Enabling for ${PKG} (UID ${TARGET_UID})"
    # Route app to this entire fuckery
    iptables -t mangle -A OUTPUT -p tcp -m owner --uid-owner "${TARGET_UID}" -j MARK --set-mark 1
    iptables -t mangle -A PREROUTING -p tcp -m mark --mark 1 -j TPROXY --on-port "${TPWS_PORT}" --tproxy-mark 1
    # Report finish
    log_inf "Done enabling for ${PKG} (UID ${TARGET_UID})"
  done
done
