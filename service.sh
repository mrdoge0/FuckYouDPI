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
  echo "127.0.0.1:1080" > "${DOTFILEDIR}/SOCKS5"
  echo "[FuckYouDPI] First time starting."
fi

# Determine architecture (needed for invoking nfqws)
case "$(getprop ro.product.cpu.abi)" in
  arm64-v8a) ARCH="aarch64" ;;
  armeabi-v7a) ARCH="armv7eabi" ;;
  x86_64) ARCH="x86_64" ;;
  x86) ARCH="i686" ;;
  *) echo "[FuckYouDPI] Architecture is NOT supported!"; exit 1 ;;
esac

# Load in settings.
NFQWS_SOCKS5_TARGET=$(cat "${DOTFILEDIR}/SOCKS5")
NFQWS_ARGS=""
[ -f "${DOTFILEDIR}/TRICK_HOSTSPELL" ] && NFQWS_ARGS="${NFQWS_ARGS} --hostspell=hoSt"
[ -f "${DOTFILEDIR}/TRICK_OOB" ] && NFQWS_ARGS="${NFQWS_ARGS} --oob"
[ -f "${DOTFILEDIR}/TRICK_DISORDER" ] && NFQWS_ARGS="${NFQWS_ARGS} --disorder"
