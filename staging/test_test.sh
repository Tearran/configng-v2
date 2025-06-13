#!/usr/bin/env bash
set -euo pipefail

# If run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Path to the module to test
  module_path="$(dirname "$0")/test.sh"

  # Load the module
  if [[ ! -f "$module_path" ]]; then
    echo "Module file not found: $module_path"
    exit 1
  fi
  # shellcheck source=/dev/null
  source "$module_path"

  # Check if the 'test' function exists
  if declare -f test >/dev/null 2>&1; then
    echo "✅ 'test' function found in $module_path"
    # Run the test function
    test
  else
    echo "❌ 'test' function NOT found in $module_path"
    exit 2
  fi
fi