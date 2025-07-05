#!/usr/bin/env bash

DOC_ROOT="./docs"
SRC_ROOT="./src"

get_parent() {
	local conf="$1"
	grep -E '^parent=' "$conf" | head -n1 | cut -d= -f2- | xargs
}

get_group() {
	local conf="$1"
	grep -E '^group=' "$conf" | head -n1 | cut -d= -f2- | xargs
}

get_summary() {
	local md="$1"
	awk 'NR>1 && NF && $0 !~ /^#/' "$md" | head -n1
}

find_modules() {
	find "$SRC_ROOT" -type f -name "*.sh" | sort
}


generate_docs_flat_index() {
	echo "# Module Documentation" > "$DOC_ROOT/INDEX.md"
	echo >> "$DOC_ROOT/INDEX.md"
	i=1
	for md in "$DOC_ROOT"/*.md; do
		[[ "$md" == "$DOC_ROOT/INDEX.md" ]] && continue
		mod_name="$(basename "$md" .md)"
		# Grab the first non-empty, non-header line as summary
		summary="$(awk 'NR>1 && NF && $0 !~ /^#/' "$md" | head -n1)"
		echo "${i}. [${mod_name}](./${mod_name}.md)${summary:+ — $summary}" >> "$DOC_ROOT/INDEX.md"
		((i++))
	done
}

generate_docs_index() {
	echo "# Module Documentation" > "$DOC_ROOT/README.md"
	echo >> "$DOC_ROOT/README.md"

	declare -A tree

	while IFS= read -r sh_file; do
		modname="$(basename "$sh_file" .sh)"
		conf_file="$(dirname "$sh_file")/${modname}.conf"
		md_file="${modname}.md"
		parent="NoParent"
		group="Ungrouped"
		if [[ -f "$conf_file" ]]; then
			p="$(get_parent "$conf_file")"
			[[ -n "$p" ]] && parent="$p"
			g="$(get_group "$conf_file")"
			[[ -n "$g" ]] && group="$g"
		fi
		tree["$parent|$group"]+="${tree[$parent|$group]:+$'\n'}${modname}|$md_file"
	done < <(find_modules)

	# Sorted unique parents
	mapfile -t parents < <(for k in "${!tree[@]}"; do echo "${k%%|*}"; done | sort -u)
	for parent in "${parents[@]}"; do
		echo "## $parent" >> "$DOC_ROOT/README.md"
		# Sorted unique groups under parent
		mapfile -t groups < <(for k in "${!tree[@]}"; do [[ "${k%%|*}" == "$parent" ]] && echo "${k#*|}"; done | sort -u)
		for group in "${groups[@]}"; do
			echo "- $group" >> "$DOC_ROOT/README.md"
			key="${parent}|${group}"
			while IFS='|' read -r mod_name md_file; do
				[[ -z "$mod_name" ]] && continue
				md_path="./${md_file}"
				summary="$(get_summary "$DOC_ROOT/$md_file")"
				echo "    - [${mod_name}](${md_path})${summary:+ — $summary}" >> "$DOC_ROOT/README.md"
			done <<< "${tree[$key]}"
		done
		echo >> "$DOC_ROOT/README.md"
	done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	generate_docs_flat_index
	generate_docs_index

fi