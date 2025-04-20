#!/bin/bash
set -euo pipefail

# === Sync Script ===
sync_dir="$SHX_HOME"
remote_repo="https://github.com/subatomicERROR/SHX-sync.git"

if [ ! -d "$sync_dir" ]; then
    echo -e "${RED}❌ Sync directory $sync_dir not found.${RESET}"
    exit 1
fi

cd "$sync_dir"

if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠️ Initializing Git repository in $sync_dir...${RESET}"
    git init
fi

echo -e "${CYAN}🛠 Adding all files to Git...${RESET}"
git add .

read -p "📝 Commit message: " commit_message
echo -e "${CYAN}🛠 Committing changes...${RESET}"
git commit -m "$commit_message"

read -p "📝 Remote repository URL (e.g., https://github.com/username/repo.git): " remote_url
echo -e "${CYAN}🛠 Setting up remote repository...${RESET}"
git remote add origin "$remote_url"

echo -e "${CYAN}🛠 Pushing changes to remote repository...${RESET}"
git push -u origin main

echo -e "${GREEN}✅ Changes synced to remote repository successfully.${RESET}"