#!/usr/bin/env bash
set -euo pipefail

# service - Armbian Config V2 module

# src path: src/software/internal/service.sh

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

# service - Armbian Config V2 Test

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	source lib/armbian-config/core.sh
	submenu service
fi
