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

if ! command -v cmake >/dev/null 2>&1; then
    echo "ERROR: CMake was not found in PATH."
    echo "Install CMake and verify with: cmake --version"
    exit 1
fi

normalize_project "$project"
normalize_build_type "$build_type"

project_dir="$SCRIPT_DIR/projects/$PROJECT_LOWER"
if [[ ! -f "$project_dir/src/${PROJECT_LOWER}.c" ]]; then
    echo "ERROR: Project '$PROJECT' is not available in this checkout."
    echo "Expected source file: $project_dir/src/${PROJECT_LOWER}.c"
    exit 1
fi

build_dir="$SCRIPT_DIR/build/$BUILD_TYPE/$PROJECT_LOWER"
output_dir="$SCRIPT_DIR/bin/$BUILD_TYPE/$PROJECT_LOWER"

mkdir -p "$build_dir"

echo "============================================================"
echo "Building $PROJECT - $BUILD_TYPE"
echo "============================================================"
echo "Root Dir:   $SCRIPT_DIR"
echo "Build Dir:  $build_dir"
echo "Output Dir: $output_dir"
echo

cmake -S "$SCRIPT_DIR" -B "$build_dir" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DSELECTED_PROJECT="$PROJECT"
cmake --build "$build_dir" --config "$BUILD_TYPE" -j

echo
echo "Build completed successfully."
echo "Output location: $output_dir/main"
echo "Use ./run.sh $PROJECT $BUILD_TYPE to launch the application."