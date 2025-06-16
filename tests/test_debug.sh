#!/bin/bash
set -euo pipefail

# debug - Armbian Config V3 test

#!/bin/bash
set -euo pipefail
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG=${DEBUG:-true}
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
	#source "$SCRIPT_DIR/debug.sh"
	source "$SCRIPT_DIR/../src/initialize/debug.sh"
	debug reset
	debug "Wait one second"
	sleep 1
	debug "Done"
	debug total
fi

