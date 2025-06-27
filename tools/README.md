## Tools Workflow

The `tools/` directory contains scripts to help develop, test, and manage mini modules and modules. These scripts are designed to be used both manually and with GitHub Actions.

```
tools/
├── 10_validate_module.sh        # Checks a mini module for correctness and style
├── 20_promote_module.sh         # Moves a tested mini module into the next stage or parent module
├── 30_consolidate_module.sh     # Combines/promotes multiple mini modules into a parent module
├── configng_v2.sh               # Main entry script for the tools suite
└── start_here.sh                # Use this to scaffold (create) a new mini module
```

### Typical Workflow

1. **Create a new mini module:**  
   Run `tools/start_here.sh your_new_module` to scaffold a starter script, configuration file, and template documentation.

2. **Validate the mini module:**  
   Use `tools/10_validate_module.sh` to check the new mini module for errors or style issues.

3. **Promote the module:**  
   If validation passes, run `tools/20_promote_module.sh` to move the mini module into staging or to its parent module.

4. **Consolidate modules (as needed):**  
   Use `tools/30_consolidate_module.sh` to combine or finalize related mini modules into a complete module.

5. **Automated checks:**  
   GitHub Actions will automatically run these scripts (in order) on pull requests that touch `tools/` or `staging/`.

### Notes

- Scripts are numbered to ensure they run in the right order.
- All scripts use tab indentation and follow the same Bash coding style.
- You can run any script manually for local development, or let the CI handle them on PRs.

For more details, check the comments in each script or run it with `--help`.