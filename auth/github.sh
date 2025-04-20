#!/bin/bash

shx_login_github() {
    echo -e "🔐 ${CYAN}Starting Git Login via Personal Access Token...${RESET}"

    read -p "📝 GitHub Username: " gh_user
    read -s -p "🔑 GitHub Personal Access Token (Paste hidden): " gh_token
    echo ""

    mkdir -p "$HOME/.shx"
    echo "username=$gh_user" > "$HOME/.shx/github.cfg"
    echo "token=$gh_token" >> "$HOME/.shx/github.cfg"

    shx_log "${GREEN}✅ GitHub login saved for user: $gh_user${RESET}"
}