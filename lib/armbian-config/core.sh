
####### ./src/core/initialize/list_options.sh #######
set -euo pipefail

# Merge multiple associative arrays into global module_options
_merge_list_options() {
	for array_name in "$@"; do
		local -n src="$array_name"
		for key in "${!src[@]}"; do
			module_options["$key"]="${src[$key]}"
		done
	done
}

# List options from a given associative array with neat formatting
list_module_options() {
	local -n arr="$1"

	local prog_name
	prog_name="$(basename "$0")"

	echo -e "Usage: ${prog_name} [options]\n"

	local modules=()
	for key in "${!arr[@]}"; do
		if [[ $key =~ ^([^,]+),feature$ ]]; then
			modules+=("${BASH_REMATCH[1]}")
		fi
	done

	IFS=$'\n' sorted=($(sort <<<"${modules[*]}"))
	unset IFS

	for mod in "${sorted[@]}"; do
		local uid="${arr[$mod,unique_id]:-NOID}"
		local desc="${arr[$mod,description]:-No description}"
		local feature="${arr[$mod,feature]:-command}"
		local options="${arr[$mod,options]:-}"

		echo -e "${uid} - ${desc}\n\t${feature} ${options}\n"
	done
}

# Dispatch listing based on group name, defaulting to main group
list_options() {
	case "${1:-main}" in
		main|"")
			list_module_options module_options
		;;
		core|software|network|system)
			list_module_options "${1}_options"
		;;
		help|--help|-h)
			_about_list_options
		;;
		*)
			echo "Unrecognized option group: $1"
			echo
			_about_list_options
			exit 1
		;;
	esac
}

# Help text for list_options usage
_about_list_options() {
	cat <<EOF
Usage: list_options [group]

commands:
	main      - All modules (default)
	core      - Core helpers and interface tools
	system    - System utilities and login helpers
	software  - Software install and management modules
	network   - Network management modules
	help      - Show this help message

Examples:
	# List all available modules
	list_options

	# List core option modules
	list_options core

	# Show help
	list_options help

Notes:
	- Use 'help', '--help', or '-h' to display this message.
	- Output is generated live from module metadata arrays.
	- For more details, see each module's _about_ function or README.
	- Intended for use with config-ng menu and scripting.
	- Keep this help message up to date if group names or commands change.
EOF
}







####### ./src/core/initialize/trace.sh #######


trace() {
	local cmd="${1:-}" msg="${2:-}"
	case "$cmd" in
		help)
			_about_trace
			;;
		reset)
			_trace_start=$(date +%s)
			_trace_time=$_trace_start
			;;
		total)
			if [[ -n "${TRACE:-}" ]]; then
				_trace_time=${_trace_start:-$(date +%s)}
				trace "TOTAL time elapsed"
			fi
			trace reset
			;;
		*)
			if [[ -n "${TRACE:-}" ]]; then
				local now elapsed
				now=$(date +%s)
				: "${_trace_time:=$now}"  # Initialize if unset
				elapsed=$((now - _trace_time))
				printf "%-30s %4d sec\n" "$cmd" "$elapsed"
				_trace_time=$now
			fi
			;;
	esac
}

_about_trace() {
	cat <<EOF
Usage: trace <option> | <"message string">

Options:
	help               Show this help message
	"message string"   Show trace message (if TRACE is set)
	reset              (Re)set starting point for timing
	total              Show total time since reset, then reset

Examples:
	# Start a new timing session
	trace reset

	# Print elapsed time with a message
	trace "Step 1 complete"

	# Show total elapsed time and reset
	trace total

Notes:
	- When TRACE is set (e.g., TRACE="true"), trace outputs timing info.
	- Elapsed time is shown since last trace call.
	- Intended for use in config-ng modules and scripting.
	- Keep this help message in sync with available options.

For more info, see this file or related README in ./lib/.
EOF
}







####### ./src/core/interface/input_box.sh #######

_about_input_box() {
	cat <<EOF
Usage: input_box ["prompt"]
Prompts the user for a line of input using whiptail, dialog, or shell fallback.

Examples:
	echo "Enter your name:" | input_box
	input_box <<< "Type your username:"
	input_box "What is your password?"

Pass "help" or "-h" as the prompt to see this help.
EOF
}

input_box() {
	local prompt reply code
	# Accept prompt from positional arg, stdin, or fallback
	if [[ -n "${1:-}" ]]; then
		prompt="$1"
	elif [ -p /dev/stdin ]; then
		prompt="$(cat)"
		# Strip leading/trailing whitespace
		prompt="${prompt#"${prompt%%[![:space:]]*}"}"
		prompt="${prompt%"${prompt##*[![:space:]]}"}"
	else
		echo "Error: No prompt provided." >&2
		_about_input_box
		return 1
	fi

	# Help
	if [[ "$prompt" == "help" ]] || [[ "$prompt" == "-h" ]]; then
		_about_input_box
		return 0
	fi

	case "${DIALOG:-}" in
		whiptail)
			reply=$(whiptail --title "${TITLE:-Input}" --inputbox "$prompt" 10 60 3>&1 1>&2 2>&3)
			code=$?
			;;
		dialog)
			reply=$(dialog --title "${TITLE:-Input}" --inputbox "$prompt" 10 60 3>&1 1>&2 2>&3)
			code=$?
			;;
		read)
			echo "$prompt"
			read -p "> " reply < /dev/tty
			code=0
			;;
		"")
			echo "Error: DIALOG variable not set" >&2
			return 3
			;;
		*)
			echo "Error: Unknown dialog backend: $DIALOG" >&2
			return 4
			;;
	esac

	if [[ $code -eq 0 ]]; then
		echo "$reply"
		return 0
	else
		return $code
	fi
}




####### ./src/core/interface/info_box.sh #######

_about_info_box() {
	cat <<EOF
Usage: info_box

Displays a rolling info box using dialog/whiptail.
Reads lines from stdin and displays them live.
If not used with a pipe, shows a single message.

Examples:

	echo <"string" or command> | info_box
	info_box <<< command or strings
	info_box -h --help help
EOF
}

info_box() {
	# Help flag: show about if -h or --help is the first argument
	case "${1:-}" in
		-h|--help|help)
			_about_info_box
			return 0
			;;
	esac

	local input
	local dialog="${DIALOG:-}"
	if [[ "$dialog" != "dialog" && "$dialog" != "whiptail" ]]; then
		dialog="whiptail"
	fi
	local title="${TITLE:-Info}"
	local -a buffer
	local lines=16 width=90 max_lines=18

	if [ -p /dev/stdin ]; then
		while IFS= read -r line; do
			buffer+=("$line")
			# Limit buffer size to max_lines
			((${#buffer[@]} > max_lines)) && buffer=("${buffer[@]:1}")
			# Show buffer in infobox
			TERM=ansi $dialog --title "$title" --infobox "$(printf "%s\n" "${buffer[@]}")" $lines $width
			sleep 0.5
		done
	else
		input="${1:-}"
		if [[ -z "$input" ]]; then
			echo "Error: No input provided." >&2
			_about_info_box
			return 1
		fi
		TERM=ansi $dialog --title "$title" --infobox "$input" 6 80
		sleep 2
	fi
	echo -ne '\033[3J' # clear the screen
}






####### ./src/core/interface/submenu.sh #######

# submenu - Menu dispatcher/helper for config-v3 modules
submenu() {
	local cmd="${1:-help}"
	shift || true

	case "$cmd" in
		help|-h|--help)
			_about_submenu
			;;
		*)
			_submenu "$cmd" "$@"
			;;
	esac
}

_about_submenu() {
	cat <<EOF
Usage: submenu <command>

Commands:
	<function_name>	- Show the interactive submenu for a module.
	help        - Show this help message

Examples:
	# Run the test operation
	submenu cockpit

	# Show help
	submenu help

Notes:
	- Replace 'foo' and 'bar' with real commands for your module.
	- All commands should accept '--help', '-h', or 'help' for details, if implemented.
	- Intended for use with the config-v2 menu and scripting.
	- Keep this help message up to date if commands change.

EOF
}


_submenu() {
	local function_name="${1:-}"
	shift || true

	if [[ -z "$function_name" ]]; then
		echo "No function specified for submenu."
		return 1
	fi

	local help_message
	help_message=$("$function_name" help 2>/dev/null || true)
	if [[ -z "$help_message" ]]; then
		echo "No help message from: $function_name"
		return 1
	fi

	local menu_items=()
	local item_keys=()
	while IFS= read -r line; do
		if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*-\s*(.*)$ ]]; then
			menu_items+=("${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}")
			item_keys+=("${BASH_REMATCH[1]}")
		fi
	done <<< "$help_message"

	local choice=""
	case "${DIALOG:-read}" in
		dialog)
			local dialog_options=()
			for ((i=0; i<${#item_keys[@]}; i++)); do
				dialog_options+=("${item_keys[i]}" "${menu_items[i]#*- }")
			done
			choice=$(dialog --title "${function_name^}" --menu "Choose an option:" 0 80 9 "${dialog_options[@]}" 2>&1 >/dev/tty)
			;;
		whiptail)
			local whiptail_options=()
			for ((i=0; i<${#item_keys[@]}; i++)); do
				whiptail_options+=("${item_keys[i]}" "${menu_items[i]#*- }")
			done
			choice=$(whiptail --title "${function_name^}" --menu "Choose an option:" 0 80 9 "${whiptail_options[@]}" 3>&1 1>&2 2>&3)
			;;
		read|*)
			echo "Available options:"
			echo "0. Cancel"
			for ((i=0; i<${#menu_items[@]}; i++)); do
				printf "%d. %s\n" "$((i + 1))" "${menu_items[i]}"
			done

			# $1 is the candidate menu index if provided, otherwise prompt
			if [[ "${1:-}" =~ ^[0-9]+$ ]] && (( $1 >= 0 && $1 <= ${#item_keys[@]} )); then
				choice_index="$1"
			else
				while true; do
					read -p "Enter choice number (or press Enter/0 to cancel): " choice_index
					if [[ -z "$choice_index" || "$choice_index" == "0" ]]; then
						echo "Menu canceled."
						return 1
					elif [[ "$choice_index" =~ ^[0-9]+$ ]] && (( choice_index >= 1 && choice_index <= ${#item_keys[@]} )); then
						break
					else
						echo "Invalid choice. Try again."
					fi
				done
			fi

			if [[ "$choice_index" == "0" ]]; then
				echo "Menu canceled."
				return 1
			fi

			choice="${item_keys[choice_index-1]}"
			;;
	esac

	if [[ -z "${choice:-}" ]]; then
		echo "Menu canceled."
		return 1
	fi

	"$function_name" "$choice"
}




####### ./src/core/interface/yes_no_box.sh #######

_about_yes_no_box() {
	cat <<EOF
Usage: yes_no_box ["message"]
Prompt the user for a Yes/No answer using whiptail, dialog, or shell.

Examples:
	echo "Proceed with install?" | yes_no_box
	yes_no_box <<< "Continue with upgrade?"
	yes_no_box "Are you sure you want to reboot?"

Pass "help" or "-h" as the message to show this help.
EOF
}

yes_no_box() {
	local message="${1:-$(cat)}"
	if [ "$message" = "help" ] || [ "$message" = "-h" ]; then
		_about_yes_no_box
		return 0
	fi
	if [ -z "$message" ]; then
		echo "Error: Missing message argument" >&2
		return 2
	fi

	case "$DIALOG" in
		whiptail)
			whiptail --title "$TITLE" --yesno "$message" 10 60
			return $?
			;;
		dialog)
			dialog --title "$TITLE" --yesno "$message" 10 60
			return $?
			;;
		read)
			echo "$message"
			read -p "[y/N]: " reply < /dev/tty
			if [ "${reply,,}" != "y" ]; then
				echo "Canceled."
				return 1
			fi
			return 0
			;;
		"") # DIALOG not set
			echo "Error: DIALOG variable not set" >&2
			return 3
			;;
		*)
			echo "Error: Unknown dialog backend: $DIALOG" >&2
			return 4
			;;
	esac
}





####### ./src/core/interface/ok_box.sh #######

_about_ok_box() {
	cat <<EOF
Usage: ok_box ["message"]
Examples:
	echo "Hello from stdin" | ok_box
	ok_box <<< "Message from here-string"
EOF

}

function ok_box() {
	# Read the input from the pipe
	local input="${1:-$(cat)}"
	TITLE="${TITLE:-}"


	if [ "$input" = "help" ] || [ "$input" = "-h" ]; then
		_about_ok_box
		return 0
	fi
	if [ -z "$input" ]; then
		echo "Error: Missing message argument" >&2
		return 2
	fi

	case "$DIALOG" in
	whiptail)
		whiptail --title "$TITLE" --msgbox "$input" 0 0
		;;
	dialog)
		dialog --title "$TITLE" --msgbox "$input" 0 0
		;;
	read)
		echo -e "$input"
		read -p "Press [Enter] to continue..." < /dev/tty
		;;
	*)
		echo -e "$input"
		;;
	esac
}




####### ./src/core/software/service.sh #######

# src/software/internal/service.sh

_srv_system_running() {
	[[ $(systemctl is-system-running) =~ ^(running|degraded)$ ]];
}


srv_active() {
	# fail inside container
	_srv_system_running && systemctl is-active --quiet "$@"
}


srv_daemon_reload() {
	# ignore inside container
	_srv_system_running && systemctl daemon-reload || true
}

srv_disable() {
	systemctl disable "$@";
}


srv_enable() {
	systemctl enable "$@";
}



srv_enabled() {
	systemctl is-enabled "$@";
}

srv_mask() {
	systemctl mask "$@";
}


srv_reload() {
	# ignore inside container
	_srv_system_running && systemctl reload "$@" || true
}


srv_restart() {
	# ignore inside container
	_srv_system_running && systemctl restart "$@" || true
}


srv_start() {
	# ignore inside container
	_srv_system_running && systemctl start "$@" || true
}


srv_status() {
	systemctl status "$@";
}


srv_stop() {
	# ignore inside container
	_srv_system_running && systemctl stop "$@" || true
}


srv_unmask() {
	systemctl unmask "$@";
}

service() {
	case "${1:-}" in
		active)         shift; srv_active "$@";;
		daemon-reload)  shift; srv_daemon_reload "$@";;
		disable)        shift; srv_disable "$@";;
		enable)         shift; srv_enable "$@";;
		enabled)        shift; srv_enabled "$@";;
		mask)           shift; srv_mask "$@";;
		reload)         shift; srv_reload "$@";;
		restart)        shift; srv_restart "$@";;
		start)          shift; srv_start "$@";;
		status)         shift; srv_status "$@";;
		stop)           shift; srv_stop "$@";;
		unmask)         shift; srv_unmask "$@";;
		help|-h|--help|"")
			_about_service
			;;
		*)
			echo "Unknown command: $1" >&2
			_about_service
			return 1
			;;
	esac
}

_about_service() {
	cat <<EOF
Usage: service <command> [service_name]

Commands:
	active <service>         - Test if the service is active (running)
	daemon-reload            - Reload systemd manager configuration
	disable <service>        - Disable the service (prevent start at boot)
	enable <service>         - Enable the service (start at boot)
	enabled <service>        - Test if the service is enabled
	mask <service>           - Mask the service (prevent all starts)
	reload <service>         - Reload the service (if supported)
	restart <service>        - Restart the service
	start <service>          - Start the service
	status <service>         - Show status for the service
	stop <service>           - Stop the service
	unmask <service>         - Unmask the service
	help                     - Show this help message

Examples:
	# Start the ssh service
	service start ssh

	# Check if ssh is enabled and print a message
	service enabled ssh && echo "ssh enabled"

Notes:
	- All commands should be run as root or with appropriate permissions.
	- 'active', 'enabled', and similar commands return 0 for true, nonzero for false.
	- Commands that alter services (start, stop, enable, etc.) will not execute inside containers if systemd is not running.
	- This module is intended for use with the config-v2 menu and scripts.
	- See systemctl(1) for additional options and details.
	- Keep this help message up to date if commands change.

EOF
}




####### ./src/core/software/package.sh #######

# src/software/internal/package.sh

# internal function
_pkg_have_stdin() { [[ -t 0 ]]; }


pkg_configure() {
	_pkg_have_stdin && debconf-apt-progress -- dpkg --configure "$@" || dpkg --configure "$@"
}


pkg_full_upgrade() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y full-upgrade "$@" || apt-get -y full-upgrade "$@"
}


pkg_install() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y install "$@" || apt-get -y install "$@"
}


pkg_installed() {
	local status
	status=$(dpkg -s "$1" 2>/dev/null | sed -n 's/Status: //p')
	! [[ -z "$status" || "$status" = *deinstall* || "$status" = *not-installed* ]]
}


pkg_remove() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y remove --purge --auto-remove "$@" \
		|| apt-get -y remove --purge --auto-remove "$@"
}


pkg_update() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y update || apt-get -y update
}


pkg_upgrade() {
	_pkg_have_stdin && debconf-apt-progress -- apt-get -y upgrade "$@" || apt-get -y upgrade "$@"
}

package() {
	case "${1:-}" in
		update)           shift; pkg_update "$@";;
		upgrade)          shift; pkg_upgrade "$@";;
		full-upgrade)     shift; pkg_full_upgrade "$@";;
		install)          shift; pkg_install "$@";;
		remove)           shift; pkg_remove "$@";;
		configure)        shift; pkg_configure "$@";;
		installed)        shift; pkg_installed "$@";;
		help|-h|--help|"")
			_about_package
			;;
		*)
			echo "Unknown command: $1" >&2
			_about_package
			return 1
			;;
	esac
}

_about_package() {
	cat <<EOF
Usage: package <command> [package_name(s)]

Commands:
	update             - Update APT package lists
	upgrade            - Upgrade all installed packages
	full-upgrade       - Perform a full system upgrade (may remove obsolete packages)
	install <pkgs>     - Install one or more packages
	remove <pkgs>      - Remove and autopurge one or more packages
	configure <pkgs>   - Configure unpacked but unconfigured packages
	installed <pkg>    - Test if a package is installed (returns 0 if present)
	help               - Show this help message

Examples:
	# Install nano
	package install nano

	# Check if nano is installed and print a message
	package installed nano && echo "nano is installed"

Notes:
	- All commands use apt and require root privileges.
	- 'installed' returns success (0) if the package is present, nonzero otherwise.
	- Use quotes for multiple package names: package install "pkg1 pkg2"
	- This module is intended for use with the config-v2 menu and scripts.
	- Keep this help message up to date if any commands change.

EOF
}



