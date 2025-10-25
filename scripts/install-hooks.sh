#!/bin/bash
# EduLift Mobile - Git Hooks Installation Script
# Installs custom git hooks for code quality

set -e

echo "🔧 Installing Git hooks for EduLift Mobile..."

# Get the root directory of the git repository
GIT_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$GIT_ROOT/.git/hooks"
CUSTOM_HOOKS_DIR="$GIT_ROOT/.githooks"

# Check if .githooks directory exists
if [ ! -d "$CUSTOM_HOOKS_DIR" ]; then
    echo "❌ Error: .githooks directory not found"
    exit 1
fi

# Install pre-commit hook
if [ -f "$CUSTOM_HOOKS_DIR/pre-commit" ]; then
    cp "$CUSTOM_HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/pre-commit"
    echo "✅ Installed pre-commit hook"
else
    echo "⚠️  Warning: pre-commit hook not found in .githooks/"
fi

echo ""
echo "✨ Git hooks installed successfully!"
echo ""
echo "The following checks will run before each commit:"
echo "  1. dart format (auto-formats code)"
echo "  2. flutter analyze (checks for issues)"
echo ""
echo "To skip these checks (not recommended), use: git commit --no-verify"
echo ""

exit 0
