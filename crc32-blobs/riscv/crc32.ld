/*
 * RISC-V CRC32 Algorithm Linker Script
 * Position-independent code layout for probe-rs flash algorithms
 * 
 * Memory layout:
 *   0x00: Algorithm header with entry points  
 *   0x10: Main code section
 *   0xXX: Lookup tables (4KB for slicing-by-4)
 */

ENTRY(_start)

SECTIONS
{
    /* Algorithm starts at address 0 for position independence */
    . = 0x00000000;
    
    /* Algorithm header with entry point table */
    .header : {
        /* RISC-V breakpoint instruction: ebreak (0x00100073) */
        LONG(0x00100073)        /* Breakpoint for probe-rs detection */
        LONG(0x00000000)        /* Reserved */
        LONG(0x00000000)        /* Reserved */
        LONG(0x00000000)        /* Reserved - entry point offset filled by probe-rs */
        
        /* Entry point table at fixed offsets for probe-rs compatibility */
        . = 0x10;
    }
    
    /* Main code section */
    .text : ALIGN(4) {
        *(.text.startup)
        *(.text.init_crc32)
        *(.text.uninit_crc32) 
        *(.text.calculate_crc32)
        *(.text.sector_crc32)
        *(.text)
        *(.text.*)
        
        /* Ensure minimum alignment for function pointers */
        . = ALIGN(4);
    }
    
    /* Read-only data (CRC32 lookup tables) */
    .rodata : ALIGN(4) {
        *(.rodata)
        *(.rodata.*)
        
        /* Ensure 4-byte alignment for table access efficiency */
        . = ALIGN(4);
    }
    
    /* Small data section (if any) */
    .sdata : ALIGN(4) {
        *(.sdata)
        *(.sdata.*)
    }
    
    /* Ensure total size is 4-byte aligned */
    . = ALIGN(4);
    
    /* Discard unwanted sections that could break position independence */
    /DISCARD/ : {
        *(.dynamic)
        *(.dynstr)
        *(.dynsym)
        *(.hash)
        *(.gnu.hash)
        *(.gnu.version)
        *(.gnu.version_*)
        *(.got)
        *(.got.*)
        *(.plt)
        *(.plt.*)
        *(.interp)
        *(.note.*)
        *(.comment)
        *(.debug_*)
        *(.eh_frame)
        *(.eh_frame_hdr)
        *(.riscv.attributes)
    }
}

/* Virtual memory region - probe-rs will load this into target RAM */
MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 16K
}

/* Provide symbols for code analysis */
_text_start = ADDR(.text);
_text_end = ADDR(.text) + SIZEOF(.text);
_rodata_start = ADDR(.rodata);
_rodata_end = ADDR(.rodata) + SIZEOF(.rodata);
_total_size = .;