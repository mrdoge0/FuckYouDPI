# Fuck You DPI - Telemetry framework
# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0

# This is the telemetry framework, not the daemon.
# Just like common-func.sh, it should be sourced, not executed.

# Function to catch ROM
get_rom() {
  # LineageOS
  if getprop ro.lineage.build.version; then 
    echo "LineageOS $(getprop ro.lineage.build.version) [$(getprop ro.lineage.version)]"
  fi

  # AOSP and Pixel replicas
  if [ "$(getprop ro.product.name)" == "aosp*" ] || [ "$(getprop ro.product.name)" == "treble*" ] || [ "$(getprop ro.product.name)" == "gsi_gms*" ]; then
    echo "AOSP or a Pixel replica"
  fi

  # MIUI / HyperOS
  if [ "$(getprop ro.build.version.incremental)" == "OS*XM" ]; then
    X=$(getprop ro.build.version.incremental)
    if [ ${#${X}} -eq 3 ]; then
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
