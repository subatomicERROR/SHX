#!/bin/bash
set -euo pipefail

# === Install Module Script ===
module_name="$1"
module_path="$SHX_HOME/marketplace/$module_name.sh"

if [ -f "$module_path" ]; then
    echo -e "${RED}❌ Module $module_name already installed.${RESET}"
    exit 1
fi

# Download module from marketplace
curl -sL https://raw.githubusercontent.com/subatomicERROR/SHX-marketplace/main/$module_name.sh -o "$module_path"
chmod +x "$module_path"

echo -e "${GREEN}✅ Module $module_name installed successfully.${RESET}"