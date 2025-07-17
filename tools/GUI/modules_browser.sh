#!/bin/bash

# Get absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set project root as the parent directory of SCRIPT_DIR
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Path to your JSON metadata file (relative to script location!)
JSON="$SCRIPT_DIR/modules_metadata.json"

# Check for jq and zenity
command -v jq >/dev/null 2>&1 || { zenity --error --text="jq is required. Install with: sudo apt install jq"; exit 1; }
command -v zenity >/dev/null 2>&1 || { echo "zenity is required. Install with: sudo apt install zenity"; exit 1; }

# Select category
categories=$(jq -r 'keys_unsorted[]' "$JSON")
category=$(echo "$categories" | zenity --list --title="Select Category" --column=Category)
[ -z "$category" ] && exit 0

# Select group
groups=$(jq -r --arg cat "$category" '.[$cat] | keys_unsorted[]' "$JSON")
group=$(echo "$groups" | zenity --list --title="Select Group" --column=Group)
[ -z "$group" ] && exit 0

# Select feature
features=$(jq -r --arg cat "$category" --arg grp "$group" '.[$cat][$grp] | keys_unsorted[]' "$JSON")
feature=$(echo "$features" | zenity --list --title="Select Feature" --column=Feature)
[ -z "$feature" ] && exit 0

# Get feature details
details=$(jq -r --arg cat "$category" --arg grp "$group" --arg feat "$feature" '.[$cat][$grp][$feat]' "$JSON" | jq)

# Show details
zenity --info --title="Feature Details" --width=600 --height=400 --text="<span font='monospace'>$(echo "$details" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</span>" --no-markup

exit 0
