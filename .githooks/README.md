# Git Hooks for EduLift Mobile

Custom Git hooks to ensure code quality and consistency.

## Available Hooks

### pre-commit

Runs before each commit to ensure code quality:

1. **dart format** - Automatically formats all Dart code
2. **flutter analyze** - Checks for code issues

If any check fails, the commit is blocked until issues are fixed.

## Installation

Run the installation script from the project root:

```bash
bash scripts/install-hooks.sh
```

Or manually:

```bash
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Usage

The hooks run automatically before each commit. No additional action needed!

### Skipping Hooks (Not Recommended)

If you absolutely need to bypass the hooks:

```bash
git commit --no-verify -m "Your message"
```

⚠️ **Warning**: Only skip hooks if you know what you're doing. The CI pipeline will still run these checks.

## Benefits

- ✅ Consistent code formatting across the team
- ✅ Catch issues early, before pushing to remote
- ✅ Faster CI pipeline (fewer failed builds)
- ✅ Better code quality and maintainability
