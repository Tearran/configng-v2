# configng-v2: Next Generation Armbian Configuration

---

## Project Pitch

**configng-v2** is the next step for making Armbian system configuration easy, clear, and maintainable—for users, maintainers, and contributors.  
It’s a modular Bash framework that builds on everything we learned from the original *armbian-config* and *configng*. We’ve stripped away confusing parts and put a focus on transparency, flexibility, and a contributor workflow that actually works.

- **For users:**  
  Every configuration task is a framework module—grouped, focused scripts. All options are visible, easy to use from the CLI, and every module provides a help message.
- **For contributors:**  
  The workflow is streamlined:  
  1. Scaffold a new mini-module with a single command.  
  2. Develop and test in `staging/`.  
  3. Validate, document, and promote to production.  
  4. All scripts use tabs (no mixing), and configs use a flat key=value format.

**No hidden runtime logic, no mysterious wrappers.**  
The code you see is the code that runs—no black boxes.  
If you want to add or fix something, you can start right away using the tools in `tools/`, with clear validation and self-contained help.

**configng-v2** is built to avoid the patchwork and confusion of legacy config tools. It's open, transparent, and ready to grow with the community.  
If you want to contribute, you’ll find the workflow approachable, the structure predictable, and the docs right where you need them.

---

## Why configng-v2?

- Clear split between backend logic and UI—improve either without breaking the other
- Modular structure—focus on just the part you want to change
- Tab-indented Bash—no exceptions
- Flat configs—simple key=value; no nested config logic in modules
- CLI and TUI options—use it how you want, scriptable and interactive
- Designed for maintainability and easy onboarding

> **Note:**  
> configng-v2 module configs use a flat key=value format for simplicity.  
> YAML is used elsewhere in the project where appropriate (for example, for Netplan integration, CI workflows, or packaging), but not as the primary format for configuring modules themselves.

---

## Contributor Workflow Snapshot

1. **Scaffold:**  
   `./tools/start_here.sh newmod`
2. **Develop & Document:**  
   Edit `.sh`, `.conf`, `.md` in `staging/`
3. **Validate:**  
   `./tools/10_validate_module.sh`
4. **Promote:**  
   Maintainers move working modules to `src/`
5. **Consolidate:**  
   Prepare release by flattening to `lib/`

Tabs only, keep it flat, and a help message is required for each module.

---

> We’re not just rewriting old tools—we’re building a system where anyone can jump in, contribute, and trust what’s running on their board.  
> If you want to help shape the next-gen config tool for Armbian, configng-v2 is open for your ideas, scripts, and docs.

---

*See `tools/README.md` and `CONTRIBUTING.md` for details. Or just run `tools/start_here.sh` and get started!*
