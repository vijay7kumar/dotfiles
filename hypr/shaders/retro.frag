#version 300 es
// Retro: light scanlines + vignette (static, so it costs nothing while idle)
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float line = 0.92 + 0.08 * sin(v_texcoord.y * 1080.0 * 3.14159);
    vec2 d = v_texcoord - 0.5;
    float vignette = 1.0 - dot(d, d) * 0.55;
    fragColor = vec4(c.rgb * line * vignette, c.a);
}
