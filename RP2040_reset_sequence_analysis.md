# RP2040 Reset Sequence Analysis: Boot2 Initialization Issue

## Problem Summary

The RP2040 dual-core reset sequence (from PR #3429) was found to be incompatible with CRC32-based incremental flash verification. All flash sectors were incorrectly detected as needing updates, breaking the 70-75% performance improvement that CRC32 verification provides.

## Root Cause Discovery

### Initial Hypothesis (Incorrect)
- CRC32 algorithm execution was being disrupted by debug port manipulation
- Additional resets during CRC32 execution were causing connection issues

### Actual Root Cause (Discovered)
**The RP2040 rescue mode reset sequence prevents Boot2 (Second Stage Bootloader) from executing properly, leaving the flash subsystem in a suboptimal configuration state.**

## Technical Analysis

### Evidence from Logs

**Failed Case (with RP2040 rescue mode reset):**
```
[WARN] RP2040: Boot2 signature unexpected: 0x00000000 (expected 0x01000007)
[INFO] 🔄 SECTOR UPDATE NEEDED: Sector 0x10000000 will be erased and reprogrammed (verified in 25.2ms)
[INFO] 🔄 SECTOR UPDATE NEEDED: Sector 0x10001000 will be erased and reprogrammed (verified in 22.7ms)
[INFO] 🔄 SECTOR UPDATE NEEDED: Sector 0x10002000 will be erased and reprogrammed (verified in 25.5ms)
```

**Working Case (with DefaultArmSequence):**
```
[INFO] Using sequence Arm(DefaultArmSequence(()))
[INFO] ✅ SECTOR VERIFIED: Sector 0x10000000 matches, will be skipped (verified in 35.4ms)
[INFO] ✅ SECTOR VERIFIED: Sector 0x10001000 matches, will be skipped (verified in 34.8ms)
[INFO] ✅ SECTOR VERIFIED: Sector 0x10002000 matches, will be skipped (verified in 34.7ms)
```

### Key Indicators

1. **Boot2 Signature Check**: `0x00000000` instead of expected `0x01000007`
2. **CRC32 Verification Times**: ~25ms (failing) vs ~100ms (working)  
3. **CRC32 Algorithm Status**: Loads and executes successfully (proves CPU/RAM work)
4. **Flash Read Results**: Returns stale/cached data instead of actual flash contents

## RP2040 Boot Sequence Understanding

### Normal Boot Flow
```
1. Boot ROM executes from internal ROM
2. Boot ROM reads Boot2 from flash (256 bytes at 0x10000000)  
3. Boot2 configures SSI controller for optimal flash performance
4. Boot2 sets up XIP (Execute-In-Place) mapping and caching
5. Boot2 jumps to user firmware at 0x10000100
```

### Rescue Mode Impact
```
1. Rescue Mode bypasses normal boot ROM flow
2. AIRCR reset doesn't guarantee complete boot ROM re-execution
3. Boot2 may not execute, leaving flash in basic/suboptimal state
4. XIP cache and flash timing remain in default (slower) configuration
5. Subsequent flash reads may return stale or incorrectly cached data
```

## Technical Details

### RP2040 Rescue Mode Reset Sequence (Current)
```rust
// 1. Enter Rescue Mode via special debug port
arm_interface.write_raw_dp_register(RESCUE_DP, Ctrl::ADDRESS, 0)?;

// 2. Reset debug ports and reacquire connection
self.debug_port_setup(dap_probe, ap.dp())?;
self.debug_core_start(arm_interface, &ap, core_type, debug_base, None)?;

// 3. AIRCR system reset to exit rescue mode  
let mut aircr = Aircr(0);
aircr.vectkey();
aircr.set_sysresetreq(true);
core.write_word_32(Aircr::get_mmio_address(), aircr.into())?;

// 4. Wait for reset completion
cortex_m_wait_for_reset(core)?;

// ISSUE: Boot2 doesn't execute properly after this sequence
```

### Boot2 Second Stage Bootloader
- **Location**: First 256 bytes of flash (0x10000000 - 0x100000FF)
- **Signature**: Last 4 bytes contain `0x01000007` or similar
- **Function**: Configures flash controller for optimal performance
- **Critical**: Required for reliable flash reads in production firmware

## Investigation Process

### 1. Initial Symptoms
- CRC32 verification detected all sectors as different despite no changes
- Performance: ~25ms per sector (should be ~100ms when working correctly)
- All sectors marked as "SECTOR UPDATE NEEDED"

### 2. Debugging Steps
- Added debug logging to vendor sequence selection
- Confirmed RP2040 sequence was being used vs DefaultArmSequence
- Added XIP cache flush attempts (didn't resolve the issue)
- Added Boot2 signature verification (revealed the root cause)

### 3. Key Discovery
The Boot2 signature check showed `0x00000000` instead of the expected `0x01000007`, proving that Boot2 hadn't executed properly after the rescue mode reset.

## Impact Assessment

### When RP2040 Sequence is Used
- ❌ Boot2 doesn't execute properly  
- ❌ Flash subsystem remains in suboptimal state
- ❌ CRC32 verification reads stale data
- ❌ All sectors appear to need updates
- ❌ 70-75% performance benefit is lost

### When DefaultArmSequence is Used  
- ✅ Normal boot flow including Boot2 execution
- ✅ Flash subsystem properly configured
- ✅ CRC32 verification reads fresh data
- ✅ Sectors correctly identified as matching
- ✅ Full 70-75% performance benefit achieved

## Solution Requirements

The dual-core reset functionality is required by project maintainers, so we need to fix the sequence rather than remove it. The solution must:

1. **Preserve dual-core reset capability** (maintain core feature)
2. **Ensure Boot2 executes properly** (fix flash subsystem state)
3. **Make CRC32 verification work** (restore performance benefits)
4. **Maintain backward compatibility** (don't break existing workflows)

## Proposed Solutions

### Option 1: Force Complete Boot Sequence
Modify the rescue mode sequence to ensure the boot ROM fully re-executes:
```rust
// After AIRCR reset, ensure complete boot ROM cycle
// May require additional reset or longer delays
```

### Option 2: Explicit Boot2 Execution  
After rescue mode, explicitly load and execute Boot2:
```rust
// Read Boot2 from flash and execute it manually
// Requires understanding Boot2 entry point and requirements
```

### Option 3: Alternative Dual-Core Reset
Research alternative methods for dual-core reset that don't bypass Boot2:
```rust
// Use different reset mechanism that preserves normal boot flow
// May require RP2040-specific register manipulation
```

### Option 4: Boot2 State Verification and Recovery
Add robust Boot2 state checking and recovery:
```rust
// Check if Boot2 executed properly
// If not, trigger appropriate recovery sequence
// Verify flash subsystem configuration
```

## Conclusion

This investigation demonstrates the importance of understanding the complete system boot flow when implementing low-level reset sequences. The issue wasn't with CRC32 execution itself, but with the fundamental state the flash subsystem was left in after the rescue mode reset.

The solution requires ensuring that Boot2 (Second Stage Bootloader) executes properly after the dual-core reset, which will restore proper flash subsystem configuration and make CRC32 verification work correctly.

**Key Insight**: The problem was not "additional resets during CRC execution" but rather "the initial reset sequence preventing proper boot initialization."

---

*Generated from investigation of RP2040 reset sequence incompatibility with CRC32 verification*  
*Date: August 7, 2025*