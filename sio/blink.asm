SIO = %00000010

        .org $0000
on:
				ld a, %00000101
				out (SIO), a 

				ld a, %10000000
				out (SIO), a

				call delay

off:
				ld a, %00000101
				out (SIO), a

				ld a, %00000000
				out (SIO), a

				call delay
				
				jp on

delay:
				ld bc, $FFFF
				;ld e, 32
loop:
				dec bc
				ld a, b
        or c
				;jp nz, loop
				;dec e
				ret z
				;ld bc, $FFFF
				jp loop


        DS 32768 - $
