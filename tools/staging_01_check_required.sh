#!/bin/bash
set -euo pipefail

check_md() {
	file="$1"
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		exit 1
	fi
	if ! grep -q "^# " "$file"; then
		echo "WARN: $file missing top-level header"
		exit 1
	fi
	echo "OK: $file"
}

check_sh() {
	file="$1"
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		exit 2
	fi
	if ! grep -q "^help()" "$file"; then
		echo "WARN: $file missing help()"
		exit 2
	fi
	echo "OK: $file"
}

check_conf() {
	file="$1"
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		exit 3
	fi
	if ! grep -qv '^\s*#' "$file"; then
		echo "WARN: $file is only comments or empty"
		exit 3
	fi
	echo "OK: $file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	check_md "./staging/docs_foo.md"
	check_sh "./staging/foo.sh"
	check_conf "./staging/foo.conf"
fi