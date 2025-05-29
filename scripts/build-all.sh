#!/bin/bash

# 100 Numbers Game Solver - Local Cross-Platform Build Script
# This script builds the solver for all supported platforms locally

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="ReleaseFast"
RUN_TESTS=false
CLEAN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --test)
            RUN_TESTS=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --build-type TYPE  Build type (Debug, ReleaseSafe, ReleaseFast, ReleaseSmall)"
            echo "  --test            Run tests before building"
            echo "  --clean           Clean previous builds"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${CYAN}🎯 100 Numbers Game Solver - Cross-Platform Builder${NC}"
echo -e "${YELLOW}Build Type: $BUILD_TYPE${NC}"

# Clean previous builds if requested
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
    rm -rf zig-out builds
fi

# Run tests if requested
if [ "$RUN_TESTS" = true ]; then
    echo -e "${YELLOW}🧪 Running comprehensive test suite...${NC}"
    if ! zig build test; then
        echo -e "${RED}❌ Tests failed! Aborting build.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ All tests passed!${NC}"
fi

# Create builds directory
mkdir -p builds

# Define target platforms
declare -a targets=(
    "windows-x86_64:x86_64-windows:.exe"
    "linux-x86_64:x86_64-linux:"
    "linux-aarch64:aarch64-linux:"
    "macos-x86_64:x86_64-macos:"
    "macos-aarch64:aarch64-macos:"
)

echo -e "${YELLOW}🔨 Building for ${#targets[@]} platforms...${NC}"

success_count=0
failed_builds=()

for target_info in "${targets[@]}"; do
    IFS=':' read -r name target extension <<< "$target_info"
    
    echo -e "${GRAY}  ⚙️  Building for $name...${NC}"
    
    # Build for the target platform
    if zig build -Doptimize="$BUILD_TYPE" -Dtarget="$target"; then
        # Copy the built executable to builds directory
        if [ -n "$extension" ]; then
            source_file="zig-out/bin/100.exe"
        else
            source_file="zig-out/bin/100"
        fi
        
        dest_file="builds/100-numbers-$name$extension"
        
        if [ -f "$source_file" ]; then
            cp "$source_file" "$dest_file"
            if [ -z "$extension" ]; then
                chmod +x "$dest_file"
            fi
            
            file_size=$(stat -c%s "$dest_file" 2>/dev/null || stat -f%z "$dest_file" 2>/dev/null || echo "0")
            file_size_kb=$((file_size / 1024))
            echo -e "${GREEN}    ✅ Success! (${file_size_kb} KB)${NC}"
            ((success_count++))
        else
            echo -e "${RED}    ❌ Build succeeded but executable not found${NC}"
            failed_builds+=("$name")
        fi
    else
        echo -e "${RED}    ❌ Build failed${NC}"
        failed_builds+=("$name")
    fi
done

echo ""
echo -e "${CYAN}📊 Build Summary:${NC}"
echo -e "${GREEN}  ✅ Successful: $success_count/${#targets[@]}${NC}"

if [ ${#failed_builds[@]} -gt 0 ]; then
    echo -e "${RED}  ❌ Failed: ${#failed_builds[@]}${NC}"
    echo -e "${RED}    Failed targets: $(IFS=', '; echo "${failed_builds[*]}")${NC}"
fi

if [ $success_count -eq ${#targets[@]} ]; then
    echo ""
    echo -e "${GREEN}🎉 All builds completed successfully!${NC}"
    echo -e "${YELLOW}📁 Binaries available in 'builds' directory:${NC}"
    
    for file in builds/*; do
        if [ -f "$file" ]; then
            file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")
            file_size_kb=$((file_size / 1024))
            echo -e "  📦 $(basename "$file") (${file_size_kb} KB)"
        fi
    done
    
    echo ""
    echo -e "${GREEN}🚀 Ready for distribution!${NC}"
else
    exit 1
fi

echo ""
echo -e "${CYAN}💡 Usage Examples:${NC}"
echo "  ./builds/100-numbers-linux-x86_64          # Linux"
echo "  ./builds/100-numbers-macos-x86_64          # macOS"
echo "  ./builds/100-numbers-windows-x86_64.exe    # Windows (via Wine)"
