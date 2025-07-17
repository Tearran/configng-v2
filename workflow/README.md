# Contribution Guide: configng-v2 Modules

This guide covers the **practical workflow** for contributing modules to configng-v2.  

---

## Directory Structure

- `staging/` — Work-in-progress modules (development area).
- `src/` — Develomnet modules (after promotion).
- `lib/` — Assembled Bash libraries (for the final framework).
- `workflow/` — Scripts for scaffolding, checking, and automating the workflow.

---

## Module Contribution Workflow

1. **Scaffold a Module**
   - run
   ```sh
   ./workflow/start_here.sh <modulename>
   ```
   - Creates `staging/<modulename>.sh`, and `.conf`.

3. **Develop**
   - Write module logic in `.sh` (use **tabs** for indentation).
   - Fill out `.conf` (flat key=value).

4. **Verify & Test**
   - Manually test your module in `staging/`.
   - Run:
     ```sh
     ./workflow/10_validate_module.sh
     ```
   - fix invalid if any
     
5. **Promote modules to `./src`**
   - Move ready modules from `staging/` to `src/` as defined in `.conf`.
   - run
     ```sh
     ./workflow/20_promote_module.sh
     ```
6. **Generate Documents from metadata**
   - run
     ```sh
     ./workflow/30_docstring.sh
     ```
7. **Generate json object**
   - Used for ./workflow/GUI/modules_browser.*`
   - run
     ```sh
      ./workflow/35_web_docs.sh"
      ```
   - generates a json object
   - injets json object into modules-brouser.hmtl for use with go and weserver
8. **Consolidate (for maintainers)**
   - Flatten `src/` modules into `lib/` as needed for releases.
   - run
     ```sh
     ./workflow/40_consolidate_module.sh
     ```
---

## Best Practices

- **Tabs for indentation** in Bash code.
- **Keep configs flat:** Only key=value pairs in `.conf`.
- **Each module must be:**
  - Runnable as a script (CLI/test).
  - Sourceable by the framework (TUI/automation).
- **Minimal dependencies:** Document any required module dependencies.
- **Clear help output:** Each module must support `--help`.

---

## Quick Reference

- Scaffold: `./workflow/start_here.sh foo`
- Verify:   `./workflow/10_validate_module.sh`
- Tabs only for Bash scripts.
- Keep `.conf` files flat and simple.
- Submit a pull request after local checks pass.

---

For more details, see the main [README.md](../README.md) or ask in project discussions.
