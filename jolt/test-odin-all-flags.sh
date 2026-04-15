#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT"

CONSTANTS_FILE="$ROOT/jolt/constants.odin"
CONSTANTS_BAK="$CONSTANTS_FILE.bak"

cp "$CONSTANTS_FILE" "$CONSTANTS_BAK"
trap 'mv "$CONSTANTS_BAK" "$CONSTANTS_FILE"' EXIT

set_odin_constants() {
  local double_precision="$1"
  local object_layer_bits="$2"

  python3 - <<PY
from pathlib import Path
import re

p = Path("$CONSTANTS_FILE")
text = p.read_text()

text = re.sub(r'JPC_OBJECT_LAYER_BITS\s*::\s*\d+', f'JPC_OBJECT_LAYER_BITS :: {${object_layer_bits}}', text)
text = re.sub(r'JPC_DOUBLE_PRECISION\s*::\s*(true|false)', f'JPC_DOUBLE_PRECISION  :: {"true" if ${double_precision} else "false"}', text)

p.write_text(text)
PY
}

find_one() {
  find "$1" -type f \( -name 'libjoltc.a' -o -name 'joltc.lib' -o -name 'libjoltc.so' -o -name 'libjoltc.dylib' \) | head -n 1
}

find_jolt() {
  find "$1" -type f \( -name 'libJolt.a' -o -name 'Jolt.lib' -o -name 'libJolt.so' -o -name 'libJolt.dylib' \) | head -n 1
}

run_odin_test() {
  local test_dir="$1"
  local out_name="$2"
  local linker_flags="$3"

  echo
  echo "Building Odin test: ${test_dir}"

  odin build "$test_dir" \
      -out:"build-joltc/${out_name}" \
      -extra-linker-flags:"${linker_flags}"

  echo "Running Odin test: ${test_dir}"
  "./build-joltc/${out_name}"
}

build_and_test() {
  local cmake_flags="$1"
  local double_precision="$2"
  local object_layer_bits="$3"

  echo
  echo "======================================================="
  echo "CMake flags: ${cmake_flags}"
  echo "Odin flags:  DOUBLE=${double_precision} LAYER_BITS=${object_layer_bits}"
  echo "======================================================="

  rm -rf build-joltc

  cmake -S JoltC -B build-joltc ${cmake_flags}
  cmake --build build-joltc

  set_odin_constants "${double_precision}" "${object_layer_bits}"

  JOLTC_LIB=$(find_one build-joltc)
  JOLT_LIB=$(find_jolt build-joltc)

  if [[ -z "${JOLTC_LIB}" ]]; then
      echo "ERROR: libjoltc not found"
      exit 1
  fi

  if [[ -z "${JOLT_LIB}" ]]; then
      echo "ERROR: libJolt not found"
      exit 1
  fi

  JOLTC_DIR=$(dirname "$JOLTC_LIB")
  JOLT_DIR=$(dirname "$JOLT_LIB")

  echo "Found joltc: $JOLTC_LIB"
  echo "Found Jolt:  $JOLT_LIB"

  EXTRA_LINKS=""
  case "$(uname -s)" in
      Linux*)
          EXTRA_LINKS="-L${JOLTC_DIR} -ljoltc -L${JOLT_DIR} -lJolt -lstdc++ -lpthread -lm"
          ;;
      Darwin*)
          EXTRA_LINKS="-L${JOLTC_DIR} -ljoltc -L${JOLT_DIR} -lJolt -lc++ -lm"
          ;;
      *)
          echo "Unsupported platform"
          exit 1
          ;;
  esac

  run_odin_test "tests/physics_smoke"          "odin_physics_smoke"          "${EXTRA_LINKS}"
  run_odin_test "tests/raycast_smoke"          "odin_raycast_smoke"          "${EXTRA_LINKS}"
  run_odin_test "tests/contact_listener_smoke" "odin_contact_listener_smoke" "${EXTRA_LINKS}"
  run_odin_test "tests/constraint_smoke"       "odin_constraint_smoke"       "${EXTRA_LINKS}"
}

build_and_test "" 0 16
build_and_test "-DDOUBLE_PRECISION=ON" 1 16
build_and_test "-DOBJECT_LAYER_BITS=32" 0 32

echo
echo "All Odin/JoltC tests passed."
