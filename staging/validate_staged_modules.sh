#!/usr/bin/env bash
set -euo pipefail

# ./validate_staged_modules.sh - Armbian Config V2 module

validate_staged_modules() {
	case "${1:-}" in
		help|-h|--help)
			_about_validate_staged_modules
			;;
		*)
			_validate_staged_modules_main
			;;
	esac
}

_validate_staged_modules_main() {
shopt -s nullglob   # <--- Add this!
			local failed=0
			local shfiles=(./staging/*.sh)
			if [ ${#shfiles[@]} -eq 0 ]; then
				echo "No modules found in ./staging/"
				#Sexit 1
			fi
			for shfile in "${shfiles[@]}"; do
				modname="$(basename "$shfile" .sh)"
				echo "==> Checking module: $modname"
				_check_sh "./staging/$modname.sh" || failed=1
				_check_conf "./staging/$modname.conf" || failed=1
				_check_duplicate_anywhere "$modname" || failed=1
				echo
			done
			if [[ "$failed" -ne 0 ]]; then
				echo "One or more modules failed validation" >&2
				exit 1
			fi
}



_check_sh() {
	file="$1"
	modname="$(basename "$file" .sh)"
	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi
	# Check for _about_<modname>() function
	if ! grep -Eq "^(function[[:space:]]+)?_about_${modname}[[:space:]]*\(\)[[:space:]]*\{" "$file"; then
		echo "FAIL: $file missing _about_${modname}()"
		return 1
	fi

	echo "OK: $file"
}

_check_conf() {
	# Check for required fields in <modulename>.conf
	local REQUIRED_CONF_FIELDS=(feature options helpers description parent group contributor port)
	local file="$1"
	local failed=0
	local failed_fields=()

	if [ ! -f "$file" ]; then
		echo "MISSING: $file"
		return 1
	fi
	# Check for feature= line
	local feature
	feature="$(grep -E "^feature=" "$file" | cut -d= -f2- | xargs)"

	for field in "${REQUIRED_CONF_FIELDS[@]}"; do
		if ! grep -qE "^$field=" "$file"; then
			failed=1
			failed_fields+=("$field (missing)")
			continue
		fi

		local value
		value="$(grep -E "^$field=" "$file" | cut -d= -f2- | xargs)"

		case "$field" in
			helpers)
		# Check for _about_<feature> function in CSV or space-separated helpers list
				if [[ -n $feature && ! $value =~ (^|,)_about_${feature}(,|$) ]]; then
					failed=1
					failed_fields+=("helpers must have at least (_about_$feature)")
				fi
				;;
			options)
				if [ -z "$value" ]; then
					failed=1
					failed_fields+=("options (blank; should describe supported options or 'none')")
				fi
				;;
			parent|group)
				if [ -z "$value" ]; then
					failed=1
					failed_fields+=("$field (empty)")
				elif [[ "$value" =~ [A-Z\ ] ]]; then
					failed=1
					failed_fields+=("$field (should be lowercase, no spaces)")
				fi
				;;
			contributor)
				if [ -z "$value" ]; then
					failed=1
					failed_fields+=("contributor (empty)")
				elif [[ ! "$value" =~ ^@[a-zA-Z0-9_-]+$ ]]; then
					failed=1
					failed_fields+=("contributor (should be valid github username, like @tearran)")
				fi
				;;
			feature|description|port)
				if [ -z "$value" ]; then
					failed=1
					failed_fields+=("$field (empty)")
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
			echo "  - $f"
		done
		return 1
	fi
}


# Check for duplicates in src/ and docs/ (excluding ./staging)
_check_duplicate_anywhere() {
	local modname="$1"
	local found=0
	for dir in ./src ; do
		for ext in .sh .conf; do
			# Find all matches, ignoring ./staging
			while IFS= read -r file; do
				# Skip if nothing found or file is in ./staging
				[[ -z "$file" ]] && continue
				[[ "$file" == ./staging/* ]] && continue
				# FAIL if file exists outside staging
				if [ -f "$file" ]; then
					echo "FAIL: Duplicate found in $dir: $file"
					found=1
				else
					echo "OK: No duplicate found in $dir: $file"
				fi
			done < <(find "$dir" -type f -name "$modname$ext")
		done
	done
	return $found
}

_about_validate_staged_modules() {
	cat <<EOF
Usage: validate_staged_modules <command> [options]

Commands:
	test        - Run a basic test of the validate_staged_modules module
	foo         - Example 'foo' operation (replace with real command)
	bar         - Example 'bar' operation (replace with real command)
	help        - Show this help message

Examples:
	# Run the test operation
	validate_staged_modules test

	# Perform the foo operation with an argument
	validate_staged_modules foo arg1

	# Show help
	validate_staged_modules help

Notes:
	- Replace 'foo' and 'bar' with real commands for your module.
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}

### START ./validate_staged_modules.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(validate_staged_modules help)"
	echo "$help_output" | grep -q "Usage: validate_staged_modules" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	validate_staged_modules "$@"
fi

### END ./validate_staged_modules.sh - Armbian Config V2 test entrypoint

