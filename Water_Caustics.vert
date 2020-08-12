#version 460

//precision highp float;
//precision highp int;

//uniform mat4 modelViewMatrix;
//uniform mat4 projectionMatrix;
uniform float uTime;
uniform float uZDepth;

attribute vec3 position;
attribute vec3 normal;

varying vec3 vPosition;
varying vec3 vPositionRefrac;
varying vec3 vNormal;
varying vec3 vSurface;
varying vec3 nSurface;
varying float vAngle;

const float refracIdxAir = 1.000277;
const float refracIdxWater = 1.333;

float xPartZ(in float x) {
    float z = 0;
    for(int i = 1; i < 2; i++) {
        z += 0.5 * (sin(4.0 * float(i) * x * 3.14 + uTime) + 1.0) / 2.0 / (float(i) * 5.0);
    }
    return(z);
}

float yPartZ(in float y) {
    //float z = 0.5 * (sin(4.0 * y * 3.14 + 2.0 * uTime) + 1.0)/2.0;
    float z = 0.0;
    return(z);
}

void main() {

    vec3 vIn = normalize(vec3(0.0, 0.0, 1.0));

    // Arbitrary transformation on input plane model
    vPosition = position;//vec3(position.x, position.y, 0.00);
    vNormal = normal;


    float xStep = 0.001;
    float yStep = 0.001;
    //float zAmp = 0.1;

    vSurface = vec3(vPosition.xy, xPartZ(vPosition.x) + yPartZ(vPosition.y));
    vec3 dX = vec3(xStep, 0.0, xPartZ(vPosition.x) - xPartZ(vPosition.x + xStep));
    vec3 dY = vec3(0.0, yStep, yPartZ(vPosition.y) - yPartZ(vPosition.y + yStep));
    nSurface = -vec3(normalize(cross(dX, dY)));

    // Calculate direction of ray after refraction on interface
    vec3 refracDir = refract(vIn, nSurface, refracIdxAir/refracIdxWater);

    // Calculate intersection of ray and ground plane
    //float d = 1.0; // distance of plane
    //float d = -mod(uTime/10, 10);
    float t = -(dot(vSurface, vNormal) + uZDepth) / (dot(refracDir, vNormal)); // length of refracted vector to plane
    vPositionRefrac = vSurface + t * refracDir;

    vec3 groundPlane = vec3(vPosition.xy, uZDepth/2);
    vAngle = dot(normalize(refracDir), normalize(vNormal));


    //gl_Position = projectionMatrix * modelViewMatrix * vec4( vPosition.xyz, 1.0 );
    gl_Position = <transform>;

}