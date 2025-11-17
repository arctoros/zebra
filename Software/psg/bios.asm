;+-- Symbols ---
;Only Port A is hooked up
SIO_DATA = %00000000					; Port A data register
SIO_CMD	= %00000010						; Port A command register

CTC_C0 = %00110000						; Channel 0
CTC_C1 = %00110001						; Channel 1
CTC_C2 = %00110010						; Channel 2
CTC_C3 = %00110011						; Channel 3

PSG_INACT = %00100000					; BDIR Low, BC1 Low
PSG_READ  = %00100001					; BDIR Low, BC1 High
PSG_WRITE = %00100010					; BDIR High, BC1 Low
PSG_ADDR  = %00100011					; BDIR High, BC1 High

; RAM
STACK = $5000
;---

;+-- Reset ---  
				org $8000

reset:
				;+-- CPU Initialisation
				ld sp, STACK
				ld a, hi(intVectors)
				ld i, a
				im 2
				di
				;---

				;+-- SIO Initialisation
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
				call printChar
				;---

				;+-- CTC Initialisation
				ld a, lo(CTCVec)
        out (CTC_C0), a
        
				ld a, %10100101
				;      │││ │││└─────── Control Word
				;      │││ ││└──────── Continued Operation
				;      │││ │└───────── Time Constant Follows
				;      │││ └────────── Automatic trigger
				;      ││└──────────── Prescaler Value = 256 
				;      │└───────────── Select Timer Mode
				;      └────────────── Enable Interrupts 
        out (CTC_C0), a

				ld a, $FF							; Start Timer
				out (CTC_C0), a
				;---

				;+-- PSG  Initialisation
				ld b, 16
				ld hl, PSGCommands
PSGReset:
				ld d, l
				ld e, (hl)
				call PSGInit
				inc l
				djnz PSGReset
				;--- 

				;+-- Player Initialisation
				ld hl,MusicStart    	;Declared below.
    		xor a                 ;Subsong 0 (the main one).
    		call PLY_AKG_Init
				;---

				;+-- VRAM Initialisation
				ld hl, $8000
wipe:		ld (hl), 0
				inc hl
				ld a, h
				or l
				jp nz, wipe
				;---
;---

;+-- Loop ---
loop:
				ei
				halt
				halt
				di
				
				call PLY_AKG_Play
				
				jp loop
;---

;+-- Subroutines
.local
printChar::
				push bc
				out (SIO_DATA), a			; Print A to SIO
				ld b, 40
delay:	djnz delay						; 7 + 13 * 28 + 8 = 379 T
				pop bc
				ret
.endlocal

PSGInit::
				ld a, d
				out (PSG_ADDR), a
				ld a, e
				out (PSG_WRITE), a
				ret
;---

;+-- Interrupt Handlers
				org $8F00
intVectors:
CTCVec:	DB lo(CTCInt), hi(CTCInt)
SIOVec:	DB lo(SIOInt), hi(CTCInt)

CTCInt:			
				ei
				reti

SIOInt:
				ei
				reti
;---

;+-- Look-up Tables
				org $9000					; LSB should be $00
PSGCommands:
				DB $00							; R0, Port A fine adjustment = $DE
				DB $00							; R1, Port A coarse adjustment = $01
				DB $00							; R2, Clear
				DB $00							; R3, Clear
				DB $00							; R4, Clear
				DB $00							; R5, Clear
				DB $00							; R6, Clear
				DB $FE							; R7, Tone Enable on Channel A, Noise Disable, Input Disable
				DB $0F							; R8, Full Volume
				DB $00							; R9, Clear
				DB $00							; RA, Clear
				DB $00							; RB, Clear
				DB $00							; RC, Clear
				DB $00							; RD, Clear
				DB $00							; RE, Clear
				DB $00							; RF, Clear
;---
				
;+-- Includes				
				org $9100
				.include "PlayerAkg.asm"
				
				org $A000
MusicStart:
				.include "buzz.asm"
;------
