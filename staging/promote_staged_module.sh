#!/usr/bin/env bash
set -euo pipefail

# ./promote_staged_module.sh - Armbian Config V2 module

promote_staged_module() {
	case "${1:-}" in
		help|-h|--help)
			_about_promote_staged_module
			;;
		*)
			_promote_staged_module_main
			;;
	esac
}

_promote_staged_module_main() {
	for sh_file in ./staging/*.sh; do
		[[ -f "$sh_file" ]] || continue
		base_name="$(basename "$sh_file" .sh)"
		conf_file="./staging/${base_name}.conf"
		if [[ -f "$conf_file" ]]; then
			parent="$(grep '^parent=' "$conf_file" | head -n1 | cut -d= -f2- | xargs)"
			group="$(grep '^group=' "$conf_file" | head -n1 | cut -d= -f2- | xargs)"

			if [[ -z "$parent" ]]; then
				echo "No parent= in $conf_file, skipping $sh_file"
				continue
			fi

			if [[ -n "$group" ]]; then
				dest_dir="./src/$parent/$group"
			else
				dest_dir="./src/$parent"
			fi
			mkdir -p "$dest_dir"

			echo "Moving $sh_file and $conf_file to $dest_dir/"
			mv "$sh_file" "$dest_dir/"
			mv "$conf_file" "$dest_dir/"

			# Move any matching image files to the module destination directory
			for ext in png jpg jpeg gif svg; do
				img_file="./staging/${base_name}.${ext}"
				if [[ -f "$img_file" ]]; then
					echo "Moving image: $img_file to $dest_dir/"
					mv "$img_file" "$dest_dir/"
				fi
			done
		else
			echo "ERROR: No .conf file for $sh_file, cannot promote."
			exit 1
		fi
	done

	# Check for orphans
	if [[ -d "./staging" ]]; then
		if [[ -z "$(ls -A ./staging)" ]]; then
			echo "Removing empty ./staging directory."
			rmdir ./staging
		else
			echo "ERROR: Orphaned files left in ./staging after promotion!"
			ls -l ./staging
			exit 1
		fi
	fi
}

_about_promote_staged_module() {
	cat <<EOF
Usage: promote_staged_module <command> [options]

Commands:
	test        - Run a basic test of the promote_staged_module module
	foo         - Example 'foo' operation (replace with real command)
	bar         - Example 'bar' operation (replace with real command)
	help        - Show this help message

Examples:
	# Run the test operation
	promote_staged_module test

	# Perform the foo operation with an argument
	promote_staged_module foo arg1

	# Show help
	promote_staged_module help

Notes:
	- Replace 'foo' and 'bar' with real commands for your module.
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}

### START ./promote_staged_module.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="$(promote_staged_module help)"
	echo "$help_output" | grep -q "Usage: promote_staged_module" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	promote_staged_module "$@"
fi

### END ./promote_staged_module.sh - Armbian Config V2 test entrypoint

