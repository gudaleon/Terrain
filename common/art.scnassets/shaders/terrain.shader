#pragma arguments

uniform sampler2D grassTexture;
uniform sampler2D dirtTexture;

#pragma transparent
#pragma body

vec4 diffuseGrass = texture2D(u_diffuseTexture, _surface.diffuseTexcoord);
vec4 diffuseDirt = texture2D(dirtTexture, _surface.diffuseTexcoord);

vec4 color = diffuseGrass;
_surface.diffuse = color;
