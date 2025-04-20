#!/bin/bash

shx_login_hf() {
    echo -e "🤖 ${CYAN}Starting Hugging Face Login...${RESET}"

    read -p "📝 Hugging Face Username: " hf_user
    read -s -p "🔑 Hugging Face Token (Paste hidden): " hf_token
    echo ""

    mkdir -p "$HOME/.shx"
    echo "username=$hf_user" > "$HOME/.shx/hf.cfg"
    echo "token=$hf_token" >> "$HOME/.shx/hf.cfg"

    shx_log "${GREEN}✅ Hugging Face login saved for user: $hf_user${RESET}"
}