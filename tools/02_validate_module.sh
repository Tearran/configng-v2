#!/bin/bash
set -euo pipefail

_about_validate_module() {
	cat <<EOF

usage: $0 <modulename> or help

Check results:
	OK      - File exists and passes checks
	MISSING - File is missing
	WARN    - File exists but is incomplete

Checks performed:
	- docs_<modulename>.md   (must have more than a top-level header)
	- <modulename>.sh        (must contain Help info in _about_<modulename>() function)
	- <modulename>.conf      (must have non-comment content)

EOF
}

_check_md() {
	file="$1"
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi
	if ! grep -q "^# " "$file"; then
		echo "WARN: $file missing top-level header"
		return 1
	fi
	# Check for more content than the header (ignore lines with only # ...)
	if [ "$(grep -c "^# " "$file")" -eq "$(wc -l < "$file")" ]; then
		echo "WARN: $file has only a top-level header"
		return 1
	fi
	echo "OK: $file"
}

_check_sh() {
	file="$1"
	modname="$(basename "$file" .sh)"
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi
	if ! grep -q "^_about_${modname}()" "$file"; then
		echo "WARN: $file missing _about_${modname}()"
		return 1
	fi
	echo "OK: $file"
}

# At top of your script
REQUIRED_CONF_FIELDS=(feature helpers description)

_check_conf() {
	file="$1"
	local missing=0
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi

	for field in "${REQUIRED_CONF_FIELDS[@]}"; do
		if ! grep -qE "^$field=" "$file"; then
			echo "WARN: $file missing required field: $field"
			missing=1
		fi
	done

	if [ "$missing" -eq 0 ]; then
		echo "OK: $file"
		return 0
	else
		return 1
	fi
}

validate_module() {
	local cmd="${1:-help}"
	local status=0
	case "$cmd" in
		help|--help|-h)
			_about_validate_module
			exit 0
		;;
		*)
			_check_md "./staging/docs_$cmd.md" || status=1
			_check_sh "./staging/$cmd.sh" || status=1
			_check_conf "./staging/$cmd.conf" || status=1
			if [[ "$status" -ne 0 ]]; then
				echo "One or more validation checks failed for module: $cmd" >&2
				exit 1
			fi
		;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	validate_module "$@"
fi
