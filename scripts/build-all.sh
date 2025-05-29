#!/bin/bash

# 100 Numbers Game Solver - Local Cross-Platform Build Script
# This script builds the solver for all supported platforms locally

# Note: set -e removed to allow handling of timeouts and partial failures

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
CORE_ONLY=false

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
        --core-only)
            CORE_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --build-type TYPE  Build type (Debug, ReleaseSafe, ReleaseFast, ReleaseSmall)"
            echo "  --test            Run tests before building"
            echo "  --clean           Clean previous builds"
            echo "  --core-only       Build only core targets (Linux x86_64, Windows x86_64)"
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

# Define target platforms (ordered by likelihood of success)
# Note: ARM and macOS builds may take very long or fail due to cross-compilation complexity
if [ "$CORE_ONLY" = true ]; then
    declare -a targets=(
        "linux-x86_64:x86_64-linux:"
        "windows-x86_64:x86_64-windows:.exe"
    )
    echo -e "${YELLOW}🎯 Building core targets only (Linux x86_64, Windows x86_64)${NC}"
else
    declare -a targets=(
        "linux-x86_64:x86_64-linux:"
        "windows-x86_64:x86_64-windows:.exe"
        "linux-aarch64:aarch64-linux:"
        "macos-x86_64:x86_64-macos:"
        "macos-aarch64:aarch64-macos:"
    )
fi

echo -e "${YELLOW}🔨 Building for ${#targets[@]} platforms...${NC}"

success_count=0
failed_builds=()

for target_info in "${targets[@]}"; do
    IFS=':' read -r name target extension <<< "$target_info"
    
    echo -e "${GRAY}  ⚙️  Building for $name (this may take a few minutes)...${NC}"
    
    # Build for the target platform with timeout to prevent hanging
    if timeout 300s zig build -Doptimize="$BUILD_TYPE" -Dtarget="$target" 2>/dev/null; then
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
        build_exit_code=$?
        if [ $build_exit_code -eq 124 ]; then
            echo -e "${RED}    ❌ Build timed out (5 minutes)${NC}"
        else
            echo -e "${RED}    ❌ Build failed (exit code: $build_exit_code)${NC}"
        fi
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
elif [ $success_count -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Partial build success! Some targets failed but others succeeded.${NC}"
    echo -e "${YELLOW}📁 Available binaries in 'builds' directory:${NC}"
    
    for file in builds/*; do
        if [ -f "$file" ]; then
            file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")
            file_size_kb=$((file_size / 1024))
            echo -e "  📦 $(basename "$file") (${file_size_kb} KB)"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}💡 You can still create a release with the successful builds.${NC}"
    # Don't exit with error code for partial success
else
    echo -e "${RED}❌ All builds failed!${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}💡 Usage Examples:${NC}"
echo "  ./builds/100-numbers-linux-x86_64          # Linux"
echo "  ./builds/100-numbers-macos-x86_64          # macOS"
echo "  ./builds/100-numbers-windows-x86_64.exe    # Windows (via Wine)"
