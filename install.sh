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
  -p, --pstack       Also install the 60 isolated PStack Production Rigor skills
  --no-rules         Skip installing Global Rules (~/.gemini/config/rules)
  --no-plugins       Skip installing Plugins (~/.gemini/config/plugins & config.json registration)
  -h, --help         Show this help message

Examples:
  ./install.sh                # Install standard curated skills globally
  ./install.sh --pstack       # Install standard skills + PStack rigor suite
  ./install.sh --workspace    # Install into current project
  ./install.sh -t /custom/dir # Install into custom path
EOF
    exit 0
}

# Parse options
MODE="global"
CUSTOM_TARGET=""
INCLUDE_PSTACK=false
INSTALL_RULES=true
INSTALL_PLUGINS=true

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
        -p|--pstack)
            INCLUDE_PSTACK=true
            shift
            ;;
        --no-rules)
            INSTALL_RULES=false
            shift
            ;;
        --no-plugins)
            INSTALL_PLUGINS=false
            shift
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
    RULES_TARGET_DIR="$HOME/.gemini/config/rules"
elif [[ "$MODE" == "workspace" ]]; then
    TARGET_DIR="$(pwd)/.agents/skills"
    RULES_TARGET_DIR="$(pwd)/.agents/rules"
elif [[ "$MODE" == "custom" ]]; then
    TARGET_DIR="$CUSTOM_TARGET"
    RULES_TARGET_DIR="$(dirname "$CUSTOM_TARGET")/rules"
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

if [[ "$INCLUDE_PSTACK" == true ]]; then
    echo ""
    echo -e "${BOLD}${CYAN}Installing isolated PStack Production Rigor suite:${RESET}"
    PSTACK_SOURCE=""
    if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/pstack" ]]; then
        PSTACK_SOURCE="$SCRIPT_DIR/pstack"
    elif [[ -n "$TMP_DIR" && -d "$TMP_DIR/${REPO_NAME}-${DEFAULT_BRANCH}/pstack" ]]; then
        PSTACK_SOURCE="$TMP_DIR/${REPO_NAME}-${DEFAULT_BRANCH}/pstack"
    fi

    if [[ -n "$PSTACK_SOURCE" && -d "$PSTACK_SOURCE" ]]; then
        PSTACK_COUNT=0
        for pstack_path in "$PSTACK_SOURCE"/*; do
            if [[ -d "$pstack_path" ]]; then
                pstack_name="$(basename "$pstack_path")"
                dest_path="$TARGET_DIR/$pstack_name"
                mkdir -p "$dest_path"
                cp -r "$pstack_path/"* "$dest_path/"
                echo -e "  ${CYAN}🛡️${RESET} ${BOLD}${pstack_name}${RESET}"
                PSTACK_COUNT=$((PSTACK_COUNT + 1))
                COUNT=$((COUNT + 1))
            fi
        done
        echo -e "Installed ${BOLD}${PSTACK_COUNT}${RESET} PStack rigor skills."
    fi
fi

RULES_COUNT=0
if [[ "$INSTALL_RULES" == true ]]; then
    ROOT_SOURCE=""
    if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/rules" ]]; then
        ROOT_SOURCE="$SCRIPT_DIR"
    elif [[ -n "$TMP_DIR" && -d "$TMP_DIR/${REPO_NAME}-${DEFAULT_BRANCH}/rules" ]]; then
        ROOT_SOURCE="$TMP_DIR/${REPO_NAME}-${DEFAULT_BRANCH}"
    fi

    if [[ -n "$ROOT_SOURCE" && -d "$ROOT_SOURCE/rules" ]]; then
        echo ""
        echo -e "${BOLD}${BLUE}Installing Global Rules & Skill Playbook Router:${RESET}"
        mkdir -p "$RULES_TARGET_DIR"
        RESOLVED_GLOBAL_CONFIG="$HOME/.gemini/config"
        for rule_path in "$ROOT_SOURCE/rules"/*.md; do
            if [[ -f "$rule_path" ]]; then
                rule_name="$(basename "$rule_path")"
                sed "s|~/.gemini/config|${RESOLVED_GLOBAL_CONFIG}|g" "$rule_path" > "$RULES_TARGET_DIR/$rule_name"
                echo -e "  ${GREEN}✓${RESET} ${BOLD}${rule_name}${RESET}"
                RULES_COUNT=$((RULES_COUNT + 1))
            fi
        done

        if [[ -f "$ROOT_SOURCE/AGENTS.template.md" ]]; then
            mkdir -p "$HOME/.gemini/config"
            cp "$ROOT_SOURCE/AGENTS.template.md" "$HOME/.gemini/config/AGENTS.template.md"
            echo -e "  ${GREEN}✓${RESET} ${BOLD}AGENTS.template.md${RESET}"
        fi
    fi
fi

PLUGINS_COUNT=0
PLUGINS_TARGET_DIR="$HOME/.gemini/config/plugins"
if [[ "$INSTALL_PLUGINS" == true && "$MODE" == "global" ]]; then
    ROOT_SOURCE=""
    if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/plugins" ]]; then
        ROOT_SOURCE="$SCRIPT_DIR"
    elif [[ -n "$TMP_DIR" && -d "$TMP_DIR/${REPO_NAME}-${DEFAULT_BRANCH}/plugins" ]]; then
        ROOT_SOURCE="$TMP_DIR/${REPO_NAME}-${DEFAULT_BRANCH}"
    fi

    if [[ -n "$ROOT_SOURCE" && -d "$ROOT_SOURCE/plugins" ]]; then
        echo ""
        echo -e "${BOLD}${YELLOW}Installing & Registering Antigravity Plugins:${RESET}"
        mkdir -p "$PLUGINS_TARGET_DIR"
        for plugin_path in "$ROOT_SOURCE/plugins"/*; do
            if [[ -d "$plugin_path" ]]; then
                plugin_name="$(basename "$plugin_path")"
                dest_plugin="$PLUGINS_TARGET_DIR/$plugin_name"
                mkdir -p "$dest_plugin"
                cp -r "$plugin_path/"* "$dest_plugin/"
                echo -e "  ${GREEN}✓${RESET} ${BOLD}${plugin_name}${RESET}"
                PLUGINS_COUNT=$((PLUGINS_COUNT + 1))
            fi
        done

        MANIFEST_PATH="$ROOT_SOURCE/config/plugins-manifest.json"
        CONFIG_JSON_PATH="$HOME/.gemini/config/config.json"
        if [[ -f "$MANIFEST_PATH" ]]; then
            if command -v python3 >/dev/null 2>&1; then
                python3 - "$MANIFEST_PATH" "$CONFIG_JSON_PATH" << 'PYEOF'
import json, os, sys
manifest_path, config_path = sys.argv[1], sys.argv[2]
with open(manifest_path, "r", encoding="utf-8") as f:
    manifest = json.load(f)
cfg = {}
if os.path.exists(config_path):
    with open(config_path, "r", encoding="utf-8") as f:
        cfg = json.load(f)
cfg.setdefault("plugins", {})
for k, v in manifest.get("plugins", {}).items():
    cfg["plugins"][k] = v
with open(config_path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2)
PYEOF
                echo -e "  ${GREEN}✓${RESET} Registered ${PLUGINS_COUNT} plugins in ${CONFIG_JSON_PATH}"
            elif command -v node >/dev/null 2>&1; then
                node -e '
const fs = require("fs");
const [manifestPath, configPath] = process.argv.slice(1);
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const cfg = fs.existsSync(configPath) ? JSON.parse(fs.readFileSync(configPath, "utf8")) : {};
cfg.plugins = Object.assign({}, cfg.plugins || {}, manifest.plugins || {});
fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2));
' "$MANIFEST_PATH" "$CONFIG_JSON_PATH"
                echo -e "  ${GREEN}✓${RESET} Registered ${PLUGINS_COUNT} plugins in ${CONFIG_JSON_PATH}"
            else
                echo -e "  ${YELLOW}!${RESET} python3/node not found; please merge config/plugins-manifest.json into ${CONFIG_JSON_PATH} manually."
            fi
        fi
    fi
fi

echo ""
echo -e "${BOLD}${GREEN}🎉 Installation successful!${RESET}"
echo -e "Total skills installed: ${BOLD}${COUNT}${RESET} skills"
echo -e "Total rules installed:  ${BOLD}${RULES_COUNT}${RESET} rules"
echo -e "Total plugins synced:   ${BOLD}${PLUGINS_COUNT}${RESET} plugins"
echo -e "Installed location:     ${CYAN}${TARGET_DIR}${RESET}"
if [[ "$INSTALL_RULES" == true ]]; then
    echo -e "Rules location:         ${CYAN}${RULES_TARGET_DIR}${RESET}"
fi
if [[ "$INSTALL_PLUGINS" == true && "$MODE" == "global" ]]; then
    echo -e "Plugins location:       ${CYAN}${PLUGINS_TARGET_DIR}${RESET}"
fi
echo ""
echo -e "Skills, global rules, and plugins are now active and ready to be used by Antigravity in this environment!"
