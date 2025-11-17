SIO = %00000010

        .org $0000

on:
        ld a, %00000101       ; Select WR5
        out (SIO), a
        ld a, %10000000       ; Set DTR (bit 7)
        out (SIO), a

off:
        ld a, %00000101       ; Select WR5
        out (SIO), a
        ld a, %00000000       ; Clear DTR (bit 7)
        out (SIO), a
        jp on

        DS 32768 - $
