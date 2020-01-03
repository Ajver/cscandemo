#version 300 es
#define MAX_LIGHT_DATA_STRUCTS 409
#define MAX_FORWARD_LIGHTS 8
#define MAX_REFLECTION_DATA_STRUCTS 455
#define MAX_SKELETON_BONES 1365
#define USE_FORWARD_LIGHTING
#define USE_RADIANCE_MAP
#define USE_RADIANCE_MAP_ARRAY
#define USE_MULTIPLE_RENDER_TARGETS
#define USE_CONTACT_SHADOWS
#define SHADOW_MODE_PCF_5
#define SPECULAR_DISABLED
#define ENABLE_UV_INTERP
precision highp float;
precision highp int;
precision highp sampler2D;
precision highp samplerCube;
precision highp sampler2DArray;

#define M_PI 3.14159265359

/*
from VisualServer:

ARRAY_VERTEX=0,
ARRAY_NORMAL=1,
ARRAY_TANGENT=2,
ARRAY_COLOR=3,
ARRAY_TEX_UV=4,
ARRAY_TEX_UV2=5,
ARRAY_BONES=6,
ARRAY_WEIGHTS=7,
ARRAY_INDEX=8,
*/

//hack to use uv if no uv present so it works with lightmap


/* INPUT ATTRIBS */

layout(location=0) in highp vec4 vertex_attrib;
layout(location=1) in vec3 normal_attrib;
#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)
layout(location=2) in vec4 tangent_attrib;
#endif

#if defined(ENABLE_COLOR_INTERP)
layout(location=3) in vec4 color_attrib;
#endif

#if defined(ENABLE_UV_INTERP)
layout(location=4) in vec2 uv_attrib;
#endif

#if defined(ENABLE_UV2_INTERP) || defined(USE_LIGHTMAP)
layout(location=5) in vec2 uv2_attrib;
#endif

uniform float normal_mult;

#ifdef USE_SKELETON
layout(location=6) in uvec4 bone_indices; // attrib:6
layout(location=7) in vec4 bone_weights; // attrib:7
#endif

#ifdef USE_INSTANCING

layout(location=8) in highp vec4 instance_xform0;
layout(location=9) in highp vec4 instance_xform1;
layout(location=10) in highp vec4 instance_xform2;
layout(location=11) in lowp vec4 instance_color;

#if defined(ENABLE_INSTANCE_CUSTOM)
layout(location=12) in highp vec4 instance_custom_data;
#endif

#endif

layout(std140) uniform SceneData { //ubo:0

	highp mat4 projection_matrix;
	highp mat4 inv_projection_matrix;
	highp mat4 camera_inverse_matrix;
	highp mat4 camera_matrix;

	mediump vec4 ambient_light_color;
	mediump vec4 bg_color;

	mediump vec4 fog_color_enabled;
	mediump vec4 fog_sun_color_amount;

	mediump float ambient_energy;
	mediump float bg_energy;

	mediump float z_offset;
	mediump float z_slope_scale;
	highp float shadow_dual_paraboloid_render_zfar;
	highp float shadow_dual_paraboloid_render_side;

	highp vec2 viewport_size;
	highp vec2 screen_pixel_size;
	highp vec2 shadow_atlas_pixel_size;
	highp vec2 directional_shadow_pixel_size;

	highp float time;
	highp float z_far;
	mediump float reflection_multiplier;
	mediump float subsurface_scatter_width;
	mediump float ambient_occlusion_affect_light;
	mediump float ambient_occlusion_affect_ao_channel;
	mediump float opaque_prepass_threshold;

	bool fog_depth_enabled;
	highp float fog_depth_begin;
	highp float fog_depth_curve;
	bool fog_transmit_enabled;
	highp float fog_transmit_curve;
	bool fog_height_enabled;
	highp float fog_height_min;
	highp float fog_height_max;
	highp float fog_height_curve;

};

uniform highp mat4 world_transform;


#ifdef USE_LIGHT_DIRECTIONAL

layout(std140) uniform DirectionalLightData { //ubo:3

	highp vec4 light_pos_inv_radius;
	mediump vec4 light_direction_attenuation;
	mediump vec4 light_color_energy;
	mediump vec4 light_params; //cone attenuation, angle, specular, shadow enabled,
	mediump vec4 light_clamp;
	mediump vec4 shadow_color_contact;
	highp mat4 shadow_matrix1;
	highp mat4 shadow_matrix2;
	highp mat4 shadow_matrix3;
	highp mat4 shadow_matrix4;
	mediump vec4 shadow_split_offsets;
};

#endif

#ifdef USE_VERTEX_LIGHTING
//omni and spot

struct LightData {

	highp vec4 light_pos_inv_radius;
	mediump vec4 light_direction_attenuation;
	mediump vec4 light_color_energy;
	mediump vec4 light_params; //cone attenuation, angle, specular, shadow enabled,
	mediump vec4 light_clamp;
	mediump vec4 shadow_color_contact;
	highp mat4 shadow_matrix;

};


layout(std140) uniform OmniLightData { //ubo:4

	LightData omni_lights[MAX_LIGHT_DATA_STRUCTS];
};

layout(std140) uniform SpotLightData { //ubo:5

	LightData spot_lights[MAX_LIGHT_DATA_STRUCTS];
};

#ifdef USE_FORWARD_LIGHTING


uniform int omni_light_indices[MAX_FORWARD_LIGHTS];
uniform int omni_light_count;

uniform int spot_light_indices[MAX_FORWARD_LIGHTS];
uniform int spot_light_count;

#endif

out vec4 diffuse_light_interp;
out vec4 specular_light_interp;

void light_compute(vec3 N, vec3 L,vec3 V, vec3 light_color, float roughness, inout vec3 diffuse, inout vec3 specular) {

	float dotNL = max(dot(N,L), 0.0 );
	diffuse += dotNL * light_color / M_PI;

	if (roughness > 0.0) {

		vec3 H = normalize(V + L);
		float dotNH = max(dot(N,H), 0.0 );
		float intensity = (roughness >= 1.0 ? 1.0 : pow( dotNH, (1.0-roughness) * 256.0));
		specular += light_color * intensity;

	}
}

void light_process_omni(int idx, vec3 vertex, vec3 eye_vec,vec3 normal, float roughness,inout vec3 diffuse, inout vec3 specular) {

	vec3 light_rel_vec = omni_lights[idx].light_pos_inv_radius.xyz-vertex;
	float light_length = length( light_rel_vec );
	float normalized_distance = light_length*omni_lights[idx].light_pos_inv_radius.w;
	vec3 light_attenuation = vec3(pow( max(1.0 - normalized_distance, 0.0), omni_lights[idx].light_direction_attenuation.w ));

	light_compute(normal,normalize(light_rel_vec),eye_vec,omni_lights[idx].light_color_energy.rgb * light_attenuation,roughness,diffuse,specular);

}

void light_process_spot(int idx, vec3 vertex, vec3 eye_vec, vec3 normal, float roughness, inout vec3 diffuse, inout vec3 specular) {

	vec3 light_rel_vec = spot_lights[idx].light_pos_inv_radius.xyz-vertex;
	float light_length = length( light_rel_vec );
	float normalized_distance = light_length*spot_lights[idx].light_pos_inv_radius.w;
	vec3 light_attenuation = vec3(pow( max(1.0 - normalized_distance, 0.001), spot_lights[idx].light_direction_attenuation.w ));
	vec3 spot_dir = spot_lights[idx].light_direction_attenuation.xyz;
	float spot_cutoff=spot_lights[idx].light_params.y;
	float scos = max(dot(-normalize(light_rel_vec), spot_dir),spot_cutoff);
	float spot_rim = (1.0 - scos) / (1.0 - spot_cutoff);
	light_attenuation *= 1.0 - pow( max(spot_rim,0.001), spot_lights[idx].light_params.x);


	light_compute(normal,normalize(light_rel_vec),eye_vec,spot_lights[idx].light_color_energy.rgb*light_attenuation,roughness,diffuse,specular);
}


#endif

/* Varyings */

out highp vec3 vertex_interp;
out vec3 normal_interp;

#if defined(ENABLE_COLOR_INTERP)
out vec4 color_interp;
#endif

#if defined(ENABLE_UV_INTERP)
out vec2 uv_interp;
#endif

#if defined(ENABLE_UV2_INTERP) || defined (USE_LIGHTMAP)
out vec2 uv2_interp;
#endif


#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)
out vec3 tangent_interp;
out vec3 binormal_interp;
#endif


#if defined(USE_MATERIAL)

layout(std140) uniform UniformData { //ubo:1


};

#endif
uniform sampler2D m_base_tex;


#ifdef RENDER_DEPTH_DUAL_PARABOLOID

out highp float dp_clip;

#endif

#define SKELETON_TEXTURE_WIDTH 256

#ifdef USE_SKELETON
uniform highp sampler2D skeleton_texture; //texunit:-1
#endif

out highp vec4 position_interp;

// FIXME: This triggers a Mesa bug that breaks rendering, so disabled for now.
// See GH-13450 and https://bugs.freedesktop.org/show_bug.cgi?id=100316
//invariant gl_Position;

void main() {

	highp vec4 vertex = vertex_attrib; // vec4(vertex_attrib.xyz * data_attrib.x,1.0);

	mat4 world_matrix = world_transform;


#ifdef USE_INSTANCING

	{
		highp mat4 m=mat4(instance_xform0,instance_xform1,instance_xform2,vec4(0.0,0.0,0.0,1.0));
		world_matrix = world_matrix * transpose(m);
	}
#endif

	vec3 normal = normal_attrib * normal_mult;


#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)
	vec3 tangent = tangent_attrib.xyz;
	tangent*=normal_mult;
	float binormalf = tangent_attrib.a;
#endif

#if defined(ENABLE_COLOR_INTERP)
	color_interp = color_attrib;
#if defined(USE_INSTANCING)
	color_interp *= instance_color;
#endif

#endif


#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)

	vec3 binormal = normalize( cross(normal,tangent) * binormalf );
#endif

#if defined(ENABLE_UV_INTERP)
	uv_interp = uv_attrib;
#endif

#if defined(ENABLE_UV2_INTERP) || defined(USE_LIGHTMAP)
	uv2_interp = uv2_attrib;
#endif

#if defined(USE_INSTANCING) && defined(ENABLE_INSTANCE_CUSTOM)
	vec4 instance_custom = instance_custom_data;
#else
	vec4 instance_custom = vec4(0.0);
#endif

	highp mat4 local_projection = projection_matrix;

//using world coordinates
#if !defined(SKIP_TRANSFORM_USED) && defined(VERTEX_WORLD_COORDS_USED)

	vertex = world_matrix * vertex;

#if defined(ENSURE_CORRECT_NORMALS)
	mat3 normal_matrix = mat3(transpose(inverse(world_matrix)));
	normal = normal_matrix * normal;
#else
	normal = normalize((world_matrix * vec4(normal,0.0)).xyz);
#endif

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)

	tangent = normalize((world_matrix * vec4(tangent,0.0)).xyz);
	binormal = normalize((world_matrix * vec4(binormal,0.0)).xyz);
#endif
#endif

	float roughness=0.0;

//defines that make writing custom shaders easier
#define projection_matrix local_projection
#define world_transform world_matrix


#ifdef USE_SKELETON
	{
		//skeleton transform
		ivec4 bone_indicesi = ivec4(bone_indices); // cast to signed int

		ivec2 tex_ofs = ivec2( bone_indicesi.x%256, (bone_indicesi.x/256)*3 );
		highp mat3x4 m = mat3x4(
			texelFetch(skeleton_texture,tex_ofs,0),
			texelFetch(skeleton_texture,tex_ofs+ivec2(0,1),0),
			texelFetch(skeleton_texture,tex_ofs+ivec2(0,2),0)
		) * bone_weights.x;

		tex_ofs = ivec2( bone_indicesi.y%256, (bone_indicesi.y/256)*3 );

		m+= mat3x4(
					texelFetch(skeleton_texture,tex_ofs,0),
					texelFetch(skeleton_texture,tex_ofs+ivec2(0,1),0),
					texelFetch(skeleton_texture,tex_ofs+ivec2(0,2),0)
				) * bone_weights.y;

		tex_ofs = ivec2( bone_indicesi.z%256, (bone_indicesi.z/256)*3 );

		m+= mat3x4(
					texelFetch(skeleton_texture,tex_ofs,0),
					texelFetch(skeleton_texture,tex_ofs+ivec2(0,1),0),
					texelFetch(skeleton_texture,tex_ofs+ivec2(0,2),0)
				) * bone_weights.z;


		tex_ofs = ivec2( bone_indicesi.w%256, (bone_indicesi.w/256)*3 );

		m+= mat3x4(
					texelFetch(skeleton_texture,tex_ofs,0),
					texelFetch(skeleton_texture,tex_ofs+ivec2(0,1),0),
					texelFetch(skeleton_texture,tex_ofs+ivec2(0,2),0)
				) * bone_weights.w;

		mat4 bone_matrix = transpose(mat4(m[0],m[1],m[2],vec4(0.0,0.0,0.0,1.0)));

		world_matrix = bone_matrix * world_matrix;
	}
#endif

	mat4 modelview = camera_inverse_matrix * world_matrix;
{
	{
	}


}



//using local coordinates (default)
#if !defined(SKIP_TRANSFORM_USED) && !defined(VERTEX_WORLD_COORDS_USED)

	vertex = modelview * vertex;

#if defined(ENSURE_CORRECT_NORMALS)
	mat3 normal_matrix = mat3(transpose(inverse(modelview)));
	normal = normal_matrix * normal;
#else
	normal = normalize((modelview * vec4(normal,0.0)).xyz);
#endif

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)

	tangent = normalize((modelview * vec4(tangent,0.0)).xyz);
	binormal = normalize((modelview * vec4(binormal,0.0)).xyz);
#endif
#endif

//using world coordinates
#if !defined(SKIP_TRANSFORM_USED) && defined(VERTEX_WORLD_COORDS_USED)

	vertex = camera_inverse_matrix * vertex;
	normal = normalize((camera_inverse_matrix * vec4(normal,0.0)).xyz);

#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)

	tangent = normalize((camera_inverse_matrix * vec4(tangent,0.0)).xyz);
	binormal = normalize((camera_inverse_matrix * vec4(binormal,0.0)).xyz);
#endif
#endif

	vertex_interp = vertex.xyz;
	normal_interp = normal;


#if defined(ENABLE_TANGENT_INTERP) || defined(ENABLE_NORMALMAP) || defined(LIGHT_USE_ANISOTROPY)
	tangent_interp = tangent;
	binormal_interp = binormal;
#endif


#ifdef RENDER_DEPTH


#ifdef RENDER_DEPTH_DUAL_PARABOLOID

	vertex_interp.z*= shadow_dual_paraboloid_render_side;
	normal_interp.z*= shadow_dual_paraboloid_render_side;

	dp_clip=vertex_interp.z; //this attempts to avoid noise caused by objects sent to the other parabolloid side due to bias

	//for dual paraboloid shadow mapping, this is the fastest but least correct way, as it curves straight edges

	highp vec3 vtx = vertex_interp+normalize(vertex_interp)*z_offset;
	highp float distance = length(vtx);
	vtx = normalize(vtx);
	vtx.xy/=1.0-vtx.z;
	vtx.z=(distance/shadow_dual_paraboloid_render_zfar);
	vtx.z=vtx.z * 2.0 - 1.0;

	vertex_interp = vtx;


#else

	float z_ofs = z_offset;
	z_ofs += (1.0-abs(normal_interp.z))*z_slope_scale;
	vertex_interp.z-=z_ofs;

#endif //RENDER_DEPTH_DUAL_PARABOLOID

#endif //RENDER_DEPTH

	gl_Position = projection_matrix * vec4(vertex_interp,1.0);

	position_interp=gl_Position;

#ifdef USE_VERTEX_LIGHTING

	diffuse_light_interp=vec4(0.0);
	specular_light_interp=vec4(0.0);

#ifdef USE_FORWARD_LIGHTING

	for(int i=0;i<omni_light_count;i++) {
		light_process_omni(omni_light_indices[i],vertex_interp,-normalize( vertex_interp ),normal_interp,roughness,diffuse_light_interp.rgb,specular_light_interp.rgb);
	}

	for(int i=0;i<spot_light_count;i++) {
		light_process_spot(spot_light_indices[i],vertex_interp,-normalize( vertex_interp ),normal_interp,roughness,diffuse_light_interp.rgb,specular_light_interp.rgb);
	}
#endif

#ifdef USE_LIGHT_DIRECTIONAL

	vec3 directional_diffuse = vec3(0.0);
	vec3 directional_specular = vec3(0.0);
	light_compute(normal_interp,-light_direction_attenuation.xyz,-normalize( vertex_interp ),light_color_energy.rgb,roughness,directional_diffuse,directional_specular);

	float diff_avg = dot(diffuse_light_interp.rgb,vec3(0.33333));
	float diff_dir_avg = dot(directional_diffuse,vec3(0.33333));
	if (diff_avg>0.0) {
		diffuse_light_interp.a=diff_dir_avg/(diff_avg+diff_dir_avg);
	} else {
		diffuse_light_interp.a=1.0;
	}

	diffuse_light_interp.rgb+=directional_diffuse;

	float spec_avg = dot(specular_light_interp.rgb,vec3(0.33333));
	float spec_dir_avg = dot(directional_specular,vec3(0.33333));
	if (spec_avg>0.0) {
		specular_light_interp.a=spec_dir_avg/(spec_avg+spec_dir_avg);
	} else {
		specular_light_interp.a=1.0;
	}

	specular_light_interp.rgb+=directional_specular;

#endif //USE_LIGHT_DIRECTIONAL


#endif // USE_VERTEX_LIGHTING

}
