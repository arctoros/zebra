from PIL import Image, ImageOps

font = Image.open('./font.png').convert("L")
packed_bytes = bytearray()

binary_pixels = [1 if p >= 128 else 0 for p in font.getdata()]

for character in range(0, 96):
    for y in range(0, 8):
        byte = 0
        i = y * 768 + character * 8
        for bit_index, bit in enumerate(binary_pixels[i:i+8]):
           byte |= (bit << (7 - bit_index))
        packed_bytes.append(byte)

with open('CROM.asm', 'wt') as f:
    f.write(f"Characters:")
    for i in range(0, len(packed_bytes), 8):
        line_bytes = packed_bytes[i:i+8]
        formatted = ", ".join(f"${b:02X}" for b in line_bytes)
        f.write(f"              DB {formatted}\n")
