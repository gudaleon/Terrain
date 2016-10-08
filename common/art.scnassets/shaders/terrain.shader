#pragma arguments

uniform sampler2D alphaTexture;
uniform sampler2D grassTexture;
uniform sampler2D dirtTexture;

#pragma transparent
#pragma body

vec4 alpha = texture2D(alphaTexture, _surface.diffuseTexcoord);
vec4 diffuseGrass = texture2D(grassTexture, _surface.diffuseTexcoord);
vec4 diffuseSand = vec4(.8, .8, .7, 1.0);
vec4 diffuseSnow = vec4(.8, .9, 1.0, 1.0);

vec4 color = diffuseGrass * alpha.r;
color = mix( color, diffuseSand, alpha.g );
color = mix( color, diffuseSnow, alpha.b );
_surface.diffuse = color;
