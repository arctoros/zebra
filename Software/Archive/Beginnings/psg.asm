WRITE		 = $0000
READ     = $0001
ADDRESS  = $0001

				.org $0000
			
				ld a,$00
				out ADDRESS,a

				ld a,$DE
				out WRITE,a

				ld a,$01
				out ADDRESS,a

				ld a,$01
				out WRITE,a

				ld a,$07
				out ADDRESS,a

				ld a,$FE
				out WRITE,a

				ld a,$08
				out ADDRESS,a

				ld a,$0F
				out WRITE,a
				
loop:
				jp loop

				.org $7FFF
				.db $00
