#!/bin/bash
set -euo pipefail

# === Initialize SHX Script ===
if [ ! -d "$SHX_HOME" ]; then
    echo -e "${CYAN}🛠 Initializing SHX Home Directory...${RESET}"
    mkdir -p "$SHX_HOME" "$SHX_HOME/pipelines" "$SHX_HOME/workspaces" "$SHX_HOME/landing-page" "$SHX_HOME/marketplace" "$SHX_HOME/extensions" "$SHX_HOME/templates" "$SHX_HOME/users" "$SHX_HOME/modules"
    touch "$SHX_HOME/shx.log"
    echo -e "${GREEN}✅ SHX Home Directory Initialized at $SHX_HOME${RESET}"
else
    echo -e "${YELLOW}⚠️ SHX Home Directory already exists at $SHX_HOME${RESET}"
fi