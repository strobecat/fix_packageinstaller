SKIPUNZIP=1

if [[ "$API" != '19' || "$ARCH" != 'arm' ]]; then
  abort '! arm32 kitkat expected'
fi

mkdir -p "$MODPATH/system/app"

output="$MODPATH/system/app/PackageInstaller.odex"
maxfd=$(ulimit -n 2>/dev/null) || maxfd=256
outputfd=3

while :; do
    # test if fd is already open
    if [ ! -e "/proc/self/$outputfd" ]; then
        eval "exec $outputfd<>$output"
        if [ "$?" -eq 0 ]; then
	    break
        fi
    fi
    outputfd=$((outputfd + 1))
    if [ "$outputfd" -gt "$maxfd" ]; then
        abort "! File descriptors run out"
    fi
done

ui_print "- Extracting module files"

# https://android.googlesource.com/platform/frameworks/native/+/refs/tags/android-4.4.4_r2.0.1/cmds/installd/commands.c#581
/system/bin/dexopt --zip 0 "$outputfd" "$ZIPFILE" "$(getprop dalvik.vm.dexopt-flags)" < "$ZIPFILE" || abort '! Failed to dexopt' 

unzip -o "${ZIPFILE}" module.prop -d "${MODPATH}" >&2
set_perm_recursive "$MODPATH" 0 0 0755 0644
