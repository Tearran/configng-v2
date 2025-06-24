# list_options - Configng V2 extra documents

```
list_options <command>
```

## Commands

| Command    | Description                                |
|------------|--------------------------------------------|
| core       | List core module options and features       |
| software   | List software module options and features   |
| network    | List network module options and features    |
| help       | Show help message and available commands    |
| --help     | Show help message and available commands    |
| -h         | Show help message and available commands    |
| (empty)    | Show help message and available commands    |

## Usage

```bash
list_options <command>
```
Examples:
```bash
list_options core
list_options software
list_options network
list_options help
```

## Behavior

- Displays a numbered summary of available features and options for config-ng modules.
- Shows example usage for each option group.
- When called with no argument or a help flag, prints a help message describing available commands.
- When called with `core`, `software`, or `network`, lists those specific group options using data from module arrays.

## Notes

- Requires the arrays file at `../lib/armbian-config/module_options_arrays.sh`.
- Intended for use as a configng-v2 module or as a standalone script.
- Output is formatted for readability in the terminal.
- Handles missing or unknown commands gracefully by showing the help message.
