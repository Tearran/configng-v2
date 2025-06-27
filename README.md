# configng-v2: Next Generation Armbian Configuration

---

Welcome to **configng-v2**!  
This project is an open, community-driven take on configuring Armbian-based systems—modular, maintainable, and designed for contributors of all skill levels.

**Note:**  
This README is a living document. We aim to update it as development continues and as contributions shape the project. It’s a promise to keep things open and clear, not a definitive contract.

---

## What is configng-v2?

**configng-v2** is a modular Bash framework for runtime configuration of Armbian systems.  
It’s built on lessons learned from previous tools like [armbian/config](https://github.com/armbian/config) and [armbian/configng](https://github.com/armbian/configng), but is rewritten for clarity, transparency, and contributor workflow.

- **All config tasks are “mini modules”**—small, focused scripts grouped into parent modules.
- **No build-time image changes**—everything happens on the running system.
- **Tab-indented Bash only**—for readability and consistency.
- **Both CLI and TUI support**—scriptable and interactive.
- **Consistent option parsing**—every module provides `--help`.

---

## Why another config tool?

Previous tools grew confusing as features piled on.  
configng-v2 aims to be:

- **Modular:** Each config task is its own script. Edit or add just what you need.
- **Transparent:** No hidden wrappers, no black boxes.
- **Welcoming:** Contributors scaffold, develop, and document with a clear workflow and simple validation.

---

## Contributor Workflow (Snapshot)

1. **Scaffold:**  
   `./tools/start_here.sh mymodule`
2. **Develop:**  
   Write logic in `.sh`, fill out `.conf` (flat key=value), and document in `.md`—all in `staging/`
3. **Validate:**  
   `./tools/10_validate_module.sh` (checks format, required fields)
4. **Promote:**  
   Maintainers move modules to `src/` when ready.
5. **Consolidate:**  
   Prepare for release by flattening to `lib/`

- **Tabs only** for Bash scripts.
- **Flat configs** in `.conf`.
- **Clear help output** required.

---

## What’s the current state?

- Core dispatcher and scaffolding are working.
- Example modules show the structure.
- CLI and TUI are under active development.
- Modules and helpers are being refactored from [armbian/configng](https://github.com/armbian/configng).

---

## Roadmap (Subject to Change)

- Keep migrating and refining modules.
- Improve option parsing and automation.
- Build out automated/manual testing.
- Continue separating backend logic and UI.
- Update docs and help as the project evolves.

---

## Contribution Guidelines

- **No gatekeeping:** Anyone can contribute—just follow the style conventions (tabs, flat configs, clear docs).
- **Start new modules** with `tools/start_here.sh`.
- **Each module** must provide a clear help output and be both runnable and sourceable.
- **Ask questions:** Docs and workflow are evolving—your feedback is welcome.

For more, see [`tools/README.md`](tools/README.md) and [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

> *This README is a living document. If you spot missing info, outdated details, or want to clarify something, please open a PR or issue. Help us keep it useful!*

---