# Fuck You DPI - Telemetry framework
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0

# This is the telemetry framework, not the daemon.
# Just like common-func.sh, it should be sourced, not executed.

# Function to catch ROM
get_rom() {
  # LineageOS
  if getprop ro.lineage.build.version > /dev/null; then 
    echo "LineageOS $(getprop ro.lineage.build.version) [$(getprop ro.lineage.version)]"
  fi

  # AOSP and Pixel replicas
  case "$(getprop ro.product.name)" in
    aosp*|treble*|gsi_gms*)
      echo "AOSP or a Pixel replica";;
  esac

  # MIUI / HyperOS
  if [ "$(getprop ro.build.version.incremental)" == "OS*XM" ]; then
    X=$(getprop ro.build.version.incremental)
    if [ ${#X} -eq 3 ]; then
      A="$(echo "${X}" | cut -c3).$(echo "${X}" | cut -c7)"
    else
      A="$(echo "${X}" | cut -c3).0"
    fi
    echo "HyperOS ${A} [${X}]"
  elif [ "$(getprop ro.build.version.incremental)" == "V*XM" ]; then
    X=$(getprop ro.build.version.incremental)
    A="$(echo "${X}" | cut -c2)$(echo "${X}" | cut -c3).$(echo "${X}" | cut -c5)"
    echo "MIUI ${A} [${X}]"
  fi
}

# Function to catch root solution
get_root_solution() {
  # Common variable
  PMRESULT=$(pm list packages)

  # Magisk
  if echo "${PMRESULT}" | grep "com.topjohnwu.magisk" > /dev/null; then
    echo "Magisk v$(su -v | cut -d':' -f1) [$(su -V)]"

  # KernelSU
  elif echo "${PMRESULT}" | grep "me.weishu.kernelsu" > /dev/null; then
    echo "KernelSU v$(su -v | cut -d':' -f1) [$(su -V)]"

  # KernelSU Next
  elif echo "${PMRESULT}" | grep "com.rifsxd.ksunext" > /dev/null; then
    echo "KSU Next v$(su -v | cut -d':' -f1) [$(su -V)]"

  # APatch
  elif echo "${PMRESULT}" | grep "me.bmax.apatch" > /dev/null; then
    echo "APatch v$(su -v | cut -d':' -f1) [$(su -V)]"

  # SukiSU
  elif echo "${PMRESULT}" | grep "sukisu" > /dev/null; then
    echo "SukiSU v$(su -v | cut -d':' -f1) [$(su -V)]"

  # Other
  else
    echo "Unknown (Hidden?)"
  fi
}

# Generate telemetry data
generate_data() {
  # JSON Header
  echo '{'

  # Device
  echo "  \"device\": \"$(getprop ro.product.brand) $(getprop ro.product.model) [$(getprop ro.product.device)]\","

  # Android version
  echo "  \"android_version\": \"$(getprop ro.build.version.release_or_codename) [$(getprop ro.build.version.sdk)]\","

  # Fingerprint
  echo "  \"fingerprint\": \"$(getprop ro.build.fingerprint)\","

  # Root solution
  echo "  \"root_solution\": \"$(get_root_solution)\","

  # ROM
  GETROM_RESULT=$(get_rom)
  if [ $(echo "${GETROM_RESULT}" | wc -l) -eq 1 ]; then
    echo "  \"rom\": \"${GETROM_RESULT}\","
  else
    echo "  \"rom\": \"$(echo ${GETROM_RESULT} | paste -sd ', ' -)\","
  fi

  # FuckYouDPI version code
  echo "  \"fydpi_vercode\": \"$(cat /data/adb/modules/fuckyoudpi/module.prop | grep versionCode | cut -d= -f2)\","

  # Architecture
  case "$(getprop ro.product.cpu.abi)" in
    arm64-v8a) echo "  \"arch\": \"aarch64\"";;
    x86_64) echo "  \"arch\": \"x86_64\"";;
    *) echo "  \"arch\": \"unsupported\"";;
  esac

  # JSON Footer
  echo '}'
}
