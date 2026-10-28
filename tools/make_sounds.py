#!/usr/bin/env python3
"""make_sounds.py <sfx folder>: the menu's sounds, made from nothing - the
intro's orchestra warming up, a tick to move, a lower one with a breath of air to change
category, a two-note chime to choose, a swell when the menu opens and a quiet
drone under it, looped without a seam. 44.1 kHz, 16-bit, mono."""
import sys, wave
import numpy as np
from scipy.signal import butter, sosfilt

RATE = 44100


def seconds(s):
    return np.arange(int(RATE * s)) / RATE


def envelope(t, attack, decay):
    return np.minimum(t / attack, 1.0) * np.exp(-np.maximum(t - attack, 0) / decay)


def bell(freq, t, decay):
    # A struck bar: a few partials, the high ones dying first.
    out = np.zeros_like(t)
    for ratio, gain, fade in ((1.0, 1.0, 1.0), (2.756, 0.35, 0.45), (5.404, 0.12, 0.25)):
        out += gain * np.sin(2 * np.pi * freq * ratio * t) * envelope(t, 0.003, decay * fade)
    return out


def room(x, mix=0.25):
    # A small room: four combs and an allpass, Schroeder's, done in blocks.
    out = np.zeros(len(x) + RATE)
    src = np.concatenate([x, np.zeros(RATE)])
    for delay_ms, feedback in ((29.7, 0.72), (37.1, 0.7), (41.1, 0.68), (43.7, 0.66)):
        d = int(RATE * delay_ms / 1000)
        y = src.copy()
        for start in range(d, len(y), d):
            end = min(start + d, len(y))
            y[start:end] += feedback * y[start - d:end - d]
        out += y / 4
    d = int(RATE * 0.005)
    ap = np.zeros_like(out)
    for i in range(len(out)):
        delayed = ap[i - d] if i >= d else 0.0
        ap[i] = -0.6 * out[i] + (out[i - d] if i >= d else 0.0) + 0.6 * delayed
    wet = ap
    dry = src
    mixed = dry * (1 - mix) + wet * mix
    # Trim the tail where it has died away.
    level = np.abs(mixed)
    last = np.nonzero(level > 1e-4)[0]
    return mixed[: (last[-1] + 1) if len(last) else len(x)]


def lowpass(x, cutoff, order=2):
    return sosfilt(butter(order, cutoff, fs=RATE, output="sos"), x)


def bandpass(x, lo, hi):
    return sosfilt(butter(2, [lo, hi], btype="band", fs=RATE, output="sos"), x)


def normalised(x, peak_db):
    return x / np.max(np.abs(x)) * 10 ** (peak_db / 20)


def fade_ends(x, ms=4):
    n = int(RATE * ms / 1000)
    x = x.copy()
    x[:n] *= np.linspace(0, 1, n)
    x[-n:] *= np.linspace(1, 0, n)
    return x


def save(path, x):
    data = np.clip(x, -1, 1)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((data * 32767).astype("<i2").tobytes())


def move():
    t = seconds(0.07)
    tone = np.sin(2 * np.pi * 1480 * t) + 0.3 * np.sin(2 * np.pi * 2960 * t)
    click = lowpass(np.random.default_rng(1).normal(size=len(t)), 6000) * envelope(t, 0.0005, 0.003)
    return fade_ends(normalised(tone * envelope(t, 0.002, 0.014) + 0.4 * click, -14))


def category():
    t = seconds(0.16)
    tone = np.sin(2 * np.pi * 990 * t) + 0.25 * np.sin(2 * np.pi * 1980 * t)
    air = bandpass(np.random.default_rng(2).normal(size=len(t)), 1800, 5200)
    air *= np.sin(np.pi * np.clip(t / 0.16, 0, 1)) ** 2
    return fade_ends(normalised(tone * envelope(t, 0.002, 0.02) + 0.12 * air, -13))


def confirm():
    t = seconds(0.9)
    first = bell(880.0, t, 0.35)
    second = np.zeros_like(t)
    lag = int(RATE * 0.085)
    second[lag:] = bell(1318.5, t[: len(t) - lag], 0.5)[: len(t) - lag]
    return fade_ends(normalised(room(0.8 * first + second, 0.3), -9))


def opening():
    t = seconds(2.6)
    out = np.zeros_like(t)
    # A major chord, each note two voices a little apart, made of a few
    # harmonics - a soft pad - rising in and falling away.
    for f in (220.0, 329.63, 440.0, 554.37, 659.25):
        for detune in (-0.7, 0.7):
            for h, g in ((1, 1.0), (2, 0.35), (3, 0.15), (4, 0.07)):
                out += g / h * np.sin(2 * np.pi * (f + detune) * h * t + h * f)
    shape = np.minimum(t / 0.9, 1.0) ** 2 * np.clip((2.6 - t) / 1.6, 0, 1) ** 1.5
    shimmer = 0.06 * np.sin(2 * np.pi * 1760 * t) * np.exp(-((t - 0.9) / 0.4) ** 2)
    pad = lowpass(out * shape, 2400) + shimmer
    return fade_ends(normalised(room(pad, 0.35), -11))


def boot():
    # The intro: an orchestra warming up - strings and reeds each trying a
    # note of their own, sliding and wavering, more of them and louder, until
    # they find one chord together, which swells and falls away.
    length = 8.0
    t = seconds(length)
    rng = np.random.default_rng(11)
    out = np.zeros_like(t)
    notes = (110.0, 146.83, 164.81, 220.0, 277.18, 329.63, 440.0, 554.37, 659.25, 880.0)
    chord_at = 3.6
    for voice in range(26):
        reed = voice % 3 == 0
        start = rng.uniform(0.0, 2.6)
        wander = rng.choice(notes) * rng.uniform(0.97, 1.03)
        home = notes[voice % len(notes)]
        # Its pitch: where it wanders, sliding to its note of the chord.
        slide = np.clip((t - chord_at + rng.uniform(0.0, 0.6)) / 0.5, 0, 1)
        pitch = wander + (home - wander) * slide * slide * (3 - 2 * slide)
        vibrato = 1 + 0.004 * np.sin(2 * np.pi * rng.uniform(4.5, 6.0) * t + voice)
        phase = 2 * np.pi * np.cumsum(pitch * vibrato) / RATE
        if reed:
            tone = np.sin(phase) + 0.3 * np.sin(3 * phase) + 0.12 * np.sin(5 * phase)
        else:
            tone = sum(np.sin(h * phase) / h for h in range(1, 7))
        # It comes in, plays a little, and grows into the chord.
        come = np.clip((t - start) / rng.uniform(0.3, 0.9), 0, 1)
        murmur = 0.35 + 0.25 * np.sin(2 * np.pi * rng.uniform(0.3, 0.8) * t + voice) ** 2
        swell = np.clip((t - chord_at) / 1.4, 0, 1)
        fall = np.clip((length - 0.2 - t) / 2.4, 0, 1)
        level = come * (murmur * (1 - swell) + swell) * fall
        out += tone * level * (0.6 if reed else 1.0) / (1 + voice % 4)
    breath = bandpass(rng.normal(size=len(t)), 400, 2500) * 0.04 * np.clip(t / 1.5, 0, 1) * np.clip((chord_at + 1.5 - t) / 2, 0, 1)
    body = lowpass(out, 3200) + breath
    return fade_ends(normalised(room(body, 0.4), -5), 40)


def ambient():
    # Twelve seconds that loop without a seam: every frequency and every
    # slow change of loudness goes round a whole number of times in them.
    length = 12.0
    t = seconds(length)
    out = np.zeros_like(t)
    for f, g in ((110.0, 1.0), (164.75, 0.6), (220.0, 0.5), (277.25, 0.25), (329.5, 0.2)):
        f = round(f * length) / length
        swell = 0.6 + 0.4 * np.sin(2 * np.pi * t / length * (1 + int(f) % 3) + f)
        out += g * swell * (np.sin(2 * np.pi * f * t) + 0.2 * np.sin(2 * np.pi * 2 * f * t))
    # Filtered twice round and the second kept, so the filter has no start.
    twice = lowpass(np.concatenate([out, out]), 1200, 1)[len(out):]
    return normalised(twice, -20)


if __name__ == "__main__":
    folder = sys.argv[1]
    for name, make in (("xmb_boot", boot), ("xmb_move", move), ("xmb_category", category), ("xmb_confirm", confirm), ("xmb_open", opening), ("xmb_ambient", ambient)):
        sound = make()
        save(f"{folder}/{name}.wav", sound)
        print(name, f"{len(sound) / RATE:.2f} s")
