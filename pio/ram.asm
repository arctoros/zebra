;+-- Symbols ---
SIO_DATA = %00000000
SIO_CMD	= %00000010
;---

;+-- Reset --- 
        .org $0000

reset:
				ld a, %00000011       ; Select WR3
				out (SIO_CMD), a
        ld a, %11000001
				;      ││     └─────── Rx Enable
				;      └┴───────────── 8 bits per character
        out (SIO_CMD), a

        ld a, %00000100       ; Select WR4
        out (SIO_CMD), a
        ld a, %10000111
				;      │││││││└─────── Parity Enable
				;      ││││││└──────── Parity Even
				;      ││││└┴───────── 1 Stop Bit
				;      ││└┴─────────── Sync Mode Disable
				;      └┴───────────── X32 Clock Mode 
        out (SIO_CMD), a

				ld a, %00000101       ; Select WR5
        out (SIO_CMD), a
        ld a, %01101000
				;       ││ └────────── Tx Enable
				;       └┴──────────── 8 bits per character 
        out (SIO_CMD), a 

				ld hl, $5000
				ld sp, hl
				
				ld bc, $42
				push bc
				ld bc, $64
				pop bc
				ld a, c
				out (SIO_DATA), a
loop:
				jp loop
;---
