# ok_box

`ok_box` is a simple Bash function/script to display "OK" message dialogs using `whiptail`, `dialog`, or plain terminal output. It accepts messages from arguments, stdin, or here-strings, making it suitable for both interactive scripts and CLI tools.

## Features

- **Flexible display:** Uses `whiptail`, `dialog`, or a plain terminal prompt, depending on the `DIALOG` environment variable.
- **Input methods:** Accepts messages as arguments, via stdin, or from here-strings.
- **Safe for scripts:** Uses `set -euo pipefail` for robust error handling.
- **TTY-aware:** The "read" fallback works even when input is piped.

## Usage

### As a function

Source the file or define `ok_box` in your script.  
Call with a message as an argument, via stdin, or a here-string.

```bash
echo "Hello from stdin" | ok_box
ok_box <<< "Message from here-string"
```

### As a script

If run directly, the script demonstrates all dialog modes:

```bash
./ok_box
```

## Dialog Modes

Set the `DIALOG` environment variable to select the dialog backend:

- `whiptail`: Shows a whiptail message box.
- `dialog`: Shows a dialog message box.
- `read`: Prints the message and prompts for [Enter].
- *(any other value or unset)*: Prints the message only.

Example:

```bash
DIALOG="whiptail" ok_box "Your settings have been saved."
DIALOG="dialog" echo "Task finished" | ok_box
DIALOG="read" ok_box <<< "Continue?"
```

## Dependencies

- [whiptail](https://en.wikipedia.org/wiki/Whiptail_(Unix))
- [dialog](https://invisible-island.net/dialog/)
- Bash

The script will fall back to plain output if no dialog tool is available.

## Function Reference

- `_about_ok_box`: Prints brief usage instructions for `ok_box`.
- `ok_box`: Shows a message using the selected dialog method.

