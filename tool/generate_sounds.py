"""Generates Tic Tac Toe's sound effects into assets/sounds/.

Every sound is synthesised from scratch here (no samples), so there are no
third-party licences involved: a chalk-like tap for each mark (X a little
brighter than O) and short marimba tunes for the end of a game. Re-run after
tweaking:

    python tool/generate_sounds.py      (from the project folder, needs numpy)
"""

import pathlib
import wave

import numpy as np

RATE = 22050
OUT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "sounds"
rng = np.random.default_rng(3)


def silence(seconds):
    return np.zeros(int(RATE * seconds))


def tap(pitch=1.0, length=0.12, brightness=1.0):
    """A mark drawn on the board: a short woody knock plus a scratch."""
    t = np.arange(int(RATE * length)) / RATE
    modes = [(520, 1.0, 45), (1240, 0.5 * brightness, 70),
             (2650, 0.25 * brightness, 110)]
    sound = sum(
        amp * np.sin(2 * np.pi * freq * pitch * t) * np.exp(-decay * t)
        for freq, amp, decay in modes
    )
    n = int(RATE * 0.012)
    sound[:n] += rng.normal(0, 0.5 * brightness, n) * np.linspace(1, 0, n)
    return sound


def marimba(freq, length=0.7):
    """A struck wooden bar: fundamental plus the bar's high fourth partial."""
    t = np.arange(int(RATE * length)) / RATE
    attack = np.minimum(1, t / 0.003)
    body = np.sin(2 * np.pi * freq * t) * np.exp(-5 * t)
    over = 0.3 * np.sin(2 * np.pi * freq * 4 * t) * np.exp(-18 * t)
    return (body + over) * attack


def mix(parts, total):
    """parts: list of (start_seconds, samples)."""
    out = silence(total)
    for start, samples in parts:
        i = int(RATE * start)
        end = min(len(out), i + len(samples))
        out[i:end] += samples[: end - i]
    return out


def save(name, samples, peak):
    samples = samples / np.max(np.abs(samples)) * peak
    fade = int(RATE * 0.01)
    samples[-fade:] *= np.linspace(1, 0, fade)
    data = (samples * 32767).astype("<i2").tobytes()
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(data)
    print(f"{name}.wav  {len(data) // 1024} KB")


C5, D5, E5, G5, C6 = 523.3, 587.3, 659.3, 784.0, 1046.5
A4, G4, E4, C4 = 440.0, 392.0, 329.6, 261.6

save("move_x", tap(1.15, brightness=1.2), peak=0.55)
save("move_o", tap(0.85, brightness=0.8), peak=0.55)
save("win", mix([(0.11 * k, marimba(f, 0.8))
                 for k, f in enumerate([C5, E5, G5, C6])], 1.3), peak=0.75)
save("lose", mix([(0.18 * k, marimba(f, 0.9))
                  for k, f in enumerate([G4, E4, C4])], 1.4), peak=0.6)
save("draw", mix([(0, marimba(D5)), (0.2, marimba(A4)),
                  (0.4, marimba(D5, 0.9))], 1.3), peak=0.6)
