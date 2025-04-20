#!/bin/bash
set -euo pipefail

# === Logout Entry Point ===
case "$1" in
    github) "$SHX_HOME/auth/github_logout.sh" ;;
    hf) "$SHX_HOME/auth/huggingface_logout.sh" ;;
    *) echo "Usage: shx logout [github|hf]" ;;
esac