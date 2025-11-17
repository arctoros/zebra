;+-- Symbols ---
; IO
PIO_IN_DATA = %00010000 ; Port A data register
PIO_IN_CMD = %00010010 ; Port A command register
PIO_OUT_DATA = %00010001 ; Port B data register
PIO_OUT_CMD = %00010011 ; Port B command register

;Only Port B is hooked up
SIO_DATA = %00000001
SIO_CMD	= %00000011

; RAM
KEYBOARD_MAP = $4000
STACK = $5000
;---

;+-- Reset --- 
        .org $8000

reset:
				; CPU INITIALISATION
				ld sp, STACK

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

				ld a, ">"
				call print
				
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

				; Reset Keyboad Map
				ld b, 8
				ld hl, KEYBOARD_MAP
resetKeyboardMap:
				ld (hl), 0
				inc hl
				djnz resetKeyboardMap
;---

;+-- Loop ---
loop:
				ld b, $FF
strobe:
				push bc
				ld b, $FF
delay: 	djnz delay

				ld d, %00000001				; Load the initial output coordinate
				ld hl, KEYBOARD_MAP - 1		; Load the initial address of the keyboard map pointer
bitBang:
				ld a, d								; Load in the next bit
				out (PIO_OUT_DATA), a ; Strobe the next bit
				inc hl								; Increment keyboard map pointer
				sla d									; Shit output coordinate left by 1
				in a, (PIO_IN_DATA)		; Read back the input coordinate
				ld (hl), a						; Load the ready byte into ram at keyboard map pointer
				jp nc, bitBang 				; Break if carry is set (Bit has arrived)

				pop bc
				djnz strobe

				call printCharacters
				jp loop
;---

;+--- Subroutines
.local
print::
				push bc
				out (SIO_DATA), a			; Print A to SIO
				ld b, 28     		   		; 7 T
delay:												; Total 7 + 13 * 28 = 379 T
    		djnz delay		    		; 28 × 13 + 8 = 372 T
				pop bc
				ret
.endlocal

.local
printCharacters::
				ld bc, 0							; B is data byte, C is bit index
				ld de, 0							; D is shift bit, E is unused
				ld hl, KEYBOARD_MAP		; hl is map pointer, l is byte index
				ld a, (hl)						; Load 0th byte of map
				and %01000000					; Mask the shift bit
				ld d, a								; Store shift bit in D
byteLoop:
				ld b, (hl)						; Load in next byte of map

bitLoop:
				bit 0, b							; Test the 0th bit
				jp z, next						; Jump if clear
															; If bit is set:
				push bc
				push hl				
				ld a, l								; Load in the byte index
				sla a									; Byte Index << 3
				sla a
				sla a
				add c									; Add bit index
				or d									; Set the shift bit accordingly

				ld hl, CoordsToASCII	; Load the ASCII LUT offset
				ld bc, 0							; Clear BC
				ld c, a								; Load character index into c (to prevent 8-bit overflow)
				add hl, bc						; Add character index
				ld a, (hl)						; Retrieve ASCII character with index
				add 0									; Set the condition flags
				call nz, print				; Only print if not null
		
				pop hl
				pop bc

next:
				srl b									; Shift byte right
				ld a, 8
				inc c									; Increment bit index
				cp c									; Compare bit index to 8
				jp nz, bitLoop				; Repeat if C != 8

				ld c, 0								; If C = 8, reset C
				ld a, lo(KEYBOARD_MAP + 8)	; Load the last address of map
				inc hl								; Increment byte index
				cp l									; Compare byte index to last address
				jp nz, byteLoop				; Repeat if not arrived at last address
				ret										; Else, return
.endlocal
;---

;+-- Look-up Tables
				.org $9000
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
				DB 7Eh, 2Ah, 00h, 49h, 1Bh, 4Bh, 00h, 3Ch
				DB 21h, 28h, 51h, 4Fh, 41h, 4Ch, 5Ah, 3Eh
				DB 40h, 29h, 57h, 50h, 53h, 3Ah, 58h, 3Fh
				DB 23h, 5Fh, 45h, 7Bh, 44h, 22h, 43h, 00h
				DB 24h, 2Bh, 52h, 7Dh, 46h, 0Ah, 56h, 00h
				DB 25h, 08h, 54h, 7Ch, 47h, 00h, 42h, 00h
				DB 5Eh, 00h, 59h, 00h, 48h, 00h, 4Eh, 00h
				DB 26h, 00h, 55h, 00h, 4Ah, 20h, 4Dh, 00h
;---
