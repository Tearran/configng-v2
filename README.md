# configng-v2

Welcome to the configng-v2 modular metadata and configuration system!

---

## 📦 About configng-v2

configng-v2 is a proof-of-concept modular utility for metadata-parsed documentation (outputting to `md` and `json`) and system configuration, inspired by [armbian/configng](https://github.com/armbian/configng). It features redesigned metadata usability for user-friendly documentation clarity, scaffolding for easier module development, validation for maintainability, and an open approach to contribution. The goal is to make configuration more transparent, easier to document, and simpler for anyone to extend.


---

## 🗺️ Project Roadmap

Want to understand the project's progress and future plans?  
**Check our [Project Roadmap](./ROADMAP.md)** for detailed milestone tracking!

- View completion status of major development phases
- See what's been accomplished and what's planned
- Find ways to contribute to specific milestones
- Track progress on features like testing framework, UI expansion, and release packaging

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
Try the live demo at [GitHub Pages](https://tearran.github.io/configng-v2/index.html) or documentation [modules_browsers](https://github.com/Tearran/configng-v2/blob/main/modules_browsers/README.md)

---

## 🛠 Workflow Scripts

Workflow scripts automate common tasks for module development, validation, and documentation.  
Explore them in [`workflow/`](./workflow/):

```
workflow/
├── 00_start_here.sh         # Guided entry point for new contributors
├── 10_validate_module.sh    # Validate module structure and metadata
├── 20_promote_module.sh     # Promote a validated module for public use
├── 30_docstring.sh          # Extract and format docstrings for documentation
├── 35_web_docs.sh           # Build web documentation from module metadata
├── 40_consolidate_module.sh # Merge module changes and metadata
├── configng_v2.sh           # Main CLI: manage, browse, and generate configs
├── index.html               # Web demo for module browser (see above)
└── README.md                # Workflow folder documentation and usage tips
```

All scripts are modular and documented for clarity—see [`workflow/README.md`](./workflow/README.md) for details.

---

**Questions or suggestions?  
Open an issue or check out the docs!**
