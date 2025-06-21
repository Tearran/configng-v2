#!/bin/bash
set -euo pipefail

_about_validate_module() {
	cat <<EOF

usage: $0 <modulename>|all|help

Check results:
	OK      - File exists and passes checks
	MISSING - File is missing
	WARN    - File exists but is incomplete

Checks performed:
	- <modulename>.md   (must have more than a top-level header)
	- <modulename>.sh   (must contain Help info in _about_<modulename>() function)
	- <modulename>.conf (must have required non-comment fields: feature, helpers, description)
	- Checks for duplicate-named files in src/** (warns if present)

Examples:
	$0 ok_box
	$0 all

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
	# Accepts either with or without function, with optional spaces
	if ! grep -Eq "^(function[[:space:]]+)?_about_${modname}[[:space:]]*\(\)[[:space:]]*\{" "$file"; then
		echo "WARN: $file missing _about_${modname}()"
		return 1
	fi
	echo "OK: $file"
}

_check_conf() {
	local REQUIRED_CONF_FIELDS=(feature helpers description)
	file="$1"
	local missing=0
	local missing_fields=()
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi

	for field in "${REQUIRED_CONF_FIELDS[@]}"; do
		if ! grep -qE "^$field=" "$file"; then
			missing=1
			missing_fields+=("$field")
		fi
	done

	if [ "$missing" -eq 0 ]; then
		echo "OK: $file"
		return 0
	else
		echo "WARN: $file missing required fields: ${missing_fields[*]}"
		return 1
	fi
}

_check_dup_src() {
	file="$1"
	modname="$(basename "$file")"
	# Look for same-named files in src/** (excluding ./staging)
	dups=$(find ./src -type f -name "$modname")
	if [ -n "$dups" ]; then
		echo "WARN: $modname also exists in:"
		echo "$dups"
		echo "If refactoring or bugfix: remove the old src copy."
		echo "If not: rename the new module to avoid conflict."
		return 1
	fi
}

validate_module() {
	local cmd="${1:-all}"
	local status=0
	case "$cmd" in
		help|--help|-h)
			_about_validate_module
			exit 0
		;;
		all|"")
			local failed=0
			for shfile in ./staging/*.sh; do
				modname="$(basename "$shfile" .sh)"
				echo "==> Checking module: $modname"
				_check_md "./staging/$modname.md" || failed=1
				_check_sh "./staging/$modname.sh" || failed=1
				_check_conf "./staging/$modname.conf" || failed=1
				_check_dup_src "./staging/$modname.sh" || failed=1

				echo
			done
			if [[ "$failed" -ne 0 ]]; then
				echo "One or more modules failed validation" >&2
				exit 1
			fi
		;;
		*)
			_check_conf "./staging/$cmd.conf" || status=1
			_check_md "./staging/$cmd.md" || status=1
			_check_sh "./staging/$cmd.sh" || status=1
			_check_dup_src "./staging/$cmd.sh" || status=1

			if [[ "$status" -ne 0 ]]; then
				echo "One or more validation checks failed for module: $cmd" >&2
				exit 1
			fi
		;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	validate_module "${1:-all}"
fi

