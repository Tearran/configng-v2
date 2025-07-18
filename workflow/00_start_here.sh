#!/usr/bin/env bash
set -euo pipefail

# ./setup_module.sh - Scaffold generator for Configng V2 modules

_about_setup_module() {
	cat << EOF

Usage: $0 <module_name>

Creates Armbian Config V2 module scaffolding in ./staging/

	<module_name>   Name of the new module (required).

Outputs:
	- <module_name>.conf    Module metadata template
	- <module_name>.sh      Module Bash template
	- <module_name>.md      Documentation stub (deprecated)

Example:
	$0 mymodule

EOF
}

_template_conf() {
	local MODULE="$1"
	cat <<-EOF
		# ${MODULE} - Configng V2 metadata

		[${MODULE}]
		# Main feature provided by this module (usually the same as the module name).
		feature=${MODULE}

		# Short, single-line summary describing what this module does.
		description=

		# Longer description with more details about the module's features or usage.
		extend_desc=

		# Comma-separated list of commands supported by this module (e.g., help,status,reload).
		options=

		# Main category this module belongs to. Must be one of: network, system, software, locales.
		parent=

		# Group or tag for this module. See docs/readme.md (group index) for options.
		# If none fit, suggest a new group in your pull request.
		group=

		# Contributor's GitHub username (use @username).
		contributor=

		# Comma-separated list of supported CPU architectures.
		arch=

		# Comma-separated list of supported operating systems.
		require_os=

		# What kernel are you using? (minimum required version, e.g., 5.15+)
		require_kernel=

		# Comma-separated list of network ports used by this module (e.g., 8080,8443). Use 'false' if not applicable.
		port=false

		# Comma-separated list of functions in this module (all functions except the main feature).
		# NOTE: You must include the help message function _about_${MODULE}; validation will fail if it is missing.
		helpers=

		# List each command and its description below.
		# Example:
		# show=Display the current configuration
		[options]
		help=Show help for this module

EOF
}

_template_sh() {
	local MODULE="$1"
	cat <<EOH
#!/usr/bin/env bash
set -euo pipefail

# ./${MODULE}.sh - Armbian Config V2 module

${MODULE}() {
	case "\${1:-}" in
		help|-h|--help)
			_about_${MODULE}
			;;
		*)
			_${MODULE}_main
			;;
	esac
}

_${MODULE}_main() {
	# TODO: implement module logic
	echo "${MODULE} - Armbian Config V2 test"
	echo "Scaffold test"
}

_about_${MODULE}() {
	cat <<EOF
Usage: ${MODULE} <command> [options]

Commands:
	test        - Run a basic test of the ${MODULE} module
	foo         - Example 'foo' operation (replace with real command)
	bar         - Example 'bar' operation (replace with real command)
	help        - Show this help message

Examples:
	# Run the test operation
	${MODULE} test

	# Perform the foo operation with an argument
	${MODULE} foo arg1

	# Show help
	${MODULE} help

Notes:
	- Replace 'foo' and 'bar' with real commands for your module.
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}

### START ./${MODULE}.sh - Armbian Config V2 test entrypoint

if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
	# --- Capture and assert help output ---
	help_output="\$(${MODULE} help)"
	echo "\$help_output" | grep -q "Usage: ${MODULE}" || {
		echo "fail: Help output does not contain expected usage string"
		echo "test complete"
		exit 1
	}
	# --- end assertion ---
	${MODULE} "\$@"
fi

### END ./${MODULE}.sh - Armbian Config V2 test entrypoint

EOH
}

_template_md() {
	local MODULE="$1"
	cat <<EOF
# ${MODULE} - Configng V2 extra documents

\`\`\`
${MODULE} <command>
\`\`\`

## Commands

| Command    | Description              |
|------------|--------------------------|
|            |                          |

## Usage

\`\`\`bash
${MODULE} <command>
\`\`\`

## Behavior

- Describe what the module does here.

## Notes

- List requirements or integration notes.
- Intended for use as a configng-v2 module or standalone.
- Output is simple and command-oriented.

EOF
}

_make_module() {
	local STAGING_DIR="${STAGING_DIR:-./staging}"
	local MODULE="${1:-}"

	# Validate module name
	if [[ -z "$MODULE" ]]; then
		echo "No argument provided"
		_about_setup_module
		return 1
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
		_template_conf "$MODULE" > "$conf"
		echo "Created: $conf"
		created=$((created+1))
	fi

	# .sh
	local modsh="${STAGING_DIR}/${MODULE}.sh"
	if [[ -f "$modsh" ]]; then
		echo "Skip: $modsh already exists"
		skipped=$((skipped+1))
	else
		_template_sh "$MODULE" > "$modsh"
		echo "Created: $modsh"
		created=$((created+1))
	fi

	# .md is deprecated; call deprecating_md manually if needed.

	echo -e "Staging: Complete\nScaffold for ${MODULE} can be found at ${STAGING_DIR}/."
	echo "Created: $created, Skipped: $skipped"
}

deprecating_md() {
	# Deprecated: use only for legacy compatibility.
	local STAGING_DIR="${STAGING_DIR:-./staging}"
	local MODULE="${1:-}"
	local md="${STAGING_DIR}/${MODULE}.md"
	if [[ -f "$md" ]]; then
		echo "Skip: $md already exists"
	else
		_template_md "$MODULE" > "$md"
		echo "Created: $md"
	fi
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
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
	[[ "$1" != "help" ]] && "$ROOT_DIR/workflow/10_validate_module.sh" staging

fi
