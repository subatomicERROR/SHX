#!/bin/bash
set -euo pipefail

# === Unlock Premium Script ===
key="$1"
key_file="$HOME/.shx/premium.key"

if [ -f "$key_file" ]; then
    echo -e "${RED}❌ Premium key already activated.${RESET}"
    exit 1
fi

echo "key=$key" > "$key_file"
echo -e "${GREEN}✅ Premium features unlocked with key: $key${RESET}"