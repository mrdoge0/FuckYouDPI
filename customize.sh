# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0

# Minimum-maximum API settings.
MINAPI=27
MAXAPI=36

# Permissions and companion install.
set_permissions() {
  set_perm_recursive $MODPATH/static-aarch64      0 0 0755 0755
  set_perm_recursive $MODPATH/static-x86_64       0 0 0755 0755
  set_perm_recursive $MODPATH/system/bin          0 0 0755 0755
  set_perm           $MODPATH/action.sh           0 0 0755
  set_perm           $MODPATH/fydpi_metaworker.sh 0 0 0755
  set_perm           $MODPATH/fydpi_worker.sh     0 0 0755
  set_perm           $MODPATH/service.sh          0 0 0755
  ui_print "- Installing companion"
  unzip -qjo "$ZIPFILE" 'companion.apk' -d $TMPDIR >&2
  pm install --user 0 $TMPDIR/companion.apk
}

# Logic from MMT Extended
SKIPUNZIP=1
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh
