// xmb_veil.shader: black over the menu, `fade` of it - nought, nothing over
// it, to one, all of it black: what the game starts in, what the menu comes
// in from, and what it goes out to when a test is opened.

uniform Look : 1 {
    float fade = 1.0;
}

fragment {
    target = vec4(0.0, 0.0, 0.0, fade) * COLOR;
}
