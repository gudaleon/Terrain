#pragma arguments

uniform sampler2D dirtTexture;
uniform sampler2D alphaTexture;

#pragma transparent
#pragma body

vec4 diffuseColor = texture2D(u_diffuseTexture, _surface.diffuseTexcoord);
vec4 alpha = texture2D(alphaTexture, _surface.diffuseTexcoord * 0.125);
vec4 dirt = texture2D(dirtTexture, _surface.diffuseTexcoord * 0.125);
vec4 snow = vec4(1.0, .98, 0.93, 1.0);

vec4 outColor = diffuseColor * alpha.r; // Red channel
outColor = mix( outColor, dirt, alpha.g ); // Green channel
outColor = mix( outColor, snow, alpha.b ); // Blue channel
_surface.diffuse = outColor;
