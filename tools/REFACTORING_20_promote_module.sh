#!/usr/bin/env bash
set -euo pipefail

# Promote modules from ./staging to their src/ destinations
promote_module() {
	# Move .sh (not docs_*.sh) with a matching .conf to src/$parent/$group/
	for sh_file in ./staging/*.sh; do
		[[ -f "$sh_file" ]] || continue
		base_name="$(basename "$sh_file" .sh)"
		conf_file="./staging/${base_name}.conf"
		if [[ -f "$conf_file" ]]; then
			parent="$(grep '^parent=' "$conf_file" | head -n1 | cut -d= -f2- | xargs)"
			group="$(grep '^group=' "$conf_file" | head -n1 | cut -d= -f2- | xargs)"

			# Validate presence of parent
			if [[ -z "$parent" ]]; then
				echo "No parent= in $conf_file, skipping $sh_file"
				continue
			fi

			# Compose destination directory and create it
			if [[ -n "$group" ]]; then
				dest_dir="./src/$parent/$group"
			else
				dest_dir="./src/$parent"
			fi
			mkdir -p "$dest_dir"

			# Move files
			echo "Moving $sh_file and $conf_file to $dest_dir/"
			mv "$sh_file" "$dest_dir/"
			mv "$conf_file" "$dest_dir/"
		else
			echo "WARNING: No .conf file for $sh_file, cannot promote."
		fi
	done

	# Remove ./staging if empty
	if [[ -d "./staging" ]]; then
		if [[ -z "$(ls -A ./staging)" ]]; then
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
