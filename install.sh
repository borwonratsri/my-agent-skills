#!/usr/bin/env bash
# ==============================================================================
# Antigravity Skills Installer
# Repository: https://github.com/borwonratsri/my-agent-skills
#
# Quick install (Global - works everywhere):
#   curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
#
# Project-specific install (Current workspace only):
#   curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash -s -- --workspace
# ==============================================================================

set -euo pipefail

# ANSI Colors
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

REPO_OWNER="borwonratsri"
REPO_NAME="my-agent-skills"
DEFAULT_BRANCH="main"

show_help() {
    cat << EOF
${BOLD}Antigravity Skills Installer${RESET}

Usage:
  install.sh [options]
  curl -sSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${DEFAULT_BRANCH}/install.sh | bash -s -- [options]

Options:
  -g, --global       Install skills globally to ~/.gemini/config/skills (Default)
  -w, --workspace    Install skills to current workspace (./.agents/skills)
  -t, --target <dir> Install skills to a specific custom directory
  -h, --help         Show this help message

Examples:
  ./install.sh                # Install globally
  ./install.sh --workspace    # Install into current project
  ./install.sh -t /custom/dir # Install into custom path
EOF
    exit 0
}

# Parse options
MODE="global"
CUSTOM_TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--global)
            MODE="global"
            shift
            ;;
        -w|--workspace)
            MODE="workspace"
            shift
            ;;
        -t|--target)
            MODE="custom"
            CUSTOM_TARGET="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $1${RESET}" >&2
            show_help
            ;;
    esac
done

# Resolve Target Directory
if [[ "$MODE" == "global" ]]; then
    TARGET_DIR="$HOME/.gemini/config/skills"
elif [[ "$MODE" == "workspace" ]]; then
    TARGET_DIR="$(pwd)/.agents/skills"
elif [[ "$MODE" == "custom" ]]; then
    TARGET_DIR="$CUSTOM_TARGET"
fi

echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BOLD}${CYAN}   🚀 Antigravity Skills Installer (${REPO_OWNER}/${REPO_NAME})${RESET}"
echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BLUE}Mode:${RESET}   ${BOLD}${MODE}${RESET}"
echo -e "${BLUE}Target:${RESET} ${TARGET_DIR}"
echo ""

# Find source skills
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
TMP_DIR=""

if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/skills" ]]; then
    SKILLS_SOURCE="$SCRIPT_DIR/skills"
else
    # Running via pipe (curl | bash), download archive from GitHub
    echo -e "${YELLOW}Downloading latest skills from GitHub...${RESET}"
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    
    ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${DEFAULT_BRANCH}.tar.gz"
    if ! curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TMP_DIR"; then
        echo -e "${RED}Failed to download repository from GitHub.${RESET}" >&2
        exit 1
    fi
    SKILLS_SOURCE="$TMP_DIR/${REPO_NAME}-${DEFAULT_BRANCH}/skills"
fi

if [[ ! -d "$SKILLS_SOURCE" ]]; then
    echo -e "${RED}Error: Skills directory not found at $SKILLS_SOURCE${RESET}" >&2
    exit 1
fi

# Create target directory
mkdir -p "$TARGET_DIR"

COUNT=0
echo -e "${BOLD}Installing skills:${RESET}"
for skill_path in "$SKILLS_SOURCE"/*; do
    if [[ -d "$skill_path" ]]; then
        skill_name="$(basename "$skill_path")"
        dest_path="$TARGET_DIR/$skill_name"
        
        # Copy skill directory
        mkdir -p "$dest_path"
        cp -r "$skill_path/"* "$dest_path/"
        
        echo -e "  ${GREEN}✓${RESET} ${BOLD}${skill_name}${RESET}"
        COUNT=$((COUNT + 1))
    fi
done

echo ""
echo -e "${BOLD}${GREEN}🎉 Installation successful!${RESET}"
echo -e "Total skills installed: ${BOLD}${COUNT}${RESET} skills"
echo -e "Installed location:     ${CYAN}${TARGET_DIR}${RESET}"
echo ""
echo -e "Skills are now active and ready to be used by Antigravity in this environment!"
