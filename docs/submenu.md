# submenu

```
submenu <function_name> [args...]
```

## Options

| Option                 | Description                       |
|------------------------|-----------------------------------|
| `help`, `-h`, `--help` | Show usage and help message       |

## Usage

```bash
submenu <function_name>
submenu --help
```

## Behavior

- Shows a menu of actions based on `<function_name> help` output (`action - Description` format)
- User selects an action; runs `<function_name> <action>`
- Uses `$DIALOG` for menu (`dialog`, `whiptail`, or terminal prompt)

## Notes

- Requires Bash 4+
- UI menus need `dialog` or `whiptail`
- Exits 0 on success, 1 if canceled or error
