#!/usr/bin/env python3
"""make_tiles.py: the pictures of the tile test - art/tiles.png, a sheet of
eight 32 pixel tiles (grass, a path, a stone wall, water, brick, flowers,
sand and planks), and art/walker.png, the frames of a little walker: four
steps on the first row, two breaths on the second. Drawn the same each time
from a fixed seed. Run from the project's folder."""
import math
import random
from PIL import Image, ImageDraw

T = 32
rng = random.Random(7)


def speckle(d, x0, y0, base, spread, count, size=1):
    for _ in range(count):
        x, y = x0 + rng.randrange(T), y0 + rng.randrange(T)
        s = rng.randint(-spread, spread)
        c = tuple(max(0, min(255, v + s)) for v in base)
        d.rectangle([x, y, x + size - 1, y + size - 1], fill=c)


def grass(d, x0, y0, flowers=False):
    d.rectangle([x0, y0, x0 + T - 1, y0 + T - 1], fill=(74, 140, 62))
    speckle(d, x0, y0, (74, 140, 62), 22, 90)
    for _ in range(14):
        x, y = x0 + rng.randrange(2, T - 2), y0 + rng.randrange(4, T)
        d.line([x, y, x + rng.choice([-1, 0, 1]), y - 3], fill=(108, 178, 84))
    if flowers:
        for colour in [(240, 90, 120), (250, 220, 90), (180, 140, 250), (250, 250, 250)]:
            x, y = x0 + rng.randrange(4, T - 4), y0 + rng.randrange(4, T - 4)
            d.ellipse([x - 2, y - 2, x + 2, y + 2], fill=colour)
            d.point([x, y], fill=(255, 240, 160))


def path(d, x0, y0):
    d.rectangle([x0, y0, x0 + T - 1, y0 + T - 1], fill=(150, 112, 74))
    speckle(d, x0, y0, (150, 112, 74), 18, 120)
    for _ in range(5):
        x, y = x0 + rng.randrange(3, T - 3), y0 + rng.randrange(3, T - 3)
        d.ellipse([x - 2, y - 1, x + 2, y + 1], fill=(120, 110, 100))


def stone(d, x0, y0):
    d.rectangle([x0, y0, x0 + T - 1, y0 + T - 1], fill=(70, 72, 80))
    for row, y in enumerate(range(0, T, 11)):
        shift = 8 if row % 2 else 0
        for x in range(-16 + shift, T, 16):
            a, b = max(0, x + 1), min(T - 1, x + 15)
            if a >= b:
                continue
            shade = rng.randint(118, 150)
            d.rectangle([x0 + a, y0 + y + 1, x0 + b, y0 + min(T - 1, y + 9)], fill=(shade, shade, shade + 8))
            d.line([x0 + a, y0 + y + 1, x0 + b, y0 + y + 1], fill=(shade + 30, shade + 30, shade + 36))


def water(d, x0, y0):
    for y in range(T):
        t = y / T
        d.line([x0, y0 + y, x0 + T - 1, y0 + y], fill=(int(40 + 20 * t), int(110 + 20 * t), int(200 - 10 * t)))
    for y in range(4, T, 8):
        for x in range(0, T, 2):
            yy = y + math.sin((x + y) * 0.4) * 1.5
            d.point([x0 + x, y0 + int(yy)], fill=(150, 200, 250))


def brick(d, x0, y0):
    d.rectangle([x0, y0, x0 + T - 1, y0 + T - 1], fill=(200, 196, 186))
    for row, y in enumerate(range(0, T, 8)):
        shift = 8 if row % 2 else 0
        for x in range(-16 + shift, T, 16):
            a, b = max(0, x + 1), min(T - 1, x + 15)
            if a >= b:
                continue
            r = rng.randint(150, 182)
            d.rectangle([x0 + a, y0 + y + 1, x0 + b, y0 + y + 6], fill=(r, r // 3 + 20, r // 4 + 10))


def sand(d, x0, y0):
    d.rectangle([x0, y0, x0 + T - 1, y0 + T - 1], fill=(222, 200, 140))
    speckle(d, x0, y0, (222, 200, 140), 20, 160)


def planks(d, x0, y0):
    for i, y in enumerate(range(0, T, 8)):
        c = (150 + (i % 2) * 14, 100 + (i % 2) * 8, 58)
        d.rectangle([x0, y0 + y, x0 + T - 1, y0 + y + 7], fill=c)
        d.line([x0, y0 + y + 7, x0 + T - 1, y0 + y + 7], fill=(90, 58, 30))
        nail = rng.randrange(4, T - 4)
        d.point([x0 + nail, y0 + y + 3], fill=(60, 50, 40))


sheet = Image.new("RGBA", (4 * T, 2 * T))
d = ImageDraw.Draw(sheet)
grass(d, 0, 0)
path(d, T, 0)
stone(d, 2 * T, 0)
water(d, 3 * T, 0)
brick(d, 0, T)
grass(d, T, T, flowers=True)
sand(d, 2 * T, T)
planks(d, 3 * T, T)
sheet.save("art/tiles.png")


def walker(d, x0, y0, step, breath, blink):
    """A round little walker facing right: a body bobbing with the step,
    two legs swinging, an eye."""
    bob = abs(math.sin(step * math.pi / 2)) * 2 if step >= 0 else breath
    swing = math.sin(step * math.pi / 2) * 5 if step >= 0 else 0
    cx, cy = x0 + 16, y0 + 15 - bob
    for side, sign in ((0, 1), (1, -1)):
        foot = cx + sign * swing - 2 + side * 4
        d.line([cx - 2 + side * 4, cy + 7, foot, y0 + 29], fill=(60, 50, 70), width=3)
        d.ellipse([foot - 3, y0 + 27, foot + 3, y0 + 31], fill=(60, 50, 70))
    d.ellipse([cx - 10, cy - 10, cx + 10, cy + 10], fill=(240, 150, 60), outline=(120, 60, 30))
    d.ellipse([cx - 6, cy - 7, cx + 1, cy - 2], fill=(255, 205, 140))
    if blink:
        d.line([cx + 3, cy - 2, cx + 8, cy - 2], fill=(40, 30, 40), width=2)
    else:
        d.ellipse([cx + 3, cy - 5, cx + 8, cy], fill=(255, 255, 255))
        d.ellipse([cx + 5, cy - 4, cx + 8, cy - 1], fill=(40, 30, 40))


frames = Image.new("RGBA", (4 * T, 2 * T), (0, 0, 0, 0))
d = ImageDraw.Draw(frames)
for i in range(4):
    walker(d, i * T, 0, i, 0, False)
walker(d, 0, T, -1, 0, False)
walker(d, T, T, -1, 1, False)
walker(d, 2 * T, T, -1, 1, True)
walker(d, 3 * T, T, -1, 0, False)
frames.save("art/walker.png")
print("art/tiles.png, art/walker.png")
