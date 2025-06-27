<p align="center">
  <a href="#overview">
    <img src="https://raw.githubusercontent.com/armbian/configng/main/share/icons/hicolor/scalable/configng-tux.svg" width="128" alt="Armbian Config Logo" />
  </a><br>
  <strong>configng-v2: Next Generation Armbian Configuration<br></strong>
  <br>
</p>

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [How it Works: TUI & Backend Logic](#how-it-works-tui--backend-logic)
- [Example Flow](#example-flow)
- [Tools & Module Development](#tools--module-development)
- [Current State](#current-state)
- [Roadmap](#roadmap)
- [Contribution Guidelines](#contribution-guidelines)
- [Scope](#scope)
- [See Also](#see-also)

---

## Overview

**configng-v2** is a modular Bash framework for configuring Armbian-based systems.

This project is the result of everything we’ve learned from earlier Armbian configuration tools—especially **armbian/config** (the original) and **armbian/configng** ("next-gen"). Now, configng-v2 ("next-gen v2") aims to provide a clearer, less confusing workflow for users and developers alike. The focus is on making things transparent and approachable, so development isn’t blocked by hidden steps or confusing structures.

Some sensitive details—like how to handle keys or secrets—are intentionally left out for safety. If you need to manage your own keys, that’s up to you; we don’t document every detail for those cases.

configng-v2 is designed for maintainability, flexibility, and robust CLI (Command-Line Interface) and TUI (Text-based User Interface) usage.

---

## Key Features

- **Modular Structure:**  
  Each configuration task (e.g., network, system, or service) is a “mini module”—a focused Bash script. Mini modules are grouped into parent modules, and all follow a unified command-line interface.
- **Easy Module Creation:**  
  Use [`tools/start_here.sh`](tools/start_here.sh) to scaffold new mini modules with starter scripts, configs, and docs.
- **Consistent Option Parsing:**  
  All modules use:  
  `modulename.sh [option] [arguments]`  
  Each provides `--help` output.
- **Runtime-Only:**  
  All actions happen on the running system. No build-time image changes (use [armbian/build](https://github.com/armbian/build) for that).
- **Tab-Indented Bash:**  
  All code uses tabs for indentation and clear function-first structure.

---

## How it Works: TUI & Backend Logic

configng-v2 splits the user interface (TUI) from backend logic for clarity and maintainability.

- **TUI scripts** handle user input/output with tools like `whiptail`, `dialog`, or shell prompts.
- **Backend scripts (modules/mini modules)** do the actual work: updating configs, toggling features, writing files, etc.

This makes it easy to improve the UI or backend separately.

---
## Example Flow

> **Note:** This is a general overview—actual flow details may change as development continues.

1. **TUI shows options:**  
   The user selects items using a graphical checklist (e.g., `whiptail`).
2. **TUI collects input:**  
   The chosen options are gathered.
3. **TUI calls backend:**  
   For each item, the backend script is called (e.g., `set_motd_item <item> <ON|OFF>`).
4. **Backend updates system:**  
   Configuration changes are made—no UI at this stage.
5. **TUI shows result:**  
   A summary or info box is displayed.

## Tools & Module Development

- The `tools/` directory holds scripts for developing, checking, and managing modules and mini modules.
- Scripts are numbered (`10_`, `20_`, etc.) to run in a set order, with gaps left so new steps can be added later.
- Use `tools/start_here.sh` to scaffold a new mini module.
- All scripts use tab indentation and have a `--help` option.

See [`tools/README.md`](tools/README.md) for more details.

---

## Current State

- Core dispatcher and scaffolding are established.
- Example modules (like `module_webmin.sh`) show the new structure.
- CLI and TUI interfaces are under active development.
- Modules and helpers are being migrated and refactored from [armbian/configng](https://github.com/armbian/configng).

---

## Roadmap

- **Migrate and Refine:**  
  Continue updating modules and improving option parsing.
- **Testing:**  
  Integrate automated/manual tests for reliability.
- **UI Separation:**  
  Maintain clear split between backend logic and CLI/TUI UI.
- **Documentation:**  
  Each module provides self-contained help output; project docs are updated as things evolve.

---

## Contribution Guidelines

- **Coding Style:**  
  Use tab indentation in Bash/sh scripts.  
  Keep modules and mini modules clear and function-oriented.
- **Naming:**  
  Modules: `<feature>.sh`  
  Mini modules: descriptive names; grouped by parent module if needed.
- **Module Scaffold:**  
  Start new modules with [`tools/start_here.sh`](tools/start_here.sh) to see a template:
  ```bash
  tools/start_here.sh foo
  ```
- **Help Output:**  
  Each module must provide clear, accurate help output.

> **Tip for Contributors:**  
> You’re welcome to fill out or edit the developer docs as you go. Reviewers and maintainers will have the final say to ensure accuracy and clarity. Your best effort is always appreciated—even imperfect docs help move things forward!

For contributing details, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Scope

- **Image-space Only:**  
  configng-v2 is for configuring running Armbian systems.  
  Build-time changes belong in [armbian/build](https://github.com/armbian/build).
- **Feature Requests & Bugs:**  
  Please limit requests to runtime features and bugs.

---

For further details, see individual workflow, scripts in [tools/](tools/), and [`tools/README.md`](tools/README.md) for contributing workflow.
