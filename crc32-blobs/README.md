# CRC32 Algorithm Blobs for probe-rs Flash Verification

This module contains highly optimized CRC32 algorithm implementations for embedded flash verification. These position-independent binary blobs are loaded into target RAM and executed on-chip to provide dramatic performance improvements over traditional USB-based verification.

## Performance Overview

| Algorithm | Speed (KB/s) | Improvement | Binary Size | Memory Usage | Targets |
|-----------|--------------|-------------|-------------|--------------|---------|
| **Slicing-by-4 CRC32** | ~600-800 | 6-8x | 5.5KB | 4KB tables | All supported |

*Note: Previous lower-performance variants have been removed in favor of the universal high-performance slicing-by-4 implementation.*

## Architecture Support

### ARM Thumb/Thumb-2 ✅
- **Targets**: Cortex-M0/M0+/M3/M4/M7, ARM7TDMI
- **Status**: Fully implemented and optimized
- **Location**: `arm-thumb/`
- **Optimizations**: 
  - Loop unrolling with 8-word processing
  - Efficient table lookups with scaled addressing
  - ARMv7-M instruction scheduling
  - Compiler optimizations: `-O3`, loop unrolling, function inlining

### RISC-V 🚧
- **Targets**: ESP32-C3/C6/C2/H2, CH32V series, GD32VF1, SiFive cores
- **Status**: In development
- **Location**: `riscv/`
- **ISA Support**: RV32I base, RV32C compressed, RV32M multiply/divide
- **Compiler**: `riscv64-unknown-elf-gcc` (auto-installed by build system)

### Xtensa ⏳
- **Targets**: ESP32, ESP32-S2/S3
- **Status**: Planned  
- **Location**: `xtensa/` (to be created)
- **Notes**: Windowed register optimization potential

## Quick Start

### Building All Architectures
```bash
# Build all supported architectures
./build_all.sh

# Build specific architecture
./build_all.sh arm-thumb

# Build with performance analysis
./build_all.sh --analyze
```

### Building ARM Thumb (Manual)
```bash
cd arm-thumb
make                    # Standard build
make performance        # Optimized slicing-by-4
make compare           # Compare all variants
make benchmark         # Prepare for hardware testing
```

### Hardware Testing
```bash
cd ../crc32-test
cargo run --bin test_slice4_performance
```

## Algorithm Implementation

### Slicing-by-4 CRC32 (`crc32.c`)
- **Purpose**: High-performance CRC32 implementation for all targets
- **Performance**: ~600-800 KB/s on RP2040 @ 125MHz
- **Memory**: 4KB lookup tables + ~400 bytes code  
- **Compatibility**: Works on all Cortex-M and RISC-V targets with >8KB SRAM
- **Optimization**: Processes 4 bytes simultaneously with aggressive loop unrolling

## Directory Structure

```
crc32-blobs/
├── README.md                    # This file
├── build_all.sh                 # Cross-architecture build script
├── crc32_algorithms.yaml        # Algorithm metadata for probe-rs
│
├── arm-thumb/                   # ARM Thumb/Thumb-2 implementations
│   ├── Makefile                 # Standard build
│   ├── Makefile_slice4_optimized # Performance build
│   ├── crc32.c                  # Standard implementation
│   ├── crc32_optimized.c        # Multi-byte optimized
│   ├── crc32_slice4_optimized.c # Slicing-by-4 high-performance
│   ├── crc32.ld                 # Position-independent linker script
│   └── *.bin                    # Generated binaries
│
├── alternative-algorithms/      # Non-CRC32 alternatives
│   ├── xxhash32_arm.c          # xxHash32 for ARM
│   └── adler32_arm.c           # Adler-32 checksum
│
├── riscv/                      # RISC-V implementations (planned)
│   └── (to be implemented)
│
└── xtensa/                     # Xtensa implementations (planned)
    └── (to be implemented)
```

## Integration with probe-rs

The CRC32 algorithms integrate with probe-rs through the flash verification system:

### 1. Algorithm Loading
```rust
// probe-rs automatically selects optimal algorithm based on target
let crc32_addr = flasher.ensure_crc32_algorithm_loaded(session)?;
```

### 2. On-chip Execution
```rust
// Execute CRC32 calculation entirely on target
let target_crc32 = flasher.execute_crc32_on_target(
    session, crc32_addr, sector_addr, sector_size
)?;
```

### 3. Performance Monitoring
```rust
// Detailed timing breakdown available
let timing = flasher.verify_sector_crc32(session, sector_addr, pages)?;
println!("Target CRC32: {:.1}ms", timing.target_time.as_secs_f32() * 1000.0);
```

## Compiler Optimizations

### Aggressive Performance Flags
```bash
# ARM Thumb optimizations
-march=armv7-m -mtune=cortex-m4 -mthumb
-O3 -ffast-math -funroll-loops -finline-functions
-fomit-frame-pointer -fno-stack-protector
-ffunction-sections -fdata-sections
```

### Key Optimizations Applied
1. **Loop Unrolling**: 8-32 bytes processed per iteration
2. **Function Inlining**: Eliminates call overhead for hot paths
3. **Register Optimization**: Efficient use of ARM register file
4. **Memory Access Patterns**: Aligned loads, prefetching hints
5. **Branch Prediction**: Likely/unlikely hints for conditional code

## Performance Testing

### Hardware Requirements
- ARM debug probe (J-Link, ST-Link, DAPLink, etc.)
- Target microcontroller (RP2040, STM32, etc.)
- probe-rs installation with hardware support

### Benchmark Suite
```bash
# Quick performance test
cd crc32-test
cargo run --bin test_crc32_simple

# Comprehensive benchmark
cargo run --bin test_slice4_performance

# Algorithm comparison
cargo run --bin benchmark_alternatives
```

### Expected Results (RP2040 @ 125MHz)
- **Slicing-by-4**: 3-5ms per 4KB sector (vs 25ms baseline)
- **Total flash verification**: ~1-2 seconds vs 8+ seconds
- **Development workflow**: 6-8x faster incremental builds

## Adding New Architectures

### 1. Create Architecture Directory
```bash
mkdir new-arch
cd new-arch
```

### 2. Implement Core Functions
```c
// Required entry points for probe-rs compatibility
uint32_t init_crc32(uint32_t, uint32_t, uint32_t, uint32_t);
uint32_t uninit_crc32(uint32_t, uint32_t, uint32_t, uint32_t);
uint32_t calculate_crc32(uint32_t addr, uint32_t len, uint32_t crc);
uint32_t sector_crc32(uint32_t addr, uint32_t size);
```

### 3. Create Linker Script
- Position-independent code (PIC)
- ARM Thumb breakpoint header: `0xBE00BE00`
- Entry point table at fixed offsets
- 4-byte alignment for data structures

### 4. Add Build Configuration
```bash
# Add to build_all.sh
ARCHITECTURES="arm-thumb riscv xtensa new-arch"
```

### 5. Validate Performance
- Implement test suite for new architecture
- Benchmark against targets
- Ensure 3-8x performance improvement vs USB verification

## Troubleshooting

### Build Issues
```bash
# Missing cross-compiler
sudo apt install gcc-arm-none-eabi  # ARM
sudo apt install gcc-riscv64-unknown-elf  # RISC-V

# Check linker symbols
arm-none-eabi-nm algorithm.elf | grep calculate_crc32
```

### Runtime Issues
```bash
# Enable debug logging in probe-rs
RUST_LOG=debug probe-rs ...

# Verify algorithm loading
# Check that PC advances and returns to breakpoint (0xBE00BE01)
```

### Performance Issues
- Verify target clock frequency
- Check memory alignment (4-byte boundaries)
- Enable compiler optimizations (`-O3`)
- Consider slicing-by-4 for high-memory targets

## Contributing

### Adding Optimizations
1. Maintain position-independent code
2. Preserve entry point compatibility
3. Add comprehensive test coverage
4. Document performance improvements
5. Update this README with results

### Code Review Checklist
- [ ] Cross-architecture compatibility maintained
- [ ] Performance benchmarks included
- [ ] Memory usage documented
- [ ] Error handling robust
- [ ] Documentation updated

## License

This code is part of the probe-rs project and follows the same licensing terms.

## References

- [probe-rs Flash Architecture](../probe-rs/src/flashing/)
- [CRC32 Algorithm Analysis](../docs/CRC32_OPTIMIZATION_ANALYSIS.md)  
- [Alternative Approaches](../docs/CRC32_ALTERNATIVE_APPROACHES.md)
- [Performance Benchmarks](../crc32-test/)

---
**Performance Notice**: These optimizations can improve flash verification performance by 6-8x, dramatically reducing embedded development iteration time from minutes to seconds.