<img width="256" height="256" alt="armbian-configng" src="https://github.com/user-attachments/assets/49f1a04e-c80a-4b38-9f1e-7c2afce5aa78" />

## 📦 About configng-v2

configng-v2 is a proof-of-concept modular utility focused on making configuration modules easier to build, document, and maintain. Inspired by [armbian/configng](https://github.com/armbian/configng), this project is not a re-implementation of `armbian-config` itself, but a toolkit (SDK) and documentation system for creating compatible modules.

This version (v2) targets developers and advanced users who want to create or extend configuration modules in a consistent, interoperable way. The system enables users to specify API calls for desired functionality, and allows developers to provide compatible implementations for those APIs in a standardized format. It also provides features for gathering cluster information, system analysis, and module adjustment, making it possible to build smarter, context-aware modules.

A key goal is backwards compatibility: although the internal tooling and documentation are redesigned, the final production output should remain the same or very similar to existing solutions.

By focusing on clarity, maintainability, and ease of contribution, configng-v2 aims to make configuration more transparent, flexible, and accessible for everyone.

---

## 🗺️ Project Roadmap

Want to understand the project's progress and future plans?  
**Check our [Project Roadmap](./ROADMAP.md)** for detailed milestone tracking!

- View completion status of major development phases
- See what's been accomplished and what's planned
- Find ways to contribute to specific milestones
- Track progress on features like the testing framework, UI expansion, and release packaging

---

## 📚 Documentation & Module Index

Looking for what this project can do?  
**Start by browsing our [Module Documentation](./docs/README.md)!**

- Every module is documented with its features, usage, and extended description.
- Images and metadata are included for visual clarity.
- Modules are grouped by parent and group, so you can easily find related tools.

---

## 🗂 Module Browsers

Module browsers are proof-of-concept GUI applications that use JSON to display and interact with modules.  
Try the live demo at [GitHub Pages](https://tearran.github.io/configng-v2/index.html) or see documentation in [modules_browsers](https://github.com/Tearran/configng-v2/blob/main/modules_browsers/README.md).

---

## 🛠 SDK Scripts

SDK scripts automate common tasks for module development, validation, and documentation.  
Explore them in [`SDK/`](./SDK/):

All scripts are modular and documented for clarity—see [`SDK/README.md`](./SDK/README.md) for details.

---

**Questions or suggestions?  
Open an issue or check out the docs!**
