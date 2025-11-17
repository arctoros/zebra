STACK = $5000

        .org $8000
reset:	ld sp, STACK
				di
				
				ld bc, image
				ld hl, $8000
wipe:		ld a, (bc)
				ld (hl), a
				inc bc
				inc hl
				ld a, h
				or l
				jp nz, wipe
				halt

image:	.incbin "out80x50.bin"
