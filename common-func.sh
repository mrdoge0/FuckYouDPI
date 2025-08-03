# Set dotfile directory
DOTFILEDIR="/data/adb/fuckyoudpi.d"

# Debugging options
[ -f "${DOTFILEDIR}/TRICK_DEBUG" ] && set -x

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
