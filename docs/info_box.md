# info_box

```
info_box
```

## Options

| Option                | Description                     |
|-----------------------|---------------------------------|
| `help`, `-h`, `--help`| Show usage and help message     |

## Usage

```bash
echo "Hello, world!" | info_box
long_running_command | info_box
info_box <<< "Single static message"
info_box "Another message"
info_box --help
```

## Behavior

- Uses `$DIALOG` for UI (`whiptail` or `dialog`, default: `whiptail`)
- Title set via `$TITLE` (default: "Info")
- Rolling buffer (up to 18 lines), live updates if piped
- Uses `TERM=ansi` for compatibility

## Notes

- Requires `dialog` or `whiptail`
- For TUI Bash scripts/modules
- Suitable for live log display or single messages
