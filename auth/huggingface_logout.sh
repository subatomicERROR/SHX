#!/bin/bash
set -euo pipefail

# === Hugging Face Logout Script ===
echo -e "🤖 ${CYAN}Logging out of Hugging Face...${RESET}"

if [ -f "$HOME/.shx/hf.cfg" ]; then
    rm -f "$HOME/.shx/hf.cfg"
    echo -e "${GREEN}✅ Successfully logged out of Hugging Face.${RESET}"
else
    echo -e "${YELLOW}⚠️ You are not logged into Hugging Face.${RESET}"
fi