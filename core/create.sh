#!/bin/bash
set -euo pipefail

# === Create Project Script ===
project_type="$1"
pipeline_script="$SHX_HOME/pipelines/$project_type.sh"

if [ ! -f "$pipeline_script" ]; then
    echo -e "${RED}❌ Pipeline script for '$project_type' not found.${RESET}"
    exit 1
fi

echo -e "${CYAN}🛠 Running Pipeline Script for $project_type...${RESET}"
bash "$pipeline_script"
echo -e "${GREEN}✅ Project $project_type created successfully.${RESET}"