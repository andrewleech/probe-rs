# RISC-V CRC32 Algorithm Implementation

High-performance slicing-by-4 CRC32 implementation optimized for RISC-V targets.

## 🎯 **Performance Target**
- **Speed**: 600-800 KB/s (6-8x improvement over USB verification)
- **Memory**: 4KB lookup tables + ~600 bytes code
- **Compatibility**: ESP32-C3/C6/C2/H2, CH32V series, GD32VF1, SiFive cores

## 🏗️ **Build Requirements**
- **Compiler**: `riscv64-unknown-elf-gcc` (auto-installed by build system)
- **Target ISA**: RV32I base, optional RV32C compressed, RV32M multiply
- **ABI**: `ilp32` (32-bit integers, longs, pointers)

## 🚀 **Quick Build**
```bash
# From crc32-blobs directory
make -C riscv

# Or use build system
./build_all.sh riscv
```

## 📊 **Target-Specific Optimizations**

### ESP32-C3 (RV32IMC)
- **Clock**: 160MHz
- **SRAM**: 400KB (plenty for 4KB tables)
- **ISA**: Integer + Multiply + Compressed
- **Expected**: ~800-1000 KB/s

### CH32V Series (RV32IMAC)
- **Clock**: 144MHz  
- **SRAM**: 20-64KB (sufficient for algorithm)
- **ISA**: Integer + Multiply + Atomic + Compressed
- **Expected**: ~700-900 KB/s

### GD32VF1 (RV32IMAC)
- **Clock**: 108MHz
- **SRAM**: 32KB
- **ISA**: Integer + Multiply + Atomic + Compressed  
- **Expected**: ~600-700 KB/s

## 🔧 **Implementation Status**
- [x] Directory structure created
- [x] Compiler toolchain installed  
- [x] Baseline slicing-by-4 CRC32 implementation
- [x] Position-independent linker script
- [x] Makefile and build configuration
- [ ] Hardware testing and validation

## 📝 **Development Notes**
- RISC-V calling convention: `a0`=addr, `a1`=len, `a2`=crc → `a0`=result
- 32 registers available (vs ARM's 16) - aggressive register allocation possible
- No barrel shifter - use efficient shift sequences
- Regular instruction encoding - predictable performance characteristics

---
**Status**: Implementation in progress  
**Updated**: 2025-01-23