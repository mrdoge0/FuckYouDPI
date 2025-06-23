# (c) 2025 mrdoge0, Free Software Licensed under Apache-2.0

# Fail function
fail() {
    echo "! $1"
    echo "! Please install KSU WebUI Standalone manually."
    exit 1
}

# Download function
download() {
    PATH=/data/adb/magisk:/data/data/com.termux/files/usr/bin:$PATH
    if command -v curl >/dev/null 2>&1; then
        curl --connect-timeout 10 -Ls "$1"
    else
        busybox wget -T 10 --no-check-certificate -qO- "$1"
    fi
    PATH="$ORG_PATH"
}

# Get WebUI function
get_webui() {
    echo "- Downloading KSU WebUI Standalone..."
    API="https://api.github.com/repos/5ec1cff/KsuWebUIStandalone/releases/latest"
    ping -c 1 -w 5 raw.githubusercontent.com &>/dev/null || fail "Unable to connect to raw.githubusercontent.com."
    URL=$(download "$API" | grep -o '"browser_download_url": "[^"]*"' | cut -d '"' -f 4) || fail "Unable to get latest version."
    download "$URL" > "$APK_PATH" || fail "APK download failed."

    echo "- Installing..."
    pm install -r "$APK_PATH" || {
        rm -f "$APK_PATH"
        fail "APK installation failed."
    }

    echo "- Done."
    rm -f "$APK_PATH"

    echo "- Launching WebUI..."
    am start -n "io.github.a13e300.ksuwebui/.WebUIActivity" -e id "fuckyoudpi"
}

# Launch KSUWebUI standalone or MMRL
if pm path io.github.a13e300.ksuwebui >/dev/null 2>&1; then
    echo "- Launching WebUI in KSUWebUIStandalone..."
    am start -n "io.github.a13e300.ksuwebui/.WebUIActivity" -e id "fuckyoudpi"
elif pm path com.dergoogler.mmrl.wx > /dev/null 2>&1; then
    echo "- Launching WebUI in WebUI X..."
    am start -n "com.dergoogler.mmrl.wx/.ui.activity.webui.WebUIActivity" -e MOD_ID "fuckyoudpi"
else
    echo "! No WebUI app found"
    get_webui
fi
