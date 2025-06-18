#!/usr/bin/env bash
# Robust parser: builds ${parent}_helpers[...] and ${parent}_options[...] arrays
# from .conf files, emitting every key/value, regardless of key order, plus a unique_id.

set -euo pipefail

SRC_ROOT="./src"
OUT_FILE="./lib/armbian-config/module_options_arrays.sh"
LIB_ROOT="./lib/armbian-config"
IGNORE_FILES=("readme.sh")

declare -A array_entries
declare -A group_counts  # For unique id per group

# Required keys for helpers (no 'documents')
required_helper_keys=(description extend_desc parent group)

_consolidate_src() {
	mkdir -p "$LIB_ROOT"
	for DIR in "$SRC_ROOT"/*/; do
		local NS OUT f fname skip relpath
		NS=$(basename "$DIR")
		OUT="$LIB_ROOT/$NS.sh"
		: > "$OUT" # clear output

		for f in "$DIR"/*.sh; do
			[[ -e "$f" ]] || continue
			fname=$(basename "$f")
			skip=false
			for ignore in "${IGNORE_FILES[@]}"; do
				if [[ "${fname,,}" == "${ignore,,}" ]]; then
					skip=true
					break
				fi
			done

			if [[ "$skip" == true ]]; then
				continue
			fi

			relpath="${DIR%/}/$fname"
			echo -e "\n####### $relpath #######" >> "$OUT"
			sed '1{/^#!.*bash/d}' "$f" >> "$OUT"
			echo -e "\n" >> "$OUT"
		done
	done
	echo "All library files have assembled in $LIB_ROOT/"
}

emit_section() {
	local section="$1"
	declare -n mapref="$2"
	local parent group arr group_key id_num unique_id key
	parent="${mapref[parent]:-}"
	group="${mapref[group]:-}"

	[[ -z "$section" || -z "$parent" || -z "$group" ]] && return

	if [[ "$section" == _* ]]; then
		for req in "${required_helper_keys[@]}"; do
			if [[ -z "${mapref[$req]:-}" ]]; then
				echo "Error: Helper section [$section] missing required key: $req" >&2
				exit 1
			fi
		done
		arr="${parent}_helpers"
	else
		arr="${parent}_options"
	fi

	group_key=$(echo "$group" | tr '[:lower:]' '[:upper:]' | cut -c1-3)
	group_counts["$group_key"]=$(( ${group_counts["$group_key"]:-0} + 1 ))
	id_num=$(printf "%03d" "${group_counts["$group_key"]}")
	unique_id="${group_key}${id_num}"

	mapref["unique_id"]="$unique_id"

	for key in "${!mapref[@]}"; do
		array_entries["$arr"]+=$'\n'"${arr}[${section},${key}]=\"${mapref[$key]}\""
	done
}

_process_confs() {
	local meta section key value
	for meta in "$SRC_ROOT"/*/*.conf; do
		[[ -e "$meta" ]] || continue
		section=""
		declare -A section_kv=()

		while IFS='=' read -r key value || [[ -n "$key" ]]; do
			if [[ "$key" =~ ^\[(.*)\]$ ]]; then
				emit_section "$section" section_kv
				section="${BASH_REMATCH[1]}"
				section_kv=()
				continue
			fi
			[[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
			section_kv["$key"]="$value"
		done < "$meta"

		emit_section "$section" section_kv
	done
}

_write_arrays() {
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
}

consolidate_module() {
	local cmd="${1:-all}"
	case "$cmd" in
		consolidate)
			_consolidate_src
			;;
		generate|process)
			_process_confs
			_write_arrays
			;;
		all)
			_consolidate_src
			_process_confs
			_write_arrays
			;;
		*)
			echo "Usage: $0 [consolidate|generate|all]"
			return 1
			;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG="${DEBUG:-}"
	consolidate_module all
fi
