# CRC32 Architecture Fix Implementation

## Problem Summary
The system performs redundant CRC32 verifications and multiple init() calls, causing RP2040 hardware corruption and performance degradation.

## Solution: Single-Pass Verification with Selective Programming

### Key Changes Required

## 1. Make VerificationResult Public and Enhance It

**File: `probe-rs/src/flashing/flasher.rs`**

Change from:
```rust
pub(super) struct VerificationResult {
    sectors_needing_update: Vec<FlashSector>,
    total_sectors: usize,
    matched_sectors: usize,
}
```

To:
```rust
pub struct VerificationResult {
    pub sectors_needing_update: Vec<FlashSector>,
    pub total_sectors: usize,
    pub matched_sectors: usize,
    pub regions: Vec<LoadedRegion>, // Add regions for context
}
```

## 2. Refactor commit_with_reading_mode_preverify()

**File: `probe-rs/src/flashing/loader.rs`**

Instead of returning an error when sectors need updates, return the verification result:

```rust
fn commit_with_reading_mode_preverify(
    &self,
    session: &mut Session,
    options: &DownloadOptions,
    algos: &mut [Flasher],
) -> Result<Option<VerificationResult>, FlashError> {
    // ... existing CRC32 verification code ...
    
    // Check verification results
    if verification_result.all_match() {
        // All sectors match - no programming needed
        progress.started_filling();
        progress.finished_filling();
        // ... complete progress updates ...
        return Ok(None); // No updates needed
    }
    
    // Return verification results for selective programming
    Ok(Some(verification_result))
}
```

## 3. Implement Selective Programming

**File: `probe-rs/src/flashing/loader.rs`**

Add new method for selective programming:

```rust
fn commit_with_selective_programming(
    &self,
    session: &mut Session,
    options: DownloadOptions,
    mut algos: Vec<Flasher>,
    verification_result: VerificationResult,
) -> Result<(), FlashError> {
    tracing::info!("🎯 Selective programming: Updating {} of {} sectors",
        verification_result.sectors_needing_update.len(),
        verification_result.total_sectors);
    
    let progress = options.progress.clone().unwrap_or_else(FlashProgress::empty);
    
    // Calculate size for progress bar (only sectors being updated)
    let update_size: u64 = verification_result.sectors_needing_update
        .iter()
        .map(|s| s.size() as u64)
        .sum();
    
    progress.started_filling();
    progress.finished_filling();
    
    // Erase only sectors that need updates
    progress.started_erasing();
    progress.add_progress_bar(ProgressOperation::Erase, Some(update_size));
    
    for mut flasher in algos.iter_mut() {
        let (mut active_flasher, _) = flasher.init::<Erase>(session, &progress, None)?;
        
        // Only erase sectors that need updates
        for sector in &verification_result.sectors_needing_update {
            active_flasher.erase_sector(sector.address(), sector.size() as u32)?;
        }
    }
    progress.finished_erasing();
    
    // Program only sectors that need updates
    progress.started_programming();
    progress.add_progress_bar(ProgressOperation::Program, Some(update_size));
    
    for mut flasher in algos {
        let (mut active_flasher, regions) = flasher.init::<Program>(session, &progress, None)?;
        
        // Program only changed sectors
        for sector in &verification_result.sectors_needing_update {
            let sector_data = Flasher::get_sector_data(&regions[0], sector);
            active_flasher.program_sector(sector.address(), &sector_data)?;
        }
    }
    progress.finished_programming();
    
    // Verify only updated sectors if requested
    if options.verify {
        progress.started_verifying();
        // Verify only the updated sectors
        self.verify_selective(session, &verification_result.sectors_needing_update, progress)?;
        progress.finished_verifying();
    }
    
    Ok(())
}
```

## 4. Update Main commit_with_enhanced_preverify()

**File: `probe-rs/src/flashing/loader.rs`**

```rust
fn commit_with_enhanced_preverify(
    &self,
    session: &mut Session,
    options: DownloadOptions,
    mut algos: Vec<Flasher>,
) -> Result<(), FlashError> {
    tracing::debug!("Checking if target supports CRC32 verification");
    
    let target = session.target();
    let supports_crc32 = self.target_supports_crc32(target);
    
    if supports_crc32 {
        tracing::debug!("Target supports CRC32, using reading mode approach");
        
        // Perform CRC32 verification
        match self.commit_with_reading_mode_preverify(session, &options, &mut algos) {
            Ok(None) => {
                // All sectors match, nothing to do
                tracing::debug!("All sectors match - no programming needed");
                return Ok(());
            },
            Ok(Some(verification_result)) => {
                // Some sectors need updates - do selective programming
                tracing::info!("CRC32 verification complete: {} sectors need updates",
                    verification_result.sectors_needing_update.len());
                return self.commit_with_selective_programming(
                    session,
                    options,
                    algos,
                    verification_result
                );
            },
            Err(e) => {
                tracing::warn!("CRC32 verification failed: {}, falling back to traditional", e);
                // Fall back to traditional approach
            }
        }
    } else {
        tracing::debug!("Target doesn't support CRC32, using traditional path");
    }
    
    // Use traditional path as fallback or for non-CRC32 targets
    // But DON'T re-verify! Just do traditional programming
    self.commit_traditional_programming(session, options, algos)
}
```

## 5. Remove Redundant Verification from Traditional Path

**File: `probe-rs/src/flashing/loader.rs`**

Change `commit_traditional_preverify()` to skip redundant verification when called as fallback:

```rust
fn commit_traditional_preverify(
    &self,
    session: &mut Session,
    options: DownloadOptions,
    algos: Vec<Flasher>,
    skip_verification: bool, // Add parameter
) -> Result<(), FlashError> {
    tracing::info!("📦 Traditional preverify: Using verification before programming");
    
    if !skip_verification {
        // Only verify if not already done by CRC32
        let progress = options.progress.clone().unwrap_or_else(FlashProgress::empty);
        let verification_result = self.verify_flash_contents(session, &progress)?;
        
        if verification_result {
            tracing::info!("✅ Flash contents match, skipping programming");
            return Ok(());
        }
    }
    
    tracing::info!("🔄 Proceeding with full programming");
    self.commit_traditional_programming(session, options, algos)
}
```

## 6. Add Helper Methods to Flasher

**File: `probe-rs/src/flashing/flasher.rs`**

Add sector-level operations:

```rust
impl<'a, 'b> Flasher<'a, 'b> {
    /// Get data for a specific sector from a region
    pub fn get_sector_data(region: &LoadedRegion, sector: &FlashSector) -> Vec<u8> {
        let sector_start = sector.address();
        let sector_end = sector_start + sector.size() as u64;
        let region_start = region.location().start;
        let region_end = region.location().end;
        
        if sector_start >= region_start && sector_end <= region_end {
            let offset = (sector_start - region_start) as usize;
            let size = sector.size() as usize;
            region.data.as_bytes()[offset..offset + size].to_vec()
        } else {
            vec![0xFF; sector.size() as usize] // Fill with erased value
        }
    }
}

impl ActiveFlasher<'_, '_, Erase> {
    /// Erase a single sector
    pub fn erase_sector(&mut self, address: u64, size: u32) -> Result<(), FlashError> {
        tracing::debug!("Erasing sector at 0x{:08x}, size: {}", address, size);
        
        let algo = &self.flash_algorithm;
        let pc_erase_sector = algo.pc_erase_sector
            .ok_or(FlashError::SectorEraseNotSupported)?;
        
        let result = self.call_function_and_wait(
            &Registers {
                pc: into_reg(pc_erase_sector)?,
                r0: Some(into_reg(address)?),
                r1: Some(into_reg(size)?),
                r2: None,
                r3: None,
            },
            false,
            Duration::from_secs(5),
        )?;
        
        if result != 0 {
            return Err(FlashError::EraseFailed {
                sector_address: address,
                error_code: result,
            });
        }
        
        Ok(())
    }
}

impl ActiveFlasher<'_, '_, Program> {
    /// Program a single sector
    pub fn program_sector(&mut self, address: u64, data: &[u8]) -> Result<(), FlashError> {
        tracing::debug!("Programming sector at 0x{:08x}, size: {}", address, data.len());
        
        // Break into pages and program
        let page_size = self.flash_algorithm.page_size as usize;
        for (offset, chunk) in data.chunks(page_size).enumerate() {
            let page_address = address + (offset * page_size) as u64;
            let page = FlashPage::new(page_address, chunk);
            self.program_page(&page)?;
        }
        
        Ok(())
    }
}
```

## Benefits of This Architecture

1. **Single CRC32 Verification**: Only one CRC32 pass, no redundant verification
2. **Single Init Cycle**: Prevents RP2040 hardware corruption
3. **Selective Programming**: Only touches sectors that need updates (3/81 in your example)
4. **Performance**: Dramatic speedup from avoiding redundant work
5. **Clean State Management**: No multiple resets or state corruption
6. **Maintainable**: Clear separation between verification and programming phases

## Testing Strategy

1. Test with RP2040 where issue manifests
2. Verify only changed sectors are programmed
3. Confirm single init() call with logging
4. Measure performance improvement
5. Test fallback paths for non-CRC32 targets

## Implementation Order

1. First: Make VerificationResult public
2. Second: Refactor commit_with_reading_mode_preverify to return results
3. Third: Implement selective programming
4. Fourth: Update main flow to use selective programming
5. Fifth: Remove redundant verification from traditional path
6. Sixth: Add thorough logging and testing