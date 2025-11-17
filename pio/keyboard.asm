;+-- Symbols ---
PIO_IN_DATA = %00010000 ; Port A data register
PIO_IN_CMD = %00010010 ; Port A command register
PIO_OUT_DATA = %00010001 ; Port B data register
PIO_OUT_CMD = %00010011 ; Port B command register

;Only Port A is hooked up
SIO_DATA = %00000000
SIO_CMD	= %00000010
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
				
				; PIO INITIALISATION
				ld a, %00001111
				;      ││││└┴┴┴─────── Identifies Mode Control Word 
				;      ││└┴─────────── Don't care 
				;      └┴───────────── Mode 0 (Output)
				out (PIO_OUT_CMD), a	; Write to output port command register

				ld a, %01001111
				;      ││││└┴┴┴─────── Identifies Mode Control Word 
				;      ││└┴─────────── Don't care 
				;      └┴───────────── Mode 1 (Input)
				out (PIO_IN_CMD), a		; Write to input port command register
;---

;+-- Loop ---
strobe:
				ld d, %00000001				; Load the initial output coordinate
				ld b, 0

loop:
				ld a, d								; Load in the next bit
				out (PIO_OUT_DATA), a ; Strobe the next bit

				in a, (PIO_IN_DATA)		; Read back the input coordinate
				add 0
				jp z, next

				ld c, $FF
shift1:
				inc c
				srl a
				jp nc, shift1 

				ld hl, BitsToIndex
				add hl, bc
				ld a, (hl)

				ld c, $FF
				ld e, d
shift2:
				inc c
				srl e
				jp nc, shift2

				ld hl, BitsToIndex
				add hl, bc
				ld e, (hl)
				sla e
				sla e
				sla e
	
				add e									; Add the output coordinate to the input coordinate
				
				ld hl, CoordsToASCII	; Load the ASCII LUT offset
				ld c, a								; Load the index into lower-order byte l
				add hl, bc						; Load the index into lower-order byte l
				ld a, (hl)						; Retrieve ASCII character with index
				call print
			
next:
				sla d									; Shit output coordinate left by 1
				jp nz, loop 					; Break if carry is set (Bit has arrived)

				ld b, $02
delay1:
				push bc
				ld b, $FF
delay2:
				push bc
				ld b, $FF
delay3:
    		djnz delay3
				pop bc
				djnz delay2
				pop bc
				djnz delay1
				
				jp strobe 
;---

;+--- Subroutines
.local
print::
				out (SIO_DATA), a
				ld b, 28     		   		; 7 T
delay:												; Total 7 + 13 * 28 = 379 T
    		djnz delay		    		; 28 × 13 + 8 = 372 T
				ret	
.endlocal
;---

;+-- Look-up Tables
				.org $9000
BitsToIndex:
				DB $00, $01, $02, $03, $04, $05, $06, $07

CoordsToASCII:
    		DB 60h, 38h, 00h, 69h, 1Bh, 6Bh, 00h, 2Ch
   			DB 31h, 39h, 71h, 6Fh, 61h, 6Ch, 7Ah, 2Eh
				DB 32h, 30h, 77h, 70h, 73h, 3Bh, 78h, 2Fh
				DB 33h, 2Dh, 65h, 5Bh, 64h, 27h, 63h, 00h
				DB 34h, 3Dh, 72h, 5Dh, 66h, 0Ah, 76h, 00h
				DB 35h, 08h, 74h, 5Ch, 67h, 00h, 62h, 00h
				DB 36h, 00h, 79h, 00h, 68h, 00h, 6Eh, 00h
				DB 37h, 00h, 75h, 00h, 6Ah, 20h, 6Dh, 00h

CoordsToASCIIShift:
				DB 7Eh, 2Ah, 00h, 49h, 00h, 4Bh, 00h, 3Ch
				DB 21h, 28h, 51h, 4Fh, 41h, 4Ch, 5Ah, 3Eh
				DB 40h, 29h, 57h, 50h, 53h, 3Ah, 58h, 3Fh
				DB 23h, 5Fh, 45h, 7Bh, 44h, 22h, 43h, 00h
				DB 24h, 2Bh, 52h, 7Dh, 46h, 00h, 56h, 00h
				DB 25h, 00h, 54h, 7Ch, 47h, 00h, 42h, 00h
				DB 5Eh, 00h, 59h, 00h, 48h, 00h, 4Eh, 00h
				DB 26h, 00h, 55h, 00h, 4Ah, 00h, 4Dh, 00h
;---
