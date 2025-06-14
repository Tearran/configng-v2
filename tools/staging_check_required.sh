#!/bin/bash
set -euo pipefail

STAGING_DIR="./staging"

extract_module_names() {
	find "$STAGING_DIR" -maxdepth 1 -type f | \
		sed -n 's/.*\/[a-z]\+_\([^.]*\)\..*/\1/p' | sort -u
}

check_module_files() {
	module="$1"
	fail=0

	# Required files
	for req in "test_${module}.sh" "src_${module}.sh" "meta_${module}.conf"; do
		if [[ -f "${STAGING_DIR}/${req}" ]]; then
			echo "PASS: Found required ${req}"
		else
			echo "FAIL: Missing required ${req}"
			fail=1
		fi
	done

	# Optional file
	opt="doc_${module}.md"
	if [[ -f "${STAGING_DIR}/${opt}" ]]; then
		echo "PASS: Found optional ${opt}"
	else
		echo "NOTE: Optional ${opt} not found"
	fi

	return $fail
}

main() {
	[[ -d "$STAGING_DIR" ]] || { echo "No staging directory."; exit 1; }
	modules=($(extract_module_names))
	overall_fail=0

	for mod in "${modules[@]}"; do
		echo "== Checking module: $mod =="
		check_module_files "$mod" || overall_fail=1
		echo
	done

	if [[ "$overall_fail" -eq 0 ]]; then
		echo "PASS: All required files present for all detected modules."
	else
		echo "FAIL: One or more required files missing for at least one module."
	fi

	exit $overall_fail
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main
fi
