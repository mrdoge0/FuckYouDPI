#!/system/bin/sh
# Fuck You DPI! - Worker script
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0
DOTFILEDIR="/data/adb/fuckyoudpi.d"
PORT=$(cat "${DOTFILEDIR}/PORT")

# Detect the UID of target app.
for TARGET_UID in $(dumpsys package $1 | grep uid | cut -d= -f2 | cut -d" " -f1 | uniq); do
  
  # Report start.
  echo "[FuckYouDPI] Enabling for $1 (UID ${TARGET_UID})"
  
  # Route app to this entire fuckery.
  iptables -t mangle -A OUTPUT -p tcp -m owner --uid-owner "$TARGET_UID" -j MARK --set-mark 1
  iptables -t mangle -A PREROUTING -p tcp -m mark --mark 1 -j TPROXY --on-port "$PORT" --tproxy-mark 1
  
  # Report finish.
  echo "[FuckYouDPI] Done enabling for $1 (UID ${TARGET_UID})"
done

# Exit.
exit 0
