# Submenu Helper Script

This script provides an interactive menu for Bash functions that support a `help` command.

---

## Usage

```sh
submenu <function_name> [args...]
```

- Shows a menu of actions based on `<function_name> help` output (format: `action - Description`).
- User selects an action; that action is called as `<function_name> <action>`.

Menu interface is chosen with the `DIALOG` environment variable (`dialog`, `whiptail`, or default terminal prompt).

---

## Requirements

- Bash 4.x+
- Optional: `dialog` or `whiptail` for GUI menus


---

## Exit Codes

- `0` Success
- `1` Canceled or error

---