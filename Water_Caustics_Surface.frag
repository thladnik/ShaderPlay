#version 460

//precision highp float;
//precision highp int;

uniform sampler2D texture;
varying vec3 vPosition;
varying vec3 vPositionRefrac;
varying vec3 vSurface;
varying vec3 nSurface;
varying float vAngle;

void main() {

    gl_FragColor = vec4(0.0, 0.0, 1.0, 0.5 );

}
