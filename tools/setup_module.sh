#!/bin/bash
set -euo pipefail

_about_setup_module() {
	cat << EOF

usage: $0 <module_name>

Creates Armbian Config V3 module scaffolding in ./staging/

	<module_name>   Name of the new module (required).

Outputs:
	- <module_name>.conf    Module metadata template
	- <module_name>.sh      Module Bash template
	- <module_name>.md      Documentation stub

Example:
	$0 mymodule

EOF
}

_make_module() {
	local STAGING_DIR="${STAGING_DIR:-./staging}"
	local MODULE="${1:-}"

	# Validate module name
	if [[ -z "$MODULE" ]]; then
		echo "No argument provided"
		_about_setup_module
	fi
	if ! [[ "$MODULE" =~ ^[a-zA-Z0-9_]+$ ]]; then
		echo "Invalid module name: $MODULE"
		exit 1
	fi

	# Ensure ./staging exists
	if [[ ! -d "$STAGING_DIR" ]]; then
		mkdir -p "$STAGING_DIR"
	fi

	local created=0
	local skipped=0

	# .conf
	local conf="${STAGING_DIR}/${MODULE}.conf"
	if [[ -f "$conf" ]]; then
		echo "Skip: $conf already exists"
		skipped=$((skipped+1))
	else
		cat > "$conf" <<EOF
# ${MODULE} - Armbian Config V3 metadata

[${MODULE}]
feature=${MODULE}
description=
extend_desc=false
documents=false
options=
parent=
group=
contributor=
maintainer=false
arch=arm64 armhf x86-64
require_os=Armbian Debian Ubuntu
require_kernel=5.15+
port=false
helpers=   # Will list _*_${MODULE}() helpers when available
EOF
		echo "Created: $conf"
		created=$((created+1))
	fi

	# .sh
	local modsh="${STAGING_DIR}/${MODULE}.sh"
	if [[ -f "$modsh" ]]; then
		echo "Skip: $modsh already exists"
		skipped=$((skipped+1))
	else
		cat > "$modsh" <<EOF
#!/bin/bash
set -euo pipefail

# ${MODULE} - Armbian Config V3 module

${MODULE}() {
	# TODO: implement module logic
	echo "${MODULE} - Armbian Config V3 test"
	echo "Scaffold test"
}

_about_${MODULE}() {
	# TODO: implement standard help message
	echo "use: ${MODULE} - ..."
	echo "help - this message"
}

# ${MODULE} - Armbian Config V3 Test

if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
	echo "${MODULE} - Armbian Config V3 test"
	echo "# TODO: implement module logic"
	exit 1
fi

EOF
		echo "Created: $modsh"
		created=$((created+1))
	fi

	# .md
	local md="${STAGING_DIR}/${MODULE}.md"
	if [[ -f "$md" ]]; then
		echo "Skip: $md already exists"
		skipped=$((skipped+1))
	else
		cat > "$md" <<EOF
# ${MODULE} - Armbian Config V3 extra documents

## TODO: EXTRA Documents about the feature.

EOF
		echo "Created: $md"
		created=$((created+1))
	fi

	echo -e "Staging: Complete\nScaffold for ${MODULE} can be found at ${STAGING_DIR}/."
	echo "Created: $created, Skipped: $skipped"
}


setup_module() {
	local arg="${1:-help}"
	case "$arg" in
		help|--help|-h)
			_about_setup_module
			;;
		*)
			_make_module "$arg"
			;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	setup_module "${1:-help}"
fi
