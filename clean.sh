#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-all}"
target_lower="$(printf '%s' "$target" | tr '[:upper:]' '[:lower:]')"

remove_dir() {
    local dir="$1"

    if [[ -e "$dir" ]]; then
        echo "Removing $dir"
        rm -rf -- "$dir"
    else
        echo "Skipping $dir"
    fi
}

clean_project() {
    local name="$1"
    remove_dir "$SCRIPT_DIR/build/Debug/$name"
    remove_dir "$SCRIPT_DIR/build/Release/$name"
    remove_dir "$SCRIPT_DIR/bin/Debug/$name"
    remove_dir "$SCRIPT_DIR/bin/Release/$name"
}

echo "============================================================"
echo "Cleaning build artifacts"
echo "============================================================"

case "$target_lower" in
    all)
        remove_dir "$SCRIPT_DIR/build"
        remove_dir "$SCRIPT_DIR/bin"
        ;;
    build)
        remove_dir "$SCRIPT_DIR/build"
        ;;
    bin)
        remove_dir "$SCRIPT_DIR/bin"
        ;;
    hair_dryer)
        clean_project "hair_dryer"
        ;;
    smart_shaver)
        clean_project "smart_shaver"
        ;;
    cheetah)
        clean_project "cheetah"
        ;;
    slide_player)
        clean_project "slide_player"
        ;;
    battery_monitor)
        clean_project "battery_monitor"
        ;;
    acc_data)
        clean_project "acc_data"
        ;;
    *)
        echo "ERROR: Unknown target '$target'"
        echo "Valid targets: all, build, bin, HAIR_DRYER, SMART_SHAVER, CHEETAH, SLIDE_PLAYER, BATTERY_MONITOR, ACC_DATA"
        exit 1
        ;;
esac

echo
echo "Cleanup completed."