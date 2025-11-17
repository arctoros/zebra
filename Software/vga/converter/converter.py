from PIL import Image

img = Image.open("finchConverted.png")
pixels = list(img.getdata())

colours = {
    "000": 0,
    "484832": 1,
    "6480160": 2,
    "64144176": 3,
    "488032": 4,
    "11214480": 5,
    "809632": 6,
    "9611248": 7,
    "969680": 8,
    "968048": 9,
    "22417616": 10,
    "1448048": 11,
    "1284848": 12,
    "176144144": 13,
    "224208192": 14,
    "255255255": 15,
}


packed = bytearray()
for i in range(0, len(pixels), 2):
    s = ""
    for item in pixels[i]:
        s += str(item)
    p1 = colours[s]

    s = ""
    for item in pixels[i + 1]:
        s += str(item)
    p2 = colours[s]

    packed.append((p1 << 4) | p2)

# Save raw binary
with open("out.bin", "wb") as f:
    f.write(packed)

