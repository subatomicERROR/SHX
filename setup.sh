#!/bin/bash
set -euo pipefail

# === Setup Landing Page Script ===
echo -e "${CYAN}🛠 Setting up Landing Page for GitHub Pages...${RESET}"

# 1. Create landing page directory
mkdir -p "$SHX_HOME/landing-page"
cd "$SHX_HOME/landing-page"

# 2. Download default landing template (or copy locally)
curl -sL https://raw.githubusercontent.com/subatomicERROR/SHX/main/templates/index.html -o index.html

# 3. Initialize GH repo if not already
git init
git remote add origin https://github.com/subatomicERROR/SHX.git 2>/dev/null

# 4. Create gh-pages branch
git checkout -B gh-pages

# 5. Commit & push
git add .
git commit -m "🚀 SHX Automated Landing Page Setup"
git push origin gh-pages --force

# 6. Confirm deployment
echo -e "${GREEN}🌍 Deployed at: https://subatomicERROR.github.io/SHX${RESET}"