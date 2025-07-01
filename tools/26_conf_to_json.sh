#!/usr/bin/env bash

# This script is maintained by the project/entity/assistant. You only test and report bugs.
# If it doesn't work or doesn't match the design, it's on us (Copilot/assistant), not you.

SRC_ROOT="./src"
OUT_JSON="./lib/armbian-config/modules.json"

shopt -s globstar nullglob

conf_files=("$SRC_ROOT"/**/*.conf)
if [ ${#conf_files[@]} -eq 0 ]; then
	echo "No .conf files found in $SRC_ROOT. Aborting."
	exit 1
fi

tmp_out="$(mktemp)"
echo "{" > "$tmp_out"

declare -A nest
parents_groups=()

for conf in "${conf_files[@]}"; do
	unset parent group unique_id
	declare -A f
	while IFS='=' read -r key val; do
		[[ -z "$key" || "$key" =~ ^# || "$key" =~ ^\[ ]] && continue
		key="${key// /}"
		val="$(echo "$val" | xargs)"
		f["$key"]="$val"
	done < "$conf"

	parent="${f[parent]}"
	group="${f[group]}"
	unique_id="${f[unique_id]}"

	# Build JSON for this module
	module_json="{"
	first=1
	for k in "${!f[@]}"; do
		v="${f[$k]}"
		# Treat these keys as always string, even if they contain spaces
		if [[ "$k" =~ ^(description|extend_desc|extend_disc|extend_description|long_desc|long_description)$ ]]; then
			v="${v//\\/\\\\}"
			v="${v//\"/\\\"}"
			entry="\"$k\": \"$v\""
		# Booleans
		elif [[ "$v" == "true" || "$v" == "false" ]]; then
			entry="\"$k\": $v"
		# Array: space-separated (except exceptions above)
		elif [[ "$v" =~ [[:space:]] ]]; then
			arr="["
			for item in $v; do
				item="${item//\\/\\\\}"
				item="${item//\"/\\\"}"
				arr="$arr\"$item\", "
			done
			arr="${arr%, }]"
			entry="\"$k\": $arr"
		else
			v="${v//\\/\\\\}"
			v="${v//\"/\\\"}"
			entry="\"$k\": \"$v\""
		fi
		(( first )) && first=0 || module_json+=", "
		module_json+="$entry"
	done
	module_json+="}"

	# Remember combos for output order
	key="$parent::$group"
	if [[ ! " ${parents_groups[*]} " =~ " $key " ]]; then
		parents_groups+=("$key")
	fi
	# Save module JSON in a temp associative array
	nest["$parent::$group::$unique_id"]="$module_json"
done

# Output nested JSON
firstp=1
for pg in "${parents_groups[@]}"; do
	parent="${pg%%::*}"
	group="${pg#*::}"
	(( firstp )) && firstp=0 || echo "," >> "$tmp_out"
	echo -n "\"$parent\": {" >> "$tmp_out"
	echo -n "\"$group\": {" >> "$tmp_out"
	firstid=1
	for key in "${!nest[@]}"; do
		[[ "$key" == "$parent::$group"* ]] || continue
		unique_id="${key##*::}"
		(( firstid )) && firstid=0 || echo "," >> "$tmp_out"
		echo -n "\"$unique_id\": ${nest[$key]}" >> "$tmp_out"
	done
	echo -n "}" >> "$tmp_out"
	echo -n "}" >> "$tmp_out"
done

echo "}" >> "$tmp_out"
jq . "$tmp_out" > "$OUT_JSON" && rm "$tmp_out"
echo "Wrote $OUT_JSON"