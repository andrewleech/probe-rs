## Fix RP2040 rescue mode reset compatibility with flash operations

### Problem

The RP2040 dual-core rescue mode reset sequence (introduced in #3429) was incompatible with subsequent flash operations. After rescue mode reset, the flash subsystem remained in an unconfigured state, causing:

- Flash algorithm initialization failures with memory alignment errors (`Memory access to address 0x301754D was not aligned to 2 bytes`)
- CRC32 verification failures with all sectors incorrectly detected as needing updates
- Boot2 (Second Stage Bootloader) not executing after rescue mode reset

### Root Cause

The rescue mode reset sequence bypasses the normal boot ROM execution flow, leaving the XIP (Execute-In-Place) interface and flash controller uninitialized. While the existing flash algorithm calls `connect_internal_flash()` during initialization, this occurs too late when the memory subsystem is already in an invalid state.

### Solution

Modified the RP2040 flash algorithm to detect and recover from rescue mode reset state:

1. Added detection logic in flash algorithm `Init()` to check if flash is accessible (Boot2 signature at 0x100000FC)
2. When rescue mode state is detected (signature reads 0x00000000), immediately call `connect_internal_flash()` ROM function to restore flash connectivity
3. Proceed with normal flash algorithm initialization

This approach follows OpenOCD's established pattern for rescue mode recovery (`rp2xxx rom_api_call CX`).

### Changes

- Modified `flash-algo/src/main.rs` to add rescue mode detection and recovery in `FlashAlgorithm::new()`
- Rebuilt flash algorithm and updated `probe-rs/targets/RP2040.yaml` with new binary and PC offsets

### Testing

Verified that flash operations, including CRC32 verification, now work correctly after rescue mode reset. No memory alignment errors or verification failures observed.

### References

- Original dual-core reset PR: #3429
- OpenOCD rescue mode implementation: https://github.com/raspberrypi/openocd/blob/rpi-common/tcl/target/rp2040.cfg
- RP2040 Datasheet Section 2.3.4.2 (Rescue Debug Port)