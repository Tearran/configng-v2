#!/bin/bash
set -euo pipefail

promote_module() {

	DOC_ROOT="${DOC_ROOT:-./docs}"

	# Move *.sh (not docs_*.sh) with a matching .conf file to src/$parent/
	for sh_file in ./staging/*.sh; do
		[ -f "$sh_file" ] || continue
		base_name=$(basename "$sh_file" .sh)
		conf_file="./staging/${base_name}.conf"
		if [ -f "$conf_file" ]; then
			parent=$(grep '^parent=' "$conf_file" | head -n1 | cut -d= -f2- | xargs)
			if [ -n "$parent" ]; then
				dest_dir="./src/$parent"
				mkdir -p "$dest_dir"
				echo "Moving $sh_file and $conf_file to $dest_dir/"
				mv "$sh_file" "$dest_dir/"
				mv "$conf_file" "$dest_dir/"
			else
				echo "No parent= in $conf_file, skipping $sh_file"
			fi
		fi
	done

	# Move *.md scripts from staging to docs/
	for docs_file in ./staging/*.md; do
		[ -f "$docs_file" ] || continue
		mkdir -p "$DOC_ROOT"
		echo "Moving $docs_file to $DOC_ROOT/"
		mv "$docs_file" "$DOC_ROOT/"
	done

	# Check if ./staging is empty now
	if [ -d "./staging" ]; then
		if [ -z "$(ls -A ./staging)" ]; then
			echo "Removing empty ./staging directory."
			rmdir ./staging
		else
			echo "WARNING: ./staging is not empty after promotion."
			echo "Leftover files:"
			ls -l ./staging
			exit 1
		fi
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	promote_module
fi
