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
        mkdir -p "$SHX_HOME" "$SHX_PIPELINES_DIR" "$SHX_WORKSPACES_DIR" "$SHX_LANDING_PAGE_DIR" "$SHX_MARKETPLACE_DIR" "$SHX_EXTENSIONS_DIR" "$SHX_AUTH_DIR"
        touch "$SHX_LOG_FILE"
        shx_log "${GREEN}✅ SHX Home Directory Initialized at $SHX_HOME${RESET}"
    else
        shx_log "${YELLOW}⚠️ SHX Home Directory already exists at $SHX_HOME${RESET}"
    fi
}

# === CREATE PROJECT ===
shx_create_project() {
    local project_type="$1"
    local pipeline_script="$SHX_PIPELINES_DIR/$project_type.sh"

    if [ ! -f "$pipeline_script" ]; then
        shx_log "${RED}❌ Pipeline script for '$project_type' not found.${RESET}"
        usage
    fi

    shx_log "${CYAN}🛠 Running Pipeline Script for $project_type...${RESET}"
    bash "$pipeline_script"
    shx_log "${GREEN}✅ Project $project_type created successfully.${RESET}"
}

# === GENERATE NEW SCRIPT ===
shx_generate_script() {
    local script_name="$1"
    local script_path="$SHX_PIPELINES_DIR/$script_name.sh"

    if [ -f "$script_path" ]; then
        shx_log "${RED}❌ Script $script_name.sh already exists.${RESET}"
        exit 1
    fi

    cat <<EOF > "$script_path"
#!/bin/bash
set -euo pipefail

# === $script_name Pipeline ===
echo "🚀 Running $script_name pipeline..."
# TODO: Add your automation logic here

EOF

    chmod +x "$script_path"
    shx_log "${GREEN}✅ Generated new pipeline script at $script_path${RESET}"
}

# === GIT LOGIN ===
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

# === HUGGING FACE LOGIN ===
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

# === GIT LOGOUT ===
shx_logout_github() {
    echo -e "🔐 ${CYAN}Logging out of GitHub...${RESET}"

    if [ -f "$HOME/.shx/github.cfg" ]; then
        rm -f "$HOME/.shx/github.cfg"
        shx_log "${GREEN}✅ Successfully logged out of GitHub.${RESET}"
    else
        shx_log "${YELLOW}⚠️ You are not logged into GitHub.${RESET}"
    fi
}

# === HUGGING FACE LOGOUT ===
shx_logout_hf() {
    echo -e "🤖 ${CYAN}Logging out of Hugging Face...${RESET}"

    if [ -f "$HOME/.shx/hf.cfg" ]; then
        rm -f "$HOME/.shx/hf.cfg"
        shx_log "${GREEN}✅ Successfully logged out of Hugging Face.${RESET}"
    else
        shx_log "${YELLOW}⚠️ You are not logged into Hugging Face.${RESET}"
    fi
}

# === PUSH ===
shx_push() {
    local project_dir="$1"

    if [ ! -d "$project_dir" ]; then
        shx_log "${RED}❌ Project directory $project_dir not found.${RESET}"
        exit 1
    fi

    cd "$project_dir"

    if [ ! -d ".git" ]; then
        shx_log "${YELLOW}⚠️ Initializing Git repository in $project_dir...${RESET}"
        git init
    fi

    shx_log "${CYAN}🛠 Adding all files to Git...${RESET}"
    git add .

    read -p "📝 Commit message: " commit_message
    shx_log "${CYAN}🛠 Committing changes...${RESET}"
    git commit -m "$commit_message"

    read -p "📝 Remote repository URL (e.g., https://github.com/username/repo.git): " remote_url
    shx_log "${CYAN}🛠 Setting up remote repository...${RESET}"
    git remote add origin "$remote_url"

    shx_log "${CYAN}🛠 Pushing changes to remote repository...${RESET}"
    git push -u origin main

    shx_log "${GREEN}✅ Changes pushed to remote repository successfully.${RESET}"
}

# === SETUP LANDING PAGE ===
shx_setup_landing_page() {
    echo -e "${CYAN}🛠 Setting up Landing Page for GitHub Pages...${RESET}"

    # 1. Create landing page directory
    mkdir -p "$SHX_LANDING_PAGE_DIR"
    cd "$SHX_LANDING_PAGE_DIR"

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
    shx_log "${GREEN}🌍 Deployed at: https://subatomicERROR.github.io/SHX${RESET}"
}

# === INSTALL MODULE ===
shx_install_module() {
    local module_name="$1"
    local module_path="$SHX_MARKETPLACE_DIR/$module_name.sh"

    if [ -f "$module_path" ]; then
        shx_log "${RED}❌ Module $module_name already installed.${RESET}"
        exit 1
    fi

    # Download module from marketplace
    curl -sL https://raw.githubusercontent.com/subatomicERROR/SHX-marketplace/main/$module_name.sh -o "$module_path"
    chmod +x "$module_path"

    shx_log "${GREEN}✅ Module $module_name installed successfully.${RESET}"
}

# === RUN MODULE ===
shx_run_module() {
    local module_name="$1"
    local module_path="$SHX_MARKETPLACE_DIR/$module_name.sh"

    if [ ! -f "$module_path" ]; then
        shx_log "${RED}❌ Module $module_name not found. Try installing it first.${RESET}"
        exit 1
    fi

    shx_log "${CYAN}🛠 Running Module $module_name...${RESET}"
    bash "$module_path"
    shx_log "${GREEN}✅ Module $module_name executed successfully.${RESET}"
}

# === UNLOCK PREMIUM ===
shx_unlock_premium() {
    local key="$1"
    local key_file="$HOME/.shx/premium.key"

    if [ -f "$key_file" ]; then
        shx_log "${RED}❌ Premium key already activated.${RESET}"
        exit 1
    fi

    echo "key=$key" > "$key_file"
    shx_log "${GREEN}✅ Premium features unlocked with key: $key${RESET}"
}

# === SYNC ===
shx_sync() {
    local sync_dir="$SHX_HOME"
    local remote_repo="https://github.com/subatomicERROR/SHX-sync.git"

    if [ ! -d "$sync_dir" ]; then
        shx_log "${RED}❌ Sync directory $sync_dir not found.${RESET}"
        exit 1
    fi

    cd "$sync_dir"

    if [ ! -d ".git" ]; then
        shx_log "${YELLOW}⚠️ Initializing Git repository in $sync_dir...${RESET}"
        git init
    fi

    shx_log "${CYAN}🛠 Adding all files to Git...${RESET}"
    git add .

    read -p "📝 Commit message: " commit_message
    shx_log "${CYAN}🛠 Committing changes...${RESET}"
    git commit -m "$commit_message"

    read -p "📝 Remote repository URL (e.g., https://github.com/username/repo.git): " remote_url
    shx_log "${CYAN}🛠 Setting up remote repository...${RESET}"
    git remote add origin "$remote_url"

    shx_log "${CYAN}🛠 Pushing changes to remote repository...${RESET}"
    git push -u origin main

    shx_log "${GREEN}✅ Changes synced to remote repository successfully.${RESET}"
}

# === MAIN ===
shx_main() {
    shx_init

    case "$1" in
        login)
            case "$2" in
                github) shx_login_github ;;
                hf) shx_login_hf ;;
                *) echo "Usage: shx login [github|hf]" ;;
            esac
            ;;
        logout)
            case "$2" in
                github) shx_logout_github ;;
                hf) shx_logout_hf ;;
                *) echo "Usage: shx logout [github|hf]" ;;
            esac
            ;;
        create)
            if [ -z "$2" ]; then usage; fi
            shx_create_project "$2"
            ;;
        generate)
            if [ -z "$2" ]; then
                shx_log "${RED}❌ Please provide a script name to generate.${RESET}"
                exit 1
            fi
            shx_generate_script "$2"
            ;;
        push)
            if [ -z "$2" ]; then
                shx_log "${RED}❌ Please provide a project directory to push.${RESET}"
                exit 1
            fi
            shx_push "$2"
            ;;
        setup-landing-page)
            shx_setup_landing_page
            ;;
        init)
            shx_init
            ;;
        install)
            if [ -z "$2" ]; then
                shx_log "${RED}❌ Please provide a module name to install.${RESET}"
                exit 1
            fi
            shx_install_module "$2"
            ;;
        run)
            if [ -z "$2" ]; then
                shx_log "${RED}❌ Please provide a module name to run.${RESET}"
                exit 1
            fi
            shx_run_module "$2"
            ;;
        unlock)
            if [ -z "$2" ]; then
                shx_log "${RED}❌ Please provide a premium key to unlock.${RESET}"
                exit 1
            fi
            shx_unlock_premium "$2"
            ;;
        sync)
            shx_sync
            ;;
        *)
            usage
            ;;
    esac
}

# === ENTRY POINT ===
shx_main "$@"
