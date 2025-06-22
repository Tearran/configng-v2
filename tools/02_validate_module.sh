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
	local REQUIRED_CONF_FIELDS=(feature helpers description parent group contributor maintainer port)
	local file="$1"
	local failed=0
	local failed_fields=()

	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi

	# Extract 'feature' for helper validation
	local feature
	feature="$(grep -E "^feature=" "$file" | cut -d= -f2- | xargs)"

	for field in "${REQUIRED_CONF_FIELDS[@]}"; do
		# Must be present
		if ! grep -qE "^$field=" "$file"; then
			failed=1
			failed_fields+=(" $field (missing)")
			continue
		fi

		local value
		value="$(grep -E "^$field=" "$file" | cut -d= -f2- | xargs)"

		# Must not be empty or whitespace
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
				# Must contain _about_$feature
				if [ -n "$feature" ] && ! echo "$value" | grep -qw "_about_$feature"; then
					failed=1
					failed_fields+=(" helpers (must include _about_$feature)")
				fi
				;;
			parent|group)
				# Must be lowercase, no spaces
				if [[ "$value" =~ [A-Z\ ] ]]; then
					failed=1
					failed_fields+=(" $field (should be lowercase, no spaces)")
				fi
				;;
			contributor)
				# Must be a GitHub @username
				if [[ ! "$value" =~ ^@[a-zA-Z0-9_-]+$ ]]; then
					failed=1
					failed_fields+=(" contributor (should be valid github username, like @tearran)")
				fi
				;;
			maintainer)
				# Must be true or false
				if [[ "$value" != "true" && "$value" != "false" ]]; then
					failed=1
					failed_fields+=(" maintainer (must be 'true' or 'false')")
				fi
				;;
			options)
				# Warn (not fail) if blank
				if [ -z "$value" ]; then
					echo "WARN: options field is blank; should describe supported options or 'none'"
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
	return 0
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

