;+-- Symbols ---
; Only Port A is hooked up
DATA = %00000000
CMD	= %00000010
;---

;+-- Reset --- 
        .org $0000

reset:
				ld a, %00000011       ; Select WR3
        out (CMD), a
        ld a, %11000001
				;      ││     └─────── Rx Enable
				;      └┴───────────── 8 bits per character
        out (CMD), a

        ld a, %00000100       ; Select WR4
        out (CMD), a
        ld a, %10000111
				;      │││││││└─────── Parity Enable
				;      ││││││└──────── Parity Even
				;      ││││└┴───────── 1 Stop Bit
				;      ││└┴─────────── Sync Mode Disable
				;      └┴───────────── X32 Clock Mode 
        out (CMD), a

				ld a, %00000101       ; Select WR5
        out (CMD), a
        ld a, %01101000
				;       ││ └────────── Tx Enable
				;       └┴──────────── 8 bits per character 
        out (CMD), a 

				nop
				nop
				nop
				nop
				nop
				
				dec bc
   		 	ld a,c
    		or b
   		 	jp nz, reset 
				
				;ld bc, #0
				ld a, $61
				out (DATA), a
				jp reset
;---

;+-- Subroutines 

;---
