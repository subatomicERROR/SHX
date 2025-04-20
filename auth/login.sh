#!/bin/bash
set -euo pipefail

# === Login Entry Point ===
case "$1" in
    github) "$SHX_HOME/auth/github.sh" ;;
    hf) "$SHX_HOME/auth/huggingface.sh" ;;
    *) echo "Usage: shx login [github|hf]" ;;
esac