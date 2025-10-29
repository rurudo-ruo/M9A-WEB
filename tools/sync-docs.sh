#!/usr/bin/env bash
#
# M9A Docs Sync Script
# Sync docs from M9A repository to local project
#

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Find project root (directory containing .git)
find_git_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done
    echo "" # Not found
}

PROJECT_ROOT="$(find_git_root)"
if [[ -z "$PROJECT_ROOT" ]]; then
    echo -e "${RED}Error: Could not find project root (.git directory).${NC}"
    exit 1
fi
cd "$PROJECT_ROOT"

TEMP_DIR="$PROJECT_ROOT/M9A-temp"
DOCS_DIR="$PROJECT_ROOT/docs"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}M9A Docs Sync Script${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git command not found. Please install Git first.${NC}"
    exit 1
fi

# Clone or update M9A repository
if [ -d "$TEMP_DIR" ]; then
    echo -e "${YELLOW}Updating M9A repository...${NC}"
    cd "$TEMP_DIR"
    git fetch origin
    git reset --hard origin/main
    echo -e "${GREEN}✓ M9A repository updated successfully${NC}"
    cd "$PROJECT_ROOT"
else
    echo -e "${YELLOW}Cloning M9A repository...${NC}"
    git clone https://github.com/MAA1999/M9A.git "$TEMP_DIR"
    echo -e "${GREEN}✓ M9A repository cloned successfully${NC}"
fi

echo ""
echo -e "${YELLOW}Start syncing docs...${NC}"

# Ensure target directories exist
mkdir -p "$DOCS_DIR/zh_cn"
mkdir -p "$DOCS_DIR/en_us"

# Sync root README.md
SOURCE_README="$TEMP_DIR/docs/README.md"
TARGET_README="$DOCS_DIR/README.md"

if [ -f "$SOURCE_README" ]; then
    echo -e "  → Sync docs/README.md"
    cp "$SOURCE_README" "$TARGET_README"
    echo -e "    ${GREEN}✓ Done${NC}"
else
    echo -e "    ${YELLOW}⚠ Source file not found: $SOURCE_README${NC}"
fi

# Sync zh_cn docs
SOURCE_ZH_CN="$TEMP_DIR/docs/zh_cn/"
TARGET_ZH_CN="$DOCS_DIR/zh_cn/"

if [ -d "$SOURCE_ZH_CN" ]; then
    echo -e "  → Sync docs/zh_cn/"
    rsync -av --delete "$SOURCE_ZH_CN" "$TARGET_ZH_CN" > /dev/null 2>&1 || true
    echo -e "    ${GREEN}✓ Done${NC}"
else
    echo -e "    ${YELLOW}⚠ Source directory not found: $SOURCE_ZH_CN${NC}"
fi

# Sync en_us docs
SOURCE_EN_US="$TEMP_DIR/docs/en_us/"
TARGET_EN_US="$DOCS_DIR/en_us/"

if [ -d "$SOURCE_EN_US" ]; then
    echo -e "  → Sync docs/en_us/"
    rsync -av --delete "$SOURCE_EN_US" "$TARGET_EN_US" > /dev/null 2>&1 || true
    echo -e "    ${GREEN}✓ Done${NC}"
else
    echo -e "    ${YELLOW}⚠ Source directory not found: $SOURCE_EN_US${NC}"
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Sync completed!${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${GRAY}Note: Temporary files are in the M9A-temp directory and can be deleted anytime.${NC}"
