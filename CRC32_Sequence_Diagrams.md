# CRC32 Incremental Flash Verification - Sequence Diagrams (Updated)

## Overview
These diagrams show the current selective programming architecture for CRC32-based incremental flash verification in probe-rs, reflecting the working implementation as of the RP2040 rescue mode compatibility fix.

## Scenario 1: Complete CRC32 Match - No Programming Required (Optimal Path)

```mermaid
sequenceDiagram
    participant User
    participant Loader as FlashLoader
    participant Flasher
    participant ActiveFlasher
    participant Target as RP2040/STM32
    participant Flash as Target Flash
    
    User->>Loader: download_file() with --preverify
    
    Note over Loader: Enhanced Preverify Decision
    Loader->>Loader: target_supports_crc32()
    Loader->>Loader: ✅ ARM + CRC32 binary available
    
    Note over Loader,Target: Single CRC32 Verification Phase
    Loader->>Loader: commit_with_reading_mode_preverify()
    Loader->>Flasher: get first flasher
    Loader->>Flasher: init<Erase>()
    Flasher->>Target: Connect to core
    
    Note over Flasher,Target: RP2040 Rescue DP Reset (if needed)
    alt RP2040 Target
        Flasher->>Target: Select(0) - Standard DP
        Target-->>Flasher: Connection attempt
        alt Connection fails
            Flasher->>Target: Select(0xf1002927) - Rescue DP
            Flasher->>Target: Dual-core reset via rescue mode
            Target->>Target: Reset cores + SSI controller
        end
    end
    
    Flasher->>Target: Load flash algorithm to RAM
    
    Note over ActiveFlasher,Target: Single Init for CRC32 Verification
    ActiveFlasher->>Target: init() - Set up ROM functions
    ActiveFlasher->>Target: Load CRC32 binary to separate RAM region
    
    Note over ActiveFlasher,Target: CRC32 Verification Loop
    loop For each sector
        ActiveFlasher->>ActiveFlasher: get_sector_data() from LoadedRegion
        ActiveFlasher->>Target: call_crc32_function(address, length)
        Target->>Flash: Read flash via XIP
        Target->>Target: Calculate CRC32C on flash data
        Target-->>ActiveFlasher: Return CRC32 result
        ActiveFlasher->>ActiveFlasher: Compare with expected CRC32
        Note over ActiveFlasher: ✅ All sectors match
    end
    
    ActiveFlasher->>Target: uninit() - Restore XIP
    ActiveFlasher-->>Loader: VerificationResult: 81/81 sectors match
    
    Note over Loader: Complete match - Skip all programming!
    Flasher->>Target: Disconnect
    Loader->>User: ✅ Flash complete (0 sectors updated, 100% skipped)
```

## Scenario 2: Selective Programming - Only Changed Sectors Updated

```mermaid
sequenceDiagram
    participant User
    participant Loader as FlashLoader
    participant Flasher
    participant ActiveFlasher
    participant Target as RP2040/STM32
    participant Flash as Target Flash
    
    User->>Loader: download_file() with --preverify
    
    Note over Loader: Enhanced Preverify Decision
    Loader->>Loader: target_supports_crc32()
    Loader->>Loader: ✅ ARM + CRC32 binary available
    
    Note over Loader,Target: Single CRC32 Verification Phase
    Loader->>Loader: commit_with_reading_mode_preverify()
    Loader->>Flasher: get first flasher
    Loader->>Flasher: init<Erase>()
    Flasher->>Target: Connect to core
    
    Note over Flasher,Target: RP2040 Rescue DP Reset (if needed)
    alt RP2040 Target
        Flasher->>Target: Select(0) - Standard DP
        Target-->>Flasher: Connection attempt
        alt Connection fails
            Flasher->>Target: Select(0xf1002927) - Rescue DP
            Flasher->>Target: Dual-core reset via rescue mode
            Target->>Target: Reset cores + SSI controller
        end
    end
    
    Flasher->>Target: Load flash algorithm to RAM
    
    Note over ActiveFlasher,Target: Single Init for CRC32 Verification
    ActiveFlasher->>Target: init() - Set up ROM functions
    ActiveFlasher->>Target: Load CRC32 binary to separate RAM region
    
    Note over ActiveFlasher,Target: CRC32 Verification Loop
    loop For each sector
        ActiveFlasher->>ActiveFlasher: get_sector_data() from LoadedRegion
        ActiveFlasher->>Target: call_crc32_function(address, length)
        Target->>Flash: Read flash via XIP
        Target->>Target: Calculate CRC32C on flash data
        Target-->>ActiveFlasher: Return CRC32 result
        ActiveFlasher->>ActiveFlasher: Compare with expected CRC32
        alt Sector matches
            Note over ActiveFlasher: ✅ Sector will be skipped
        else Sector differs
            Note over ActiveFlasher: 🔄 Sector needs update
            ActiveFlasher->>ActiveFlasher: Add to sectors_needing_update
        end
    end
    
    ActiveFlasher->>Target: uninit() - Restore XIP
    ActiveFlasher-->>Loader: VerificationResult: 3/81 sectors need updates
    
    Note over Loader,Target: Selective Programming Phase
    Loader->>Loader: commit_with_selective_programming(verification_result)
    Loader->>Flasher: init<Erase>() for programming
    Flasher->>Target: Connect to core (reuse session)
    Flasher->>Target: Load flash algorithm to RAM
    
    Note over ActiveFlasher,Target: Flash Algorithm Init for Programming
    ActiveFlasher->>Target: init() - Disable XIP, setup for programming
    
    Note over ActiveFlasher,Target: Erase Only Changed Sectors
    loop For each sector in sectors_needing_update (3 sectors)
        ActiveFlasher->>Target: erase_sector(sector)
        Target->>Flash: Erase flash sector
    end
    
    Note over ActiveFlasher,Target: Program Only Changed Sectors  
    loop For each sector in sectors_needing_update (3 sectors)
        ActiveFlasher->>Target: program_page(data)
        Target->>Flash: Write flash page
    end
    
    Note over ActiveFlasher,Target: Post-Programming Verification (Optional)
    ActiveFlasher->>Target: uninit() - Restore XIP
    Flasher->>Target: Disconnect
    Loader->>User: ✅ Flash complete (3/81 sectors updated, 96% skipped)
```

## Scenario 3: Traditional Path (Non-CRC32 Targets or CRC32 Failure Fallback)

```mermaid
sequenceDiagram
    participant User
    participant Loader as FlashLoader
    participant Flasher
    participant ActiveFlasher
    participant Target as Non-ARM/Legacy
    participant Flash as Target Flash
    
    User->>Loader: download_file()
    
    Note over Loader: Enhanced Preverify Decision
    Loader->>Loader: target_supports_crc32()
    alt Non-ARM target or no CRC32 binary
        Loader->>Loader: ❌ Traditional path required
    else CRC32 verification failed
        Note over Loader: CRC32 verification returned None (hardware error)
        Loader->>Loader: 🔄 Fallback to traditional path
    end
    
    Note over Loader,Target: Traditional Flash Programming Path
    Loader->>Loader: commit_traditional_preverify()
    Loader->>Flasher: init<Erase>()
    Flasher->>Target: Connect to core
    Flasher->>Target: Load flash algorithm to RAM
    
    Note over ActiveFlasher,Target: Flash Algorithm Init
    ActiveFlasher->>Target: init() - Setup for programming
    
    Note over ActiveFlasher,Target: Full Flash Programming (No Preverify)
    Note over ActiveFlasher,Target: Erase All Sectors
    loop For each sector in flash region
        ActiveFlasher->>Target: erase_sector(sector)
        Target->>Flash: Erase flash sector
    end
    
    Note over ActiveFlasher,Target: Program All Sectors
    loop For each sector with data
        ActiveFlasher->>Target: program_page(data)
        Target->>Flash: Write flash page
    end
    
    Note over ActiveFlasher,Target: Post-Programming Verification (USB-based)
    loop For each programmed sector
        ActiveFlasher->>Target: Read flash memory via debug interface
        ActiveFlasher->>ActiveFlasher: Compare with expected data
        ActiveFlasher->>ActiveFlasher: Verify programming success
    end
    
    ActiveFlasher->>Target: uninit()
    Flasher->>Target: Disconnect
    Loader->>User: ✅ Flash complete (traditional full programming)
```

## Scenario 4: RP2040 Rescue Mode - Historical Corruption Issues (RESOLVED)

```mermaid
sequenceDiagram
    participant User
    participant Loader as FlashLoader
    participant Flasher
    participant ActiveFlasher
    participant Target as RP2040
    participant Flash as Target Flash
    
    Note over User,Target: Historical Issue (Fixed in Current Implementation)
    Note over Loader: Old Architecture: Triple-Init Problem
    
    User->>Loader: download_file() with --preverify
    
    Note over Loader,Target: Old Problematic Flow
    Loader->>Flasher: commit_with_reading_mode_preverify()
    Flasher->>Target: Connect to debug port
    
    Note over Target: ⚠️ Hardware in corrupted state from previous session
    Target-->>Flasher: NACK errors during connection
    
    loop Debug port recovery attempts
        Flasher->>Target: SWD line reset
        Flasher->>Target: Try read DPIDR
        Target-->>Flasher: NACK (connection failed)
    end
    
    Note over Flasher,Target: Rescue Mode Recovery
    Flasher->>Target: Write TARGETSEL 0xf1002927 (Rescue DP)
    Flasher->>Target: Dual-core reset via rescue mode
    Target->>Target: Reset both cores + SSI state
    
    Flasher->>Target: Connect to debug port (attempt 2)
    Target-->>Flasher: ✅ Connection successful
    
    Note over ActiveFlasher,Target: PROBLEMATIC: Multiple Init() Calls
    ActiveFlasher->>Target: init() #1 - CRC verification phase
    ActiveFlasher->>Target: uninit() - Restore XIP
    ActiveFlasher->>Target: Load CRC32 binary
    ActiveFlasher->>Target: CRC32 verification
    ActiveFlasher->>Target: init() #2 - Programming phase
    ActiveFlasher->>Target: Programming operations
    ActiveFlasher->>Target: init() #3 - Post-verify phase
    
    Note over Target: ⚠️ Triple-Init corrupted hardware state
    Target->>Target: SSI controller corruption
    Target->>Target: XIP cache coherency failure
    
    ActiveFlasher-->>Loader: Hardware left in corrupted state
    
    Note over User,Target: Physical Power Cycle Required
    User->>Target: Physical power cycle
    Note over Target: Hardware state restored
    
    Note over User,Target: ✅ RESOLUTION: Selective Programming Architecture
    Note over Loader: Current implementation eliminates multiple init() calls
```

## Scenario 5: CRC32 Function Details (Target-Side Execution)

```mermaid
sequenceDiagram
    participant ActiveFlasher
    participant Target as ARM Core
    participant RAM as Target RAM
    participant Flash as Target Flash
    participant CRC32 as CRC32 Function
    
    Note over ActiveFlasher,CRC32: CRC32 Function Loading
    ActiveFlasher->>RAM: Load CRC32 binary (432 bytes for RP2040)
    ActiveFlasher->>ActiveFlasher: Calculate entry point (base + 0x8 offset)
    
    Note over ActiveFlasher,CRC32: CRC32 Function Call
    ActiveFlasher->>Target: Set registers (PC=entry_point, R0=address, R1=length)
    ActiveFlasher->>Target: Start execution
    
    Note over Target,CRC32: Target-Side Execution
    Target->>CRC32: Jump to CRC32 function
    
    loop For each 4-byte word in range
        CRC32->>Flash: Read word from flash address (XIP)
        Flash-->>CRC32: Return flash data
        CRC32->>CRC32: Update CRC32 calculation (CRC32C/Castagnoli)
    end
    
    CRC32->>Target: Return CRC32 result in R0
    Target-->>ActiveFlasher: Function execution complete
    ActiveFlasher->>ActiveFlasher: Read R0 register for CRC32 result
    
    Note over ActiveFlasher: Compare target CRC32 vs expected CRC32
```

## Key Architecture and Performance Notes (Updated)

### Selective Programming Performance Benefits
- **Traditional Full Programming**: Erase + program all 81 sectors (~324KB)
- **Selective Programming**: Only update changed sectors (3/81 sectors, ~12KB)
- **Performance gain**: 96% reduction in flash operations
- **CRC32 Verification**: Target-side execution with XIP (~100+ MB/s vs USB ~10-50 MB/s)

### Current Architecture (Post-Fix)
1. **Single CRC32 Verification Phase**: init() → CRC32 verification → uninit() → return VerificationResult
2. **Selective Programming Phase**: init() → erase/program only changed sectors → uninit()
3. **RP2040 Rescue DP**: Proactive use of multidrop address 0xf1002927 for dual-core reset

### Resolved Issues
- **Triple-Init Problem**: Eliminated multiple flash algorithm init() calls that corrupted RP2040 hardware
- **Sector Data Extraction**: Fixed get_sector_data() to properly extract LoadedRegion pages instead of returning erased bytes
- **Progress Bars**: Restored progress reporting for --preverify operations
- **Hardware Corruption**: RP2040 rescue mode now works without leaving hardware in corrupted state

### Error Handling and Fallbacks
- CRC32 verification failure → fallback to traditional full programming
- Hardware connection issues → rescue DP reset → retry
- Non-ARM targets → traditional programming path
- Critical: Hardware power cycle only needed for legacy corruption issues (resolved)

### Memory Layout and Safety
- Flash algorithm: Loaded to RAM during init()
- CRC32 function: Separate RAM allocation to avoid stack collisions
- Entry point calculation: Base address + 0x8 offset for ARM position-independent code
- Stack management: Separate regions with safety gaps

### Verification Methods
- **CRC32C/Castagnoli**: Using embedded-crc32c crate for consistency between host and target
- **Algorithm**: Polynomial 0x1EDC6F41, hardware acceleration on supported targets
- **Binary Size**: ~432 bytes for thumbv6m-none-eabi (RP2040)