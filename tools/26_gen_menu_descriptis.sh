#!/usr/bin/env bash

# Usage:
#   ./gen_options_descriptions.bash tools/parent_descriptions tools/group_descriptions

parse_descriptions() {
local ini_file="$1"
local array_name="$2"
local section=""
local description=""
local parent=""
while IFS= read -r line || [[ -n "$line" ]]; do
	line="${line%%#*}" # Remove comments
	line="${line#"${line%%[![:space:]]*}"}" # Trim leading
	line="${line%"${line##*[![:space:]]}"}" # Trim trailing
	[[ -z "$line" ]] && continue
	if [[ "$line" =~ ^\[(.+)\]$ ]]; then
		section="${BASH_REMATCH[1]}"
		description=""
		parent=""
	elif [[ "$line" =~ ^description=(.*)$ && -n "$section" ]]; then
		description="${BASH_REMATCH[1]}"
		description="${description#"${description%%[![:space:]]*}"}"
		description="${description%"${description##*[![:space:]]}"}"
		echo "${array_name}[${section},description]=\"${description}\""
	elif [[ "$line" =~ ^parent=(.*)$ && -n "$section" ]]; then
		parent="${BASH_REMATCH[1]}"
		parent="${parent#"${parent%%[![:space:]]*}"}"
		parent="${parent%"${parent##*[![:space:]]}"}"
		echo "${array_name}[${section},parent]=\"${parent}\""
	fi
done < "$ini_file"
}

{
	parse_descriptions "tools/parent_descriptions.conf" "parent_options"
	parse_descriptions "tools/group_descriptions.conf" "group_options"
} >> lib/armbian-config/module_options_arrays.sh