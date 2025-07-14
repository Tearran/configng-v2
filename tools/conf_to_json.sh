#!/bin/bash

conf_to_json() {
	find ./src -type f -name '*.conf' | while read -r conf; do
		section=$(awk '/^\[.*\]/ {gsub(/^\[|\]$/, "", $0); print $0; exit}' "$conf")
		awk -F= -v module="$section" '
			/^[[:space:]]*#/ { next }
			/^[[:space:]]*$/ { next }
			/^\[/ { next }
			/=/ {
				gsub(/^[ \t]+|[ \t]+$/, "", $1)
				gsub(/^[ \t]+|[ \t]+$/, "", $2)
				keys[$1] = $2
			}
			END {
				printf("{")
				printf("\"module\":\"%s\"", module)
				for (k in keys) printf(",\"%s\":\"%s\"", k, keys[k])
				printf("}\n")
			}
		' "$conf"
	done | jq -s '
	# for each object, use .parent, .group, .module for nesting
	reduce .[] as $item ({};
	.[$item.parent][$item.group][$item.module] = ($item | del(.parent, .group, .module))
	)
	'

}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	conf_to_json > ./lib/armbian-config/module_options.json
fi
