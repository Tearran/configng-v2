#!/usr/bin/env bash
set -euo pipefail

# configng_v2 - Armbian Config V2 module

configng_v2() {
	# TODO: implement module logic
	echo "configng_v2 - Armbian Config V2 test"
	echo "Scaffold test"
}

_about_configng_v2() {
	# TODO: implement standard help message
	echo "use: configng_v2 - ..."
	echo "help - this message"
}

# configng_v2 - Armbian Config V2 Test

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	SCRIPT_DIR="$(dirname "$0")"
	LIB_DIR="$SCRIPT_DIR/../lib/armbian-config"
	TOOLS_DIR="$SCRIPT_DIR/../tools"

	unset module_options
	declare -A core_options
	declare -A system_options
	declare -A network_options
	declare -A software_options
	declare -A module_options

	source "$LIB_DIR/core.sh" || exit 1
	source "$LIB_DIR/module_options_arrays.sh" || exit 1
	_merge_list_options system_options software_options network_options

	list_options main

fi

