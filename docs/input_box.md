# input_box

A flexible Bash module for prompting user input from the command line or TUI (whiptail/dialog), as used in [configng-v2](https://github.com/Tearran/configng-v2).  
This tool is designed for local, modular use—no exported variables or temp files.

---

## Usage

```sh
input_box ["prompt"]
```
- Prompts the user for a line of input.
- Supports three backends, selected via the `DIALOG` environment variable:
  - `whiptail` (default if available)
  - `dialog`
  - `read` (plain shell fallback)

### Examples

Prompt with an argument:
```sh
input_box "What is your password?"
```

Prompt with text from stdin:
```sh
echo "Enter your name:" | input_box
```
or
```sh
input_box <<< "Type your username:"
```

Use the shell fallback:
```sh
DIALOG=read input_box "Enter a value:"
```

Show help:
```sh
input_box help
```

---

## Behavior

- **Prompt order:**  
  1. If an argument is given, it's used as the prompt.
  2. If stdin is a pipe, prompt is read from stdin.
  3. If neither, shows an error and usage.

- **Backends:**  
  - `whiptail`/`dialog`:  
    - Shows a graphical input box (if available), returns result to stdout.
  - `read`:  
    - Prints prompt to terminal, reads a line from user.

- **Exit codes:**  
  - `0` on success (user provided input)
  - Non-zero if cancelled or error.

---

## Implementation Notes

- No environment variable export or temp files.
- All variables are local to the function.
- For shell fallback, reads from `/dev/tty` to ensure interactive input.

---

## Demo

To try interactively:
```sh
DIALOG=whiptail bash tools/input_box.sh
DIALOG=dialog bash tools/input_box.sh
DIALOG=read bash tools/input_box.sh "Shell input:"
```

---
