#!/usr/bin/env bash
set -euo pipefail

# Get absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set project root as the parent directory of SCRIPT_DIR
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$ROOT_DIR/lib/armbian-config"
SRC_ROOT="$ROOT_DIR/src"

_about_json2docs() {
		cat <<EOF

Usage: $0 <json-file> <template-html> <output-html>

Inject a JSON object into the Configng V2 HTML docs template.

Arguments:
	<json-file>      Path to the JSON object file (object only, no JS assignment)
	<template-html>  Path to the HTML template with JSON block markers
	<output-html>    Where to write the generated docs HTML

Example:
	$0 data/menu.json tools/main.html docs/modules-menu-simple-dark.html

Notes:
	- This does NOT overwrite your template or data file.
	- Injection replaces only the marked block, preserving everything else.
	- Intended for @Tearran/configng-v2 documentation and menu generation.

EOF
}

json2docs() {
	if [[ $# -ne 3 ]]; then
		echo "Error: Missing argument(s). See --help for usage." >&2
		return 1
	fi

	local JSON_FILE="$1"
	local TEMPLATE_FILE="$2"
	local OUT_FILE="$3"

	if [[ ! -f "$JSON_FILE" ]]; then
		echo "Error: JSON file '$JSON_FILE' not found." >&2
		return 2
	fi

	if [[ ! -f "$TEMPLATE_FILE" ]]; then
		echo "Error: Template HTML file '$TEMPLATE_FILE' not found." >&2
		return 3
	fi

	local NEW_JSON JS_ASSIGN
	NEW_JSON="$(cat "$JSON_FILE")"
	JS_ASSIGN=$'\tconst JSON_URL = '"$NEW_JSON"';'

	awk -v js="$JS_ASSIGN" '
	BEGIN {inblock=0}
	{
		if ($0 ~ /\/\/ ----- BEGIN: Easy-to-edit JSON/) {
			inblock=1
			print
			print js
			next
		}
		if ($0 ~ /\/\/ ----- END: Easy-to-edit JSON/) {
			inblock=0
			print
			next
		}
		if (!inblock) print
	}
	' "$TEMPLATE_FILE" > "$OUT_FILE"

	echo "Wrote output to $OUT_FILE"
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

web_docs(){
	case "${1:-}" in
		-h|--help|help)
			_about_json2docs
			;;
		*)
			_conf_to_json > $ROOT_DIR/docs/modules_metadata.json
			cp $ROOT_DIR/tools/index.html $ROOT_DIR/docs/index.html
			json2docs "${1:-$ROOT_DIR/docs/modules_metadata.json}" "${2:-$ROOT_DIR/tools/index.html}" "${3:-$ROOT_DIR/tools/uxgo/index.html}"
			echo "done"
			;;
	esac
}

web_docs "$@"
