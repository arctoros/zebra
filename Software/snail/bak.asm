;+-- BIOS ---
				org $8000
				.include "bios.asm"
				org $9200
;---

;+-- Symbols ---
SPEED = $6000
DIR = $6001
RAND = $6002
HEAD = $6004
HEADX = $6006
TAIL = $6008
STACK = $7000

SNAILCOL = $0A
SLIMECOL = $0E
LEAFCOL = $04
TERMINATOR = $7F

LEAFCOUNT = 16

UP = -80
DOWN = 80
RIGHT = 1
LEFT = -1
;---

;+-- Reset ---   
program:
				ld a, RIGHT
				ld (DIR), a
				
				ld a, (RAND)
				cp 0
				jp nz, validSeed
				ld a, 1
				ld (RAND), a

validSeed:
				ld a, TERMINATOR
				ld (STACK + 4000), a

    		ld bc, 4000        		; counter
    		ld hl, STACK
wipe:		ld (hl), 0
    		inc hl
    		dec bc
    		ld a, b
    		or c              	 	; check if BC == 0
    		jr nz, wipe
				
				ld hl, STACK + 25 * 80 + 20
				ld (HEAD), hl					; Snail head at 20, 25
				ld a, 20
				ld (HEADX), a         ; column = 20
				ld hl, STACK + 25 * 80 + 19
				ld (TAIL), hl					; Snail tail at 20, 25
				ld (hl), RIGHT				; Render snake head going right
				
				ld b, LEAFCOUNT
spawnLeaves:
				call leaf
				djnz spawnLeaves
;---

;+-- Loop ---
programLoop:		
				ld hl, (HEAD) 
				ld (hl), SNAILCOL 

				call drawBoard				; Render
				call drawBoard				; Render again to remove artefacts
				call nextDir					; Check keyboard map for next direction

				ld hl, (HEAD) 
				ld a, (DIR) 
				ld (hl), a						; Load address with snail head
				call move							; Move the head
				call necromancer			; Check if the snail died, clobbers with a
				call slither					; Tend to the slime

				jp programLoop
;---

;+-- Subroutines ---
move:		ld a, (DIR)      			; Load signed 8-bit value into A
    		ld c, a         			; Low byte
				rla             			; Shift sign bit into carry
				sbc a, a         			; Mow A = 0x00 if positive, 0xFF if negative
				ld b, a          			; High byte = sign-extension
				ld hl, (HEAD)					; Load head address into HL
				add hl, bc       			; HL = HL + signed(DIR)
				ld (HEAD), hl

				ld de, STACK
				or a
				sbc hl, de
				jp c, death   			  ; HL < STACK

				ld de, 4000
				sbc hl, de
				jp nc, death			    ; HL >= STACK+4000

				ld a, (DIR)
				cp RIGHT
				jp z, chkRight
				cp LEFT
				jp z, chkLeft
				ret

chkRight:
				ld a, (HEADX)         ; current column 0..79
				cp 79
				jp z, death    			  ; moving right from col 79 -> out of screen
				inc a				          ; column++
				ld (HEADX), a
				ret

chkLeft:
				ld a, (HEADX)
				cp 0
				jp z, death   		   	; moving left from col 0 -> out of screen
				dec a           			; column--
				ld (HEADX), a
				ret

nextDir:ld a, (KEYBOARD_MAP + 3)
				bit 7, a							; If key (3,7) is pressed, go up
				jp nz, mvUp
				ld a, (KEYBOARD_MAP + 5)
				bit 7, a							; If key (5,7) is pressed, go right
				jp nz, mvRight
				ld a, (KEYBOARD_MAP + 6)
				bit 3, a							; If key (6,3) is pressed, go left
				jp nz, mvLeft
				ld a, (KEYBOARD_MAP + 6)
				bit 7, a							; If key (6,7) is pressed, go down
				jp nz, mvDown
				ret

mvUp:		ld a,	UP							; Subtract a line from position
				ld (DIR), a
				ret
mvDown:	ld a, DOWN						; Add a line from position
				ld (DIR), a
				ret
mvRight:ld a, RIGHT						; Add one tile to position
				ld (DIR), a
				ret
mvLeft:	ld a, LEFT						; Subtract one tile from position
				ld (DIR), a
				ret

slither:ld hl, (HEAD) 
				ld a, (hl)						; A stores previous tile
				cp LEAFCOL						; A holds previous cell value
				jp z, leaf						; If it is a leaf, leave tail and generate new leaf

				ld hl, (TAIL)					; Else, load address of tail cell
				ld a, (hl)						; Save the value
				ld (hl), 0						; and overwrite it with 0

    		ld c,a         			 	; Low byte
				rla             			; Shift sign bit into carry
				sbc a,a         			; Mow A = 0x00 if positive, 0xFF if negative
				ld b,a          			; High byte = sign-extension
				add hl,bc       			; HL = HL + signed(DIR)
				ld (TAIL),hl
				ret

leaf:		ld hl,(RAND)
				ld a,h
				rra
				ld a,l
				rra
				xor h
				ld h,a
				ld a,l
				rra
				ld a,h
				rra
				xor l
				ld l,a
				xor h
				ld h,a
				ld (RAND),hl
				
				and $0F
				ld h, a
				push hl
				ld de, 4000
				sbc hl, de
				jp nc, leaf

				pop hl
				ld de, STACK
				add hl, de

				ld a, (hl)
				call isSnail
				jp z, leaf
				cp LEAFCOL
				jp z, leaf
				
				ld (hl), LEAFCOL
				ret

necromancer:
				ld hl, (HEAD) 
				ld a, (hl)						; A stores previous tile
				call isSnail
				ret nz

death:	pop bc
				ld bc, 4000        		; Counter
				ld hl, STACK					; STACK pointer
red:		ld (hl), $0C					; Load only red
    		inc hl								; Increment VRAM pointer
    		dec bc								; Decrement counter
    		ld a, b
    		or c              	 	; 16-bit compare
    		jr nz, red						; Repeat until counter == 0
				
				call drawBoard				; Render
				call drawBoard				; Render again to remove artefacts
				
				ld a, $FF
wait		ei										; Enable Interrupts by CTC
				halt									; Wait for Interrupt
				di
				dec a									; Decremenent Speed
				jp nz, wait						; Wait until Speed is 0

				jp reset							; Reset everything after death

drawBoard:
				ld bc, STACK					; Stack Pointer
				ld de, $8000					; Pixel Pointer in VRAM

render:	ld a, (bc)						; Fetch next pixel from stack
				call isSnail

				sla a									; Shift pixel into more significant nibble
				sla a
				sla a
				sla a
				ld h, a								; Save nibble to h

				inc bc								; Point to next tile
				ld a, (bc)						; Fetch next tile
				call isSnail
				cp TERMINATOR					; Check if stack terminator	
				ret z									; Return if it is
				
				or h									; Or with first nibble
				ld (de), a						; Write colour to VRAM
				inc bc								; Point to next tile
				inc de								; Point to next pixel pair
				jp render							; Repeat until terminator has been found

isSnail:cp UP									; Z is 1 if not snail and 0 if snail
				jp z, snail
				cp DOWN
				jp z, snail	
				cp RIGHT
				jp z, snail
				cp LEFT
				jp z, snail
				ret
snail:	ld a, SLIMECOL
				ret
;---
