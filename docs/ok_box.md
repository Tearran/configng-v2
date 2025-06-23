# ok_box

```
ok_box ["message"]
```

## Options

| Option                | Description                     |
|-----------------------|---------------------------------|
| `help`, `-h`, `--help`| Show usage and help message     |

## Usage

```bash
ok_box "Message from argument"
echo "Message from stdin" | ok_box
ok_box <<< "Message from here-string"
DIALOG=whiptail ok_box "Settings saved."
DIALOG=read ok_box "Continue?"
ok_box --help
```

## Behavior

- Uses `$DIALOG` to select backend (`whiptail`, `dialog`, or `read`; falls back to plain output)
- Accepts message as argument, stdin, or here-string
- Shows a message box or prompt, or prints message if no dialog available

## Notes

- Requires `whiptail` or `dialog` for GUI mode
- Works in scripts or interactively
- No temp files or exported variables
