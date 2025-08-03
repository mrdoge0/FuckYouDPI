#!/system/bin/sh
# Fuck You DPI! - Daemon
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0
source "${0%/*}/common-func.sh"

# This is the exact place when this code turns into mental illness

# Internal variable to keep last IP routes result
LAST_ROUTES=""

# Function to apply exit ports
apply_exit_ports() {
  # Reload table 100
  ip route flush table 100
  ip rule add fwmark 1 lookup 100 2>/dev/null
  ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null
  # Get current routes
  CURRENT_ROUTES=$(ip route show default)
  # Apply this entire fuckery for each interface
  echo "${CURRENT_ROUTES}" | while read -r LINE; do
    GW=$(echo "${LINE}" | awk '{for(i=1;i<=NF;i++){if($i=="via"){print $(i+1); break}}}')
    DEV=$(echo "${LINE}" | awk '{for(i=1;i<=NF;i++){if($i=="dev"){print $(i+1); break}}}')
    if [ -n "${GW}" ] && [ -n "${DEV}" ]; then
      log_inf "Adding default route via ${GW} dev ${DEV} to table 100"
      ip route add default via "${GW}" dev "${DEV}" table 100 2>/dev/null
    elif [ -n "${DEV}" ]; then
      log_inf "Adding default route dev ${DEV} to table 100 (no gateway)"
      ip route add default dev "${DEV}" table 100 2>/dev/null
    fi
  done
  # Save last routes
  LAST_ROUTES="${CURRENT_ROUTES}"
}

# Run this the first time
apply_exit_ports

# Daemonize and literally spy on network routes
while true; do
  sleep 15
  NEW_ROUTES="$(ip route show default)"
  if [ "${NEW_ROUTES}" != "${LAST_ROUTES}" ]; then
    log_inf "Route table changed, re-applying exit ports"
    apply_exit_ports
  fi
done
