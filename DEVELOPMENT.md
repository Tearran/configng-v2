# Development Guide: configng-v2 Modules and Staging Workflow

This guide outlines the module development and assembly process for **configng-v2**.  
It defines the current approach, philosophy, and workflow for Bash-based modules, with practical steps for contributors and maintainers.

---

## 1. Philosophy: Bash-Native Modularity

- **Modules are Bash scripts** designed to run independently (CLI/test/demo) or be sourced by the main framework (TUI/automation).
- **Config files** (`.conf`) use simple, flat key=value pairs—like classic Linux `.conf` or `.ini` files.
- **No forced Pythonic patterns:**  
	- Avoid unnecessary functions or complex/nested.
	- Prefer simple, transparent Bash logic; use functions for clarity, not for forced structure.
- **Independence is key:**  
	- Each module should be testable, callable, and understandable on its own.
	- Interdependencies must be minimal and always explicit.

---

## 2. Directory & File Structure

- `staging/` — Where modules are created and refined before integration.
- `src/` — Production modules (moved here after staging).
- `testing/` — Manual and automated test scripts for modules.
- `tools/` — Helper scripts for scaffolding, assembly, and automation.

Each module consists of:
- `modulename.sh` — The Bash implementation.
- `modulename.conf` — Configuration and registration info (flat, Bash/INI style).
- `[optional] modulename_test.sh` — Test script for the module.

---

## 3. Staging & Module Workflow

### Step 1: Scaffold

- Create a new module with:
	```sh
	./tools/staging_setup_scaffold.sh <modulename>
	```
- This generates:
	- `staging/<modulename>.sh`
	- `staging/<modulename>.conf`

### Step 2: Develop

- Implement logic in `.sh` with **tabs** for indentation.
- Fill out all fields in `.conf` (see template below).
- (Optional) Create associated test script in `staging/`.

### Step 3: Submit

- Commit and push both `.sh` and `.conf` (and test, if present) to the staging area.
- Pull request triggers CI/workflow checks:
	- Confirms all required files are present and `.conf` is valid.

### Step 4: Integration

- On successful checks:
	- The `.conf` file is parsed for placement and registration (e.g., `placement=src/software/`).
	- Module code and test scripts are moved to their respective directories.
	- Central arrays/configs are updated for module discovery.

**Do not bypass this process or repurpose staging for other tasks—this ensures robust, repeatable integration.**

---

## 4. Example Module Configuration (`.conf`)

```conf name=staging/example_module.conf
feature=example
description=Configure Example Feature
parent=system
group=managers
contributor=tearran
maintainer=tearran
arch=arm64 armhf x86-64
require_os=Debian Ubuntu
require_kernel=5.15+
port=false
placement=src/software/
has_test=true
test_file=example_test.sh
```

---

## 5. Module Best Practices

- **Keep configs flat:**  
	No nesting, no complex lists—just key=value or simple [section] headers if absolutely needed.
- **Write Bash, not Python:**  
	Tabs for indentation, no forced classes or object models.
- **Modules must be callable as scripts** (for CLI/test) and sourceable (for TUI/framework).
- **Avoid hard dependencies:**  
	If a module depends on another, document and handle this explicitly in `.conf` and code.
- **Document with Bash users in mind:**  
	Clear comments, usage examples, and minimal assumptions.

---

## 6. FAQ & Rationale

**Q: Why `.conf` and not `.meta` or `.json`?**  
A: `.conf` is universally editable, Bash-native, and works with Linux tooling. No extra parsing or editor config needed.

**Q: Can I use arrays or complex data?**  
A: Stick to simple, flat config for maximum portability and ease of parsing in Bash.

**Q: Must every module be a function library?**  
A: No—modules should be as simple as possible. Use functions where helpful, but modules must be independently runnable.

**Q: Why not a central controller?**  
A: Independence makes modules more robust, easier to test, and more flexible for CLI, TUI, or automation.

---

## 7. Path Forward

- **Keep the workflow strict:**  
	Staging, check, integration—no shortcuts.
- **Keep modules independent:**  
	Each must be testable and callable alone.
- **Keep configs simple:**  
	Flat, key=value, Bash/INI style.
- **Document and automate:**  
	Every change to workflow or philosophy should be documented and, when possible, enforced through CI.

---

*Stick to these principles for a maintainable, robust, and Bash-appropriate modular system.*
