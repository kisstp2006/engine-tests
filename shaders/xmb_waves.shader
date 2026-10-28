// xmb_waves.shader: the menu's sky. A gradient from `top` to `bottom`, a
// soft light over it, three ribbons of light rolling slowly across it - each
// a translucent sheet between two waves, bright where its edges catch the
// light - and points that twinkle as they drift. `flash` lights it all for a
// moment when something is chosen.

uniform Look : 1 {
    vec4 top = vec4(0.05, 0.14, 0.42, 1.0);
    vec4 bottom = vec4(0.01, 0.03, 0.13, 1.0);
    vec4 ribbon = vec4(0.78, 0.9, 1.0, 1.0);
    // How fast the ribbons roll.
    float speed = 1.0;
    // Nought to one: a flash of light over everything.
    float flash = 0.0;
}

// A number from nought to one for each cell.
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Where ribbon `k`'s edge is across the screen at `x`.
float wave(float x, float t, float k) {
    return 0.6 + 0.07 * sin(x * 3.1 + t * 0.35 + k * 1.7) + 0.035 * sin(x * 7.3 - t * 0.6 + k * 2.9) - 0.035 * k;
}

// Ribbon `k`'s light at `uv`: a faint sheet between its two edges, a thin
// line along each, and a soft glow round the upper one.
float sheet(vec2 uv, float t, float k) {
    float a = wave(uv.x, t, k);
    float b = wave(uv.x + 0.13, t * 1.1, k + 0.5) + 0.05 + 0.03 * sin(uv.x * 2.0 + t * 0.2 + k);
    float lo = min(a, b);
    float hi = max(a, b);
    float inside = smoothstep(lo - 0.003, lo + 0.003, uv.y) * (1.0 - smoothstep(hi - 0.003, hi + 0.003, uv.y));
    float edges = exp(-abs(uv.y - a) * 240.0) + 0.55 * exp(-abs(uv.y - b) * 240.0);
    float glow = exp(-abs(uv.y - a) * 26.0) * 0.22;
    return inside * 0.06 + edges * 0.5 + glow;
}

fragment {
    vec2 uv = VIEW_UV;
    float t = TIME * speed;
    vec3 sky = mix(top.rgb, bottom.rgb, uv.y);
    // A soft light toward the upper left, where the menu is.
    float light = exp(-pow((uv.x - 0.3) * 1.6, 2.0) - pow((uv.y - 0.32) * 2.2, 2.0));
    sky = sky * (0.7 + 0.6 * light);

    float ribbons = sheet(uv, t, 0.0) + 0.75 * sheet(uv, t * 0.8, 1.0) + 0.5 * sheet(uv, t * 1.2, 2.0);

    // Points of light, one in a few cells, drifting and twinkling; more of
    // them down where the ribbons are.
    vec2 grid = vec2(48.0, 27.0);
    vec2 at = (uv + vec2(t * 0.004, 0.0)) * grid;
    float h = hash(floor(at));
    vec2 f = fract(at) - vec2(0.5);
    float twinkle = 0.5 + 0.5 * sin(t * 1.7 + h * 40.0);
    float sparks = step(0.955, h) * exp(-dot(f, f) * 70.0) * twinkle * (0.35 + 0.65 * smoothstep(0.35, 0.7, uv.y));

    vec3 color = sky + ribbon.rgb * ribbons + vec3(0.8, 0.9, 1.0) * sparks * 0.55;
    color = color + vec3(flash) * 0.6;
    // Darker toward the corners.
    vec2 off = uv - vec2(0.5);
    color = color * (1.0 - 0.4 * dot(off, off) * 1.6);
    target = vec4(color, 1.0) * COLOR;
}
