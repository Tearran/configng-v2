#!/bin/bash
set -euo pipefail

# debug - Armbian Config V3 test

#!/bin/bash
set -euo pipefail
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG=${DEBUG:-true}
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

	# Source the debug.sh file from the correct location
	if [[ -f "$SCRIPT_DIR/../src/initialize/debug.sh" ]]; then
		source "$SCRIPT_DIR/../src/initialize/debug.sh"
	elif [[ -f "$SCRIPT_DIR/debug.sh" ]]; then
		source "$SCRIPT_DIR/debug.sh"
	else
		echo "Error: Could not find debug.sh file"
		echo "Searched in: $SCRIPT_DIR/../src/initialize/debug.sh and $SCRIPT_DIR/debug.sh"
		exit 1
	fi
fi

