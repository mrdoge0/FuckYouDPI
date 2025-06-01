#!/system/bin/sh
# Fuck You DPI! - Worker script
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0
DOTFILEDIR="/data/adb/fuckyoudpi.d"
PORT=$(cat "${DOTFILEDIR}/PORT")

# Detect the UID of target app.
TARGET_UID=$(dumpsys package $1 | grep uid | cut -d= -f2 | cut -d" " -f1 | uniq)

# Report start.
echo "[FuckYouDPI] Enabling for $1 (UID ${TARGET_UID})"

# Route.
iptables -t mangle -A OUTPUT -p tcp -m owner --uid-owner "$TARGET_UID" -j MARK --set-mark 1
iptables -t mangle -A PREROUTING -p tcp -m mark --mark 1 -j TPROXY --on-port "$PORT" --tproxy-mark 1

# Report finish.
echo "[FuckYouDPI] Done enabling for $1 (UID ${TARGET_UID})"
