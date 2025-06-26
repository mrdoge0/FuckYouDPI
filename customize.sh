# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0

# Minimum-maximum API settings.
MINAPI=27
MAXAPI=36

# Permissions
set_permissions() {
  set_perm_recursive $MODPATH/static-aarch64      0 0 0755 0755
  set_perm_recursive $MODPATH/static-x86_64       0 0 0755 0755
  set_perm_recursive $MODPATH/system/bin          0 0 0755 0755
  set_perm           $MODPATH/action.sh           0 0 0755
  set_perm           $MODPATH/fydpi_metaworker.sh 0 0 0755
  set_perm           $MODPATH/fydpi_worker.sh     0 0 0755
  set_perm           $MODPATH/service.sh          0 0 0755
}
