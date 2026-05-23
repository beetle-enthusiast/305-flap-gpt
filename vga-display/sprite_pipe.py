from PIL import Image

img = Image.open("pipe.png").convert("RGB")

# Shrink to sprite size using nearest-neighbour (keeps hard edges)
sprite = img.resize((70, 100), Image.NEAREST)

# Reduce color count to keep it clean (this step is optional)
sprite = sprite.quantize(colors=16).convert("RGB")

sprite.save("sprite_preview.png")  # save to check it looks right

with open("sprite.hex", "w") as f:
    for y in range(sprite.height):
        for x in range(sprite.width):
            r, g, b = sprite.getpixel((x, y))
            f.write(f"{r:02X}{g:02X}{b:02X}\n")