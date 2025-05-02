// Written by Emmett Hale
// 5-2-2025
// Outlines objects using a depth texture

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, unshaded;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

const float BASE_OUTLINE_THRESHOLD = 0.01;

void vertex() {
}

void fragment() {
	
	//Aquire the goods (depth texture data)
	float average_depth = 0.0;
	float __log_depth = textureLod(depth_texture, SCREEN_UV, 0.0).x;
	vec4 __depth_view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, __log_depth, 1.0);
	__depth_view.xyz /= __depth_view.w;
	float my_depth = -__depth_view.z;
	
	vec2 pixel_size = 1.0 / vec2(textureSize(depth_texture, 0));
	float count = 0.0;
	
	//Calculate if there should be an outline
    for(int y = -1; y <= 1; y++)
	{
    	for(int x = -1; x <= 1; x++)
    	{
			vec2 pixel_offset = vec2(float(x), float(y));
			float log_depth = textureLod(depth_texture, SCREEN_UV + pixel_offset * pixel_size, 0.0).x;
			vec4 depth_view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, log_depth, 1.0);
			depth_view.xyz /= depth_view.w;
			float depth = -depth_view.z;
			average_depth += depth;
			count++;
		}
	}
	
	average_depth = average_depth / count;
	
	//Smooth distance outlines
	float outline_threshold = BASE_OUTLINE_THRESHOLD;
	
	//Make outlines
	if (abs(my_depth - average_depth) >= outline_threshold)
	{
		ALBEDO = vec3(0.00000, 0.00000, 0.00000);
		ALPHA = 1.0;
	}
	else
	{
		ALPHA = 0.0;
	}
}
