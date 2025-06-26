#!/usr/bin/env bash
set -euo pipefail

#
# @description Toggle message of the day items
#
adjust_motd() {

	# show motd description
	motd_desc() {
		case $1 in
			clear)
				echo "Clear screen on login"
				;;
			header)
				echo "Show header with logo"
				;;
			sysinfo)
				echo "Display system information"
				;;
			tips)
				echo "Show Armbian team tips"
				;;
			commands)
				echo "Show recommended commands"
				;;
			*)
				echo "No description"
				;;
		esac
	}

	# read status
	motd_status() {
		source /etc/default/armbian-motd
		if [[ $MOTD_DISABLE == *$1* ]]; then
			echo "OFF"
		else
			echo "ON"
		fi
	}

	LIST=()
	for v in $(grep THIS_SCRIPT= /etc/update-motd.d/* | cut -d"=" -f2 | sed "s/\"//g"); do
		LIST+=("$v" "$(motd_desc $v)" "$(motd_status $v)")
	done

	INLIST=($(grep THIS_SCRIPT= /etc/update-motd.d/* | cut -d"=" -f2 | sed "s/\"//g"))
	CHOICES=$($DIALOG --separate-output --nocancel --title "Adjust welcome screen" --checklist "" 11 50 5 "${LIST[@]}" 3>&1 1>&2 2>&3)
	INSERT="$(echo "${INLIST[@]}" "${CHOICES[@]}" | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ' | sed 's/ *$//')"
	# adjust motd config
	sed -i "s/^MOTD_DISABLE=.*/MOTD_DISABLE=\"$INSERT\"/g" /etc/default/armbian-motd
	clear
	find /etc/update-motd.d/. -type f -executable | sort | bash
	echo "Press any key to return to armbian-config"
	read
}

_about_adjust_motd() {
	cat <<EOF
adjust_motd - Adjust Armbian's message of the day (MOTD)

Usage:
	adjust_motd [clear|header|sysinfo|tips|commands]

	clear     - Clear the screen on login
	header    - Show the header with the Armbian logo
	sysinfo   - Display basic system information
	tips      - Show Armbian team tips
	commands  - Show recommended commands

Examples:
	adjust_motd clear         # Toggle "clear screen on login"
	adjust_motd sysinfo       # Toggle "display system information"
	adjust_motd header tips   # Toggle multiple items at once

Configuration:
	MOTD settings are stored in /etc/default/armbian-motd and scripts in /etc/update-motd.d/.
	To apply changes immediately, the module will re-run the update scripts.

For more info, see: ../staging/adjust_motd.conf or the project README.

EOF

}

# adjust_motd - Armbian Config V2 Test

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	toggle="${1:-help}"
	adjust_motd "$toggle"
fi
