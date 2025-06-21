# Development Guide: configng-v2 (Armbian Config Next Generation)

This guide describes the module development and assembly process for **configng-v2**,  
the intended upgrade to [armbian/configng](https://github.com/armbian/configng).  

---

## 1. Philosophy: Bash-Native Modularity

- **Modules are Bash scripts** designed to run independently (CLI/test/demo) or be sourced by the main framework (TUI/automation).
- **Config files** (`.conf`) use simple, flat key=value pairs.
- **No forced Pythonic patterns:**  
	- Avoid unnecessary functions or complex/nested structures.
	- Prefer simple, transparent Bash logic; use functions for clarity, not for forced structure.
- **Independence is key:**  
	- Each module should be testable, callable, and understandable on its own.
	- Interdependencies must be minimal and always explicit.

---

## 2. Directory & File Structure

- `staging/` — Where modules are created and refined before integration.
- `src/` — Production-ready source files (promoted from staging).
- `lib/` — Consolidated, production-assembled Bash libraries (flattened from `src/`).
- `tools/` — Scripts for scaffolding, promotion, consolidation, packaging, and workflow automation.
	- Module scaffold: [`tools/00_setup_module.sh`](https://github.com/Tearran/configng-v2/blob/main/tools/00_setup_module.sh)

Each module consists of:
- `modulename.sh` — The Bash implementation.
- `modulename.conf` — Configuration and registration info (flat, Bash/INI style).
- `modulename.md` — Documentation for the module.

---

## 3. Module Workflow: From Staging to Package

Each module follows a strict flow from creation to packaging:

### Step 1: Scaffold

Create a new module scaffold:

```sh
./tools/staging_setup_scaffold.sh <modulename>
```

This generates:
- `staging/<modulename>.sh`
- `staging/<modulename>.conf`
- `staging/<modulename>.md`

### Step 2: Develop

- Implement logic in `.sh` with **tabs** for indentation.
- Fill out all required fields in the `.conf` file.
- Update the module documentation in the `.md` file as needed.

### Step 3: Verify & Test

- GitHub Actions runs `shellcheck`, formatting checks, and required field validation.
- Run `tools/staging_01_check_required.sh` to verify required files are present.
- Manually verify module behavior in `staging/` for correctness and compatibility.

### Step 4: Promote

- Move module components to their target locations as defined in `.conf`:
	- `.sh` → `src/<parent>/`
	- `.conf` → `src/<parent>/`
	- `.md` → `src/<parent>/`
- This step makes the module part of the main tree and signals it's ready for assembly.

### Step 5: Consolidate

- Flatten all `src/<parent>/*.sh` into a single `lib/<parent>.sh`.
- This creates production-grade output files used as the main framework.

### TODO Step 6: Production Test

- Run full framework tests using the consolidated scripts in `lib/`.
- This ensures compatibility and functionality in their final state.

### TODO: Step 7: Package

- If production-test passes, package the tool (e.g., `.deb`) using the build system.
- Output is stored in `build/` or `dist/`.

**No steps should be skipped.  
The workflow enforces modular clarity, testability, and maintainability.**

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

**Q: Must every module be a function library?**  
A: Bash doesn’t have “real” functions like other programming languages. In Bash, so-called functions are just named blocks of code.

**Q: Why not a central controller?**  
A: Independence makes modules more robust, easier to test, and more flexible for CLI, TUI, or automation.

**Q: Are Bash functions meant for functional programming?**  
**A:** No. They're meant for code structure and reuse—not abstraction or composition.

---

## 7. Path Forward

- **Keep the workflow strict:**  
	Staging, promote, consolidate, production-test, package—no shortcuts.
- **Keep modules independent:**  
	Each must be testable and callable alone.
- **Keep configs simple:**  
	Flat, key=value, Bash/INI style.
- **Document and automate:**  
	Every change to workflow or philosophy should be documented and, when possible, enforced through CI.

---

*Stick to these principles for a maintainable, robust, and Bash-appropriate modular system.*
