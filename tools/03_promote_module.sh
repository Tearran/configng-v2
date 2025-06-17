#!/bin/bash
set -euo pipefail


promote_module() {

	DOC_ROOT="${DOC_ROOT:-./docs}"

	mkdir -p "$DOC_ROOT"
	declare -A array_entries
	declare -A group_counts  # For unique id per group


	# Move docs_*.sh scripts from staging to docs/
	for docs_file in ./staging/docs_*.md; do
		[ -f "$docs_file" ] || continue
		echo "Moving $docs_file to ./docs/"
		mv "$docs_file" ./docs/
	done

	# Move *.sh (not docs_*.sh) with a matching .conf file to src/$parent/
	for sh_file in ./staging/*.sh; do
		[[ "$sh_file" == *docs_*.sh ]] && continue
		[ -f "$sh_file" ] || continue
		base_name=$(basename "$sh_file" .sh)
		conf_file="./staging/${base_name}.conf"
		if [ -f "$conf_file" ]; then
			parent=$(awk -F= '/^parent=/{print $2}' "$conf_file" | head -n1)
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

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	promote_module
fi
