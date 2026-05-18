#!/bin/bash
# SuperGit-Tools v4 Setup Script

echo "SuperGit-Tools v4 Setup"
echo "======================"
echo ""

# Check if Python is installed
if ! command -v python &> /dev/null; then
    echo "ERROR: Python 3.8+ is required but not installed"
    echo "Please install Python from https://www.python.org/downloads/"
    exit 1
fi

echo "✓ Python found: $(python --version)"

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "WARNING: uv package manager not found"
    echo "Installing uv..."
    pip install uv
fi

echo "✓ uv found: $(uv --version)"

# Install dependencies
echo ""
echo "Installing backend dependencies..."
cd "$(dirname "$0")"
uv sync

echo ""
echo "✓ Setup complete!"
echo ""
echo "To run the GUI:"
echo "  powershell -NoProfile -ExecutionPolicy Bypass -File git-sync-gui-v4.ps1"
echo ""
echo "To run the CLI:"
echo "  powershell -NoProfile -ExecutionPolicy Bypass -File git-sync.ps1 -ParentFolder 'C:\path\to\repos'"
