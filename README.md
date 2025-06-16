<p align="center">
  <a href="#overview">
    <img src="https://raw.githubusercontent.com/armbian/configng/main/share/icons/hicolor/scalable/configng-tux.svg" width="128" alt="Armbian Config Logo" />
  </a><br>
  <strong>Armbian Config: V3 (configng V2)</strong><br>
  <br>
</p>

## Overview

**armbian-config** is a system configuration tool for Armbian-based systems. It provides a straightforward, interactive environment for users to configure and manage system settings.

The tool supports both command-line interfaces (CLI) and text user interfaces (TUI), catering to a range of usage scenarios and user preferences.

---

## Scope and Responsibilities

- **armbian-config operates only in image-space.**  
	It is used exclusively on a running Armbian system and does **not** participate in the image build process. It does **not** affect image creation or customization at build time.

- **Image build changes belong to the build scripts.**  
	If you wish to change the default contents, packages, or configurations included in an Armbian image before it is built, those changes must be made in the Armbian build scripts—not in armbian-config.

- **Limit feature requests and bug reports to image-space actions.**  
	Feature requests or bug reports for armbian-config should only involve tasks that can be changed or applied on a running system. Requests relating to image creation or build-time customization should be directed to the Armbian build system.

---

## Goals

- **Migrate and Refactor:**  
	Transition legacy code and features into a standard, modern development structure.

- **Enable Testing:**  
	Facilitate robust unit and integration testing for all modules and helpers.

- **Support Automation and Multiple UIs:**  
	Clean separation of backend configuration from interface logic to allow for both automation and various user-facing interfaces.

---
