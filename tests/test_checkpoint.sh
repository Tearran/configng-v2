#!/bin/bash
set -euo pipefail
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG=${DEBUG:-}
	UXMODE=${UXMODE:-}
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
	source "$SCRIPT_DIR/../src/initialize/checkpoint.sh"
	checkpoint reset
	checkpoint mark "Initializing script"
	sleep 1
	checkpoint mark "end script"
fi
