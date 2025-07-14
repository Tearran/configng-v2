#!/bin/bash

conf_to_json() {
	find ./src -type f -name '*.conf' | while read -r conf; do
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	conf_to_json > "${1:-./lib/armbian-config/module_options.json}"
fi