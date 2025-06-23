# input_box

```
input_box ["prompt"]
```

## Options

| Option                | Description                                |
|-----------------------|--------------------------------------------|
| `help`, `-h`, `--help`| Show usage and help message                |

## Usage

```bash
input_box "Prompt message"
echo "Enter value:" | input_box
input_box <<< "Prompt"
DIALOG=read input_box "Prompt with shell fallback"
input_box --help
```

## Behavior

- Uses the interface specified by `$DIALOG` (`whiptail`, `dialog`, or `read`).
- Prompt is taken from the first argument or stdin.
- Exits 0 on input, non-zero on cancel/error.

## Notes

- No exported variables or temp files.
- Requires `whiptail` or `dialog` for GUI mode, falls back to `read`.
