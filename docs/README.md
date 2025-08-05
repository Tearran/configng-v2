# Module Documentation

## core
- initialize
    - [list_options](./list_options.md) — Show available option groups and their usage for configng-v2 modules.
    - [trace](./trace.md) — Lightweight timing and trace message utility for Configng V2 modules.
    - [submenu](./submenu.md) — Parse a list_options message and present commands as an interactive menu.
- interface
    - [checklist_box](./checklist_box.md) — Show an interactive ON/OFF checklist from columnar text using dialog, whiptail, or a simple read fallback.
    - [info_box](./info_box.md) — Display a rolling info box with dialog/whiptail; reads and shows lines from stdin or a single message.
    - [input_box](./input_box.md) — Prompt the user for input using whiptail, dialog, or shell fallback; reads prompt from argument or stdin and prints result to stdout.
    - [menu](./menu.md) — Displays an interactive menu for module functions based on their help output.
    - [ok_box](./ok_box.md) — Displays a message to the user using the configured dialog tool.
    - [package](./package.md) — Helpers for bulk packages operations (install, remove, upgrade, etc.)
    - [service](./service.md) — Systemd service management helpers (start stop enable etc.)
    - [set_colors](./set_colors.md) — Set terminal and whiptail/dialog background colors.
    - [yes_no_box](./yes_no_box.md) — Portable Bash yes/no prompt function supporting whiptail, dialog, or simple shell read fallback.

## network
- network
    - [net_render](./net_render.md) — Set or check the current Netplan renderer (NetworkManager or networkd) for all interfaces.

## software
- management
    - [cockpit](./cockpit.md) — Web-based administrative interface for managing Linux servers.

## system
- kernel
    - [boot_kernel](./boot_kernel.md) — Manage, hold, unhold, and update kernel, bootloader (U-Boot), and related Armbian packages.
- user
    - [adjust_motd](./adjust_motd.md) — Adjust welcome screen (motd)

