"""Draws Tic Tac Toe's app icon and splash logo and writes every size the
platforms need.

A 3x3 grid on brand navy with an amber edge: ivory X marks in two corners and
an amber O in the centre. Re-run after tweaking:

    python tool/generate_icons.py      (from the project folder, needs Pillow)

After changing the splash logo, also run:

    dart run flutter_native_splash:create
"""

import pathlib

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
NAVY = (0x16, 0x19, 0x3A)
AMBER = (0xF2, 0xA5, 0x41)
IVORY = (0xF6, 0xF3, 0xEC)
LINE = (0x6E, 0x71, 0x88)

S = 1024  # drawn large, then scaled down


def art(background, content_scale=1.0):
    """background: "rounded" (icon tile), "square" (full bleed) or None."""
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if background == "square":
        d.rectangle((0, 0, S, S), fill=NAVY)
    elif background == "rounded":
        m = S * 0.04
        d.rounded_rectangle((m, m, S - m, S - m), radius=S * 0.2, fill=NAVY,
                            outline=AMBER, width=int(S * 0.035))

    def at(x, y):
        """Scales a point (fractions of S) around the centre."""
        return (S / 2 + (x - 0.5) * S * content_scale,
                S / 2 + (y - 0.5) * S * content_scale)

    lo, hi = 0.17, 0.83  # the grid's outer edges
    cell = (hi - lo) / 3
    grid = int(S * 0.018 * content_scale)
    for k in (1, 2):
        p = lo + cell * k
        d.line((*at(p, lo), *at(p, hi)), fill=LINE, width=grid)
        d.line((*at(lo, p), *at(hi, p)), fill=LINE, width=grid)

    mark = int(S * 0.032 * content_scale)
    inset = cell * 0.17

    def x_mark(col, row):
        x0, y0 = lo + cell * col + inset, lo + cell * row + inset
        x1, y1 = x0 + cell - 2 * inset, y0 + cell - 2 * inset
        d.line((*at(x0, y0), *at(x1, y1)), fill=IVORY, width=mark)
        d.line((*at(x0, y1), *at(x1, y0)), fill=IVORY, width=mark)

    def o_mark(col, row):
        x0, y0 = at(lo + cell * col + inset, lo + cell * row + inset)
        x1, y1 = at(lo + cell * (col + 1) - inset, lo + cell * (row + 1) - inset)
        d.ellipse((x0, y0, x1, y1), outline=AMBER, width=mark)

    x_mark(0, 0)
    o_mark(1, 1)
    x_mark(2, 2)
    return img


def save(img, path, size, rgb=False):
    out = img.resize((size, size), Image.LANCZOS)
    if rgb:
        bg = Image.new("RGB", out.size, NAVY)
        bg.paste(out, mask=out.split()[3])
        out = bg
    path.parent.mkdir(parents=True, exist_ok=True)
    out.save(path)
    print(f"{path.relative_to(ROOT)}  {size}px")


rounded = art("rounded")
square = art("square")
maskable = art("square", content_scale=0.78)  # inside the safe zone

save(rounded, ROOT / "web/favicon.png", 32)
save(rounded, ROOT / "web/icons/Icon-192.png", 192)
save(rounded, ROOT / "web/icons/Icon-512.png", 512)
save(maskable, ROOT / "web/icons/Icon-maskable-192.png", 192)
save(maskable, ROOT / "web/icons/Icon-maskable-512.png", 512)

for folder, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    save(rounded, ROOT / f"android/app/src/main/res/mipmap-{folder}/ic_launcher.png", size)

# iOS wants square, opaque icons; keep each existing file's size.
for png in sorted((ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset").glob("*.png")):
    save(square, png, Image.open(png).size[0], rgb=True)

ico = ROOT / "windows/runner/resources/app_icon.ico"
rounded.resize((256, 256), Image.LANCZOS).save(
    ico, sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
print(f"{ico.relative_to(ROOT)}  16-256px")

# Splash logo for flutter_native_splash: the marks only, on the navy splash
# colour, small enough for Android 12's round mask.
save(art(None, content_scale=0.55), ROOT / "assets/splash/splash_logo.png", 1024)
