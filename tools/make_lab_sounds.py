#!/usr/bin/env python3
"""make_lab_sounds.py: the sounds of the sound test, made the same each time
from a fixed seed - sfx/lab_music.wav, eight seconds of chords and a bass
that loop; sfx/lab_wind.wav, wind to loop under it; sfx/lab_pluck.wav, a
plucked string the test plays at every pitch; sfx/lab_hum.wav, the hum of
the bee that flies round the listener. Run from the project's folder."""
import wave
import numpy as np

RATE = 44100
rng = np.random.default_rng(11)


def save(name, samples):
    samples = np.clip(samples, -1.0, 1.0)
    with wave.open(f"sfx/{name}.wav", "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((samples * 32000).astype("<i2").tobytes())


def note(freq, seconds, shape="saw"):
    t = np.arange(int(seconds * RATE)) / RATE
    if shape == "sine":
        return np.sin(2 * np.pi * freq * t)
    out = np.zeros_like(t)
    for k in range(1, 9):
        out += np.sin(2 * np.pi * freq * k * t) / k * (0.85 ** k)
    return out


def envelope(n, attack, release):
    e = np.ones(n)
    a, r = int(attack * RATE), int(release * RATE)
    e[:a] = np.linspace(0, 1, a)
    e[n - r:] *= np.linspace(1, 0, r)
    return e


def music():
    """C, A minor, F and G, two seconds each: soft chords, a walking bass."""
    chords = [[261.63, 329.63, 392.0], [220.0, 261.63, 329.63], [174.61, 220.0, 261.63], [196.0, 246.94, 293.66]]
    bass = [[65.41, 98.0], [55.0, 82.41], [43.65, 65.41], [49.0, 73.42]]
    out = np.zeros(8 * RATE)
    for i, chord in enumerate(chords):
        at = i * 2 * RATE
        pad = sum(note(f, 2.0) for f in chord) * 0.07
        pad *= envelope(len(pad), 0.25, 0.4)
        out[at:at + len(pad)] += pad
        for j, f in enumerate(bass[i] * 2):
            b = note(f, 0.5, "sine") * 0.35 * envelope(int(0.5 * RATE), 0.01, 0.3)
            s = at + j * RATE // 2
            out[s:s + len(b)] += b
    # A soft tick on each beat, so a seek is heard.
    for beat in range(16):
        s = beat * RATE // 2
        tick = rng.standard_normal(800) * np.exp(-np.arange(800) / 120) * 0.12
        out[s:s + 800] += tick
    return out


def wind():
    noise = rng.standard_normal(6 * RATE)
    # Low-passed noise, its loudness slowly swelling, the ends crossfaded.
    smooth = np.convolve(noise, np.ones(60) / 60, mode="same")
    t = np.arange(len(smooth)) / RATE
    swell = 0.6 + 0.4 * np.sin(2 * np.pi * t / 6.0)
    out = smooth * swell * 1.6
    fade = RATE // 2
    out[:fade] = out[:fade] * np.linspace(0, 1, fade) + out[-fade:] * np.linspace(1, 0, fade)
    return out[:-fade]


def pluck():
    """Karplus-Strong at C5: a string, plucked."""
    freq = 523.25
    period = int(RATE / freq)
    buf = rng.uniform(-1, 1, period)
    out = np.zeros(int(1.2 * RATE))
    for i in range(len(out)):
        out[i] = buf[i % period]
        buf[i % period] = 0.996 * 0.5 * (buf[i % period] + buf[(i + 1) % period])
    return out * 0.8


def hum():
    t = np.arange(2 * RATE) / RATE
    wobble = 1 + 0.02 * np.sin(2 * np.pi * 7 * t)
    phase = np.cumsum(2 * np.pi * 180 * wobble / RATE)
    out = (np.sin(phase) + 0.5 * np.sin(2 * phase) + 0.25 * np.sin(3 * phase)) * 0.25
    return out


save("lab_music", music())
save("lab_wind", wind())
save("lab_pluck", pluck())
save("lab_hum", hum())
print("sfx/lab_music.wav, sfx/lab_wind.wav, sfx/lab_pluck.wav, sfx/lab_hum.wav")
