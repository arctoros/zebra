;+-- Symbols ---
; Only Port A is hooked up
DATA = %00000001
CMD	= %00000011
;---

;+-- Reset --- 
        .org $8000

reset:
				ld sp, $5000


				ld a, %00000011       ; Select WR3
        out (CMD), a
        ld a, %11000001
				;      ││     └─────── Rx Enable
				;      └┴───────────── 8 bits per character
        out (CMD), a

        ld a, %00000100       ; Select WR4
        out (CMD), a
        ld a, %01000111
				;      │││││││└─────── Parity Enable
				;      ││││││└──────── Parity Even
				;      ││││└┴───────── 1 Stop Bit
				;      ││└┴──────────0 Sync Mode Disable
				;      └┴───────────── X32 Clock Mode 
        out (CMD), a

				ld a, %00000101       ; Select WR5
        out (CMD), a
        ld a, %01101000
				;       ││ └────────── Tx Enable
				;       └┴──────────── 8 bits per character 
        out (CMD), a 
;---

;+-- Loop ---
				ld hl, message + 12
loop:
				ld d, (hl)
				ld a, d
				call print
				dec l
				jp nz, loop
halt:
				jp halt
;---

;+--- Subroutines
print:
				out (DATA), a
				ld b, 28     		   		; 7 T
delay:												; Total 7 + 13 * 28 = 379 T
    		djnz delay		    		; 28 × 13 + 8 = 372 T
				ret	

				.org $9001
;---

;+-- Look-up Tables
message:
				db '!', ' ', 'd', 'l', 'r', 'o', 'w', ' ', 'o', 'l', 'l', 'e', 'H'
;---
