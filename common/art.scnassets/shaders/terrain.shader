#pragma arguments

uniform sampler2D grassTexture;
uniform sampler2D dirtTexture;

#pragma transparent
#pragma body

vec4 diffuseColor = texture2D(u_diffuseTexture, _surface.diffuseTexcoord);
vec4 grass = texture2D(grassTexture, _surface.diffuseTexcoord * 0.125);
vec4 dirt = texture2D(dirtTexture, _surface.diffuseTexcoord * 0.125);

vec4 color = diffuseColor;
_surface.diffuse = color;
