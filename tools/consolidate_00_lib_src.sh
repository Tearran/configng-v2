#!/usr/bin/env bash
set -e

SRC_ROOT="./src"
LIB_ROOT="./lib/armbian-config"

# List of .sh files to ignore (case-insensitive, add more as needed)
IGNORE_FILES=("readme.sh" "example_skip.sh")

mkdir -p "$LIB_ROOT"

for DIR in "$SRC_ROOT"/*/; do
	NS=$(basename "$DIR")
	OUT="$LIB_ROOT/$NS.sh"
	: > "$OUT" # clear output

	# Only process .sh files
	for f in "$DIR"/*.sh; do
			[[ -e "$f" ]] || continue
			fname=$(basename "$f")
			# Check if fname (case-insensitive) is in IGNORE_FILES
			skip=false
			for ignore in "${IGNORE_FILES[@]}"; do
				if [[ "${fname,,}" == "${ignore,,}" ]]; then
					skip=true
					break
				fi
			done
			$skip && continue

			# Add separator with filename
			relpath="${DIR%/}/$fname"
			echo -e "\n####### $relpath #######" >> "$OUT"
			# Remove shebang from all files
			sed '1{/^#!.*bash/d}' "$f" >> "$OUT"
			echo -e "\n" >> "$OUT"
	done
done

echo "All library files have assembled in $LIB_ROOT/"
