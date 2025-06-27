<p align="center">
  <a href="#overview">
    <img src="https://raw.githubusercontent.com/armbian/configng/main/share/icons/hicolor/scalable/configng-tux.svg" width="128" alt="Armbian Config Logo" />
  </a><br>
  <strong>configng-v2: Next Generation Armbian Configuration<br></strong>
  <br>
</p>

## Overview

**configng-v2** is a modular Bash framework for configuring Armbian-based systems.  
It is the intended successor to [armbian/configng](https://github.com/armbian/configng), designed for maintainability, flexibility, and robust CLI/TUI usage.

> **Reference:**  
> The recommended module scaffold is [tools/00_setup_module.sh](tools/00_setup_module.sh).

---

## Key Features

- **Modular Architecture:**  
  Each configuration area (network, system, services, etc.) is handled by a standalone module. Modules follow a unified CLI interface and can be invoked independently or by the main dispatcher.
- **Helper Scripts:**  
  Reusable logic is factored into helpers (`_helper_*.sh`) to maximize code reuse and maintainability.
- **Consistent Option Parsing:**  
  All modules use the pattern: `modulename.sh [option] [arguments]`, and provide a help message with usage instructions.
- **Runtime (Image-space) Focus:**  
  All actions are performed on the running system only.  
  No code in configng-v2 customizes system images at build time; for that, use [Armbian's build scripts](https://github.com/armbian/build).
- **Tab-Indented Bash:**  
  Code style is consistent and function-first—tabs for indentation, clear function blocks, minimal global logic.

---

## Current State

- Core dispatcher and scaffolding are established ([tools/00_setup_module.sh](tools/00_setup_module.sh)).
- Sample modules (e.g., `module_webmin.sh`) demonstrate the new structure and conventions.
- CLI and TUI interfaces are under active development.
- Modules and helpers are being migrated from [armbian/configng](https://github.com/armbian/configng) and refactored for clarity and testability.

---
## TUI & Backend Separation in configng-v2

This project uses a clear separation between **TUI helpers** (front-end scripts for user interaction) and **backend logic** (actual config changes and system actions).

### Why?

- Keeps user interfaces clean and simple.
- Makes backend logic easy to test, update, and extend.
- Lets you swap or improve UI bits (like using `whiptail` or `dialog`) without touching the core logic.

---

### How It Works

#### 1. TUI Helpers

These scripts handle all user input and output. They use utilities like `whiptail`, `dialog`, or plain shell prompts.

#### 2. Backend Logic

Backend scripts (“modules”) do the actual work: updating configs, toggling features, writing files, etc. T

**Example**:
- adjust_motd.sh : Functions to enable/disable MOTD items, show previews, etc.

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


## See Also

- info_box.sh
- yes_no_box.sh
- adjust_motd.sh

---
## Roadmap

- **Migrate and Refine:**  
  Gradually migrate legacy modules, update option parsing, and add new features as needed.
- **Testing:**  
  Integrate automated and manual tests for all modules and helpers to ensure reliability.
- **UI Separation:**  
  Clean separation of backend logic and CLI/TUI UI to support scripting, automation, and alternative frontends.
- **Documentation:**  
  Each module provides self-contained help output (see example below), and project documentation is updated as interfaces evolve.

---

## Contribution Guidelines

- **Coding Style:**  
  Bash and sh scripts use tab indentation, not spaces.  
  Modules and helpers are minimal, function-oriented, and easy to read.
- **Naming:**  
  Modules: `<feature>.sh`  
  Helpers: `_<helper>_<feature>.sh`
- **Module Scaffold Reference:**  
  Use [tools/00_setup_module.sh](tools/00_setup_module.sh) as the template for new modules.
- **Help Output:**  
  Each module must provide accurate, clear help output using the pattern above.

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more information on contributing, workflow, and best practices.

---

## Scope

- **Image-space Only:**  
  configng-v2 is for configuring a running Armbian system.  
  Build-time changes belong in [armbian/build](https://github.com/armbian/build) or similar tools.
- **Feature Requests & Bugs:**  
  Limit requests to runtime (image-space) features and bugs.

---

For further details, see individual modules, helpers, and [CONTRIBUTING.md](CONTRIBUTING.md).
