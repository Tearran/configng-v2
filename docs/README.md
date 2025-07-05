# Module Documentation

## core
- initialize
    - [list_options](./list_options.md) — Show available option groups and their usage for configng-v2 modules.
    - [menu_from_options](./menu_from_options.md) — Parse a list_options message and present commands as an interactive menu.
    - [trace](./trace.md) — Lightweight timing and trace message for Armbian Config V3 modules.
- interface
    - [info_box](./info_box.md) — Display a rolling info box with dialog/whiptail; reads and shows lines from stdin or a single message.
    - [input_box](./input_box.md) — Prompt the user for input using whiptail, dialog, or shell fallback; reads prompt from argument or stdin and prints result to stdout.
    - [ok_box](./ok_box.md) — Displays a message to the user using the configured dialog tool.
    - [package](./package.md) — Helpers for bulk packages operations (install, remove, upgrade, etc.)
    - [submenu](./submenu.md) — Displays an interactive submenu for module functions based on their help output.
    - [yes_no_box](./yes_no_box.md) — Portable Bash yes/no prompt function supporting whiptail, dialog, or simple shell read fallback.

## network
- interface
    - [network_manager](./network_manager.md) — Minimal Netplan renderer switcher for configng-v2. Set or check the current Netplan renderer (NetworkManager or networkd) for all interfaces.

## software
- internal
    - [service](./service.md) — Systemd service management helpers (start stop enable etc.)
- user
    - [cockpit](./cockpit.md) — Web-based administrative interface for managing Linux servers.

## system
- login
    - [adjust_motd](./adjust_motd.md) — Adjust welcome screen (motd)

