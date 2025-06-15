#!/bin/bash
set -euo pipefail
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "${MODULE} - Armbian Config V3 test"
	echo "Scaffold test"
	exit 1
fi
