# RP2040 Debug Journey Story

The RP2040 issues turned out to be a complete nightmare to debug. What started as "this should just work" turned into weeks of chasing hardware corruption that would leave the chip in states requiring physical power cycling.

The core problem was that RP2040 has this unique rescue mode boot sequence that completely changes how the debug interface behaves. Unlike other ARM chips where you can reliably init/uninit flash algorithms, the RP2040 would get into states where repeated initialization calls would corrupt something deep in the hardware - not just software state, but actual hardware that required disconnecting power to recover.

Initially I thought it was my CRC implementation causing stack corruption or memory conflicts. Spent days trying different RAM allocations, different stack gaps, different algorithm approaches. None of it mattered because the real issue was much more fundamental.

The first breakthrough was discovering that the rescue debug port reset was wiping register settings that the flash operations depended on. This explained why things would work initially then fail unpredictably - the reset was clearing configuration that subsequent operations assumed was still there.

That led me down a rabbit hole of trying to run the ROM SPI flash bring-up code manually before CRC operations, thinking I needed to reinitialize the flash controller to get memory-mapped access working. Spent way too much time trying to replicate what the RP2040 ROM does during boot to set up XIP mode.

Then I realized the flash algorithm init was already doing this setup work. But here's where it got really tricky - the flash algorithm init puts the chip into a state where flash is configured for programming operations, but memory-mapped reading (XIP) is disabled. So when I tried to run CRC32 verification after init, the target couldn't actually read the flash content because XIP was turned off.

The final breakthrough was realizing I needed an additional uninit call before running CRC32 to restore XIP access, then another init before any erase/program operations. The sequence had to be: init (to load algorithm) → uninit (to enable XIP for reading) → CRC32 (can now read flash) → init again (if programming needed) → erase/program → uninit (cleanup).

This triple-init pattern was what was causing the hardware corruption originally because the RP2040 rescue mode couldn't handle multiple init sequences in the same session. The solution was having the flash algorithm own this entire lifecycle so there's only one entity managing the init/uninit state transitions, and it knows exactly when XIP needs to be enabled vs disabled.

What's particularly satisfying is that this also solved the architectural issues the maintainers raised. The flash algorithm is now truly in charge of all target-side functionality, and the complex state management that was causing the corruption got replaced with a clean, single-ownership model.

Testing now shows consistent 8-9 second flash times on RP2040 with no hardware corruption across dozens of cycles. The 96% reduction in flash operations for incremental changes is working reliably, and it's compatible with rescue mode, normal boot, and all the different RP2040 states I can throw at it.