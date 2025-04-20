#!/bin/bash
set -euo pipefail

# === Run Module Script ===
module_name="$1"
module_path="$SHX_HOME/marketplace/$module_name.sh"

if [ ! -f "$module_path" ]; then
    echo -e "${RED}❌ Module $module_name not found. Try installing it first.${RESET}"
    exit 1
fi

echo -e "${CYAN}🛠 Running Module $module_name...${RESET}"
bash "$module_path"
echo -e "${GREEN}✅ Module $module_name executed successfully.${RESET}"