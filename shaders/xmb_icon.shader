// xmb_icon.shader: a category's mark, drawn as a line of light with a glow
// round it - a triangle, a circle, a cross, a square or a diamond, by `kind` - brighter
// and fuller the more `lit` it is.

uniform Look : 1 {
    // 0 a triangle, 1 a circle, 2 a cross, 3 a square, 4 a diamond.
    float kind = 0.0;
    vec4 tint = vec4(1.0, 1.0, 1.0, 1.0);
    // Nought, a category passed over, to one, the one chosen.
    float lit = 1.0;
}

// How far `p` is from the edge of a triangle of size `r`, pointing up:
// below nought inside it.
float outline_triangle(vec2 p, float r) {
    float k = 1.7320508;
    vec2 q = vec2(abs(p.x) - r, p.y + r / k);
    if (q.x + k * q.y > 0.0) {
        q = vec2(q.x - k * q.y, -k * q.x - q.y) * 0.5;
    }
    q.x = q.x - clamp(q.x, -2.0 * r, 0.0);
    return -length(q) * sign(q.y);
}

// How far `p` is from the line of the mark.
float mark(vec2 p, float kind) {
    if (kind < 0.5) {
        return abs(outline_triangle(p - vec2(0.0, 0.04), 0.3));
    }
    if (kind < 1.5) {
        return abs(length(p) - 0.3);
    }
    if (kind < 2.5) {
        float d = min(abs(p.x - p.y), abs(p.x + p.y)) * 0.7071068;
        return max(d, max(abs(p.x), abs(p.y)) - 0.25);
    }
    if (kind < 3.5) {
        return abs(max(abs(p.x), abs(p.y)) - 0.25);
    }
    return abs(abs(p.x) + abs(p.y) - 0.33) * 0.7071068;
}

fragment {
    // Up is up: the picture's rows run down.
    vec2 p = vec2(UV.x - 0.5, 0.5 - UV.y);
    float d = mark(p, kind);
    float stroke = 1.0 - smoothstep(0.022, 0.04, d);
    float glow = exp(-d * 14.0) * (0.25 + 0.55 * lit);
    // The glow falls to nothing before the sprite's edge.
    glow = glow * (1.0 - smoothstep(0.36, 0.5, max(abs(p.x), abs(p.y))));
    float shown = clamp(stroke + glow, 0.0, 1.0) * (0.35 + 0.65 * lit);
    vec3 color = mix(tint.rgb, vec3(1.0), stroke * 0.6);
    target = vec4(color, shown) * COLOR;
}
