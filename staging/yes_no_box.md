# yes_no_box

```
yes_no_box ["message"]
```

## Options

| Option                 | Description                       |
|------------------------|-----------------------------------|
| `help`, `-h`, `--help` | Show usage and help message       |

## Usage

```bash
yes_no_box "Do you want to continue?"
echo "Apply settings now?" | yes_no_box
DIALOG=whiptail TITLE="Confirm" yes_no_box "Proceed?"
DIALOG=read yes_no_box "Continue?"
yes_no_box --help
```

## Behavior

- Uses `$DIALOG` to select backend (`whiptail`, `dialog`, or `read`)
- Message from argument or stdin
- Title set via `$TITLE` (optional)
- Returns 0 for Yes/OK, 1 for No/Cancel, 2 for missing message, 3 if `DIALOG` unset, 4 for unknown backend

## Notes

- Requires `whiptail` or `dialog` for GUI mode
- Fallbacks to shell input with `read` if set
- No external dependencies for `read` backend
- Suitable for Bash scripts and modules
