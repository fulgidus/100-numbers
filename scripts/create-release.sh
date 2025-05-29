#!/bin/bash

# 100 Numbers Game Solver - Release Script
# This script helps create tagged releases with proper versioning

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Default values
VERSION=""
MESSAGE=""
DRY_RUN=false
FORCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -m|--message)
            MESSAGE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 -v VERSION [OPTIONS]"
            echo "Options:"
            echo "  -v, --version VERSION    Release version (required, e.g., v1.0.0)"
            echo "  -m, --message MESSAGE    Custom release message"
            echo "  --dry-run               Show what would be done without executing"
            echo "  --force                 Force creation even with uncommitted changes"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check required parameters
if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: Version is required. Use -v or --version${NC}"
    exit 1
fi

# Validate version format (semantic versioning)
if ! [[ "$VERSION" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    echo -e "${RED}Error: Invalid version format. Use semantic versioning (e.g., v1.0.0, 1.2.3, v2.0.0-beta1)${NC}"
    exit 1
fi

# Ensure version starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v$VERSION"
fi

echo -e "${CYAN}100 Numbers Game Solver - Release Creator${NC}"
echo -e "${YELLOW}Version: $VERSION${NC}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$VERSION$" && [ "$FORCE" = false ]; then
    echo -e "${RED}Error: Tag $VERSION already exists. Use --force to overwrite.${NC}"
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ] && [ "$FORCE" = false ]; then
    echo -e "${RED}Error: There are uncommitted changes. Commit them first or use --force.${NC}"
    echo -e "${YELLOW}Uncommitted files:${NC}"
    git status --porcelain | sed 's/^/  /'
    exit 1
fi

# Run tests before release
echo -e "${YELLOW}Running comprehensive test suite...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${GRAY}[DRY RUN] Would run: zig build test${NC}"
else
    if ! zig build test; then
        echo -e "${RED}Error: Tests failed! Fix tests before creating release.${NC}"
        exit 1
    fi
    echo -e "${GREEN}All tests passed!${NC}"
fi

# Build all platforms to ensure they work
echo -e "${YELLOW}Testing cross-platform builds...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${GRAY}[DRY RUN] Would run cross-platform build test${NC}"
else
    if ! ./scripts/build-all.sh --build-type ReleaseFast --core-only; then
        echo -e "${RED}Error: Cross-platform build failed!${NC}"
        exit 1
    fi
    echo -e "${GREEN}Core platforms built successfully!${NC}"
fi

# Update CHANGELOG.md
echo -e "${YELLOW}Updating CHANGELOG.md...${NC}"
changelog_path="CHANGELOG.md"
if [ -f "$changelog_path" ]; then
    today=$(date '+%Y-%m-%d')
    version_no_v="${VERSION#v}"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${GRAY}[DRY RUN] Would update CHANGELOG.md${NC}"
    else
        # Create backup
        cp "$changelog_path" "${changelog_path}.bak"

        # Replace [Unreleased] with the new version
        sed -i.tmp "s/\[Unreleased\]/[$version_no_v] - $today/" "$changelog_path"

        # Add new [Unreleased] section
        sed -i.tmp "/## \[$version_no_v\] - $today/i\\
## [Unreleased]\\
\\
### Added\\
### Changed\\
### Deprecated\\
### Removed\\
### Fixed\\
### Security\\
" "$changelog_path"

        rm -f "${changelog_path}.tmp"
        echo -e "${GREEN}CHANGELOG.md updated${NC}"
    fi
else
    echo -e "${YELLOW}Warning: CHANGELOG.md not found${NC}"
fi

# Generate release message
if [ -z "$MESSAGE" ]; then
    MESSAGE="Release $VERSION

This release includes:
- Performance improvements and bug fixes
- Cross-platform builds for Windows, Linux, and macOS
- Comprehensive test suite validation

See CHANGELOG.md for detailed changes.

Download the appropriate binary for your platform:
- Windows: 100-numbers-windows-x86_64.zip
- Linux x64: 100-numbers-linux-x86_64.tar.gz
- Linux ARM64: 100-numbers-linux-aarch64.tar.gz
- macOS Intel: 100-numbers-macos-x86_64.tar.gz
- macOS Apple Silicon: 100-numbers-macos-aarch64.tar.gz"
fi

# Create and push the tag
echo -e "${YELLOW}Creating git tag...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${GRAY}[DRY RUN] Would run: git tag -a $VERSION -m \"$MESSAGE\"${NC}"
    echo -e "${GRAY}[DRY RUN] Would run: git push origin $VERSION${NC}"
else
    if git tag -l | grep -q "^$VERSION$" && [ "$FORCE" = true ]; then
        git tag -d "$VERSION" || true
        git push origin --delete "$VERSION" 2>/dev/null || true
    fi

    git add CHANGELOG.md 2>/dev/null || true
    git commit -m "Prepare release $VERSION" 2>/dev/null || true

    if ! git tag -a "$VERSION" -m "$MESSAGE"; then
        echo -e "${RED}Error: Failed to create git tag${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Pushing tag to remote...${NC}"
    if ! git push origin "$VERSION"; then
        echo -e "${RED}Error: Failed to push tag to remote${NC}"
        exit 1
    fi

    git push origin main 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}Release $VERSION created successfully!${NC}"
echo -e "${CYAN}GitHub Actions will automatically:${NC}"
echo -e "  ${NC}1. Run tests on all platforms${NC}"
echo -e "  ${NC}2. Build release binaries${NC}"
echo -e "  ${NC}3. Create GitHub Release with assets${NC}"
echo -e "  ${NC}4. Generate release notes${NC}"

echo ""
echo -e "${YELLOW}Monitor the release process at:${NC}"
echo -e "https://github.com/fulgidus/100-numbers/actions"

if [ "$DRY_RUN" = false ]; then
    echo ""
    echo -e "${YELLOW}The release will be available at:${NC}"
    echo -e "https://github.com/fulgidus/100-numbers/releases/tag/$VERSION"
fi
