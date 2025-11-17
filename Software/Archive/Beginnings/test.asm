SIO = %00000010

        .org $0000

        ld a, %00000101       ; Select WR5
        out (SIO), a
        ld a, %00000000       ; Clear DTR (bit 7)
        out (SIO), a
loop:
        jp loop

        DS 32768 - $
