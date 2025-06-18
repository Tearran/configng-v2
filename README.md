<p align="center">
  <a href="#overview">
    <img src="https://raw.githubusercontent.com/armbian/configng/main/share/icons/hicolor/scalable/configng-tux.svg" width="128" alt="Armbian Config Logo" />
  </a><br>
  <strong>Armbian Config: V3<br>(@Tearran/configng-v2)</strong><br>
  <br>
</p>

## Overview

**configng-v2** is an evolving system configuration framework for Armbian-based systems, forming the next stage of the classic `armbian-config` tool.  
The project focuses on maintainable, modular Bash code, enabling robust system configuration via both command-line (CLI) and text user interfaces (TUI).

---

## Current State

- **Modular Design:**  
	Modules are standalone scripts, each handling a specific area (e.g., networking, services, system info), with a clear set of options for each.
- **Unified Option Handling:**  
	All modules follow the pattern `module_name.sh [option] [arguments]`. Each module provides a help message describing its options and usage.
- **Helpers:**  
	Shared logic is factored into helpers, promoting code reuse and maintainability.
- **Config-v3 Scaffold:**  
	Core dispatcher and module scaffolding are established. Reference modules (such as `module_webmin.sh`) demonstrate the new structure and conventions.
- **Image-space Focus:**  
	All actions are performed on the running system. No code in configng-v2 affects image build or customization at build time.

---

## Planned Goals

- **Refinement and Expansion:**  
	Migrate legacy modules to the new structure, update their option parsing, and add missing functionality as needed.
- **Testing:**  
	Introduce and maintain unit and integration tests for modules and helpers.  
	Ensure changes do not break expected CLI or TUI behaviors.
- **UI Separation:**  
	Clean separation between backend (actual configuration logic) and UI (CLI/TUI) to support scripting, automation, and alternative interfaces.
- **Documentation:**  
	Update and clarify module help output and project documentation to reflect current standards and usage.  
	Each module provides a help message like the following:
    ```
    Usage: module_network.sh [option]

    Options:
    	scan                  Scan for available networks
    	connect <ssid> [psk]  Connect to a network (PSK optional)
    	disconnect            Disconnect from the current network
    	status                Show current network status
    	help                  Show this help message
    ```

---

## Scope and Responsibilities

- **Image-space Only:**  
	configng-v2 operates **only** on a running Armbian system.  
	It does **not** modify or customize system images during build—use Armbian build scripts for that.
- **Feature Requests and Bug Reports:**  
	Limit requests to runtime (image-space) issues.  
	Build-time changes are out of scope for this tool and should be directed to the build system.

---

## Contribution Notes

- **Coding Style:**  
	Bash/sh code uses tab indentation (not spaces).  
	Modules and helpers should be clear, minimal, and function-oriented.
- **Naming Conventions:**  
	Modules are named `<feature>.sh`; helpers as `_<helper>_<feature>.sh`.
- **Option Parsing:**  
	Modules expect: `<feature> [option] [args...]`  
- **Help Output:**  
	Each module must provide a accurate help message per the above example.

---

For further details, see individual module scripts and [CONTRIBUTING.md](CONTRIBUTING.md).
