#version 330

in vec2 texcoord;

uniform sampler2D tex;
uniform float time;

vec4 default_post_processing(vec4 c);

#ifndef START_TIME
#define START_TIME 0.0
#endif

vec4 window_shader() {
    vec2 texsize = textureSize(tex, 0);
    vec4 color = texture2D(tex, texcoord / texsize, 0);
    float gray = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    float progress = smoothstep(START_TIME, START_TIME + 2000.0, time);

    color.rgb = mix(vec3(gray), color.rgb, progress);
    return default_post_processing(color);
}
