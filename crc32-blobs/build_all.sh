#!/bin/bash
# 
# CRC32 Algorithm Build Script for probe-rs
# Builds optimized CRC32 implementations for all supported architectures
#
# Usage:
#   ./build_all.sh [architecture] [--analyze] [--benchmark] [--clean]
#
# Examples:
#   ./build_all.sh                    # Build all architectures
#   ./build_all.sh arm-thumb          # Build only ARM Thumb
#   ./build_all.sh --analyze          # Build with detailed analysis
#   ./build_all.sh arm-thumb --clean  # Clean and rebuild ARM
#

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Build configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_LOG="${SCRIPT_DIR}/build.log"
SUMMARY_FILE="${SCRIPT_DIR}/build_summary.txt"

# Supported architectures and their status
declare -A ARCH_STATUS=(
    ["arm-thumb"]="implemented"
    ["riscv"]="implemented"
    ["xtensa"]="planned"
)

declare -A ARCH_DESCRIPTION=(
    ["arm-thumb"]="ARM Thumb/Thumb-2 (Cortex-M series, ARM7TDMI)"
    ["riscv"]="RISC-V 32-bit (ESP32-C3, CH32V series, SiFive)"
    ["xtensa"]="Xtensa (ESP32, ESP32-S2/S3)"
)

declare -A ARCH_COMPILERS=(
    ["arm-thumb"]="arm-none-eabi-gcc"
    ["riscv"]="riscv64-unknown-elf-gcc"
    ["xtensa"]="xtensa-esp32-elf-gcc"
)

show_help() {
    echo -e "${WHITE}CRC32 Algorithm Build Script for probe-rs${NC}"
    echo ""
    echo "Usage: $0 [architecture] [options]"
    echo ""
    echo "Architectures:"
    for arch in "${!ARCH_STATUS[@]}"; do
        status="${ARCH_STATUS[$arch]}"
        desc="${ARCH_DESCRIPTION[$arch]}"
        if [[ "$status" == "implemented" ]]; then
            echo -e "  ${GREEN}$arch${NC} - $desc"
        else
            echo -e "  ${YELLOW}$arch${NC} - $desc (${status})"
        fi
    done
    echo ""
    echo "Options:"
    echo "  --analyze   Generate detailed performance analysis"
    echo "  --benchmark Prepare binaries for hardware benchmarking"
    echo "  --clean     Clean build artifacts before building"
    echo "  --verbose   Enable verbose output"
    echo "  --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     # Build all implemented architectures"
    echo "  $0 arm-thumb          # Build only ARM Thumb"
    echo "  $0 --analyze          # Build all with analysis"
    echo "  $0 arm-thumb --clean  # Clean and rebuild ARM"
}

print_header() {
    echo -e "${WHITE}=======================================${NC}"
    echo -e "${WHITE}  probe-rs CRC32 Algorithm Builder${NC}"
    echo -e "${WHITE}=======================================${NC}"
    echo ""
    echo -e "${BLUE}Build Configuration:${NC}"
    echo "  Script directory: $SCRIPT_DIR"
    echo "  Build log: $BUILD_LOG"
    echo "  Selected architecture: ${SELECTED_ARCH:-"all implemented"}"
    echo "  Analyze mode: $ANALYZE"
    echo "  Benchmark mode: $BENCHMARK"
    echo "  Clean build: $CLEAN"
    echo ""
}

check_dependencies() {
    echo -e "${BLUE}Checking build dependencies...${NC}"
    
    local missing_deps=()
    
    # Check for required tools
    for tool in make objcopy objdump size nm; do
        if ! command -v "$tool" &> /dev/null; then
            missing_deps+=("$tool")
        fi
    done
    
    # Check architecture-specific compilers
    local archs_to_check=()
    if [[ -n "$SELECTED_ARCH" ]]; then
        if [[ "${ARCH_STATUS[$SELECTED_ARCH]}" == "implemented" ]]; then
            archs_to_check=("$SELECTED_ARCH")
        fi
    else
        for arch in "${!ARCH_STATUS[@]}"; do
            if [[ "${ARCH_STATUS[$arch]}" == "implemented" ]]; then
                archs_to_check+=("$arch")
            fi
        done
    fi
    
    for arch in "${archs_to_check[@]}"; do
        local compiler="${ARCH_COMPILERS[$arch]}"
        if ! command -v "$compiler" &> /dev/null; then
            # Auto-install RISC-V compiler if possible
            if [[ "$arch" == "riscv" && "$compiler" == "riscv64-unknown-elf-gcc" ]]; then
                echo -e "${YELLOW}🔧 Installing RISC-V toolchain...${NC}"
                if sudo apt update && sudo apt install -y gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf; then
                    echo -e "${GREEN}✅ RISC-V toolchain installed successfully${NC}"
                else
                    echo -e "${RED}❌ Failed to install RISC-V toolchain${NC}"
                    missing_deps+=("$compiler")
                fi
            else
                missing_deps+=("$compiler")
            fi
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}Missing dependencies:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        echo -e "${YELLOW}Install missing dependencies:${NC}"
        echo "  # ARM Thumb"
        echo "  sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi"
        echo "  # RISC-V"
        echo "  sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf"
        echo "  # Xtensa (requires Espressif toolchain)"
        echo "  # See: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/"
        echo ""
        exit 1
    fi
    
    echo -e "${GREEN}✓ All dependencies satisfied${NC}"
    echo ""
}

build_arm_thumb() {
    local arch_dir="$SCRIPT_DIR/arm-thumb"
    echo -e "${PURPLE}Building ARM Thumb CRC32 implementations...${NC}"
    
    if [[ ! -d "$arch_dir" ]]; then
        echo -e "${RED}Error: ARM Thumb directory not found: $arch_dir${NC}"
        return 1
    fi
    
    cd "$arch_dir"
    
    # Clean if requested
    if [[ "$CLEAN" == true ]]; then
        echo "  Cleaning previous builds..."
        make clean &>> "$BUILD_LOG"
        make -f Makefile_slice4_optimized clean &>> "$BUILD_LOG"
    fi
    
    # Build standard implementation
    echo "  Building standard CRC32..."
    if make all &>> "$BUILD_LOG"; then
        echo -e "    ${GREEN}✓ Standard CRC32 built successfully${NC}"
        local size=$(stat -c%s crc32.bin)
        echo "      Binary size: $size bytes"
    else
        echo -e "    ${RED}✗ Standard CRC32 build failed${NC}"
        echo "      Check $BUILD_LOG for details"
        return 1
    fi
    
    # Build optimized implementations
    echo "  Building optimized implementations..."
    if make -f Makefile_slice4_optimized all &>> "$BUILD_LOG"; then
        echo -e "    ${GREEN}✓ Optimized implementations built successfully${NC}"
        
        # Report sizes
        for variant in crc32_slice4_optimized crc32_slice4_m0plus crc32_slice4_size; do
            if [[ -f "${variant}.bin" ]]; then
                local size=$(stat -c%s "${variant}.bin")
                echo "      ${variant}: $size bytes"
            fi
        done
    else
        echo -e "    ${YELLOW}⚠ Some optimized builds may have failed${NC}"
        echo "      Check $BUILD_LOG for details"
    fi
    
    # Generate analysis if requested
    if [[ "$ANALYZE" == true ]]; then
        echo "  Generating performance analysis..."
        if make -f Makefile_slice4_optimized analyze &>> "$BUILD_LOG"; then
            echo -e "    ${GREEN}✓ Analysis completed${NC}"
        else
            echo -e "    ${YELLOW}⚠ Analysis may be incomplete${NC}"
        fi
    fi
    
    # Prepare benchmark data if requested
    if [[ "$BENCHMARK" == true ]]; then
        echo "  Preparing benchmark data..."
        if make -f Makefile_slice4_optimized benchmark &>> "$BUILD_LOG"; then
            echo -e "    ${GREEN}✓ Benchmark preparation completed${NC}"
        else
            echo -e "    ${YELLOW}⚠ Benchmark preparation may have issues${NC}"
        fi
    fi
    
    echo -e "${GREEN}✓ ARM Thumb build completed${NC}"
    echo ""
}

build_riscv() {
    local arch_dir="$SCRIPT_DIR/riscv"
    echo -e "${PURPLE}Building RISC-V CRC32 implementation...${NC}"
    
    if [[ ! -d "$arch_dir" ]]; then
        echo -e "${RED}Error: RISC-V directory not found: $arch_dir${NC}"
        return 1
    fi
    
    cd "$arch_dir"
    
    # Clean if requested
    if [[ "$CLEAN" == true ]]; then
        echo "  Cleaning previous builds..."
        make clean &>> "$BUILD_LOG"
    fi
    
    # Build main implementation
    echo "  Building RISC-V slicing-by-4 CRC32..."
    if make all &>> "$BUILD_LOG"; then
        echo -e "    ${GREEN}✓ RISC-V CRC32 built successfully${NC}"
        local size=$(stat -c%s crc32.bin)
        echo "      Binary size: $size bytes"
        
        # Verify entry points
        local entry_count=$(make info 2>/dev/null | grep -E "(init_crc32|uninit_crc32|calculate_crc32|sector_crc32)" | wc -l)
        echo "      Entry points: $entry_count/4 found"
    else
        echo -e "    ${RED}✗ RISC-V CRC32 build failed${NC}"
        echo "      Check $BUILD_LOG for details"
        return 1
    fi
    
    # Build ISA variants if requested
    if [[ "$ANALYZE" == true ]]; then
        echo "  Building ISA variants..."
        if make variants &>> "$BUILD_LOG"; then
            echo -e "    ${GREEN}✓ RISC-V variants built successfully${NC}"
            
            # Report variant sizes
            for variant in crc32_rv32i.bin crc32_rv32im.bin crc32_rv32imc.bin crc32_rv32imac.bin; do
                if [[ -f "$variant" ]]; then
                    local size=$(stat -c%s "$variant")
                    echo "      $variant: $size bytes"
                fi
            done
        else
            echo -e "    ${YELLOW}⚠ Variant builds may have failed${NC}"
            echo "      Check $BUILD_LOG for details"
        fi
    fi
    
    # Generate detailed analysis if requested
    if [[ "$ANALYZE" == true ]]; then
        echo "  Generating RISC-V analysis..."
        if make analyze &>> "$BUILD_LOG"; then
            echo -e "    ${GREEN}✓ Analysis completed${NC}"
        else
            echo -e "    ${YELLOW}⚠ Analysis may be incomplete${NC}"
        fi
    fi
    
    # Prepare test data if requested
    if [[ "$BENCHMARK" == true ]]; then
        echo "  Preparing RISC-V test data..."
        if make test &>> "$BUILD_LOG"; then
            echo -e "    ${GREEN}✓ Test preparation completed${NC}"
        else
            echo -e "    ${YELLOW}⚠ Test preparation may have issues${NC}"
        fi
    fi
    
    echo -e "${GREEN}✓ RISC-V build completed${NC}"
    echo ""
}

build_xtensa() {
    echo -e "${YELLOW}Xtensa implementation is planned but not yet available${NC}"
    echo "  Target platforms: ESP32, ESP32-S2, ESP32-S3"
    echo "  Expected features: Windowed register optimizations"
    echo "  Status: Contributions welcome!"
    echo ""
}

generate_summary() {
    echo -e "${BLUE}Generating build summary...${NC}"
    
    {
        echo "CRC32 Algorithm Build Summary"
        echo "Generated: $(date)"
        echo "==============================="
        echo ""
        
        # ARM Thumb results
        if [[ -d "$SCRIPT_DIR/arm-thumb" ]]; then
            echo "ARM Thumb Results:"
            cd "$SCRIPT_DIR/arm-thumb"
            
            for binary in crc32.bin crc32_slice4_optimized.bin crc32_slice4_m0plus.bin; do
                if [[ -f "$binary" ]]; then
                    local size=$(stat -c%s "$binary")
                    local name=$(basename "$binary" .bin)
                    echo "  $name: $size bytes"
                fi
            done
            echo ""
        fi
        
        # RISC-V results
        if [[ -d "$SCRIPT_DIR/riscv" ]]; then
            echo "RISC-V Results:"
            cd "$SCRIPT_DIR/riscv"
            
            for binary in crc32.bin crc32_rv32i.bin crc32_rv32im.bin crc32_rv32imc.bin crc32_rv32imac.bin; do
                if [[ -f "$binary" ]]; then
                    local size=$(stat -c%s "$binary")
                    local name=$(basename "$binary" .bin)
                    echo "  $name: $size bytes"
                fi
            done
            echo ""
        fi
        
        # Expected performance summary
        echo "Expected Performance (RP2040 @ 125MHz):"
        echo "  Standard CRC32:    ~111 KB/s (baseline)"
        echo "  Multi-byte:        ~300-400 KB/s (3-4x improvement)"
        echo "  Slicing-by-4:      ~600-800 KB/s (6-8x improvement)"
        echo ""
        
        # Development impact
        echo "Development Impact:"
        echo "  4KB sector time:   25ms → 3-5ms"
        echo "  Full verification: 8.5s → 1-2s"
        echo "  Build iteration:   6-8x faster feedback"
        echo ""
        
        # Next steps
        echo "Next Steps:"
        echo "  1. Test with hardware: cd ../crc32-test && cargo run --bin test_slice4_performance"
        echo "  2. Integrate with probe-rs flash verification system"
        echo "  3. Monitor performance in real applications"
        echo ""
        
    } > "$SUMMARY_FILE"
    
    # Display summary
    cat "$SUMMARY_FILE"
    echo -e "${GREEN}✓ Build summary saved to: $SUMMARY_FILE${NC}"
}

validate_builds() {
    echo -e "${BLUE}Validating build artifacts...${NC}"
    
    local validation_passed=true
    
    # Check ARM Thumb builds
    if [[ -d "$SCRIPT_DIR/arm-thumb" ]]; then
        cd "$SCRIPT_DIR/arm-thumb"
        
        # Essential binaries
        for binary in crc32.bin; do
            if [[ -f "$binary" ]]; then
                local size=$(stat -c%s "$binary")
                if [[ $size -lt 100 || $size -gt 10000 ]]; then
                    echo -e "  ${YELLOW}⚠ Suspicious size for $binary: $size bytes${NC}"
                    validation_passed=false
                fi
            else
                echo -e "  ${RED}✗ Missing essential binary: $binary${NC}"
                validation_passed=false
            fi
        done
        
        # Check for symbols
        if [[ -f "crc32.elf" ]]; then
            if arm-none-eabi-nm crc32.elf | grep -q "calculate_crc32"; then
                echo -e "  ${GREEN}✓ ARM Thumb symbols verified${NC}"
            else
                echo -e "  ${RED}✗ Missing required symbols in ARM Thumb build${NC}"
                validation_passed=false
            fi
        fi
    fi
    
    # Check RISC-V builds
    if [[ -d "$SCRIPT_DIR/riscv" ]]; then
        cd "$SCRIPT_DIR/riscv"
        
        # Essential binaries
        for binary in crc32.bin; do
            if [[ -f "$binary" ]]; then
                local size=$(stat -c%s "$binary")
                if [[ $size -lt 1000 || $size -gt 20000 ]]; then
                    echo -e "  ${YELLOW}⚠ Suspicious size for RISC-V $binary: $size bytes${NC}"
                    validation_passed=false
                fi
            else
                echo -e "  ${RED}✗ Missing essential RISC-V binary: $binary${NC}"
                validation_passed=false
            fi
        done
        
        # Check for symbols
        if [[ -f "crc32.elf" ]]; then
            if riscv64-unknown-elf-nm crc32.elf | grep -q "calculate_crc32"; then
                echo -e "  ${GREEN}✓ RISC-V symbols verified${NC}"
            else
                echo -e "  ${RED}✗ Missing required symbols in RISC-V build${NC}"
                validation_passed=false
            fi
        fi
    fi
    
    if [[ "$validation_passed" == true ]]; then
        echo -e "${GREEN}✓ All builds validated successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Build validation failed${NC}"
        return 1
    fi
}

main() {
    # Initialize build log
    echo "CRC32 Algorithm Build Log - $(date)" > "$BUILD_LOG"
    
    print_header
    check_dependencies
    
    # Determine which architectures to build
    local archs_to_build=()
    if [[ -n "$SELECTED_ARCH" ]]; then
        if [[ "${ARCH_STATUS[$SELECTED_ARCH]}" == "implemented" ]]; then
            archs_to_build=("$SELECTED_ARCH")
        elif [[ "${ARCH_STATUS[$SELECTED_ARCH]}" == "planned" ]]; then
            archs_to_build=("$SELECTED_ARCH")  # Will show planned message
        else
            echo -e "${RED}Error: Unknown architecture: $SELECTED_ARCH${NC}"
            exit 1
        fi
    else
        # Build all implemented architectures
        for arch in "${!ARCH_STATUS[@]}"; do
            archs_to_build+=("$arch")
        done
    fi
    
    # Build each architecture
    local build_success=true
    for arch in "${archs_to_build[@]}"; do
        case "$arch" in
            arm-thumb)
                if ! build_arm_thumb; then
                    build_success=false
                fi
                ;;
            riscv)
                build_riscv
                ;;
            xtensa) 
                build_xtensa
                ;;
            *)
                echo -e "${RED}Error: Unknown architecture: $arch${NC}"
                build_success=false
                ;;
        esac
    done
    
    # Validate builds
    if ! validate_builds; then
        build_success=false
    fi
    
    # Generate summary
    generate_summary
    
    # Final status
    echo -e "${WHITE}=======================================${NC}"
    if [[ "$build_success" == true ]]; then
        echo -e "${GREEN}✓ Build completed successfully!${NC}"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo "  1. Test performance: cd crc32-test && cargo run --bin test_slice4_performance"
        echo "  2. View analysis: cat $SUMMARY_FILE"
        echo "  3. Check build log: cat $BUILD_LOG"
        exit 0
    else
        echo -e "${RED}✗ Build completed with errors${NC}"
        echo ""
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo "  1. Check build log: cat $BUILD_LOG"
        echo "  2. Verify dependencies: ./build_all.sh --help"
        echo "  3. Try clean build: ./build_all.sh --clean"
        exit 1
    fi
}

# Command line argument parsing
SELECTED_ARCH=""
ANALYZE=false
BENCHMARK=false  
CLEAN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        arm-thumb|riscv|xtensa)
            SELECTED_ARCH="$1"
            shift
            ;;
        --analyze|-a)
            ANALYZE=true
            shift
            ;;
        --benchmark|-b)
            BENCHMARK=true
            shift
            ;;
        --clean|-c)
            CLEAN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Handle Ctrl+C gracefully
trap 'echo -e "\n${YELLOW}Build interrupted by user${NC}"; exit 130' INT

# Run main function (no arguments needed since we parsed them above)
main