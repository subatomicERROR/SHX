#!/bin/bash
set -euo pipefail

# === Push Project Script ===
project_dir="$1"

if [ ! -d "$project_dir" ]; then
    echo -e "${RED}❌ Project directory $project_dir not found.${RESET}"
    exit 1
fi

cd "$project_dir"

if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠️ Initializing Git repository in $project_dir...${RESET}"
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

echo -e "${GREEN}✅ Changes pushed to remote repository successfully.${RESET}"