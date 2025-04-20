#!/bin/bash
set -euo pipefail

# === GitHub Logout Script ===
echo -e "🔐 ${CYAN}Logging out of GitHub...${RESET}"

if [ -f "$HOME/.shx/github.cfg" ]; then
    rm -f "$HOME/.shx/github.cfg"
    echo -e "${GREEN}✅ Successfully logged out of GitHub.${RESET}"
else
    echo -e "${YELLOW}⚠️ You are not logged into GitHub.${RESET}"
fi