;+-- Symbols ---
;Only Port A is hooked up
SIO_DATA = %00000000					; Port A data register
SIO_CMD	= %00000010						; Port A command register

PIO_IN_DATA = %00010000 			; Port A data register
PIO_IN_CMD = %00010010 				; Port A command register
PIO_OUT_DATA = %00010001 			; Port B data register
PIO_OUT_CMD = %00010011 			; Port B command register

CTC_C0 = %00110000						; Channel 0
CTC_C1 = %00110001						; Channel 1
CTC_C2 = %00110010						; Channel 2
CTC_C3 = %00110011						; Channel 3
;---

;+-- Reset --- 
        .org $8000

reset:
				; CPU INITIALISATION
				ld sp, $5000

				; SIO INITIALISATION
				ld a, %00000011       ; Select WR3
        out (SIO_CMD), a
        ld a, %11000001
				;      ││     └─────── Rx Enable
				;      └┴───────────── 8 bits per character
        out (SIO_CMD), a

        ld a, %00000100       ; Select WR4
        out (SIO_CMD), a
        ld a, %01000111
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

        ld a, %10100101
				;      │││ │││└─────── Control Word
				;      │││ ││└──────── Continued Operation
				;      │││ │└───────── Time Constant Follows
				;      │││ └────────── Automatic trigger
				;      ││└──────────── Prescaler Value = 256 
				;      │└───────────── Select Timer Mode
				;      └────────────── Enable Interrupts 
        out (CTC_C0), a
				ld a, $FF
				out (CTC_C0), a

;---

;+-- Loop ---
loop:
				ld a, "b"							; Load in the next bit
				out (PIO_OUT_DATA), a ; Strobe the next bit
				
				ld a, $FF
				ei
delay:	
				cp 0
				jp nz, delay
				di
				jp strobe 
;---

;+-- Subroutines
.local
print::
				out (SIO_DATA), a
				ld b, 28     		   		; 7 T
delay:												; Total 7 + 13 * 28 = 379 T
    		djnz delay		    		; 28 × 13 + 8 = 372 T
				ret	
.endlocal
;---

;+-- Interrupt Handlers
int:
				dec a
				reti
;---
