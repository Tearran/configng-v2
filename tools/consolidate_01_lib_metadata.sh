#!/usr/bin/env bash
# Robust parser: builds ${parent}_helpers[...] and ${parent}_options[...] arrays
# from .conf files, emitting every key/value, regardless of key order, plus a unique_id.

set -euo pipefail

SRC_ROOT="./src"
OUT_FILE="./lib/armbian-config/module_options_arrays.sh"


declare -A array_entries
declare -A group_counts  # For unique id per group

# Required keys for helpers (no 'documents')
required_helper_keys=(description extend_disc parent group)

# Helper: emit a finished section
emit_section() {
	local section="$1"
	declare -n mapref="$2"
	local parent="${mapref[parent]:-}"
	local group="${mapref[group]:-}"

	# Skip if section or parent is missing
	[[ -z "$section" || -z "$parent" || -z "$group" ]] && return

	# If helper, check required keys
	if [[ "$section" == _* ]]; then
		for req in "${required_helper_keys[@]}"; do
		if [[ -z "${mapref[$req]:-}" ]]; then
			echo "Error: Helper section [$section] missing required key: $req" >&2
			exit 1
		fi
		done
		local arr="${parent}_helpers"
	else
		local arr="${parent}_options"
	fi

	# Generate unique id: first 3 uppercase chars of group, padded 3-digit counter
	local group_key=$(echo "$group" | tr '[:lower:]' '[:upper:]' | cut -c1-3)
	group_counts["$group_key"]=$(( ${group_counts["$group_key"]:-0} + 1 ))
	local id_num=$(printf "%03d" "${group_counts["$group_key"]}")
	local unique_id="${group_key}${id_num}"

	mapref["unique_id"]="$unique_id"

	for key in "${!mapref[@]}"; do
		array_entries["$arr"]+=$'\n'"${arr}[${section},${key}]=\"${mapref[$key]}\""
	done
}

	# Process each .conf file in SRC_ROOT
for meta in "$SRC_ROOT"/*/*.conf; do
	[[ -e "$meta" ]] || continue
	section=""
	declare -A section_kv=()

	while IFS='=' read -r key value || [[ -n "$key" ]]; do
		# Section header: [section]
		if [[ "$key" =~ ^\[(.*)\]$ ]]; then
		emit_section "$section" section_kv
		section="${BASH_REMATCH[1]}"
		section_kv=()
		continue
		fi
		# Skip comments and blank lines
		[[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

		section_kv["$key"]="$value"
	done < "$meta"

	# Emit last section in file
	emit_section "$section" section_kv
done

mkdir -p "$(dirname "$OUT_FILE")"
{
	echo -e "######## Auto-generated. Do not edit. ########\n"
	for arr in $(printf "%s\n" "${!array_entries[@]}" | sort); do
		echo -e "######## start $arr ########\n#"
		echo "declare -A $arr"
		echo "${array_entries[$arr]}"
		echo -e "#\n######## finish $arr ########\n"
	done
} > "$OUT_FILE"

echo "Wrote generated options arrays to $OUT_FILE"
