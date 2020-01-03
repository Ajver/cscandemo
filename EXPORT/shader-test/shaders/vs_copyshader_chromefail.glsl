#version 300 es
#define LINEAR_TO_SRGB
#define DISABLE_ALPHA
precision highp float;
precision highp int;
precision highp sampler2D;
precision highp samplerCube;
precision highp sampler2DArray;


layout(location=0) in highp vec4 vertex_attrib;
#if defined(USE_CUBEMAP) || defined(USE_PANORAMA)
layout(location=4) in vec3 cube_in;
#else
layout(location=4) in vec2 uv_in;
#endif
layout(location=5) in vec2 uv2_in;

#if defined(USE_CUBEMAP) || defined(USE_PANORAMA)
out vec3 cube_interp;
#else
out vec2 uv_interp;
#endif

out vec2 uv2_interp;

#ifdef USE_COPY_SECTION

uniform vec4 copy_section;

#endif

void main() {

#if defined(USE_CUBEMAP) || defined(USE_PANORAMA)
	cube_interp = cube_in;
#elif defined(USE_ASYM_PANO)
	uv_interp = vertex_attrib.xy;
#else
	uv_interp = uv_in;
#ifdef V_FLIP
	uv_interp.y = 1.0-uv_interp.y;
#endif

#endif
	uv2_interp = uv2_in;
	gl_Position = vertex_attrib;

#ifdef USE_COPY_SECTION

	uv_interp = copy_section.xy + uv_interp * copy_section.zw;
	gl_Position.xy = (copy_section.xy + (gl_Position.xy * 0.5 + 0.5) * copy_section.zw) * 2.0 - 1.0;
#endif

}
