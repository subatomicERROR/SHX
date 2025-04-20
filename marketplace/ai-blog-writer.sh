#!/bin/bash
set -euo pipefail

# === AI Blog Writer Module ===
echo "🚀 Running AI Blog Writer Module..."

# 1. Create project directory
mkdir -p "$SHX_WORKSPACES_DIR/ai-blog-writer"
cd "$SHX_WORKSPACES_DIR/ai-blog-writer"

# 2. Initialize project
echo "This is an AI-generated blog post." > blog-post.md

# 3. Initialize Git repo
git init
git add .
git commit -m "Initial commit"

# 4. Push to remote repository
read -p "📝 Remote repository URL (e.g., https://github.com/username/ai-blog-writer.git): " remote_url
git remote add origin "$remote_url"
git push -u origin main

shx_log "${GREEN}✅ AI Blog Writer project created and pushed to remote repository successfully.${RESET}"