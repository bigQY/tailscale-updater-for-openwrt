#!/bin/sh

# Log file path
LOG_FILE="/var/tmp/tailscale_update.log"

# Temporary directory
TMP_DIR="/var/tmp"

# Function to log messages
log_message() {
    echo "`date +"%Y%m%d %H:%M:%S"` $1" >> "$LOG_FILE" 2>&1
}

# Function to clean up temporary files
cleanup() {
    local version=$1
    local arch=$2
    rm -f "$TMP_DIR/tailscale_${version}_${arch}.tgz"
    rm -rf "$TMP_DIR/tailscale_${version}_${arch}"
}

# Get system architecture
get_architecture() {
    local ts_arch="unknown"

    # First try to determine architecture from OpenWrt's DISTRIB_ARCH
    if [ -f /etc/openwrt_release ]; then
        local dist_arch=$(grep 'DISTRIB_ARCH' /etc/openwrt_release | cut -d "'" -f2)
        case $dist_arch in
            x86_64)      ts_arch="amd64" ;;
            i386*)       ts_arch="386" ;;
            arm_*)       ts_arch="arm" ;;
            aarch64*)    ts_arch="arm64" ;;
            mips_24kc)   ts_arch="mips" ;;
            mipsel_24kc) ts_arch="mipsle" ;;
            mips64*)     ts_arch="mips64" ;;
            mips64el*)   ts_arch="mips64le" ;;
            geode*)      ts_arch="geode" ;;
            riscv64*)    ts_arch="riscv64" ;;
        esac
    fi

    # If not found, try to determine using uname -m
    if [ "$ts_arch" = "unknown" ]; then
        local arch=$(uname -m)
        case $arch in
            x86_64)      ts_arch="amd64" ;;
            aarch64)     ts_arch="arm64" ;;
            armv7l|arm*) ts_arch="arm" ;;
            i386|i686)   ts_arch="386" ;;
            mips)        ts_arch="mips" ;;
            mips64)      ts_arch="mips64" ;;
            mips64el|mips64le) ts_arch="mips64le" ;;
            mipsel|mipsle)     ts_arch="mipsle" ;;
            riscv64)     ts_arch="riscv64" ;;
        esac
    fi

    # Special handling for Geode architecture
    if grep -q "Geode" /proc/cpuinfo && [ "$ts_arch" = "386" ]; then
        ts_arch="geode"
    fi

    echo "$ts_arch"
}

# Get current installed Tailscale version
get_current_version() {
    tailscale --version 2>/dev/null | head -1 || echo "unknown"
}

# Main program starts
log_message "Starting Tailscale update check"

# Get system architecture
TS_ARCH=$(get_architecture)
log_message "Detected system architecture: $TS_ARCH"

# Check architecture support
case $TS_ARCH in
    amd64|386|arm|arm64|mips|mips64|mips64le|mipsle|geode|riscv64)
        log_message "Architecture $TS_ARCH is supported for update" ;;
    *)
        log_message "Unsupported system architecture: $TS_ARCH"
        exit 1 ;;
esac

# Get latest version number
log_message "Fetching latest version information"
tag=$(wget --no-check-certificate -q -O- "https://pkgs.tailscale.com/stable/" | grep -oE "tailscale_([0-9]+\.){2}[0-9]+_${TS_ARCH}\.tgz" | head -1 | cut -d_ -f2)

if [ -z "$tag" ]; then
    log_message "Failed to get latest version information"
    exit 1
fi

# Get current version
current_version=$(get_current_version)

# Version comparison
if [ "$tag" = "$current_version" ]; then
    log_message "Already at latest version v$current_version"
    exit 0
fi

log_message "New version found: v$tag (current version: v$current_version)"

# Download new version
log_message "Starting download of new version"
if ! wget --no-check-certificate -c -O "$TMP_DIR/tailscale_${tag}_${TS_ARCH}.tgz" "https://pkgs.tailscale.com/stable/tailscale_${tag}_${TS_ARCH}.tgz"; then
    log_message "Failed to download new version"
    cleanup "$tag" "$TS_ARCH"
    exit 1
fi

# Extract package
cd "$TMP_DIR" || exit 1
if ! tar -zxf "tailscale_${tag}_${TS_ARCH}.tgz"; then
    log_message "Failed to extract package"
    cleanup "$tag" "$TS_ARCH"
    exit 1
fi

# Stop service
log_message "Stopping Tailscale service"
/etc/init.d/tailscale stop
sleep 2

# Update binary files
cd "tailscale_${tag}_${TS_ARCH}" || exit 1
if ! mv tailscale tailscaled /usr/sbin/ || ! chmod 755 /usr/sbin/tailscale /usr/sbin/tailscaled; then
    log_message "Failed to update binary files"
    cleanup "$tag" "$TS_ARCH"
    exit 1
fi

# Clean up temporary files
cd "$TMP_DIR" || exit 1
cleanup "$tag" "$TS_ARCH"

# Restart service
log_message "Restarting Tailscale service"
/etc/init.d/tailscale start
sleep 3
/etc/init.d/tailscale restart

# Verify update
new_version=$(get_current_version)
if [ "$new_version" = "$tag" ]; then
    log_message "Update completed successfully, current version: v$new_version"
else
    log_message "Update may not have succeeded, please check version: v$new_version"
fi