# yes_no_box

A portable Bash helper for Yes/No user prompts in scripts and modules, supporting `whiptail`, `dialog`, and plain shell (`read`).  
Intended for use in Armbian config-v3 modules and similar Bash automation.

---
## Usage

```bash
yes_no_box "Do you want to continue?"
```

- If called with no argument, reads the message from stdin.
- If called with `"help"` or `"-h"`, displays the function's help (via `_about_yes_no_box`).
- Returns:
  - `0` for Yes/OK
  - `1` for No/Cancel (prints `Canceled.` if using `read`)
  - `2` for missing message argument
  - `3` if `DIALOG` is not set
  - `4` for unknown backend

### Dialog Backend

The dialog system is selected via the `DIALOG` environment variable:
- `whiptail` (default/recommended)
- `dialog`
- `read` (plain shell fallback)

If unset, function returns error code 3.

### Title

Set the dialog/window title via the `TITLE` variable.
- If not set, dialog may display a blank or fallback title.

---

## Examples

#### Standard

```bash
DIALOG=whiptail TITLE="Confirm" yes_no_box "Proceed with operation?"
```

#### Using stdin

```bash
echo "Apply settings now?" | DIALOG=read yes_no_box
```

#### In tests (use `read` backend):

```bash
yes_no_box "Test prompt" <<< y   # exits 0
yes_no_box "Test prompt" <<< n   # prints "Canceled.", exits 1
```

---

## Demo (when run directly)

When the script is executed directly, it demonstrates all supported backends:

```bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	DIALOG="whiptail"
	TITLE="$DIALOG"
	yes_no_box <<< "Showing $DIALOG box"

	DIALOG="dialog"
	TITLE="$DIALOG"
	yes_no_box "Showing a $DIALOG box"

	DIALOG="read"
	TITLE="$DIALOG"
	yes_no_box <<< "Showing $DIALOG prompt"
fi
```

---

## Integration

- Source or include the function in your config-v3 module or script.
- Set `DIALOG` and `TITLE` as needed before calling.
- No external dependencies for the `read` backend.

---
