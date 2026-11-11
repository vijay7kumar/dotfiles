#version 300 es
// Mono: greyscale focus mode
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float luma = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    fragColor = vec4(vec3(luma), c.a);
}
