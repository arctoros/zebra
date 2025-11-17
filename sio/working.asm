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

loop:
				;ld a, $61
				;out (DATA), a
				
				;ld bc, #0
1$:
  		  bit #0,a    ; 8
    		bit #0,a    ; 8
   		 	bit #0,a    ; 8
   		 	and a,#255  ; 7
   		 	dec bc      ; 6
   		 	ld a,c     ; 4
    		or b     ; 4
   		 	jp nz, reset   ; 10, total = 55 states/iteration
				
				ld a, $61
				out (DATA), a
				jp reset 

;---

;+-- Subroutines 

;---
        DS 32768 - $
