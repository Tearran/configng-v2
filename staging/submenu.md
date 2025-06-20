# submenu

```
submenu <help or module_name> [args...]
```

#### Options

| Option              | Description                                                      |
|---------------------|------------------------------------------------------------------|
| `help`, `-h`, `--help` | Show usage and options                                       |
| `<function_name>`   | Show interactive submenu for a module (see below)                |

- Presents an interactive menu for a given module function, based on its `help` output.
- Supports `dialog`, `whiptail`, or plain `read` (CLI) for user interaction.
- Expects the module function to support a `help` action that lists available actions.

---

#### Example

```bash
DIALOG=read  # or DIALOG=dialog or DIALOG=whiptail
submenu mymodule
```

If `mymodule help` outputs:
```
start   - Start the service
stop    - Stop the service
status  - Show service status
```
The submenu will present a menu with those options.
Selecting an option will call `mymodule <option>`.

---

## Help Output

```
Usage: submenu <command-or-module> [args...]
Commands:
	help            Show this help.
	<function_name> Show the interactive submenu for a module.
```

---

## Details

- Reads available actions from `<function_name> help` output.  
  Each option should be formatted as:  
  `action_name  - Description`
- Presents a menu using:
  - `dialog` if `DIALOG=dialog`
  - `whiptail` if `DIALOG=whiptail`
  - fallback to `read` CLI prompt (default)
- The user selects an action, which is then executed as `<function_name> <selected_action>`.
- Cancels gracefully if no valid selection is made or help output is missing.

---
