# info_box

```
info_box
```

#### Options

| Option              | Description                                                |
|---------------------|------------------------------------------------------------|
| `-h`, `--help`, `help`  | Show usage and help message                        |

#### Usage

```bash
echo "Hello, world!" | info_box
long_running_command | info_box
info_box <<< "Single static message"
info_box "Another message"
info_box -h
```

#### Behavior

- **Dialog system:**  
  Uses the interface specified by `$DIALOG` (`dialog` or `whiptail`). Defaults to `whiptail` if not set.
- **Title:**  
  Set the title with the `$TITLE` environment variable (default: `"Info"`).
- **Buffer:**  
  Maintains a rolling buffer (up to 18 lines) for live updates.
- **Terminal:**  
  Uses `TERM=ansi` for compatibility with dialog/whiptail.

#### Example

```bash
# Live rolling output
for i in {1..10}; do
	echo "Line $i"
	sleep 1
done | info_box

# Static message
info_box "Operation complete"

# Show help
info_box --help
```

#### Help Output

```
Usage: info_box

Displays a rolling info box using dialog/whiptail.
Reads lines from stdin and displays them live.
If not used with a pipe, shows a single message.

Examples:

	echo <"string" or command> | info_box
	info_box <<< command or strings
	info_box -h --help help
```

#### Notes

- Requires `dialog` or `whiptail` installed.
- Designed for use in TUI (text user interface) Bash scripts and modules.
- Suitable for both rolling log display and one-shot informational notifications.