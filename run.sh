#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

project="${1:-HAIR_DRYER}"
build_type="${2:-Debug}"

normalize_project() {
    local input="$1"
    local upper_input

    upper_input="$(printf '%s' "$input" | tr '[:lower:]' '[:upper:]')"

    case "$upper_input" in
        HAIR_DRYER)
            PROJECT="HAIR_DRYER"
            PROJECT_LOWER="hair_dryer"
            ;;
        SMART_SHAVER)
            PROJECT="SMART_SHAVER"
            PROJECT_LOWER="smart_shaver"
            ;;
        CHEETAH)
            PROJECT="CHEETAH"
            PROJECT_LOWER="cheetah"
            ;;
        SLIDE_PLAYER)
            PROJECT="SLIDE_PLAYER"
            PROJECT_LOWER="slide_player"
            ;;
        BATTERY_MONITOR)
            PROJECT="BATTERY_MONITOR"
            PROJECT_LOWER="battery_monitor"
            ;;
        ACC_DATA)
            PROJECT="ACC_DATA"
            PROJECT_LOWER="acc_data"
            ;;
        *)
            echo "ERROR: Invalid project '$input'"
            echo "Valid projects: HAIR_DRYER, SMART_SHAVER, CHEETAH, SLIDE_PLAYER, BATTERY_MONITOR, ACC_DATA"
            return 1
            ;;
    esac
}

normalize_build_type() {
    local input="$1"
    local lower_input

    lower_input="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"

    case "$lower_input" in
        debug)
            BUILD_TYPE="Debug"
            ;;
        release)
            BUILD_TYPE="Release"
            ;;
        *)
            echo "ERROR: Invalid build type '$input'"
            echo "Valid build types: Debug, Release"
            return 1
            ;;
    esac
}

normalize_project "$project"
normalize_build_type "$build_type"

binary_path="$SCRIPT_DIR/bin/$BUILD_TYPE/$PROJECT_LOWER/main"

if [[ ! -x "$binary_path" ]]; then
    echo "ERROR: Executable not found at $binary_path"
    echo "Build it first with: ./build.sh $PROJECT $BUILD_TYPE"
    exit 1
fi

echo "============================================================"
echo "Running $PROJECT - $BUILD_TYPE"
echo "============================================================"
echo "Executable: $binary_path"
echo

cd "$SCRIPT_DIR"
exec "$binary_path"