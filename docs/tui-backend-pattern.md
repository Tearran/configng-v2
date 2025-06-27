# TUI & Backend Separation in configng-v2

This project uses a clear separation between **TUI helpers** (front-end scripts for user interaction) and **backend logic** (actual config changes and system actions).

## Why?

- Keeps user interfaces clean and simple.
- Makes backend logic easy to test, update, and extend.
- Lets you swap or improve UI bits (like using `whiptail` or `dialog`) without touching the core logic.

---

## How It Works

### 1. TUI Helpers

These scripts handle all user input and output. They use utilities like `whiptail`, `dialog`, or plain shell prompts.

**Examples**:
- [`../src/helpers/info_box.sh`](../src/helpers/info_box.sh): Shows rolling info boxes for status or logs.
- [`../src/helpers/yes_no_box.sh`](../src/helpers/yes_no_box.sh): Presents yes/no questions to the user and returns a success/fail code.
- (You can add input boxes, checklists, etc. as needed.)

**Typical usage**:
```bash
info_box <<< "Installing packages..."
if yes_no_box "Apply these changes?"; then
    do_the_thing
else
    info_box "Cancelled by user."
fi
```

### 2. Backend Logic

Backend scripts (“modules”) do the actual work: updating configs, toggling features, writing files, etc. They expect to receive already-parsed arguments or flags—never raw user input.

**Example**:
- [`../modules.d/adjust_motd.sh`](../modules.d/adjust_motd.sh): Functions to enable/disable MOTD items, show previews, etc.

**Typical usage**:
```bash
set_motd_item sysinfo ON   # No user prompts here!
```

---

## Example Flow

1. **TUI presents options:**  
   `whiptail` checklist lets the user pick MOTD items.
2. **TUI parses input:**  
   Collects which items to enable/disable.
3. **TUI calls backend:**  
   For each item, calls `set_motd_item <item> <ON|OFF>`.
4. **Backend updates system:**  
   No UI—the backend only changes configs.
5. **TUI shows result:**  
   `info_box <<< "All changes applied!"`

---

## Tips for Contributors

- **Add new TUI helpers** in `src/helpers/` as small, focused scripts.
- **Write backend logic** in `modules.d/`—functions should never prompt the user directly.
- **Always document**: Usage examples, argument patterns, and expected return codes.
- **Keep it simple:** If your TUI can’t easily express a feature, it probably doesn’t belong in the core UI.

---

## See Also

- [../src/helpers/info_box.sh](../src/helpers/info_box.sh)
- [../src/helpers/yes_no_box.sh](../src/helpers/yes_no_box.sh)
- [../modules.d/adjust_motd.sh](../modules.d/adjust_motd.sh)