This is what I wanted the usage command to return:
```
Usage:
  bundle-audit [COMMAND] [OPTIONS]

Commands:
  check, -c [DIR]     # Scan Gemfile.lock for insecure dependencies.
  update, -u          # Update the ruby-advisory-db.
  version             # Prints the bundler-audit version.
  help, -h [COMMAND]  # Describe available commands or one specific command.
  download            # Downloads ruby-advisory-db.
  stats               # Prints ruby-advisory-db stats.
  tree                # Print a tree of all available commands.
   
Options for `check`:
  --update, -u        # Update ruby-advisory-db before scanning.
  --no-update         # Do not update the advisory database.
  --verbose, -v       # Show full advisory details.
  --quiet, -q         # Suppress normal output (exit codes only).
  --ignore FILE       # Ignore one or more advisory IDs (repeatable).
  --only FILE         # Only check the specified advisory IDs.
  --gemfile PATH      # Use a specific Gemfile.lock.
  --format FORMAT     # Output format: text (default), json, yaml

Examples:
  bundle-audit check
  bundle-audit check --verbose
  bundle-audit check --ignore CVE-2020-1234
  bundle-audit check --format json > audit.json
  bundle-audit update
```
