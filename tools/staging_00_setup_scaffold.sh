#!/bin/bash
set -euo pipefail

# Basic usage: ./staging_files.sh <module_name>
# Example: ./staging_files.sh my_new_module


STAGING_DIR="./staging"


if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <module_name>"
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
description=\${description:-}
extend_disc=\${extend_disc:-false}
documents=\${documents:-false}
options=\${options:-}
parent=\${parent:-system}
group=\${group:-managers}
contributor=\${contributor:-}
maintainer=\${maintainer:-false}
arch=\${arch:-"arm64 armhf x86-64"}
require_os=\${require_os:-"Debian Ubuntu"}
require_kernel=\${require_kernel:-5.15+}
port=\${port:-false}
EOF

# Output .sh module template inside ./staging
cat > "${STAGING_DIR}/${MODULE}.sh" <<EOF
#!/bin/bash
set -euo pipefail

# ${MODULE} - Armbian Config V3 module

${MODULE}() {
	# TODO: implement module logic
	echo "\${MODULE} - Armbian Config V3 test"
	echo "Scaffold test"
}

_about${MODULE}() {
	# TODO: implement standard help message
	echo "use: \${MODULE} - ..."
	echo "help - this message"
}

EOF

# Output .sh module template inside ./staging
cat > "${STAGING_DIR}/test_${MODULE}.sh" <<EOF
#!/bin/bash
set -euo pipefail

# ${MODULE} - Armbian Config V3 test

if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
	echo "\${MODULE} - Armbian Config V3 test"
	echo "# TODO: implement module logic"
	exit 1
fi

EOF

# Output .sh module template inside ./staging
cat > "${STAGING_DIR}/doc_${MODULE}.md" <<EOF
# ${MODULE} - Armbian Config V3 extra documents

EOF

echo -e "Staging: Complete\nScaffold for ${MODULE} can be found at ${STAGING_DIR}/."
