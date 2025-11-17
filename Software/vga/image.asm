;+-- Reset --- 
        .org $8000
				
				di
				ld bc, image
				ld hl, $8000
write:
				ld a, (bc)
				ld (hl), a
				inc bc
				inc hl
				ld a, h
				or l
				jp nz, write
				halt

image:
				.incbin "out80x50.bin"
