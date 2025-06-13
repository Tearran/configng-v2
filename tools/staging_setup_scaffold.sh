#!/bin/bash

# Basic usage: ./staging_files.sh <module_name>
# Example: ./staging_files.sh my_new_module

set -e

STAGING_DIR="./staging"

if [[ -z "$1" ]]; then
  echo "Usage: $0 <module_name>"
  exit 1
fi

MODULE="$1"

# Ensure ./staging exists
if [[ ! -d "$STAGING_DIR" ]]; then
  mkdir -p "$STAGING_DIR"
fi

# Output .meta template inside ./staging
cat > "${STAGING_DIR}/meta${MODULE}.conf" <<EOF
# Armbian ConfigNG module metadata

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
cat > "${STAGING_DIR}/src_${MODULE}.sh" <<EOF
#!/bin/bash
# ${MODULE}.sh - Armbian ConfigNG module

${MODULE}() {
  # TODO: implement module logic
  echo "Module '${MODULE}' called"
}
EOF

# Output .sh module template inside ./staging
cat > "${STAGING_DIR}/test_${MODULE}.sh" <<EOF
#!/bin/bash
# ${MODULE}.sh - Armbian ConfigNG module

${MODULE}() {
  # TODO: implement module logic
  echo "Module '${MODULE}' called"
}
EOF

echo "Generated: ${STAGING_DIR}/${MODULE}.meta and ${STAGING_DIR}/${MODULE}.sh"
