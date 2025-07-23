# RISC-V CRC32 Algorithm Makefile
# Builds high-performance slicing-by-4 CRC32 for RISC-V targets

# Toolchain configuration
CROSS_COMPILE = riscv64-unknown-elf-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
SIZE = $(CROSS_COMPILE)size
NM = $(CROSS_COMPILE)nm

# Architecture and ABI settings
MARCH ?= rv32i
MABI ?= ilp32

# Compiler flags
CFLAGS = -march=$(MARCH) -mabi=$(MABI) -mno-relax
CFLAGS += -fPIC -fno-plt -fno-jump-tables
CFLAGS += -O3 -funroll-loops -finline-functions -fomit-frame-pointer
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Wall -Wextra -Wno-unused-parameter
CFLAGS += -g -ggdb

# Linker flags  
LDFLAGS = -T crc32.ld -nostdlib -nostartfiles
LDFLAGS += -Wl,-Map=crc32.map

# Source and output files
SRC = crc32.c
ELF = crc32.elf
BIN = crc32.bin
HEX = crc32.hex
MAP = crc32.map

# Build targets
.PHONY: all clean info analyze test variants help

all: $(BIN) info

$(ELF): $(SRC) crc32.ld
	@echo "🔧 Compiling RISC-V CRC32 algorithm..."
	@echo "   ISA: $(MARCH)"
	@echo "   ABI: $(MABI)"
	$(CC) $(CFLAGS) $(SRC) $(LDFLAGS) -o $@

$(BIN): $(ELF)
	@echo "🔨 Creating binary blob..."
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	@echo "📝 Creating hex file..."
	$(OBJCOPY) -O ihex $< $@

info: $(ELF) $(BIN)
	@echo ""
	@echo "📊 RISC-V CRC32 Algorithm Analysis"
	@echo "=================================="
	@echo "Target ISA: $(MARCH)"
	@echo "ABI: $(MABI)"
	@echo ""
	@echo "Binary size:"
	@$(SIZE) $(ELF)
	@echo ""
	@echo "Binary blob: $(shell ls -lh $(BIN) | awk '{print $$5}') ($(shell wc -c < $(BIN)) bytes)"
	@echo ""
	@echo "Entry points:"
	@$(NM) $(ELF) | grep -E "(calculate_crc32|init_crc32|uninit_crc32|sector_crc32)" | sort || echo "No entry points found"
	@echo ""

analyze: $(ELF)
	@echo "🔍 Detailed Analysis"
	@echo "==================="
	@echo ""
	@echo "Disassembly of key functions:"
	@$(OBJDUMP) -d $(ELF) | grep -A 20 "calculate_crc32>:" || echo "Function not found"
	@echo ""
	@echo "Symbol table:"
	@$(NM) -n $(ELF)
	@echo ""
	@echo "Section layout:"
	@$(OBJDUMP) -h $(ELF)

# Build variants for different RISC-V targets
variants:
	@echo "🎯 Building RISC-V variants..."
	@$(MAKE) clean
	@$(MAKE) MARCH=rv32i MABI=ilp32 all
	@mv $(BIN) crc32_rv32i.bin
	@echo "✅ RV32I variant: crc32_rv32i.bin"
	
	@$(MAKE) clean  
	@$(MAKE) MARCH=rv32im MABI=ilp32 all
	@mv $(BIN) crc32_rv32im.bin
	@echo "✅ RV32IM variant: crc32_rv32im.bin"
	
	@$(MAKE) clean
	@$(MAKE) MARCH=rv32imc MABI=ilp32 all
	@mv $(BIN) crc32_rv32imc.bin
	@echo "✅ RV32IMC variant: crc32_rv32imc.bin"
	
	@$(MAKE) clean
	@$(MAKE) MARCH=rv32imac MABI=ilp32 all
	@mv $(BIN) crc32_rv32imac.bin
	@echo "✅ RV32IMAC variant: crc32_rv32imac.bin"
	
	@echo ""
	@echo "📊 Variant Summary:"
	@ls -lh crc32_rv32*.bin

test: $(BIN) 
	@echo "🧪 Testing RISC-V CRC32 algorithm..."
	@echo "Binary structure validation:"
	@hexdump -C $(BIN) | head -4
	@echo ""
	@echo "⚠️  Hardware testing requires RISC-V target device"
	@echo "💡 Use: probe-rs download -i firmware.elf --chip esp32c3"

clean:
	@echo "🧹 Cleaning RISC-V build artifacts..."
	rm -f *.elf *.bin *.hex *.map *.o crc32_rv32*.bin

help:
	@echo "RISC-V CRC32 Algorithm Build System"
	@echo "===================================="
	@echo ""
	@echo "Targets:"
	@echo "  all      - Build binary blob (default)"
	@echo "  info     - Show size and symbol information"  
	@echo "  analyze  - Detailed disassembly and analysis"
	@echo "  variants - Build for multiple RISC-V ISA variants"
	@echo "  test     - Validate binary structure"
	@echo "  clean    - Remove build artifacts"
	@echo "  help     - Show this help"
	@echo ""
	@echo "Options:"
	@echo "  MARCH=   - RISC-V ISA (rv32i, rv32im, rv32imc, rv32imac)"
	@echo "  MABI=    - ABI specification (ilp32, ilp32f, ilp32d)"
	@echo ""
	@echo "Examples:"
	@echo "  make                          # Default RV32I build"
	@echo "  make MARCH=rv32imc           # ESP32-C3 optimized"
	@echo "  make MARCH=rv32imac          # CH32V optimized"
	@echo "  make variants                # All ISA variants"