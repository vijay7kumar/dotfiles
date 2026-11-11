#version 300 es
// Vibrance: richer colours without blowing out already-saturated ones
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float STRENGTH = 0.35;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    float sat = mx - mn;
    float luma = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 boosted = mix(vec3(luma), c.rgb, 1.0 + STRENGTH * (1.0 - sat));
    fragColor = vec4(clamp(boosted, 0.0, 1.0), c.a);
}
