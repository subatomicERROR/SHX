#!/bin/bash
set -euo pipefail

# === ENV VARIABLES ===
export SHX_HOME="$HOME/dev/shx"
export SHX_LOG_FILE="$SHX_HOME/shx.log"
export SHX_PIPELINES_DIR="$SHX_HOME/pipelines"
export SHX_WORKSPACES_DIR="$SHX_HOME/workspaces"
export SHX_LANDING_PAGE_DIR="$SHX_HOME/landing-page"
export SHX_MARKETPLACE_DIR="$SHX_HOME/marketplace"
export SHX_EXTENSIONS_DIR="$SHX_HOME/extensions"
export SHX_AUTH_DIR="$SHX_HOME/auth"
export SHX_CORE_DIR="$SHX_HOME/core"
export SHX_TEMPLATES_DIR="$SHX_HOME/templates"
export SHX_USERS_DIR="$SHX_HOME/users"
export SHX_MODULES_DIR="$SHX_HOME/modules"

# === COLORS ===
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
CYAN="\e[96m"
RESET="\e[0m"

# === SELF-HEAL ===
trap 'echo -e "\n${RED}❌ Error occurred at line $LINENO: $BASH_COMMAND${RESET}" >> "$SHX_LOG_FILE"; echo -e "${YELLOW}🔧 Triggering SHX Self-Healing...${RESET}"; shx_self_heal $LINENO "$BASH_COMMAND"' ERR

shx_self_heal() {
    local line=$1
    local cmd="$2"
    echo -e "${CYAN}🛠 Self-Healing (Line $line | Command: $cmd)${RESET}"

    if [[ "$cmd" == *"pip install"* ]]; then
        echo -e "${YELLOW}🔁 Retrying pip install with --no-cache-dir...${RESET}"
        pip install --no-cache-dir transformers torch gradio git-lfs huggingface_hub || true
    fi

    if [[ "$cmd" == *"huggingface-cli login"* ]]; then
        echo -e "${YELLOW}🔁 Retrying interactive Hugging Face login...${RESET}"
        huggingface-cli login || true
    fi

    if [[ "$cmd" == *"git push"* ]]; then
        echo -e "${YELLOW}🔁 Retrying git push...${RESET}"
        git push -u origin main || true
    fi

    echo -e "${GREEN}✅ Self-Heal Complete. Please rerun if needed.${RESET}"
    exit 1
}

# === LOGGING ===
shx_log() {
    local message="$1"
    echo -e "${message}" >> "$SHX_LOG_FILE"
    echo -e "${message}"
}

# === USAGE ===
usage() {
    echo -e "${CYAN}🚀 SHX: Shell-based Hyper-Automation eXecutor\n${RESET}"
    echo -e "Usage: $0 <command> [args]"
    echo -e "Commands:"
    echo -e "  login [github|hf]  - Login to GitHub or Hugging Face"
    echo -e "  logout [github|hf] - Logout from GitHub or Hugging Face"
    echo -e "  create [project-type]  - Create a new project using a pipeline script"
    echo -e "  generate [script-name] - Generate a new pipeline script"
    echo -e "  push [project-dir]     - Push a project to a remote Git repository"
    echo -e "  setup-landing-page     - Set up and deploy the SHX landing page to GitHub Pages"
    echo -e "  init                   - Initialize SHX"
    echo -e "  install [module]       - Install a module from the marketplace"
    echo -e "  run [module]           - Run a module"
    echo -e "  unlock [key]           - Unlock premium features"
    echo -e "  sync                   - Sync configurations and scripts to Hugging Face Space"
    echo -e "Available project types:"
    for script in "$SHX_PIPELINES_DIR"/*.sh; do
        echo -e "  - $(basename "$script" .sh)"
    done
    exit 1
}

# === INIT ===
shx_init() {
    if [ ! -d "$SHX_HOME" ]; then
        shx_log "${CYAN}🛠 Initializing SHX Home Directory...${RESET}"
        mkdir -p "$SHX_HOME" "$SHX_PIPELINES_DIR" "$SHX_WORKSPACES_DIR" "$SHX_LANDING_PAGE_DIR" "$SHX_MARKETPLACE_DIR" "$SHX_EXTENSIONS_DIR" "$SHX_AUTH_DIR" "$SHX_CORE_DIR" "$SHX_TEMPLATES_DIR" "$SHX_USERS_DIR" "$SHX_MODULES_DIR"
        touch "$SHX_LOG_FILE"
        shx_log "${GREEN}✅ SHX Home Directory Initialized at $SHX_HOME${RESET}"
    else
        shx_log "${YELLOW}⚠️ SHX Home Directory already exists at $SHX_HOME${RESET}"
    fi

    # Create necessary files
    shx_create_files
}

# === CREATE FILES ===
shx_create_files() {
    # Create auth files
    cat <<EOF > "$SHX_AUTH_DIR/github.sh"
#!/bin/bash
set -euo pipefail

# === GitHub Login Script ===
echo -e "🔐 ${CYAN}Starting Git Login via Personal Access Token...${RESET}"

    read -p "📝 GitHub Username: " gh_user
    read -s -p "🔑 GitHub Personal Access Token (Paste hidden): " gh_token
    echo ""

    if [ -z "$gh_user" ] || [ -z "$gh_token" ]; then
        shx_log "${RED}❌ GitHub username or token cannot be empty. Please try again.${RESET}"
        exit 1
    fi

    mkdir -p "$HOME/.shx"
    echo "username=$gh_user" > "$HOME/.shx/github.cfg"
    echo "token=$gh_token" >> "$HOME/.shx/github.cfg"

shx_log "${GREEN}✅ GitHub login saved for user: $gh_user${RESET}"
EOF
    chmod +x "$SHX_AUTH_DIR/github.sh"

    cat <<EOF > "$SHX_AUTH_DIR/huggingface.sh"
#!/bin/bash
set -euo pipefail

# === Hugging Face Login Script ===
echo -e "🤖 ${CYAN}Starting Hugging Face Login...${RESET}"

    read -p "📝 Hugging Face Username: " hf_user
    read -s -p "🔑 Hugging Face Token (Paste hidden): " hf_token
    echo ""

    if [ -z "$hf_user" ] || [ -z "$hf_token" ]; then
        shx_log "${RED}❌ Hugging Face username or token cannot be empty. Please try again.${RESET}"
        exit 1
    fi

    mkdir -p "$HOME/.shx"
    echo "username=$hf_user" > "$HOME/.shx/hf.cfg"
    echo "token=$hf_token" >> "$HOME/.shx/hf.cfg"

shx_log "${GREEN}✅ Hugging Face login saved for user: $hf_user${RESET}"
EOF
    chmod +x "$SHX_AUTH_DIR/huggingface.sh"

    cat <<EOF > "$SHX_AUTH_DIR/login.sh"
#!/bin/bash
set -euo pipefail

# === Login Entry Point ===
case "$1" in
    github) "$SHX_AUTH_DIR/github.sh" ;;
    hf) "$SHX_AUTH_DIR/huggingface.sh" ;;
    *) echo "Usage: shx login [github|hf]" ;;
esac
EOF
    chmod +x "$SHX_AUTH_DIR/login.sh"

    cat <<EOF > "$SHX_AUTH_DIR/logout.sh"
#!/bin/bash
set -euo pipefail

# === Logout Entry Point ===
case "$1" in
    github) "$SHX_AUTH_DIR/github_logout.sh" ;;
    hf) "$SHX_AUTH_DIR/huggingface_logout.sh" ;;
    *) echo "Usage: shx logout [github|hf]" ;;
esac
EOF
    chmod +x "$SHX_AUTH_DIR/logout.sh"

    cat <<EOF > "$SHX_AUTH_DIR/github_logout.sh"
#!/bin/bash
set -euo pipefail

# === GitHub Logout Script ===
echo -e "🔐 ${CYAN}Logging out of GitHub...${RESET}"

if [ -f "$HOME/.shx/github.cfg" ]; then
    rm -f "$HOME/.shx/github.cfg"
    shx_log "${GREEN}✅ Successfully logged out of GitHub.${RESET}"
else
    shx_log "${YELLOW}⚠️ You are not logged into GitHub.${RESET}"
fi
EOF
    chmod +x "$SHX_AUTH_DIR/github_logout.sh"

    cat <<EOF > "$SHX_AUTH_DIR/huggingface_logout.sh"
#!/bin/bash
set -euo pipefail

# === Hugging Face Logout Script ===
echo -e "🤖 ${CYAN}Logging out of Hugging Face...${RESET}"

if [ -f "$HOME/.shx/hf.cfg" ]; then
    rm -f "$HOME/.shx/hf.cfg"
    shx_log "${GREEN}✅ Successfully logged out of Hugging Face.${RESET}"
else
    shx_log "${YELLOW}⚠️ You are not logged into Hugging Face.${RESET}"
fi
EOF
    chmod +x "$SHX_AUTH_DIR/huggingface_logout.sh"

    # Create core files
    cat <<EOF > "$SHX_CORE_DIR/create.sh"
#!/bin/bash
set -euo pipefail

# === Create Project Script ===
local project_type="$1"
local pipeline_script="$SHX_PIPELINES_DIR/\$project_type.sh"

if [ ! -f "\$pipeline_script" ]; then
    shx_log "\${RED}❌ Pipeline script for '\$project_type' not found.\${RESET}"
    usage
fi

shx_log "\${CYAN}🛠 Running Pipeline Script for \$project_type...\${RESET}"
bash "\$pipeline_script"
shx_log "\${GREEN}✅ Project \$project_type created successfully.\${RESET}"
EOF
    chmod +x "$SHX_CORE_DIR/create.sh"

    cat <<EOF > "$SHX_CORE_DIR/init.sh"
#!/bin/bash
set -euo pipefail

# === Initialize SHX Script ===
shx_init
EOF
    chmod +x "$SHX_CORE_DIR/init.sh"

    cat <<EOF > "$SHX_CORE_DIR/push.sh"
#!/bin/bash
set -euo pipefail

# === Push Project Script ===
local project_dir="\$1"

if [ ! -d "\$project_dir" ]; then
    shx_log "\${RED}❌ Project directory \$project_dir not found.\${RESET}"
    exit 1
fi

cd "\$project_dir"

if [ ! -d ".git" ]; then
    shx_log "\${YELLOW}⚠️ Initializing Git repository in \$project_dir...\${RESET}"
    git init
fi

shx_log "\${CYAN}🛠 Adding all files to Git...\${RESET}"
git add .

read -p "📝 Commit message: " commit_message
shx_log "\${CYAN}🛠 Committing changes...\${RESET}"
git commit -m "\$commit_message"

read -p "📝 Remote repository URL (e.g., https://github.com/username/repo.git): " remote_url
shx_log "\${CYAN}🛠 Setting up remote repository...\${RESET}"
git remote add origin "\$remote_url"

shx_log "\${CYAN}🛠 Pushing changes to remote repository...\${RESET}"
git push -u origin main

shx_log "\${GREEN}✅ Changes pushed to remote repository successfully.\${RESET}"
EOF
    chmod +x "$SHX_CORE_DIR/push.sh"

    cat <<EOF > "$SHX_CORE_DIR/sync.sh"
#!/bin/bash
set -euo pipefail

# === Sync Script ===
local sync_dir="\$SHX_HOME"
local remote_repo="https://github.com/subatomicERROR/SHX-sync.git"

if [ ! -d "\$sync_dir" ]; then
    shx_log "\${RED}❌ Sync directory \$sync_dir not found.\${RESET}"
    exit 1
fi

cd "\$sync_dir"

if [ ! -d ".git" ]; then
    shx_log "\${YELLOW}⚠️ Initializing Git repository in \$sync_dir...\${RESET}"
    git init
fi

shx_log "\${CYAN}🛠 Adding all files to Git...\${RESET}"
git add .

read -p "📝 Commit message: " commit_message
shx_log "\${CYAN}🛠 Committing changes...\${RESET}"
git commit -m "\$commit_message"

read -p "📝 Remote repository URL (e.g., https://github.com/username/repo.git): " remote_url
shx_log "\${CYAN}🛠 Setting up remote repository...\${RESET}"
git remote add origin "\$remote_url"

shx_log "\${CYAN}🛠 Pushing changes to remote repository...\${RESET}"
git push -u origin main

shx_log "\${GREEN}✅ Changes synced to remote repository successfully.\${RESET}"
EOF
    chmod +x "$SHX_CORE_DIR/sync.sh"

    cat <<EOF > "$SHX_CORE_DIR/unlock.sh"
#!/bin/bash
set -euo pipefail

# === Unlock Premium Script ===
local key="\$1"
local key_file="\$HOME/.shx/premium.key"

if [ -f "\$key_file" ]; then
    shx_log "\${RED}❌ Premium key already activated.\${RESET}"
    exit 1
fi

echo "key=\$key" > "\$key_file"
shx_log "\${GREEN}✅ Premium features unlocked with key: \$key\${RESET}"
EOF
    chmod +x "$SHX_CORE_DIR/unlock.sh"

    # Create landing page setup script
    cat <<EOF > "$SHX_LANDING_PAGE_DIR/setup.sh"
#!/bin/bash
set -euo pipefail

# === Setup Landing Page Script ===
echo -e "\${CYAN}🛠 Setting up Landing Page for GitHub Pages...\${RESET}"

# 1. Create landing page directory
mkdir -p "\$SHX_LANDING_PAGE_DIR"
cd "\$SHX_LANDING_PAGE_DIR"

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
shx_log "\${GREEN}🌍 Deployed at: https://subatomicERROR.github.io/SHX\${RESET}"
EOF
    chmod +x "$SHX_LANDING_PAGE_DIR/setup.sh"

    # Create marketplace files
    cat <<EOF > "$SHX_MARKETPLACE_DIR/ai-blog-writer.sh"
#!/bin/bash
set -euo pipefail

# === AI Blog Writer Module ===
echo -e "\${CYAN}🛠 Running AI Blog Writer Module...\${RESET}"
# TODO: Add your AI blog writer logic here
EOF
    chmod +x "$SHX_MARKETPLACE_DIR/ai-blog-writer.sh"

    cat <<EOF > "$SHX_MARKETPLACE_DIR/install.sh"
#!/bin/bash
set -euo pipefail

# === Install Module Script ===
local module_name="\$1"
local module_path="\$SHX_MARKETPLACE_DIR/\$module_name.sh"

if [ -f "\$module_path" ]; then
    shx_log "\${RED}❌ Module \$module_name already installed.\${RESET}"
    exit 1
fi

# Download module from marketplace
curl -sL https://raw.githubusercontent.com/subatomicERROR/SHX-marketplace/main/\$module_name.sh -o "\$module_path"
chmod +x "\$module_path"

shx_log "\${GREEN}✅ Module \$module_name installed successfully.\${RESET}"
EOF
    chmod +x "$SHX_MARKETPLACE_DIR/install.sh"

    cat <<EOF > "$SHX_MARKETPLACE_DIR/run.sh"
#!/bin/bash
set -euo pipefail

# === Run Module Script ===
local module_name="\$1"
local module_path="\$SHX_MARKETPLACE_DIR/\$module_name.sh"

if [ ! -f "\$module_path" ]; then
    shx_log "\${RED}❌ Module \$module_name not found. Try installing it first.\${RESET}"
    exit 1
fi

shx_log "\${CYAN}🛠 Running Module \$module_name...\${RESET}"
bash "\$module_path"
shx_log "\${GREEN}✅ Module \$module_name executed successfully.\${RESET}"
EOF
    chmod +x "$SHX_MARKETPLACE_DIR/run.sh"

    # Create pipeline templates
    cat <<EOF > "$SHX_PIPELINES_DIR/landing-page.sh"
#!/bin/bash
set -euo pipefail

# === Landing Page Pipeline ===
echo -e "\${CYAN}🛠 Running Landing Page Pipeline...\${RESET}"
# TODO: Add your landing page creation logic here
EOF
    chmod +x "$SHX_PIPELINES_DIR/landing-page.sh"

    cat <<EOF > "$SHX_PIPELINES_DIR/saas-app.sh"
#!/bin/bash
set -euo pipefail

# === SaaS App Pipeline ===
echo -e "\${CYAN}🛠 Running SaaS App Pipeline...\${RESET}"
# TODO: Add your SaaS app creation logic here
EOF
    chmod +x "$SHX_PIPELINES_DIR/saas-app.sh"

    # Create main SHX script
    cat <<EOF > "$SHX_HOME/shx.sh"
#!/bin/bash
set -euo pipefail

# === ENV VARIABLES ===
export SHX_HOME="$HOME/dev/shx"
export SHX_LOG_FILE="\$SHX_HOME/shx.log"
export SHX_PIPELINES_DIR="\$SHX_HOME/pipelines"
export SHX_WORKSPACES_DIR="\$SHX_HOME/workspaces"
export SHX_LANDING_PAGE_DIR="\$SHX_HOME/landing-page"
export SHX_MARKETPLACE_DIR="\$SHX_HOME/marketplace"
export SHX_EXTENSIONS_DIR="\$SHX_HOME/extensions"
export SHX_AUTH_DIR="\$SHX_HOME/auth"
export SHX_CORE_DIR="\$SHX_HOME/core"
export SHX_TEMPLATES_DIR="\$SHX_HOME/templates"
export SHX_USERS_DIR="\$SHX_HOME/users"
export SHX_MODULES_DIR="\$SHX_HOME/modules"

# === COLORS ===
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
CYAN="\e[96m"
RESET="\e[0m"

# === SELF-HEAL ===
trap 'echo -e "\n\${RED}❌ Error occurred at line \$LINENO: \$BASH_COMMAND\${RESET}" >> "\$SHX_LOG_FILE"; echo -e "\${YELLOW}🔧 Triggering SHX Self-Healing...\${RESET}"; shx_self_heal \$LINENO "\$BASH_COMMAND"' ERR

shx_self_heal() {
    local line=\$1
    local cmd="\$2"
    echo -e "\${CYAN}🛠 Self-Healing (Line \$line | Command: \$cmd)\${RESET}"

    if [[ "\$cmd" == *"pip install"* ]]; then
        echo -e "\${YELLOW}🔁 Retrying pip install with --no-cache-dir...\${RESET}"
        pip install --no-cache-dir transformers torch gradio git-lfs huggingface_hub || true
    fi

    if [[ "\$cmd" == *"huggingface-cli login"* ]]; then
        echo -e "\${YELLOW}🔁 Retrying interactive Hugging Face login...\${RESET}"
        huggingface-cli login || true
    fi

    if [[ "\$cmd" == *"git push"* ]]; then
        echo -e "\${YELLOW}🔁 Retrying git push...\${RESET}"
        git push -u origin main || true
    fi

    echo -e "\${GREEN}✅ Self-Heal Complete. Please rerun if needed.\${RESET}"
    exit 1
}

# === LOGGING ===
shx_log() {
    local message="\$1"
    echo -e "\${message}" >> "\$SHX_LOG_FILE"
    echo -e "\${message}"
}

# === USAGE ===
usage() {
    echo -e "\${CYAN}🚀 SHX: Shell-based Hyper-Automation eXecutor\n\${RESET}"
    echo -e "Usage: \$0 <command> [args]"
    echo -e "Commands:"
    echo -e "  login [github|hf]  - Login to GitHub or Hugging Face"
    echo -e "  logout [github|hf] - Logout from GitHub or Hugging Face"
    echo -e "  create [project-type]  - Create a new project using a pipeline script"
    echo -e "  generate [script-name] - Generate a new pipeline script"
    echo -e "  push [project-dir]     - Push a project to a remote Git repository"
    echo -e "  setup-landing-page     - Set up and deploy the SHX landing page to GitHub Pages"
    echo -e "  init                   - Initialize SHX"
    echo -e "  install [module]       - Install a module from the marketplace"
    echo -e "  run [module]           - Run a module"
    echo -e "  unlock [key]           - Unlock premium features"
    echo -e "  sync                   - Sync configurations and scripts to Hugging Face Space"
    echo -e "Available project types:"
    for script in "\$SHX_PIPELINES_DIR"/*.sh; do
        echo -e "  - \$(basename "\$script" .sh)"
    done
    exit 1
}

# === MAIN ===
shx_main() {
    shx_init

    case "\$1" in
        login)
            case "\$2" in
                github) "\$SHX_AUTH_DIR/github.sh" ;;
                hf) "\$SHX_AUTH_DIR/huggingface.sh" ;;
                *) echo "Usage: shx login [github|hf]" ;;
            esac
            ;;
        logout)
            case "\$2" in
                github) "\$SHX_AUTH_DIR/github_logout.sh" ;;
                hf) "\$SHX_AUTH_DIR/huggingface_logout.sh" ;;
                *) echo "Usage: shx logout [github|hf]" ;;
            esac
            ;;
        create)
            if [ -z "\$2" ]; then usage; fi
            "\$SHX_CORE_DIR/create.sh" "\$2"
            ;;
        generate)
            if [ -z "\$2" ]; then
                shx_log "\${RED}❌ Please provide a script name to generate.\${RESET}"
                exit 1
            fi
            "\$SHX_CORE_DIR/generate.sh" "\$2"
            ;;
        push)
            if [ -z "\$2" ]; then
                shx_log "\${RED}❌ Please provide a project directory to push.\${RESET}"
                exit 1
            fi
            "\$SHX_CORE_DIR/push.sh" "\$2"
            ;;
        setup-landing-page)
            "\$SHX_LANDING_PAGE_DIR/setup.sh"
            ;;
        init)
            shx_init
            ;;
        install)
            if [ -z "\$2" ]; then
                shx_log "\${RED}❌ Please provide a module name to install.\${RESET}"
                exit 1
            fi
            "\$SHX_MARKETPLACE_DIR/install.sh" "\$2"
            ;;
        run)
            if [ -z "\$2" ]; then
                shx_log "\${RED}❌ Please provide a module name to run.\${RESET}"
                exit 1
            fi
            "\$SHX_MARKETPLACE_DIR/run.sh" "\$2"
            ;;
        unlock)
            if [ -z "\$2" ]; then
                shx_log "\${RED}❌ Please provide a premium key to unlock.\${RESET}"
                exit 1
            fi
            "\$SHX_CORE_DIR/unlock.sh" "\$2"
            ;;
        sync)
            "\$SHX_CORE_DIR/sync.sh"
            ;;
        *)
            usage
            ;;
    esac
}

# === ENTRY POINT ===
shx_main "\$@"
EOF
    chmod +x "$SHX_HOME/shx.sh"

    shx_log "${GREEN}✅ All necessary files and directories created successfully.${RESET}"
}

# === MAIN ===
shx_init
