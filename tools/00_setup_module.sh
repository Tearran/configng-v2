#!/bin/bash
set -euo pipefail

_about_setup_module() {
	cat << EOF

usage: $0 <module_name>

Creates Armbian Config V3 module scaffolding in ./staging/

	<module_name>   Name of the new module (required).

Outputs:"
	- <module_name>.conf   Module metadata template
	- <module_name>.sh     Module Bash template
	- docs_<module_name>.md  Documentation stub

Example:"
	$0 mymodule"
EOF
}

setup_module() {

	STAGING_DIR="./staging"


	if [[ -z "$1" ]]; then
		echo "No argument provided"
		exit 1
	fi

	MODULE="$1"

	# Ensure ./staging exists
	if [[ ! -d "$STAGING_DIR" ]]; then
		mkdir -p "$STAGING_DIR"
	fi

	# Output .conf metadata template inside ./staging
	cat > "${STAGING_DIR}/${MODULE}.conf" <<EOF
# ${MODULE} - Armbian Config V3 metadata

[${MODULE}]
feature=${MODULE}
description=
extend_desc=false
documents=false
options=
parent=
group=
contributor=\${contributor:-}
maintainer=false
arch=arm64 armhf x86-64
require_os=Armbian Debian Ubuntu
require_kernel=5.15+
port=false
helpers=${helpers:-}

EOF

# Output .sh module template inside ./staging
	cat > "${STAGING_DIR}/${MODULE}.sh" <<EOF
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

# Output .sh module template inside ./staging
	cat > "${STAGING_DIR}/${MODULE}.md" <<EOF
# ${MODULE} - Armbian Config V3 extra documents

## TODO: EXTRA Documents about the feature.

EOF

	echo -e "Staging: Complete\nScaffold for ${MODULE} can be found at ${STAGING_DIR}/."
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	foo="${1:-help}"
	if [[ $foo = "help" ]]; then
		_about_setup_module && exit 1
	else
		setup_module "$foo"
	fi
	unset foo
fi
