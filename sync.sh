#!/usr/bin/env bash
# ==============================================================================
# Antigravity Skills Sync Tool
# Repository: https://github.com/borwonratsri/my-agent-skills
#
# Usage:
#   ./sync.sh status          Check difference between local skills and repo
#   ./sync.sh pull            Pull latest skills from GitHub and update local install
#   ./sync.sh push "message"  Collect local custom skills, commit, and push to GitHub
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

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
RULES_DIR="$SCRIPT_DIR/rules"
GLOBAL_CONFIG_DIR="$HOME/.gemini/config"
GLOBAL_SKILLS_DIR="$GLOBAL_CONFIG_DIR/skills"
GLOBAL_RULES_DIR="$GLOBAL_CONFIG_DIR/rules"
WORKSPACE_SKILLS_DIR="$(pwd)/.agents/skills"

ACTION="${1:-status}"

cd "$SCRIPT_DIR"

show_help() {
    cat << EOF
${BOLD}Antigravity Skills Sync Tool${RESET}

Usage:
  ./sync.sh [command] [options]

Commands:
  status             Show status of repository and local skill directories (Default)
  pull               Pull updates from GitHub and re-install to ~/.gemini/config/skills
  push [message]     Collect local skills from ~/.gemini/config/skills, commit & push to GitHub
  help               Show this help message
EOF
    exit 0
}

case "$ACTION" in
    status)
        echo -e "${BOLD}${CYAN}=== Skills Repository Status ===${RESET}"
        git status -s
        echo ""
        echo -e "${BOLD}Repo Skills in $SKILLS_DIR:${RESET}"
        ls -1 "$SKILLS_DIR" 2>/dev/null | sed 's/^/  • /' || echo "  (None)"
        echo ""
        echo -e "${BOLD}Installed Global Skills in $GLOBAL_SKILLS_DIR:${RESET}"
        if [[ -d "$GLOBAL_SKILLS_DIR" ]]; then
            ls -1 "$GLOBAL_SKILLS_DIR" 2>/dev/null | sed 's/^/  • /' || echo "  (None)"
        else
            echo "  (Directory does not exist yet)"
        fi
        ;;

    pull)
        echo -e "${YELLOW}Pulling latest changes from GitHub...${RESET}"
        git pull --rebase origin main
        echo -e "${GREEN}Running install.sh to update local skills...${RESET}"
        "$SCRIPT_DIR/install.sh" --global
        ;;

    push)
        COMMIT_MSG="${2:-Update skills}"
        echo -e "${YELLOW}Gathering local skills...${RESET}"

        # Sync from global skills directory if exists
        if [[ -d "$GLOBAL_SKILLS_DIR" ]]; then
            for skill_path in "$GLOBAL_SKILLS_DIR"/*; do
                if [[ -d "$skill_path" ]]; then
                    name="$(basename "$skill_path")"
                    mkdir -p "$SKILLS_DIR/$name"
                    cp -r "$skill_path/"* "$SKILLS_DIR/$name/"
                    echo -e "  ${GREEN}+${RESET} Synced global: ${BOLD}$name${RESET}"
                fi
            done
        fi

        # Sync from workspace skills if exists and different
        if [[ -d "$WORKSPACE_SKILLS_DIR" && "$WORKSPACE_SKILLS_DIR" != "$SKILLS_DIR" ]]; then
            for skill_path in "$WORKSPACE_SKILLS_DIR"/*; do
                if [[ -d "$skill_path" ]]; then
                    name="$(basename "$skill_path")"
                    mkdir -p "$SKILLS_DIR/$name"
                    cp -r "$skill_path/"* "$SKILLS_DIR/$name/"
                    echo -e "  ${GREEN}+${RESET} Synced workspace: ${BOLD}$name${RESET}"
                fi
            done
        fi

        # Sync from global rules directory if exists
        if [[ -d "$GLOBAL_RULES_DIR" ]]; then
            mkdir -p "$RULES_DIR"
            for rule_path in "$GLOBAL_RULES_DIR"/*.md; do
                if [[ -f "$rule_path" ]]; then
                    name="$(basename "$rule_path")"
                    sed "s|$HOME/.gemini/config|~/.gemini/config|g" "$rule_path" > "$RULES_DIR/$name"
                    echo -e "  ${GREEN}+${RESET} Synced global rule: ${BOLD}$name${RESET}"
                fi
            done
        fi

        if [[ -f "$GLOBAL_CONFIG_DIR/AGENTS.template.md" ]]; then
            cp "$GLOBAL_CONFIG_DIR/AGENTS.template.md" "$SCRIPT_DIR/AGENTS.template.md"
            echo -e "  ${GREEN}+${RESET} Synced AGENTS.template.md"
        fi

        git add .
        if git diff-index --quiet HEAD -- 2>/dev/null; then
            echo -e "${BLUE}No changes to commit.${RESET}"
        else
            git commit -m "$COMMIT_MSG"
            echo -e "${YELLOW}Pushing to GitHub...${RESET}"
            git push origin main
            echo -e "${BOLD}${GREEN}✓ Successfully synced and pushed to GitHub!${RESET}"
        fi
        ;;

    help|-h|--help)
        show_help
        ;;

    *)
        echo -e "${RED}Unknown command: $ACTION${RESET}"
        show_help
        ;;
esac
