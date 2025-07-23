# Xtensa CRC32 Algorithm Build Configuration
# Targets: ESP32, ESP32-S2, ESP32-S3

# Toolchain configuration
XTENSA_TOOLCHAIN_PATH ?= $(shell which xtensa-esp32-elf-gcc | xargs dirname)
CC := xtensa-esp32-elf-gcc
OBJCOPY := xtensa-esp32-elf-objcopy
OBJDUMP := xtensa-esp32-elf-objdump
SIZE := xtensa-esp32-elf-size

# Target configuration
TARGET := esp32
VARIANT := lx6

# Compiler flags optimized for position-independent code
CFLAGS := -Os -fPIC -ffunction-sections -fdata-sections
CFLAGS += -mlongcalls -mtext-section-literals
CFLAGS += -nostdlib -nostartfiles -fno-stack-protector
CFLAGS += -Wall -Wextra -Werror

# Architecture-specific flags
ifeq ($(TARGET),esp32)
    CFLAGS += -mcpu=esp32
    ARCH_DEFINE := -DESP32
else ifeq ($(TARGET),esp32s2)
    CFLAGS += -mcpu=esp32s2
    ARCH_DEFINE := -DESP32S2
else ifeq ($(TARGET),esp32s3)
    CFLAGS += -mcpu=esp32s3
    ARCH_DEFINE := -DESP32S3
endif

CFLAGS += $(ARCH_DEFINE)

# Linker configuration
LDFLAGS := -T crc32.ld -nostdlib -Wl,--gc-sections
LDFLAGS += -Wl,--print-memory-usage

# Source and output files
SOURCES := crc32.c
OBJECTS := $(SOURCES:.c=.o)
TARGET_ELF := crc32.elf
TARGET_BIN := crc32.bin
TARGET_HEX := crc32.hex

# Build targets
.PHONY: all clean info esp32 esp32s2 esp32s3

all: info $(TARGET_BIN)

info:
	@echo "=== Xtensa CRC32 Build Configuration ==="
	@echo "Target: $(TARGET) ($(VARIANT))"
	@echo "Compiler: $(CC)"
	@echo "Flags: $(CFLAGS)"
	@echo "======================================"

# Check toolchain availability
toolchain-check:
	@if ! command -v $(CC) >/dev/null 2>&1; then \
		echo "Error: Xtensa toolchain not found!"; \
		echo "Please install ESP-IDF and source the environment:"; \
		echo "  source \$$IDF_PATH/export.sh"; \
		exit 1; \
	fi

# Build for specific ESP32 variants
esp32:
	$(MAKE) TARGET=esp32 VARIANT=lx6 all

esp32s2:
	$(MAKE) TARGET=esp32s2 VARIANT=lx7 all

esp32s3:
	$(MAKE) TARGET=esp32s3 VARIANT=lx7 all

# Compilation rules
%.o: %.c
	@echo "Compiling $< for $(TARGET)..."
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET_ELF): $(OBJECTS) crc32.ld
	@echo "Linking $@ for $(TARGET)..."
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@
	$(SIZE) $@

$(TARGET_BIN): $(TARGET_ELF)
	@echo "Creating binary $@..."
	$(OBJCOPY) -O binary $< $@
	@echo "Binary size: $$(stat -c%s $@) bytes"

$(TARGET_HEX): $(TARGET_ELF)
	@echo "Creating hex $@..."
	$(OBJCOPY) -O ihex $< $@

# Analysis and debugging
analyze: $(TARGET_ELF)
	@echo "=== Xtensa CRC32 Analysis ==="
	$(OBJDUMP) -d $(TARGET_ELF) > crc32.asm
	$(OBJDUMP) -t $(TARGET_ELF) | grep -E "(crc32|GLOBAL)" > symbols.txt
	@echo "Disassembly: crc32.asm"
	@echo "Symbols: symbols.txt"

# Clean up
clean:
	rm -f *.o *.elf *.bin *.hex *.map *.asm symbols.txt

# Placeholder implementation indicator
$(SOURCES):
	@echo "Error: Xtensa CRC32 implementation not yet available"
	@echo "This is a placeholder build system for planned Xtensa support"
	@echo ""
	@echo "Expected implementation features:"
	@echo "  - Windowed register optimization"
	@echo "  - ESP32/S2/S3 target support"
	@echo "  - Position-independent algorithm"
	@echo "  - High-performance lookup tables"
	@echo ""
	@echo "Contributions welcome! See README.md for details."
	@exit 1