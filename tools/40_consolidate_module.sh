#!/usr/bin/env bash
set -euo pipefail


SRC_ROOT="./src"
OUT_FILE="./lib/armbian-config/module_options_arrays.sh"
LIB_ROOT="./lib/armbian-config"
IGNORE_FILES=("readme.sh")

declare -A array_entries
declare -A group_counts  # For unique id per group

# Required keys for helpers
required_helper_keys=(description extend_desc parent group)

_consolidate_src() {
	mkdir -p "$LIB_ROOT"
	declare -A pipefail_written
	find "$SRC_ROOT" -type f -name '*.sh' | while read -r f; do
		rel="${f#$SRC_ROOT/}"
		namespace="${rel%%/*}"
		OUT="$LIB_ROOT/$namespace.sh"
		fname=$(basename "$f")
		skip=false
		for ignore in "${IGNORE_FILES[@]}"; do
			if [[ "${fname,,}" == "${ignore,,}" ]]; then
				skip=true
				break
			fi
		done
		[[ "$skip" == true ]] && continue

		# Only create/truncate once per OUT (per run)
		if [[ ! -e "$OUT.in_progress" ]]; then
			: > "$OUT"
			touch "$OUT.in_progress"
		fi

		echo -e "\n####### $f #######" >> "$OUT"
		awk -v pf="${pipefail_written[$OUT]:-0}" '
		BEGIN { inheader=1; inblock=0 }
		/^#!.*bash/ { next }
		inheader && /^set -euo pipefail/ {
			if (pf == 0) {
				print
				pf = 1
			}
			inheader=0
			next
		}
		inheader && NF==0 { next }
		inheader { next }
		/^set -euo pipefail/ { next }
		/^if \[\[ "\$\{BASH_SOURCE\[0\]\}" == "\$\{0\}" \]\]; then/ { inblock=1; next }
		inblock && /^\s*fi\s*$/ { inblock=0; next }
		inblock { next }
		{ print }
		' "$f" >> "$OUT"
		# Mark that pipefail is written for this output file
		pipefail_written[$OUT]=1
		echo -e "\n" >> "$OUT"
	done

	rm -f "$LIB_ROOT"/*.in_progress
	echo "All library files have been assembled in $LIB_ROOT/"
}

emit_section() {
	local section="$1"
	declare -n mapref="$2"
	local parent group arr parent_key id_num unique_id key

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

	parent_key=$(echo "$parent" | tr '[:lower:]' '[:upper:]' | cut -c1-3)
	group_counts["$parent_key"]=$(( ${group_counts["$parent_key"]:-0} + 1 ))
	id_num=$(printf "%03d" "${group_counts["$parent_key"]}")
	unique_id="${parent_key}${id_num}"

	mapref["unique_id"]="$unique_id"

	for key in "${!mapref[@]}"; do
		array_entries["$arr"]+=$'\n'"${arr}[${section},${key}]=\"${mapref[$key]}\""
	done
}


_process_confs() {
	local meta section key value
	while IFS= read -r meta; do
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
	done < <(find "$SRC_ROOT" -type f -name '*.conf')
}



_process_confs() {
	while IFS= read -r meta; do
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
	done < <(find "${SRC_DIRS[@]}" -type f -name '*.conf')
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

_conf_to_json() {
	find "$SRC_ROOT" -type f -name '*.conf' | while read -r conf; do
		# Extract section name
		section=$(awk '/^\[.*\]/ {gsub(/^\[|\]$/, "", $0); print $0; exit}' "$conf")

		# Build JSON object
		(
		echo "{"
		echo "\"module\": \"$section\""

		# Extract key-value pairs, handle multiple '=' properly
		grep -E '^[[:space:]]*[^#\[].*=' "$conf" | while read -r line; do
			# Split on first '=' only using bash parameter expansion
			key="${line%%=*}"
			value="${line#*=}"

			# Trim whitespace
			key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
			value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

			# Use jq to properly escape the value
			echo ",\"$key\": $(echo "$value" | jq -R .)"
		done
		echo "}"
		) | jq -s add  # Combine lines into single JSON object
	done | jq -s '
		# Nest by .parent, .group, .module as before
		reduce .[] as $item ({};
		.[$item.parent][$item.group][$item.module] = ($item | del(.parent, .group, .module))
		)
'
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
			_conf_to_json > "$LIB_ROOT/module_options.json"
			;;
		*)
			echo "Usage: $0 [consolidate|generate|all]"
			return 1
			;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG="${DEBUG:-}"
	consolidate_module "${1:-all}"
fi
