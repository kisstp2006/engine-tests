// xmb_glow.shader: the soft light behind the chosen row - brightest toward
// its left, fading out to the right and to its top and bottom, breathing
// slowly.

uniform Look : 1 {
    vec4 tint = vec4(0.75, 0.88, 1.0, 1.0);
    float strength = 0.22;
}

fragment {
    // Each falls to nothing before the sprite's edge, so no edge shows.
    float across = exp(-pow((UV.x - 0.3) * 3.2, 2.0)) * smoothstep(0.0, 0.18, UV.x) * smoothstep(1.0, 0.7, UV.x);
    float down = exp(-pow((UV.y - 0.5) * 4.0, 2.0)) * smoothstep(0.0, 0.25, UV.y) * smoothstep(1.0, 0.75, UV.y);
    float breath = 0.85 + 0.15 * sin(TIME * 2.6);
    target = vec4(tint.rgb, across * down * strength * breath) * COLOR;
}
