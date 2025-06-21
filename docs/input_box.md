# input_box

Prompt the user for input using whiptail, dialog, or a simple shell read.

## Script locations

- Framework implementation: `src/framework/input_box.sh`  
- Wrapper module: `staging/input_box.sh` (sources the framework version)

## Usage

```bash
input_box ["prompt_message"] [default_value]
```

- If the first argument is `help` or `-h`, displays this help and exits with code 0.
- If the prompt message is empty, prints an error to stderr and exits with code 2.
- Reads input via the specified dialog backend and writes the result to stdout.

## Environment Variables

- `DIALOG`
  - Backend to use for displaying the prompt.
  - Supported values:
    - `whiptail`
    - `dialog`
    - `read`
- `TITLE`
  - Title displayed in the dialog window (defaults to `"Input"`).

## Examples

```bash
# Run built-in tests (whiptail, dialog, read)
bash src/framework/input_box.sh

# Display help
echo "help" | bash src/framework/input_box.sh

# Read with default value via 'read' backend
DIALOG="read" TITLE="Test" bash -c 'source src/framework/input_box.sh; input_box "Enter port:" "8080"'

# Read from piped prompt
DIALOG="read" bash -c 'source src/framework/input_box.sh; echo "Enter name:" | input_box'
```

## Exit Codes

- `0` – Input read successfully or help displayed.  
- `2` – Missing prompt message.  
- `3` – `DIALOG` variable not set.  
- `4` – Unknown dialog backend specified.  

## Wrapper in staging directory

```bash
#!/bin/bash
set -euo pipefail

# input_box - Armbian Config V3 wrapper
# This module has been moved to src/framework/input_box.sh
source "$(dirname "${BASH_SOURCE[0]}")/../src/framework/input_box.sh"
```