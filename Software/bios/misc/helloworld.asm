message:db $0D, $0A, '!', ' ', 'd', 'l', 'r', 'o', 'w', ' ', 'o', 'l', 'l', 'e', 'H'

				ld hl, message + 14
hello:	ld a, (hl)
				call printChar
				dec l
				jp nz, hello
				jp loop
