#version 300 es

uniform lowp vec4 prova_uniform;

in highp vec3 vertex_interp;
in lowp vec3 normal_interp;
in lowp vec2 uv_interp;

layout(location = 0) out lowp vec4 out_color;

void main() {
    out_color = vec4(vertex_interp.x * normal_interp.x * uv_interp.x * prova_uniform.x, 0.0, 0.0, 1.0);
}