#!/sbin/sh
#
# Backup and restore addon /system files
#

export C=/tmp/backupdir
export S=/system

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
cp -f /tmp/install/bin/backuptool.functions /tmp

# Backup fonts
preserve_fonts() {
  mkdir -p /tmp/fonts
  cp -a /system/fonts/Roboto* /tmp/fonts/
  chmod 644 /tmp/fonts/*.ttf
}

# Restore fonts
restore_fonts() {
  if [ -d /system/fonts/ ]; then
    cp -a /tmp/fonts/* /system/fonts/
    rm -rf /tmp/fonts
    chmod 644 /tmp/fonts/*.ttf
  fi
}

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  mkdir -p /tmp/addon.d/
  cp -a /system/addon.d/* /tmp/addon.d/
  chmod 755 /tmp/addon.d/*.sh
}

# Restore /system/addon.d in /tmp/addon.d
restore_addon_d() {
  cp -a /tmp/addon.d/* /system/addon.d/
  rm -rf /tmp/addon.d/
}

# Execute /system/addon.d/*.sh scripts with $1 parameter
run_stage() {
for script in $(find /tmp/addon.d/ -name '*.sh' |sort -n); do
  $script $1
done
}

case "$1" in
  backup)
    mkdir -p $C
    preserve_addon_d
    preserve_fonts
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
  ;;
  restore)
    run_stage pre-restore
    run_stage restore
    run_stage post-restore
    restore_addon_d
    restore_fonts
    rm -rf $C
    sync
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
