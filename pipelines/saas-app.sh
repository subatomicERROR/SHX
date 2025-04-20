#!/bin/bash
set -euo pipefail

# === SaaS App Pipeline ===
echo "🚀 Running SaaS App Pipeline..."

# 1. Create project directory
mkdir -p "$SHX_WORKSPACES_DIR/saas-app"
cd "$SHX_WORKSPACES_DIR/saas-app"

# 2. Initialize Flask app
echo "from flask import Flask" > app.py
echo "app = Flask(__name__)" >> app.py
echo "@app.route('/')" >> app.py
echo "def hello_world():" >> app.py
echo "    return 'Hello, World!'" >> app.py

# 3. Create requirements file
echo "Flask==2.0.1" > requirements.txt

# 4. Initialize Git repo
git init
git add .
git commit -m "Initial commit"

# 5. Push to remote repository
read -p "📝 Remote repository URL (e.g., https://github.com/username/saas-app.git): " remote_url
git remote add origin "$remote_url"
git push -u origin main

shx_log "${GREEN}✅ SaaS App created and pushed to remote repository successfully.${RESET}"