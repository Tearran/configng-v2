# Development Guide: configng-v2 (Armbian Config Next Generation)

This guide describes the module development and assembly process for **configng-v2**,  
the intended upgrade to [armbian/configng](https://github.com/armbian/configng).

📋 **For project milestones and roadmap, see [ROADMAP.md](./ROADMAP.md)**

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
- `workflow/` — Scripts for scaffolding, promotion, consolidation, packaging, and workflow automation.
	- Module scaffold: [`workflow/00_setup_module.sh`](./workflow/00_setup_module.sh)

Each module consists of:
- `modulename.sh` — The Bash implementation.
- `modulename.conf` — Configuration and registration info (flat, Bash/INI style).
- `modulename.md` — Metadata generatated documentation for the module.

---

## 3. Module Workflow: From Staging to Package

Each module follows a flow from creation to packaging:

### Step 1: Scaffold

Create a new module scaffold:

```sh
./workflow/00_setup_module.sh <modulename>
```

This generates:
- `staging/<modulename>.sh`
- `staging/<modulename>.conf`

### Step 2: Develop

- Implement logic in `.sh` with **tabs** for indentation.
- Fill out all required fields in the `.conf` file.

### Step 3: Verify & Test

- Run `./workflow/10_validate_module.sh` to check your files in `staging/` for formatting, required fields, and basic issues.
- Manually verify module behavior in `staging/` for correctness and compatibility.
- GitHub Actions runs `shellcheck`, and formatting checks.

### Step 4: Promote
- Run `./workflow/20_promote_module.sh`
- this will move module components to their target locations as defined in `.conf`:
	- `.sh` → `src/<parent>/`
	- `.conf` → `src/<parent>/`
- This step makes the module part of the main tree and signals it's ready for assembly.

### Step 5: Generate documentation
- Run `workflow/30_docstring.sh`
- This will generate a Markdown file for each valid module.

### Step 6: Consolidate
- run `./workflow/40_consolidate_module.sh`
- this will Flatten all `src/<parent>/*.sh` into a single `lib/<parent>.sh`.
- Generates an associative array from `src/<parent>/*.conf`
- This creates production-grade output files used as the main framework.

### Step 7: Generate json object
- run `./workflow/50_array_to_json.sh`
- this is use for TUI/GUI/UX interfacing 

### TODO Step 8: Production Test

- Run full framework tests using the consolidated scripts in `lib/`.
- This ensures compatibility and functionality in their final state.

### TODO: Step 9: Package

- If production-test passes, package the tool (e.g., `.deb`) using the build system.
- Output is stored in `build/` or `dist/`.

**No steps should be skipped.  
The workflow enforces modular clarity, testability, and maintainability.**

---

## 4. Module Best Practices

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

## 5. FAQ & Rationale

**Q: Must every module be a function library?**  
A: Bash doesn’t have “real” functions like other programming languages. In Bash, so-called functions are just named blocks of code.

**Q: Why not a central controller?**  
A: Independence makes modules more robust, easier to test, and more flexible for CLI, TUI, or automation.

**Q: Are Bash functions meant for functional programming?**  
A: No. They're meant for code structure and reuse—not abstraction or composition.

---

## 6. Path Forward

- **Keep the workflow strict:**  
	Staging, promote, consolidate, production-test, package—no shortcuts.
- **Keep modules independent:**  
	Each must be testable and callable alone.
- **Keep configs simple:**  
	Flat, key=value, Bash/INI style.
- **Document and automate:**  
	Every change to workflow or philosophy should be documented and, when possible, enforced through CI.

---

## Definitions

**User-Facing Module**  
A script or command intended for direct use by the end-user (via CLI or TUI). Handles user input, displays help, and coordinates module actions.

**Module Backend Logic**  
The functions and code within each module that perform actual system operations or configuration changes. Invoked by user-facing modules or the main framework.

**Framework Infrastructure**  
The core logic that loads, parses, and dispatches modules. This includes scaffolding, option parsing, and coordination between modules, but is not directly user-facing.

**Module Scaffold**  
The baseline template and directory structure used to create new modules. (See: [`workflow/00_setup_module.sh`](./workflow/00_setup_module.sh))

---

## TL;DR

- Step 1: `./workflow/00_start_here.sh <modulename>`
- Step 2: `./workflow/10_validate_module.sh`
- Step 3: `./workflow/20_promote_module.sh`
- Step 4: Fix failing Checks if needed
- Step 5: Request review


---

Please use these terms as defined above in project discussions.

*Stick to these principles for a maintainable, robust, and Bash-appropriate modular system.*
