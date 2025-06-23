#!/bin/bash
set -euo pipefail

_about_validate_module() {
	cat <<EOF

usage: $0 <modulename>|all|help

Check results:
	OK      - File exists and passes checks
	MISSING - File is missing
	FAIL    - File exists but is incomplete

Checks performed:
	- <modulename>.md   (must have more than a top-level header)
	- <modulename>.sh   (must contain Help info in _about_<modulename>() function)
	- <modulename>.conf (must have required non-comment fields: feature, helpers, description)
	- Checks for duplicate-named files in src/** and docs/** (outside of ./staging)

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
		echo "FAIL: $file missing top-level header"
		return 1
	fi
	if [ "$(grep -c "^# " "$file")" -eq "$(wc -l < "$file")" ]; then
		echo "FAIL: $file has only a top-level header"
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
	if ! grep -Eq "^(function[[:space:]]+)?_about_${modname}[[:space:]]*\(\)[[:space:]]*\{" "$file"; then
		echo "FAIL: $file missing _about_${modname}()"
		return 1
	fi
	echo "OK: $file"
}

_check_conf() {
	local REQUIRED_CONF_FIELDS=(feature options helpers description parent group contributor maintainer port)
	local file="$1"
	local failed=0
	local failed_fields=()

	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi

	local feature
	feature="$(grep -E "^feature=" "$file" | cut -d= -f2- | xargs)"

	for field in "${REQUIRED_CONF_FIELDS[@]}"; do
		if ! grep -qE "^$field=" "$file"; then
			failed=1
			failed_fields+=(" $field (missing)")
			continue
		fi

		local value
		value="$(grep -E "^$field=" "$file" | cut -d= -f2- | xargs)"

		if [ -z "$value" ]; then
			if [ "$field" = "helpers" ]; then
				failed_fields+=(" helpers (no helper listed; must have at least _about_$feature)")
			else
				failed_fields+=(" $field (empty)")
			fi
			failed=1
			continue
		fi

		case "$field" in
			helpers)
				if [ -n "$feature" ] && ! echo "$value" | grep -qw "_about_$feature"; then
					failed=1
					failed_fields+=(" helpers (must include _about_$feature)")
				fi
				;;
			parent|group)
				if [[ "$value" =~ [A-Z\ ] ]]; then
					failed=1
					failed_fields+=(" $field (should be lowercase, no spaces)")
				fi
				;;
			contributor)
				if [[ ! "$value" =~ ^@[a-zA-Z0-9_-]+$ ]]; then
					failed=1
					failed_fields+=(" contributor (should be valid github username, like @tearran)")
				fi
				;;
			maintainer)
				if [[ "$value" != "true" && "$value" != "false" ]]; then
					failed=1
					failed_fields+=(" maintainer (must be 'true' or 'false')")
				fi
				;;
			options)
				if [ -z "$value" ]; then
					failed=1
					failed_fields+=(" options (blank; should describe supported options or 'none')")
				fi
				;;
		esac
	done

	if [ "$failed" -eq 0 ]; then
		echo "OK: $file"
		return 0
	else
		echo "FAIL: $file missing or invalid fields:"
		for f in "${failed_fields[@]}"; do
			echo "  -$f"
		done
		return 1
	fi
}

# Check for duplicates in src/ and docs/ (excluding ./staging)
_check_duplicate_anywhere() {
	local modname="$1"
	local found=0
	for dir in ./src ./docs; do
		for ext in .sh .md .conf; do
			# Find all matches, ignoring ./staging
			while IFS= read -r file; do
				# Skip if nothing found or file is in ./staging
				[[ -z "$file" ]] && continue
				[[ "$file" == ./staging/* ]] && continue
				# FAIL if file exists outside staging
				if [ -f "$file" ]; then
					echo "FAIL: Duplicate found in $dir: $file"
					found=1
				fi
			done < <(find "$dir" -type f -name "$modname$ext")
		done
	done
	return $found
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
				_check_duplicate_anywhere "$modname" || failed=1
				echo
			done
			if [[ "$failed" -ne 0 ]]; then
				echo "One or more modules failed validation" >&2
				exit 1
			fi
		;;
		*)
			modname="$cmd"
			_check_conf "./staging/$modname.conf" || status=1
			_check_md "./staging/$modname.md" || status=1
			_check_sh "./staging/$modname.sh" || status=1
			_check_duplicate_anywhere "$modname" || status=1
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
