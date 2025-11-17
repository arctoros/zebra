PORTA = $0000
PORTB = $0001
CMDA	= $0002
CMDB	= $0003


				.org $0000
			
				ld a,%11001111
				out CMDA,a

				ld a,$00
				out CMDA,a

				ld a,%00000111
				out CMDA,a

				ld a,$AA
				out PORTA,a

				.org $7FFF
				.db $00
