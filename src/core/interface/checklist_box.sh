#!/usr/bin/env bash
set -euo pipefail

_about_checklist_box() {
	cat <<EOF
Usage: checklist_box [<columnar message>]
Show an interactive ON/OFF checklist from columnar text.

Examples:
	adjust_motd show | checklist_box
	echo -e "clear\tClear the MOTD screen\tOFF\nheader\tSystem banner & version\tON" | checklist_box

Input format:
	Item       Description                    Status
	--------   ------------------------------ ------
	clear      Clear the MOTD screen          OFF
	header     System banner & version        ON
	sysinfo    System info (load, CPU, memory) ON
	tips       Random Armbian tips            OFF
	commands   Suggested Armbian commands     ON

Notes:
	- Use with output of adjust_motd show or similar modules.
	- Status must be ON or OFF (uppercase, third column).
	- Outputs selected items as a space-separated list.
EOF
}

checklist_box() {
	# Show help if requested
	if [[ "${1:-}" == "help" || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
		_about_checklist_box
		return 0
	fi

	# Read from stdin or from argument (if not a file)
	local input
	if [[ -t 0 && -n "${1:-}" && ! -f "$1" ]]; then
		input="$1"
	else
		input="$(cat)"
	fi

	local items=()
	while IFS= read -r line; do
		# Skip header and empty lines
		[[ "$line" =~ ^(Item|--------|[[:space:]]*$) ]] && continue
		# Parse columns: item, description, status
		# Use awk for robust column splitting
		local item desc status
		item=$(echo "$line" | awk '{print $1}')
		desc=$(echo "$line" | awk '{$1=""; $NF=""; print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
		status=$(echo "$line" | awk '{print $NF}')
		[[ -n "$item" && -n "$desc" && "$status" =~ ^(ON|OFF)$ ]] || continue
		items+=("$item" "$desc" "$status")
	done <<< "$input"

	if [[ ${#items[@]} -eq 0 ]]; then
		echo "No valid checklist items found." >&2
		return 2
	fi

	local selected=""
	case "${DIALOG:-whiptail}" in
		dialog)
			selected=$(dialog --title "${TITLE:-Checklist}" --checklist \
				"Choose items to enable/disable:" 20 60 10 \
				"${items[@]}" 2>&1 >/dev/tty)
			;;
		whiptail)
			selected=$(whiptail --title "${TITLE:-Checklist}" --checklist \
				"Choose items to enable/disable:" 20 60 10 \
				"${items[@]}" 3>&1 1>&2 2>&3)
			;;
		read)
			echo "Available items:"
			for ((i=0;i<${#items[@]};i+=3)); do
				printf "%2d. %s [%s]\n" $((i/3+1)) "${items[i+1]}" "${items[i+2]}"
			done
			local choices
			read -p "Enter numbers to select (space/comma, empty to cancel): " choices < /dev/tty
			[[ -z "$choices" ]] && echo "Canceled." && return 1
			selected=""
			for idx in $choices; do
				idx=$((idx-1))
				[[ $idx -ge 0 && $((idx*3)) -lt ${#items[@]} ]] && selected+=" ${items[idx*3]}"
			done
			;;
		*)
			echo "Error: Unknown dialog backend: $DIALOG" >&2
			return 3
			;;
	esac

	# Output selected items (space-separated)
	if [[ -n "${selected// /}" ]]; then
		echo "$selected"
	else
		echo "No items selected."
		return 1
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	# Get absolute path to the directory containing this script
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	# Set project root as the parent directory of SCRIPT_DIR
	ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
	DIALOG="${DIALOG:-whiptail}"
	TITLE="${TITLE:-Checklist}"
	source $ROOT_DIR/src/system/login/adjust_motd.sh
	listing=$(adjust_motd show)
	checklist_box "$listing"
fi
