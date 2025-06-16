#!/bin/bash
set -e

# Move test_*.sh scripts from staging to tests/
for test_file in ./staging/test_*.sh; do
	[ -f "$test_file" ] || continue
	echo "Moving $test_file to ./tests/"
	mv "$test_file" ./tests/
done

# Move *.sh (not test_*.sh) with a matching .meta file to src/$parent/
for sh_file in ./staging/*.sh; do
	[[ "$sh_file" == *test_*.sh ]] && continue
	[ -f "$sh_file" ] || continue
	base_name=$(basename "$sh_file" .sh)
	meta_file="./staging/${base_name}.meta"
	if [ -f "$meta_file" ]; then
		parent=$(awk -F= '/^parent=/{print $2}' "$meta_file" | head -n1)
		if [ -n "$parent" ]; then
			dest_dir="./src/$parent"
			mkdir -p "$dest_dir"
			echo "Moving $sh_file and $meta_file to $dest_dir/"
			mv "$sh_file" "$dest_dir/"
			mv "$meta_file" "$dest_dir/"
		else
			echo "No parent= in $meta_file, skipping $sh_file"
		fi
	fi
done
