#!/bin/bash
set -euo pipefail
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DEBUG=${DEBUG:-}
	UXMODE=${UXMODE:-}
	. src/initialize/checkpoint.sh
	checkpoint reset
	checkpoint mark "Initializing script"
	sleep 1
	checkpoint mark "end script"
fi
