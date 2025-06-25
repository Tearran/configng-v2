#!/usr/bin/env bash
set -euo pipefail

# service - Armbian Config V2 module

# service.sh

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

srv_mask() { systemctl mask "$@";
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
	# Standard help message (run `service help`)
	cat <<EOF

Usage: service <command> [service_name]

Commands:
	active         - Test if the service is active (running)
	daemon-reload  - Reload systemd manager configuration
	disable        - Disable service (prevent start at boot)
	enable         - Enable service (start at boot)
	enabled        - Test if the service is enabled
	mask           - Mask service (prevent all starts)
	reload         - Reload service (if supported)
	restart        - Restart service
	start          - Start service
	status         - Show status for service
	stop           - Stop service
	unmask         - Unmask service

Examples:
	service start ssh
	service enabled ssh && echo "ssh enabled"

EOF

}

# service - Armbian Config V2 Test

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "service - Armbian Config V2 test"
	_about_service
	exit 1
fi
