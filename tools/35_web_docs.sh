#!/usr/bin/env bash
set -euo pipefail

# ./tools/json2docs.sh - Inject a JSON object into an HTML template for Configng V2 documentation.
#
# Usage:
#   ./tools/json2docs.sh <json-file> <template-html> <output-html>
#
# Example:
#   ./tools/json2docs.sh data/menu.json tools/main.html docs/modules-menu-simple-dark.html
#
# Reads <json-file> (object only), injects it as "const data = ..." between the
# "// ----- BEGIN: Easy-to-edit JSON (paste here to update) -----" and
# "// ----- END: Easy-to-edit JSON -----" block of <template-html>, and writes
# the result to <output-html>.
#
# The template is never overwritten. You can safely use this for docs builds.
#
# Options:
#   -h, --help    Show this help message and exit.

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
	JS_ASSIGN=$'\tconst data = '"$NEW_JSON"';'

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

case "${1:-}" in
	-h|--help|help)
		_about_json2docs
		;;
	*)
		json2docs "${1:-docs/modules_metadata.json}" "${2:-tools/main.html}" "${3:-docs/INDEX.html}"
		;;
esac
