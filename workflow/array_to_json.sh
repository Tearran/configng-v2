#!/usr/bin/env bash

# ./array_to_json.sh - Armbian Config V2 module
# Outputs all parents as a single JSON object (legacy-compatible)
# The "command" field is a proper array (split on commas)
# If a parent or group description is missing, it will be marked as ***MISSING DESCRIPTION: [parent,group]***

array_to_json() {
	case "${1:-}" in
		help|-h|--help)
			_about_array_to_json
			;;
		*)
			_array_to_json_main | jq --indent 4 .
			;;
	esac
}
_array_to_json_main() {
	echo '{'
	echo '	"menu": ['

	first_parent=true
	for arrname in "${arrays[@]}"; do
		declare -n arr="$arrname"
		declare -A parents=()
		declare -A groups=()
		declare -A items=()

		for key in "${!arr[@]}"; do
			mod="${key%%,*}"
			parent="${arr[$mod,parent]}"
			group="${arr[$mod,group]}"
			feature="${arr[$mod,feature]}"
			[[ -z "$parent" || -z "$group" || -z "$feature" ]] && continue
			parents["$parent"]=1
			groups["$parent|$group"]=1
			items["$parent|$group|$feature"]=1
		done

		for parent in "${!parents[@]}"; do
			[[ -z "$parent" ]] && continue
			$first_parent || echo ','
			first_parent=false

			parent_desc="${arr[$parent,description]}"
			if [[ -z "$parent_desc" ]]; then
				parent_desc="***MISSING DESCRIPTION: Add [$parent] to [options] section in list_options.conf ***"
			fi

			echo "		{"
			echo "			\"id\": \"$parent\","
			echo "			\"description\": \"$parent_desc\","
			echo "			\"sub\": ["

			# Gather groups for this parent, sort for consistent output
			group_keys=()
			for k in "${!groups[@]}"; do
				p="${k%%|*}"
				grp="${k#*|}"
				[[ "$p" == "$parent" ]] && group_keys+=("$grp")
			done
			IFS=$'\n' sorted_groups=($(sort <<<"${group_keys[*]}"))
			unset IFS

			first_group=true
			for grp in "${sorted_groups[@]}"; do
				# If group name matches parent, output features directly (no group nesting)
				if [[ "$grp" == "$parent" ]]; then
					# Collect features for this direct group
					group_items=()
					for ik in "${!items[@]}"; do
						ip="${ik%%|*}"
						rest="${ik#*|}"
						ig="${rest%%|*}"
						ifeature="${rest#*|}"
						[[ "$ip" != "$parent" ]] && continue
						[[ "$ig" != "$grp" ]] && continue
						group_items+=("$ik")
					done
					IFS=$'\n' sorted_group_items=($(sort <<<"${group_items[*]}"))
					unset IFS
					group_idx=1
					for ik in "${sorted_group_items[@]}"; do
						$first_group || echo ','
						first_group=false
						mod="${ik##*|}"
						group_prefix="$(echo "${grp:0:3}" | tr '[:lower:]' '[:upper:]')"
						feature_id="$(printf "%s%03d" "$group_prefix" "$group_idx")"
						group_idx=$((group_idx + 1))

						# Command array
						cmds="${arr[$mod,command]}"
						IFS=',' read -ra cmd_array <<< "$cmds"
						cmd_json=""
						for idx in "${!cmd_array[@]}"; do
							c="$(echo "${cmd_array[$idx]}" | xargs)"
							[ $idx -gt 0 ] && cmd_json+=", "
							cmd_json+="\"$c\""
						done

						cat <<EOF
				{
					"id": "$feature_id",
					"feature": "${arr[$mod,feature]}",
					"description": "${arr[$mod,description]}",
					"options": "${arr[$mod,options]}",
					"author": "${arr[$mod,contributor]}",
					"arch": "${arr[$mod,arch]}",
					"require_os": "${arr[$mod,require_os]}",
					"require_kernel": "${arr[$mod,require_kernel]}",
					"status": "Stable",
					"helpers": "${arr[$mod,helpers]}",
					"about": "${arr[$mod,extend_desc]}",
					"condition": "${arr[$mod,condition]}",
					"command": [
						$cmd_json
					]
				}
EOF
					done
					continue
				fi

				# Otherwise, emit group as normal
				$first_group || echo ','
				first_group=false

				group_desc="${arr[$parent,$grp]}"
				if [[ -z "$group_desc" ]]; then
					group_desc="***MISSING DESCRIPTION: Add $grp to [$parent] section in list_options.conf ***"
				fi

				echo "				{"
				echo "					\"id\": \"$grp\","
				echo "					\"description\": \"$group_desc\","
				echo "					\"sub\": ["

				# Features for this group
				group_items=()
				for ik in "${!items[@]}"; do
					ip="${ik%%|*}"
					rest="${ik#*|}"
					ig="${rest%%|*}"
					ifeature="${rest#*|}"
					[[ "$ip" != "$parent" ]] && continue
					[[ "$ig" != "$grp" ]] && continue
					group_items+=("$ik")
				done
				IFS=$'\n' sorted_group_items=($(sort <<<"${group_items[*]}"))
				unset IFS
				group_idx=1
				first_mod=true
				for ik in "${sorted_group_items[@]}"; do
					$first_mod || echo ','
					first_mod=false
					mod="${ik##*|}"
					group_prefix="$(echo "${grp:0:3}" | tr '[:lower:]' '[:upper:]')"
					feature_id="$(printf "%s%03d" "$group_prefix" "$group_idx")"
					group_idx=$((group_idx + 1))

					# Command array
					cmds="${arr[$mod,command]}"
					IFS=',' read -ra cmd_array <<< "$cmds"
					cmd_json=""
					for idx in "${!cmd_array[@]}"; do
						c="$(echo "${cmd_array[$idx]}" | xargs)"
						[ $idx -gt 0 ] && cmd_json+=", "
						cmd_json+="\"$c\""
					done

					cat <<EOF
						{
							"id": "$feature_id",
							"feature": "${arr[$mod,feature]}",
							"description": "${arr[$mod,description]}",
							"options": "${arr[$mod,options]}",
							"author": "${arr[$mod,contributor]}",
							"arch": "${arr[$mod,arch]}",
							"require_os": "${arr[$mod,require_os]}",
							"require_kernel": "${arr[$mod,require_kernel]}",
							"status": "Stable",
							"helpers": "${arr[$mod,helpers]}",
							"about": "${arr[$mod,extend_desc]}",
							"condition": "${arr[$mod,condition]}",
							"command": [
								$cmd_json
							]
						}
EOF
				done

				echo "					]"
				echo "				}"
			done

			echo "			]"
			echo "		}"
		done
	done

	echo '	]'
	echo '}'
}

_about_array_to_json() {
	cat <<EOF
Usage: array_to_json <command> [options]

Commands:
	test        - Run a basic test of the array_to_json module
	foo         - Example 'foo' operation (replace with real command)
	bar         - Example 'bar' operation (replace with real command)
	help        - Show this help message

Examples:
	# Run the test operation
	array_to_json test

	# Perform the foo operation with an argument
	array_to_json foo arg1

	# Show help
	array_to_json help

Notes:
	- Replace 'foo' and 'bar' with real commands for your module.
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}

### START ./array_to_json.sh - Armbian Config V2 test entrypoint

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

	# Set project root as the parent directory of SCRIPT_DIR
	ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
	LIB_DIR="$ROOT_DIR/lib/armbian-config"
	SRC_ROOT="$ROOT_DIR/src"

	arrays=(system_options network_options software_options)

	source "$ROOT_DIR/lib/armbian-config/module_options_arrays.sh"

	array_to_json | jq --indent 4 . > "$ROOT_DIR/lib/armbian-config/config.jobs.json"
	cp "$ROOT_DIR/lib/armbian-config/config.jobs.json" "$ROOT_DIR/modules_browsers/modules_metadata.json"
	cp "$ROOT_DIR/lib/armbian-config/config.jobs.json" "$ROOT_DIR/docs/modules_metadata.json"
fi

### END ./array_to_json.sh - Armbian Config V2 test entrypoint
